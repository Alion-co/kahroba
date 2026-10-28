import 'package:url_launcher/url_launcher.dart';

/// باز کردن برنامه‌های خود گوشی: تلفن، پیامک، نقشه.
/// برنامه هیچ پیامکی خودکار نمی‌فرستد؛ فقط برنامه‌ی پیامک گوشی با متن آماده
/// باز می‌شود و ارسال با خود تعمیرکار است. هیچ سروری در کار نیست.
abstract final class Launcher {
  static Future<bool> call(String phone) =>
      _open(Uri(scheme: 'tel', path: phone));

  static Future<bool> sms(String phone, String body) {
    // از queryParameters استفاده نمی‌کنیم چون فاصله‌ها را «+» می‌کند و
    // بعضی برنامه‌های پیامک همان «+» را نشان می‌دهند.
    final uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(body)}');
    return _open(uri);
  }

  /// باز کردن موقعیت یا آدرس در برنامه‌ی نقشه‌ی گوشی (نشان، بلد، گوگل‌مپ...).
  static Future<bool> map({double? lat, double? lng, String address = ''}) {
    final Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    } else {
      uri = Uri.parse('geo:0,0?q=${Uri.encodeComponent(address)}');
    }
    return _open(uri);
  }

  static Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
