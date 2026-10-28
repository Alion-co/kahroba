import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/database.dart';
import '../../data/defaults.dart';

/// درخواست امتیاز در مایکت.
///
/// فقط وقتی پرسیده می‌شود که کاربر واقعاً با برنامه کار کرده باشد:
/// دست‌کم [minDays] روز از اولین اجرا گذشته و [minCases] پرونده ثبت شده.
/// «بعداً» آن را [laterDays] روز عقب می‌اندازد؛ «امتیاز می‌دهم» و «نه، ممنون»
/// برای همیشه خاموشش می‌کنند. در هر اجرای برنامه حداکثر یک بار.
abstract final class RatePrompt {
  static const packageId = 'ir.kahroba.alion';
  static const minDays = 5;
  static const minCases = 5;
  static const laterDays = 7;

  static bool _askedThisRun = false;

  /// صفحه‌ی ثبت امتیاز و نظر کهربا در مایکت (اگر مایکت نصب نبود، سایت)
  static Future<void> openMyket() async {
    try {
      final ok = await launchUrl(
        Uri.parse('myket://comment?id=$packageId'),
        mode: LaunchMode.externalApplication,
      );
      if (ok) return;
    } catch (_) {}
    try {
      await launchUrl(
        Uri.parse('https://myket.ir/app/$packageId'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  static Future<void> maybeAsk(BuildContext context) async {
    if (kIsWeb || _askedThisRun) return;
    final s = await appDb.getSettings();
    final state = s.raw[SettingKeys.rateState] ?? '';
    if (state == 'done' || state == 'never') return;

    final now = DateTime.now();
    final first = DateTime.tryParse(s.raw[SettingKeys.firstOpenAt] ?? '');
    if (first == null) {
      await appDb.setSetting(SettingKeys.firstOpenAt, now.toIso8601String());
      return;
    }
    if (now.difference(first).inDays < minDays) return;
    final next = DateTime.tryParse(s.raw[SettingKeys.rateNextAt] ?? '');
    if (next != null && now.isBefore(next)) return;
    if ((await appDb.getCases()).length < minCases) return;
    if (!context.mounted) return;

    _askedThisRun = true;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.star_rounded, size: 40, color: Color(0xFFFFB020)),
        title: const Text('کهربا به کارتان آمده؟'),
        content: const Text(
          'اگر از کهربا راضی هستید، با یک امتیاز و نظر در مایکت کمک کنید '
          'تعمیرکارهای بیشتری پیدایش کنند. کهربا رایگان می‌ماند.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('never'),
            child: const Text('نه، ممنون'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('later'),
            child: const Text('بعداً'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.of(ctx).pop('rate'),
            child: const Text('امتیاز می‌دهم'),
          ),
        ],
      ),
    );
    switch (choice) {
      case 'rate':
        await appDb.setSetting(SettingKeys.rateState, 'done');
        await openMyket();
      case 'never':
        await appDb.setSetting(SettingKeys.rateState, 'never');
      default:
        // «بعداً» یا بستن پنجره
        await appDb.setSetting(SettingKeys.rateNextAt,
            now.add(const Duration(days: laterDays)).toIso8601String());
    }
  }
}
