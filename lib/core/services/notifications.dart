import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/database.dart';
import '../utils/text_utils.dart';

/// اعلان‌های محلی (بدون اینترنت):
/// - یادآور یک ساعت پیش از هر کار در محل
/// - خلاصه‌ی صبح (ساعت ۷:۳۰) برای روزهایی که کار در محل دارند
/// - یادآور پشتیبان‌گیری اگر بیش از یک هفته پشتیبان نگرفته باشید
///
/// هر بار که پرونده‌ها عوض می‌شوند، همه‌ی اعلان‌های آینده از نو چیده
/// می‌شوند ([sync])؛ پس تغییر یا لغو قرار خودبه‌خود اعمال می‌شود.
abstract final class Notifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static bool _asked = false;

  /// اعلان فقط روی گوشی (وب و دسکتاپ نه)
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static const _jobs = AndroidNotificationDetails(
    'jobs',
    'کارهای در محل',
    channelDescription: 'یادآور قرارهای کار در محل مشتری',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _daily = AndroidNotificationDetails(
    'daily',
    'خلاصه‌ی صبح',
    channelDescription: 'فهرست کارهای در محل هر روز',
  );
  static const _backup = AndroidNotificationDetails(
    'backup',
    'پشتیبان‌گیری',
    channelDescription: 'یادآور گرفتن نسخه‌ی پشتیبان دفتر',
  );

  static Future<void> _init() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  /// اجازه‌ی اعلان (اندروید ۱۳ به بعد)؛ فقط یک بار در هر اجرا پرسیده می‌شود
  static Future<void> _askPermission() async {
    if (_asked) return;
    _asked = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// چیدن دوباره‌ی همه‌ی اعلان‌های آینده
  static Future<void> sync({
    required List<CaseRow> cases,
    required bool jobsOn,
    required DateTime? lastBackupAt,
  }) async {
    if (!supported) return;
    try {
      await _init();
      await _plugin.cancelAll();
      final now = DateTime.now();

      if (jobsOn) {
        // کارهای باز در محل با زمان قرار در آینده (تا ۳۰ روز)
        final jobs = cases.where((r) {
          final c = r.repairCase;
          final a = c.appointmentAt;
          return c.jobType == JobType.onSite &&
              c.status.isOpen &&
              a != null &&
              a.isAfter(now) &&
              a.isBefore(now.add(const Duration(days: 30)));
        }).toList()
          ..sort((a, b) => a.repairCase.appointmentAt!
              .compareTo(b.repairCase.appointmentAt!));

        if (jobs.isNotEmpty) await _askPermission();

        // یادآور یک ساعت قبل
        for (final r in jobs) {
          final at = r.repairCase.appointmentAt!;
          final remind = at.subtract(const Duration(hours: 1));
          if (!remind.isAfter(now)) continue;
          await _schedule(
            id: 100000 + r.repairCase.id,
            at: remind,
            title: 'یک ساعت دیگر: ${r.customer.name}',
            body: '${r.deviceTitle} • ساعت ${_hm(at)}'
                '${r.customer.address.isEmpty ? '' : ' • ${r.customer.address}'}',
            details: _jobs,
          );
        }

        // خلاصه‌ی صبح هر روز کاری
        final byDay = <DateTime, List<CaseRow>>{};
        for (final r in jobs) {
          final a = r.repairCase.appointmentAt!;
          final d = DateTime(a.year, a.month, a.day);
          byDay.putIfAbsent(d, () => []).add(r);
        }
        for (final e in byDay.entries) {
          final at = e.key.add(const Duration(hours: 7, minutes: 30));
          if (!at.isAfter(now)) continue;
          final list = e.value;
          await _schedule(
            id: 200000 + e.key.difference(DateTime(2020)).inDays,
            at: at,
            title: 'امروز ${toFaDigits(list.length)} کار در محل دارید',
            body: list
                .take(4)
                .map((r) => '${_hm(r.repairCase.appointmentAt!)} ${r.customer.name}')
                .join('، '),
            details: _daily,
          );
        }
      }

      // یادآور پشتیبان: یک هفته پس از آخرین پشتیبان، ساعت ۲۰
      final due = (lastBackupAt ?? now).add(const Duration(days: 7));
      var remindAt = DateTime(due.year, due.month, due.day, 20);
      if (!remindAt.isAfter(now)) {
        remindAt = DateTime(now.year, now.month, now.day, 20);
        if (!remindAt.isAfter(now)) {
          remindAt = remindAt.add(const Duration(days: 1));
        }
      }
      await _schedule(
        id: 1,
        at: remindAt,
        title: 'وقت پشتیبان‌گیری است',
        body: 'یک نسخه از دفتر کهربا بگیرید تا با خرابی گوشی از دست نرود.',
        details: _backup,
      );
    } catch (e) {
      // اعلان نباید هیچ‌وقت کار برنامه را متوقف کند
      debugPrint('notifications: $e');
    }
  }

  static Future<void> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required AndroidNotificationDetails details,
  }) =>
      _plugin.zonedSchedule(
        id: id,
        // لحظه‌ی دقیق به وقت جهانی؛ به منطقه‌ی زمانی گوشی وابسته نیست
        scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
        notificationDetails: NotificationDetails(android: details),
        // بدون نیاز به مجوز «هشدار دقیق»؛ ممکن است چند دقیقه جابه‌جا شود
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: title,
        body: body,
      );

  /// «۱۰:۳۰»
  static String _hm(DateTime d) => toFaDigits(
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}');
}
