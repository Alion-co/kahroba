import 'package:flutter_test/flutter_test.dart';

import 'package:kahroba/core/utils/format.dart';
import 'package:kahroba/core/utils/text_utils.dart';
import 'package:kahroba/data/enums.dart';

void main() {
  test('هر وضعیت پرونده برچسب فارسی دارد', () {
    for (final s in CaseStatus.values) {
      expect(s.label.isNotEmpty, isTrue);
    }
  });

  group('ارقام و شماره تلفن', () {
    test('تبدیل ارقام فارسی و عربی', () {
      expect(toEnDigits('۰۹۱۲۳۴۵٦٧٨٩'), '09123456789');
      expect(toFaDigits('05-0142'), '۰۵-۰۱۴۲');
    });

    test('یکسان‌سازی شماره', () {
      expect(normalizePhone('۰۹۱۲ ۳۴۵ ۶۷۸۹'), '09123456789');
      expect(normalizePhone('+98 912 345 6789'), '09123456789');
      expect(normalizePhone('00989123456789'), '09123456789');
      expect(normalizePhone('9123456789'), '09123456789');
      expect(normalizePhone('021-1234-5678'), '02112345678');
      expect(normalizePhone(''), '');
    });

    test('عدد شل', () {
      expect(parseIntLoose('۱۲۰٬۰۰۰'), 120000);
      expect(parseIntLoose('abc'), isNull);
    });
  });

  group('جستجو', () {
    test('کد خطا با شکل‌های مختلف یکی می‌شود', () {
      expect(normalizeForSearch('E-21'), normalizeForSearch('e21'));
      expect(normalizeForSearch('۴E'), '4e');
      expect(normalizeForSearch('كيك'), 'کیک');
    });
  });

  group('قالب‌بندی', () {
    test('کد پرونده و دستگاه', () {
      expect(formatCaseCode(1405, 142), '05-0142');
      expect(formatCaseCode(1410, 1), '10-0001');
      expect(formatDeviceCode('bk', 37), 'BK-0037');
    });

    test('مبلغ', () {
      expect(formatNumber(1250000), '۱٬۲۵۰٬۰۰۰');
      expect(formatNumber(0), '۰');
      expect(formatToman(500), '۵۰۰ تومان');
    });

    test('الگوی پیامک', () {
      expect(
        fillTemplate('{name} عزیز، کد {code}', {'name': 'علی', 'code': '05-0001'}),
        'علی عزیز، کد 05-0001',
      );
    });
  });
}
