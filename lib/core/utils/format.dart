import 'package:shamsi_date/shamsi_date.dart';

import 'text_utils.dart';

/// نمایش مبلغ به تومان با جداکننده‌ی هزارگان و ارقام فارسی.
String formatToman(int amount) => '${formatNumber(amount)} تومان';

String formatNumber(int n) {
  final negative = n < 0;
  final digits = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) b.write('٬');
    b.write(digits[i]);
  }
  return toFaDigits('${negative ? '-' : ''}$b');
}

const jalaliMonthNames = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// ۱۴۰۵/۰۸/۰۲
String formatDate(DateTime dt) {
  final j = Jalali.fromDateTime(dt.toLocal());
  return toFaDigits('${j.year}/${_two(j.month)}/${_two(j.day)}');
}

/// ۱۴۰۵/۰۸/۰۲ — ۱۴:۳۰
String formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  return '${formatDate(local)} — ${toFaDigits('${_two(local.hour)}:${_two(local.minute)}')}';
}

/// «۲ آبان»
String formatDayMonth(DateTime dt) {
  final j = Jalali.fromDateTime(dt.toLocal());
  return '${toFaDigits(j.day)} ${jalaliMonthNames[j.month - 1]}';
}

/// تعداد روزهای گذشته، برای نمایش «۵ روز پیش».
int daysSince(DateTime dt) => DateTime.now().difference(dt).inDays;

/// کد پرونده: دو رقم آخر سال شمسی + شمارنده‌ی چهاررقمی، مثل 05-0142.
String formatCaseCode(int jalaliYear, int number) =>
    '${_two(jalaliYear % 100)}-${number.toString().padLeft(4, '0')}';

/// کد دستگاه: پیشوند دسته + شمارنده، مثل BK-0037.
String formatDeviceCode(String prefix, int number) =>
    '${prefix.toUpperCase()}-${number.toString().padLeft(4, '0')}';

/// بازه‌ی یک ماه شمسی به‌صورت [شروع، شروع ماه بعد).
(DateTime, DateTime) jalaliMonthRange(int year, int month) {
  final start = Jalali(year, month, 1).toDateTime();
  final next = month == 12 ? Jalali(year + 1, 1, 1) : Jalali(year, month + 1, 1);
  return (start, next.toDateTime());
}

/// متن الگوی پیامک را با مقادیر واقعی پر می‌کند. مثلاً {name} و {code}.
String fillTemplate(String template, Map<String, String> values) {
  var out = template;
  values.forEach((k, v) => out = out.replaceAll('{$k}', v));
  return out;
}
