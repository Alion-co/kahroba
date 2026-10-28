import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../utils/format.dart';
import '../utils/text_utils.dart';
import 'jalali_calendar.dart';

const _weekDays = [
  'دوشنبه',
  'سه‌شنبه',
  'چهارشنبه',
  'پنج‌شنبه',
  'جمعه',
  'شنبه',
  'یکشنبه',
];

/// نام روز هفته از روی DateTime (weekday: ۱ = دوشنبه)
String weekDayName(DateTime d) => _weekDays[d.weekday - 1];

/// انتخاب زمان قرار: روز از تقویم شمسی و بعد ساعت (۲۴ساعته).
/// اگر کاربر منصرف شود null برمی‌گرداند.
Future<DateTime?> pickAppointment(BuildContext context, {DateTime? initial}) async {
  final day = await showJalaliDatePicker(
    context,
    title: 'روز قرار',
    initial: initial,
    firstDate: DateTime.now(),
  );
  if (day == null || !context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: initial == null
        ? const TimeOfDay(hour: 10, minute: 0)
        : TimeOfDay.fromDateTime(initial),
    helpText: 'ساعت قرار',
    initialEntryMode: TimePickerEntryMode.dial,
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (time == null) return null;
  return DateTime(day.year, day.month, day.day, time.hour, time.minute);
}

/// «امروز ۱۰:۳۰»، «فردا ۱۶:۰۰» یا «سه‌شنبه ۵ آبان ۱۰:۳۰»
String formatAppointment(DateTime dt) {
  final today = DateUtils.dateOnly(DateTime.now());
  final day = DateUtils.dateOnly(dt);
  final diff = day.difference(today).inDays;
  final time = toFaDigits(
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}');
  final dayLabel = switch (diff) {
    0 => 'امروز',
    1 => 'فردا',
    -1 => 'دیروز',
    _ => '${weekDayName(dt)} ${formatDayMonth(dt)}',
  };
  return '$dayLabel $time';
}

/// سال شمسی فعلی
int currentJalaliYear() => Jalali.now().year;
