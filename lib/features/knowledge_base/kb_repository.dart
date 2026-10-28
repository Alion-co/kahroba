import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/utils/text_utils.dart';
import '../../data/defaults.dart';

enum KbType {
  code('کد خطا'),
  symptom('علامت خرابی');

  const KbType(this.label);
  final String label;
}

/// یک برند در بانک فنی.
class KbBrand {
  const KbBrand({
    required this.id,
    required this.fa,
    required this.en,
    required this.iranian,
  });

  final String id;
  final String fa;
  final String en;
  final bool iranian;

  factory KbBrand.fromJson(Map<String, dynamic> j) => KbBrand(
        id: j['id'] as String,
        fa: (j['fa'] as String?) ?? '',
        en: (j['en'] as String?) ?? '',
        iranian: j['origin'] == 'ir',
      );
}

/// یک مورد بانک فنی: یا کد خطای یک برند، یا یک علامت خرابی.
/// [brandId] خالی یعنی مورد عمومی (مستقل از برند).
class KbEntry {
  KbEntry({
    required this.id,
    required this.type,
    required this.device,
    required this.brandId,
    required this.brand,
    required this.code,
    required this.aliases,
    required this.title,
    required this.meaning,
    required this.causes,
    required this.steps,
    required this.parts,
    required this.safety,
    required this.verified,
    this.source = '',
    this.sourceLabel = '',
    this.confidence = '',
    this.series = '',
  }) : searchText = normalizeForSearch(
          [brand, code, ...aliases, title, meaning, series, deviceName(device)]
              .join(' '),
        );

  final String id;
  final KbType type;

  /// پیشوند دسته (مثل LS) یا «*» برای عمومی
  final String device;
  final String brandId;
  final String brand;
  final String code;
  final List<String> aliases;
  final String title;
  final String meaning;
  final List<String> causes;
  final List<String> steps;
  final List<String> parts;
  final String? safety;
  final bool verified;

  /// آدرس منبعی که این مورد از آن استخراج شده
  final String source;

  /// توضیح منبع وقتی لینک مستقیم نداریم (مثلاً «گردآوری از منابع ایرانی»)
  final String sourceLabel;

  /// میزان اطمینان: high، medium یا خالی
  final String confidence;

  /// سری یا مدل‌هایی که این کد برایشان است (مثلاً «سری CV» یا «آنالوگ»)
  final String series;

  /// «اطمینان: بالا/متوسط» برای نمایش؛ خالی اگر مشخص نشده
  String get confidenceLabel => switch (confidence) {
        'high' => 'اطمینان: بالا',
        'medium' => 'اطمینان: متوسط',
        'low' => 'اطمینان: کم',
        _ => '',
      };

  /// متن منبع برای نمایش: نام سایت یا توضیح منبع
  String get sourceText => sourceHost.isNotEmpty ? sourceHost : sourceLabel;
  final String searchText;

  /// نام سایت منبع برای نمایش
  String get sourceHost => Uri.tryParse(source)?.host ?? '';

  /// برای کدها: «لباسشویی سامسونگ — کد 4E»؛ برای علائم: خود عنوان.
  String get displayTitle => type == KbType.code
      ? '${deviceName(device)} $brand — کد $code'
      : title;

  /// کدهای مشابه برای نمایش، مثل «4C، E1»
  String get aliasText => aliases.join('، ');

  static String deviceName(String prefix) {
    if (prefix == '*') return 'عمومی';
    for (final (name, p, _) in defaultCategories) {
      if (p == prefix) return name;
    }
    return prefix;
  }

  factory KbEntry.fromJson(Map<String, dynamic> j) {
    List<String> list(String key) =>
        ((j[key] as List?) ?? const []).map((e) => e.toString()).toList();
    final safety = j['safety'] as String?;
    return KbEntry(
      id: j['id'] as String,
      type: j['type'] == 'code' ? KbType.code : KbType.symptom,
      device: (j['device'] as String?) ?? '*',
      brandId: (j['brandId'] as String?) ?? '',
      brand: (j['brand'] as String?) ?? '',
      code: (j['code'] as String?) ?? '',
      aliases: list('aliases'),
      title: (j['title'] as String?) ?? '',
      meaning: (j['meaning'] as String?) ?? '',
      causes: list('causes'),
      steps: list('steps'),
      parts: list('parts'),
      safety: (safety == null || safety.isEmpty) ? null : safety,
      verified: (j['verified'] as bool?) ?? false,
      source: (j['source'] as String?) ?? '',
      sourceLabel: (j['sourceLabel'] as String?) ?? '',
      confidence: (j['confidence'] as String?) ?? '',
      series: (j['series'] as String?) ?? '',
    );
  }
}

/// بانک فنی از فایل assets/kb/kb.json خوانده می‌شود و کاملاً آفلاین است.
/// محتوا متنی است تا هر کسی بتواند در GitHub مورد جدید پیشنهاد بدهد.
class KbRepository {
  KbRepository._();
  static final instance = KbRepository._();

  List<KbEntry>? _entries;
  List<KbBrand> _brands = const [];

  Future<void> _load() async {
    if (_entries != null) return;
    final raw = await rootBundle.loadString('assets/kb/kb.json');
    // خواندن و آماده‌سازی ۲۰۰۰+ مورد در پس‌زمینه تا صفحه هنگ نکند
    final parsed = await compute(_parseKb, raw);
    _brands = parsed.$1;
    _entries = parsed.$2;
  }

  Future<List<KbEntry>> all() async {
    await _load();
    return _entries!;
  }

  /// برندها: اول آن‌هایی که مورد دارند، بعد بقیه.
  Future<List<KbBrand>> brands() async {
    await _load();
    final counts = countByBrand(_entries!);
    final list = [..._brands];
    list.sort((a, b) {
      final ca = counts[a.id] ?? 0;
      final cb = counts[b.id] ?? 0;
      if ((ca > 0) != (cb > 0)) return ca > 0 ? -1 : 1;
      return a.fa.compareTo(b.fa);
    });
    return list;
  }

  /// تعداد موارد هر برند
  static Map<String, int> countByBrand(List<KbEntry> entries) {
    final m = <String, int>{};
    for (final e in entries) {
      m[e.brandId] = (m[e.brandId] ?? 0) + 1;
    }
    return m;
  }

  /// دستگاه‌های یک برند (پیشوند دسته ← تعداد موارد).
  /// [brandId] خالی یعنی موارد عمومی.
  static Map<String, int> devicesOf(List<KbEntry> entries, String brandId) {
    final m = <String, int>{};
    for (final e in entries) {
      if (e.brandId != brandId) continue;
      m[e.device] = (m[e.device] ?? 0) + 1;
    }
    return m;
  }

  Future<KbEntry?> byId(String id) async {
    for (final e in await all()) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// جستجو. کد دقیق (مثل 4E یا یکی از کدهای مشابه) اول می‌آید.
  List<KbEntry> search(
    List<KbEntry> entries, {
    String query = '',
    String? device,
    KbType? type,
  }) {
    final q = normalizeForSearch(query);
    final result = <(int, KbEntry)>[];
    for (final e in entries) {
      if (type != null && e.type != type) continue;
      if (device != null && e.device != device && e.device != '*') continue;
      if (q.isEmpty) {
        result.add((2, e));
        continue;
      }
      final codes = [e.code, ...e.aliases].map(normalizeForSearch);
      if (codes.contains(q)) {
        result.add((0, e));
      } else if (e.searchText.contains(q)) {
        result.add((1, e));
      }
    }
    result.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final r in result) r.$2];
  }
}

/// در isolate جدا اجرا می‌شود (روی وب در همان رشته).
(List<KbBrand>, List<KbEntry>) _parseKb(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final brands = ((json['brands'] as List?) ?? const [])
      .map((e) => KbBrand.fromJson(e as Map<String, dynamic>))
      .toList();
  final entries = (json['entries'] as List)
      .map((e) => KbEntry.fromJson(e as Map<String, dynamic>))
      .toList();
  return (brands, entries);
}
