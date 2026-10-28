import 'package:flutter/services.dart';

import 'text_utils.dart';

/// قالب‌دهنده‌های ورودی برنامه:
/// - [MoneyInputFormatter]: فقط عدد، با جداکننده‌ی سه‌رقمی (۱٬۲۵۰٬۰۰۰)
/// - [PhoneInputFormatter]: فقط عدد، با فاصله‌ی شماره تلفن (۰۹۱۲ ۳۴۵ ۶۷۸۹)
/// - [DigitsInputFormatter]: فقط عدد (تعداد، سال، روز، درصد)
///
/// ارقام فارسی، عربی و انگلیسی همه پذیرفته می‌شوند و به فارسی نمایش داده
/// می‌شوند. برای خواندن مقدار از `parseIntLoose` و `normalizePhone`
/// استفاده کنید که جداکننده‌ها را خودشان حذف می‌کنند.

const _sep = '٬'; // جداکننده‌ی هزارگان فارسی

/// فقط ارقام انگلیسیِ متن
String _digitsOf(String s) =>
    toEnDigits(s).replaceAll(RegExp(r'[^0-9]'), '');

/// ساختن مقدار جدید و نگه داشتن مکان‌نما بعد از همان تعداد رقم
TextEditingValue _rebuild(
  TextEditingValue newValue,
  String formatted,
) {
  // چند رقم قبل از مکان‌نما بوده؟
  final cursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
  final digitsBefore = _digitsOf(newValue.text.substring(0, cursor)).length;
  var seen = 0;
  var pos = formatted.length;
  if (digitsBefore == 0) {
    pos = 0;
  } else {
    for (var i = 0; i < formatted.length; i++) {
      if (_isDigit(formatted.codeUnitAt(i))) {
        seen++;
        if (seen == digitsBefore) {
          pos = i + 1;
          break;
        }
      }
    }
  }
  return TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: pos),
  );
}

bool _isDigit(int unit) =>
    (unit >= 0x30 && unit <= 0x39) || (unit >= 0x6F0 && unit <= 0x6F9);

// ───────────────────────── مبلغ

/// نمایش یک مبلغ داخل فیلد: ۱۲۵۰۰۰۰ ← «۱٬۲۵۰٬۰۰۰»
String formatMoneyInput(int? value) =>
    value == null || value == 0 ? '' : _groupMoney(value.toString());

String _groupMoney(String digits) {
  final b = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) b.write(_sep);
    b.write(digits[i]);
  }
  return toFaDigits(b.toString());
}

class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter({this.maxDigits = 13});
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digitsOf(newValue.text).replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > maxDigits) return oldValue;
    return _rebuild(newValue, digits.isEmpty ? '' : _groupMoney(digits));
  }
}

// ───────────────────────── شماره تلفن

/// نمایش شماره داخل فیلد: «09123456789» ← «۰۹۱۲ ۳۴۵ ۶۷۸۹»
String formatPhoneInput(String? phone) =>
    phone == null || phone.isEmpty ? '' : _groupPhone(_digitsOf(phone));

/// موبایل (۰۹…): ۴-۳-۴ ← ۰۹۱۲ ۳۴۵ ۶۷۸۹
/// ثابت با کد شهر (۰…): ۳-۴-۴ ← ۰۲۱ ۳۳۴۴ ۵۵۶۶
/// بدون صفر: ۴-۴ ← ۳۳۴۴ ۵۵۶۶
String _groupPhone(String d) {
  final List<int> groups;
  if (d.startsWith('09')) {
    groups = [4, 3, 4];
  } else if (d.startsWith('0')) {
    groups = [3, 4, 4];
  } else {
    groups = [4, 4, 4];
  }
  final parts = <String>[];
  var i = 0;
  for (final g in groups) {
    if (i >= d.length) break;
    final end = (i + g).clamp(0, d.length);
    parts.add(d.substring(i, end));
    i = end;
  }
  if (i < d.length) parts.add(d.substring(i));
  return toFaDigits(parts.join(' '));
}

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = toEnDigits(newValue.text).trim();
    // +98 و 0098 به 0 تبدیل شود (چسباندن شماره از مخاطبین)
    if (text.startsWith('+98')) {
      text = '0${text.substring(3)}';
    } else if (text.startsWith('0098')) {
      text = '0${text.substring(4)}';
    }
    final digits = _digitsOf(text);
    if (digits.length > 11) return oldValue;
    final fixed = newValue.copyWith(text: text);
    return _rebuild(fixed, digits.isEmpty ? '' : _groupPhone(digits));
  }
}

// ───────────────────────── فقط عدد

class DigitsInputFormatter extends TextInputFormatter {
  const DigitsInputFormatter({this.maxDigits = 6});
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digitsOf(newValue.text);
    if (digits.length > maxDigits) return oldValue;
    return _rebuild(newValue, toFaDigits(digits));
  }
}

/// تنظیمات آماده برای فیلدها (نوع صفحه‌کلید، قالب‌دهنده و جهت متن)
abstract final class InputKinds {
  static const moneyFormatters = <TextInputFormatter>[MoneyInputFormatter()];
  static const phoneFormatters = <TextInputFormatter>[PhoneInputFormatter()];
  static const digitsFormatters = <TextInputFormatter>[DigitsInputFormatter()];

  /// شماره تلفن با فاصله باید چپ‌به‌راست نوشته شود تا ترتیب گروه‌ها
  /// در متن راست‌به‌چپ به هم نریزد.
  static const phoneDirection = TextDirection.ltr;
}
