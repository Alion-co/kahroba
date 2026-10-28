/// ابزارهای متن: ارقام فارسی/انگلیسی، یکسان‌سازی شماره تلفن و متن جستجو.
library;

const _faDigits = '۰۱۲۳۴۵۶۷۸۹';
const _arDigits = '٠١٢٣٤٥٦٧٨٩';

/// ارقام فارسی و عربی را به انگلیسی تبدیل می‌کند.
String toEnDigits(String input) {
  final b = StringBuffer();
  for (final ch in input.split('')) {
    var i = _faDigits.indexOf(ch);
    if (i < 0) i = _arDigits.indexOf(ch);
    b.write(i >= 0 ? i.toString() : ch);
  }
  return b.toString();
}

/// ارقام انگلیسی را برای نمایش به فارسی تبدیل می‌کند.
String toFaDigits(Object input) {
  final s = input.toString();
  final b = StringBuffer();
  for (final unit in s.codeUnits) {
    if (unit >= 48 && unit <= 57) {
      b.write(_faDigits[unit - 48]);
    } else {
      b.writeCharCode(unit);
    }
  }
  return b.toString();
}

/// شماره تلفن را یکسان می‌کند تا «۰۹۱۲...»، «0912...» و «+98912...» یکی شوند.
/// خروجی فقط رقم انگلیسی است و موبایل‌ها با 09 شروع می‌شوند.
String normalizePhone(String input) {
  var s = toEnDigits(input).replaceAll(RegExp(r'[^0-9+]'), '');
  if (s.startsWith('+98')) {
    s = '0${s.substring(3)}';
  } else if (s.startsWith('0098')) {
    s = '0${s.substring(4)}';
  } else if (s.startsWith('98') && s.length == 12) {
    s = '0${s.substring(2)}';
  } else if (s.startsWith('9') && s.length == 10) {
    s = '0$s';
  }
  return s.replaceAll('+', '');
}

/// متن را برای جستجو یکسان می‌کند: ارقام انگلیسی، حروف کوچک، ی و ک فارسی،
/// و حذف فاصله و خط‌تیره. پس «E-21»، «e21» و «ای ۲۱» به هم نزدیک می‌شوند.
String normalizeForSearch(String input) {
  return toEnDigits(input)
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ى', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll('ة', 'ه')
      .replaceAll('‌', '')
      .replaceAll(RegExp(r'[\s\-_./]'), '');
}

/// عدد واردشده توسط کاربر (با ارقام فارسی یا جداکننده) را می‌خواند.
int? parseIntLoose(String input) {
  final s = toEnDigits(input).replaceAll(RegExp(r'[^0-9]'), '');
  if (s.isEmpty) return null;
  return int.tryParse(s);
}
