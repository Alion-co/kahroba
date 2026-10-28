import '../../data/database.dart';
import '../../data/defaults.dart';
import '../utils/format.dart';
import 'launcher.dart';

/// ساخت متن پیامک‌ها از روی الگوهای تنظیمات و باز کردن برنامه‌ی پیامک.
abstract final class CaseMessages {
  static Map<String, String> _values(CaseRow row, ShopSettings s, {int? amount}) => {
        'shop': s.shopName,
        'shopPhone': s.shopPhone,
        'name': row.customer.name,
        'code': row.repairCase.code,
        'device': row.deviceTitle,
        'amount': amount == null ? '' : formatToman(amount),
      };

  static String receipt(CaseRow row, ShopSettings s) =>
      fillTemplate(s.get(SettingKeys.tplReceipt), _values(row, s)).trim();

  static String ready(CaseRow row, ShopSettings s) =>
      fillTemplate(s.get(SettingKeys.tplReady), _values(row, s)).trim();

  static String approval(CaseRow row, ShopSettings s, int amount) => fillTemplate(
        s.get(SettingKeys.tplApproval),
        _values(row, s, amount: amount),
      ).trim();

  static String debt(CaseRow row, ShopSettings s, int due) => fillTemplate(
        s.get(SettingKeys.tplDebt),
        _values(row, s, amount: due),
      ).trim();

  /// اگر مشتری شماره نداشته باشد false برمی‌گرداند.
  static Future<bool> send(CaseRow row, String body) async {
    final phone = row.customer.phone.isNotEmpty
        ? row.customer.phone
        : row.customer.phone2;
    if (phone.isEmpty) return false;
    return Launcher.sms(phone, body);
  }
}
