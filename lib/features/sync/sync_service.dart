import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/services/photo_store.dart';
import '../../core/utils/format.dart';
import '../../data/database.dart';
import '../../data/defaults.dart';

/// همگام‌سازی دو گوشی در یک شبکه‌ی Wi‑Fi، بدون اینترنت و بدون سرور.
///
/// ساختار «گوشی اصلی و همکار»:
/// ۱. گوشی اصلی (اوستا) یک سرویس کوچک روی Wi‑Fi محلی باز می‌کند و یک کد
///    ۶ رقمی نشان می‌دهد.
/// ۲. گوشی همکار وصل می‌شود و فقط «تغییرات خودش از آخرین همگام‌سازی» را
///    می‌فرستد: ردیف‌های جدید، ویرایش‌شده و حذف‌شده.
/// ۳. گوشی اصلی آن‌ها را ادغام می‌کند (مشتری تکراری با شماره، کد تکراری با
///    کد تازه) و بعد کل دفتر به‌روز را به همکار برمی‌گرداند.
///
/// تشخیص تعارض سه‌طرفه است: همکار برای هر ردیف «اثر انگشت» نسخه‌ای را که
/// آخرین بار از گوشی اصلی گرفته نگه می‌دارد. اگر همان ردیف در گوشی اصلی هم
/// عوض شده باشد، نسخه‌ی گوشی اصلی نگه داشته و تعارض گزارش می‌شود.

const syncPort = 47613;
const _protocol = 1;

/// جدول‌ها به ترتیب وابستگی (والد قبل از فرزند)
const _tables = [
  'categories',
  'customers',
  'devices',
  'repair_cases',
  'case_parts',
  'case_photos',
  'status_events',
  'payments',
  'price_items',
  'kb_notes',
  'part_equivalents',
];

/// ستون‌های کلید خارجی: جدول ← {ستون: جدول والد}
const _fks = <String, Map<String, String>>{
  'devices': {'customer_id': 'customers', 'category_id': 'categories'},
  'repair_cases': {'device_id': 'devices', 'customer_id': 'customers'},
  'case_parts': {'case_id': 'repair_cases'},
  'case_photos': {'case_id': 'repair_cases'},
  'status_events': {'case_id': 'repair_cases'},
  'payments': {'case_id': 'repair_cases'},
};

/// ستون‌هایی که مسیر عکس دارند (مسیر هر گوشی فرق دارد؛ فقط نام فایل مهم است)
const _photoCols = {'case_photos': 'path', 'devices': 'nameplate_photo'};

/// تنظیماتی که از گوشی اصلی به همکار می‌رود (ظاهر و نام گوشی نه)
const _sharedSettings = [
  SettingKeys.shopName,
  SettingKeys.shopPhone,
  SettingKeys.shopAddress,
  SettingKeys.shopTagline,
  SettingKeys.abandonDays,
  SettingKeys.defaultWarrantyDays,
  SettingKeys.tplReceipt,
  SettingKeys.tplReady,
  SettingKeys.tplApproval,
  SettingKeys.tplDebt,
  SettingKeys.tplWinter,
  SettingKeys.tplSummer,
];

/// کلیدهای داخلی همگام‌سازی در تنظیمات
abstract final class SyncKeys {
  /// شناسه‌ی ثابت این گوشی وقتی گوشی اصلی است
  static const ownId = 'sync_id';

  /// شناسه‌ی گوشی اصلی‌ای که این گوشی آخرین بار با آن همگام شد
  static const peerId = 'sync_peer';
  static const lastHost = 'sync_last_host';
  static const lastAt = 'sync_last_at';
}

class SyncException implements Exception {
  SyncException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// نتیجه‌ی ادغام در گوشی اصلی
class SyncStats {
  int inserted = 0;
  int merged = 0;
  int updated = 0;
  int deleted = 0;
  final conflicts = <String>[];
  final renamed = <String>[];

  Map<String, dynamic> toJson() => {
        'inserted': inserted,
        'merged': merged,
        'updated': updated,
        'deleted': deleted,
        'conflicts': conflicts,
        'renamed': renamed,
      };

  static SyncStats fromJson(Map<String, dynamic> j) => SyncStats()
    ..inserted = (j['inserted'] as num?)?.toInt() ?? 0
    ..merged = (j['merged'] as num?)?.toInt() ?? 0
    ..updated = (j['updated'] as num?)?.toInt() ?? 0
    ..deleted = (j['deleted'] as num?)?.toInt() ?? 0
    ..conflicts.addAll(((j['conflicts'] as List?) ?? const []).map((e) => '$e'))
    ..renamed.addAll(((j['renamed'] as List?) ?? const []).map((e) => '$e'));
}

// ───────────────────────── ابزار پایگاه داده ─────────────────────────

typedef SyncRow = Map<String, Object?>;

final _ident = RegExp(r'^[a-z_][a-z0-9_]*$');

/// اثر انگشت یک ردیف (مسیر عکس فقط با نام فایل حساب می‌شود)
String rowHash(String table, SyncRow row) {
  final keys = row.keys.toList()..sort();
  final photoCol = _photoCols[table];
  final b = StringBuffer();
  for (final k in keys) {
    Object? v = row[k];
    if (k == photoCol && v is String && !v.startsWith('data:')) {
      v = p.basename(v);
    }
    b
      ..write(k)
      ..write('=')
      ..write(jsonEncode(v))
      ..write('\u0001');
  }
  return _fnv(utf8.encode(b.toString()));
}

String _fnv(List<int> bytes) {
  var h1 = 0x811c9dc5;
  var h2 = 0x050c5d1f;
  for (final x in bytes) {
    h1 = ((h1 ^ x) * 0x01000193) & 0xFFFFFFFF;
    h2 = ((h2 ^ x) * 0x01000193 + 0x9e3779b9) & 0xFFFFFFFF;
  }
  return '${h1.toRadixString(16).padLeft(8, '0')}${h2.toRadixString(16).padLeft(8, '0')}';
}

class _Db {
  _Db(this.db);
  final AppDatabase db;
  final _columns = <String, Set<String>>{};

  Future<List<SyncRow>> rows(String t) async => (await db
          .customSelect('SELECT * FROM $t ORDER BY id')
          .get())
      .map((r) => SyncRow.of(r.data))
      .toList();

  Future<SyncRow?> row(String t, int id) async {
    final r = await db
        .customSelect('SELECT * FROM $t WHERE id = ?',
            variables: [Variable.withInt(id)])
        .getSingleOrNull();
    return r == null ? null : SyncRow.of(r.data);
  }

  Future<SyncRow?> findBy(String t, Map<String, Object?> where) async {
    final cols = where.keys.toList();
    final cond =
        cols.map((c) => where[c] == null ? '$c IS NULL' : '$c = ?').join(' AND ');
    final args = [
      for (final c in cols)
        if (where[c] != null) _variable(where[c]),
    ];
    final r = await db
        .customSelect('SELECT * FROM $t WHERE $cond LIMIT 1', variables: args)
        .getSingleOrNull();
    return r == null ? null : SyncRow.of(r.data);
  }

  Future<Set<String>> columns(String t) async {
    final cached = _columns[t];
    if (cached != null) return cached;
    final r = await db.customSelect('PRAGMA table_info($t)').get();
    return _columns[t] = r.map((x) => x.data['name'] as String).toSet();
  }

  Future<int> insert(String t, SyncRow v) async {
    final cols = v.keys.toList();
    await db.customStatement(
      'INSERT INTO $t (${cols.join(', ')}) VALUES (${List.filled(cols.length, '?').join(', ')})',
      [for (final c in cols) v[c]],
    );
    final r = await db.customSelect('SELECT last_insert_rowid() AS id').getSingle();
    return r.data['id'] as int;
  }

  Future<void> update(String t, int id, SyncRow v) async {
    final cols = v.keys.where((c) => c != 'id').toList();
    if (cols.isEmpty) return;
    await db.customStatement(
      'UPDATE $t SET ${cols.map((c) => '$c = ?').join(', ')} WHERE id = ?',
      [for (final c in cols) v[c], id],
    );
  }

  Future<void> delete(String t, int id) =>
      db.customStatement('DELETE FROM $t WHERE id = ?', [id]);

  static Variable _variable(Object? v) => switch (v) {
        int x => Variable.withInt(x),
        double x => Variable.withReal(x),
        bool x => Variable.withBool(x),
        _ => Variable.withString('$v'),
      };

  // ── جدول اثر انگشت‌ها (فقط در گوشی همکار پر می‌شود)

  Future<void> ensureBaseline() => db.customStatement(
      'CREATE TABLE IF NOT EXISTS kahroba_sync_baseline ('
      'tbl TEXT NOT NULL, rid INTEGER NOT NULL, hash TEXT NOT NULL, '
      'PRIMARY KEY (tbl, rid))');

  Future<Map<String, Map<int, String>>> loadBaseline() async {
    await ensureBaseline();
    final out = <String, Map<int, String>>{};
    final r = await db.customSelect('SELECT tbl, rid, hash FROM kahroba_sync_baseline').get();
    for (final x in r) {
      out.putIfAbsent(x.data['tbl'] as String, () => {})[x.data['rid'] as int] =
          x.data['hash'] as String;
    }
    return out;
  }

  Future<void> saveBaseline(Map<String, List<SyncRow>> tables) async {
    await ensureBaseline();
    await db.customStatement('DELETE FROM kahroba_sync_baseline');
    for (final e in tables.entries) {
      for (final r in e.value) {
        await db.customStatement(
          'INSERT INTO kahroba_sync_baseline (tbl, rid, hash) VALUES (?, ?, ?)',
          [e.key, r['id'], rowHash(e.key, r)],
        );
      }
    }
  }

  Future<String> setting(String key) async {
    final r = await db
        .customSelect('SELECT content FROM app_settings WHERE name = ?',
            variables: [Variable.withString(key)])
        .getSingleOrNull();
    return (r?.data['content'] as String?) ?? '';
  }

  Future<void> setSetting(String key, String value) => db.customStatement(
        'INSERT INTO app_settings (name, content) VALUES (?, ?) '
        'ON CONFLICT(name) DO UPDATE SET content = excluded.content',
        [key, value],
      );
}

/// شناسه‌ی ثابت این گوشی (برای اینکه همکار بداند با کدام گوشی اصلی همگام است)
Future<String> _ownId(_Db d) async {
  var id = await d.setting(SyncKeys.ownId);
  if (id.isEmpty) {
    final r = math.Random.secure();
    id = List.generate(16, (_) => r.nextInt(16).toRadixString(16)).join();
    await d.setSetting(SyncKeys.ownId, id);
  }
  return id;
}

Future<Map<String, String>> _readPhotos(Iterable<String> paths) async {
  final out = <String, String>{};
  for (final path in paths) {
    if (path.isEmpty || path.startsWith('data:')) continue;
    final f = File(path);
    if (await f.exists()) {
      out[p.basename(path)] = base64Encode(await f.readAsBytes());
    }
  }
  return out;
}

Future<void> _writePhotos(Map<String, dynamic> photos) async {
  if (photos.isEmpty) return;
  final dir = await PhotoStore.photosDir();
  for (final e in photos.entries) {
    final name = p.basename(e.key);
    if (name.isEmpty || name.contains('..')) continue;
    final f = File(p.join(dir.path, name));
    if (!await f.exists()) await f.writeAsBytes(base64Decode(e.value as String));
  }
}

/// مسیر عکس را به پوشه‌ی عکس همین گوشی برمی‌گرداند
Future<SyncRow> _localizePhoto(String t, SyncRow v) async {
  final col = _photoCols[t];
  final path = col == null ? null : v[col];
  if (path is String && path.isNotEmpty && !path.startsWith('data:')) {
    final dir = await PhotoStore.photosDir();
    v[col!] = p.join(dir.path, p.basename(path));
  }
  return v;
}

// ───────────────────────── گوشی اصلی: ادغام ─────────────────────────

class _Merger {
  _Merger(this.d, this.first);
  final _Db d;
  final bool first;
  final stats = SyncStats();
  final idMap = <String, Map<int, int>>{};

  int _map(String parent, int id) => idMap[parent]?[id] ?? id;

  Future<SyncRow?> _clean(String t, Map raw, {bool keepId = false}) async {
    final cols = await d.columns(t);
    final v = <String, Object?>{};
    for (final e in raw.entries) {
      final k = '${e.key}';
      if (!_ident.hasMatch(k) || !cols.contains(k)) continue;
      if (k == 'id' && !keepId) continue;
      v[k] = e.value;
    }
    for (final fk in (_fks[t] ?? const <String, String>{}).entries) {
      final x = v[fk.key];
      if (x is int) {
        final mapped = _map(fk.value, x);
        if (await d.row(fk.value, mapped) == null) return null; // والد نیست
        v[fk.key] = mapped;
      }
    }
    return _localizePhoto(t, v);
  }

  /// اگر همین ردیف از قبل در گوشی اصلی هست، شناسه‌اش را برمی‌گرداند
  Future<int?> _existing(String t, SyncRow v) async {
    Future<int?> by(Map<String, Object?> w) async =>
        (await d.findBy(t, w))?['id'] as int?;
    switch (t) {
      case 'categories':
        return by({'prefix': v['prefix']});
      case 'customers':
        final phone = '${v['phone'] ?? ''}';
        return phone.isEmpty ? null : by({'phone': phone});
      case 'devices':
        final r = await d.findBy(t, {'code': v['code']});
        if (r != null &&
            r['customer_id'] == v['customer_id'] &&
            r['category_id'] == v['category_id']) {
          return r['id'] as int;
        }
        return null;
      case 'repair_cases':
        final r = await d.findBy(t, {'code': v['code']});
        if (r != null &&
            r['device_id'] == v['device_id'] &&
            r['received_at'] == v['received_at']) {
          return r['id'] as int;
        }
        return null;
      case 'case_parts':
        return by({
          'case_id': v['case_id'],
          'name': v['name'],
          'qty': v['qty'],
          'unit_price': v['unit_price'],
        });
      case 'payments':
        return by({'case_id': v['case_id'], 'amount': v['amount'], 'at': v['at']});
      case 'status_events':
        return by({'case_id': v['case_id'], 'status': v['status'], 'at': v['at']});
      case 'case_photos':
        return by({'case_id': v['case_id'], 'path': v['path']});
      case 'price_items':
        return by({'name': v['name']});
      case 'kb_notes':
        final r = await d.findBy(t, {'entry_id': v['entry_id']});
        if (r == null) return null;
        final mine = r['updated_at'], theirs = v['updated_at'];
        if (theirs is int && mine is int && theirs > mine) {
          await d.update(t, r['id'] as int, {'body': v['body'], 'updated_at': theirs});
        }
        return r['id'] as int;
      case 'part_equivalents':
        return by({'part_name': v['part_name'], 'equivalent': v['equivalent']});
    }
    return null;
  }

  /// کد تکراری دستگاه یا پرونده را با کد تازه از شمارنده‌ی گوشی اصلی عوض می‌کند
  Future<void> _uniqueCode(String t, SyncRow v) async {
    if (t != 'devices' && t != 'repair_cases') return;
    final code = '${v['code']}';
    if (await d.findBy(t, {'code': code}) == null) return;
    final String fresh;
    if (t == 'devices') {
      final cat = await d.row('categories', v['category_id'] as int);
      final prefix = '${cat?['prefix'] ?? code.split('-').first}';
      fresh = formatDeviceCode(prefix, await _next('device-$prefix', t, '$prefix-'));
    } else {
      final year = _jalaliYear(v['received_at']);
      final yy = (year % 100).toString().padLeft(2, '0');
      fresh = formatCaseCode(year, await _next('case-$year', t, '$yy-'));
    }
    v['code'] = fresh;
    stats.renamed.add('$code ← $fresh');
  }

  /// شماره‌ی بعدی: بزرگ‌تر از شمارنده و از همه‌ی کدهای موجود
  Future<int> _next(String counter, String t, String codePrefix) async {
    final c = await d.db
        .customSelect('SELECT current FROM counters WHERE name = ?',
            variables: [Variable.withString(counter)])
        .getSingleOrNull();
    var n = (c?.data['current'] as int?) ?? 0;
    n = math.max(n, await _maxCode(t, codePrefix));
    n++;
    await d.db.customStatement(
      'INSERT INTO counters (name, current) VALUES (?, ?) '
      'ON CONFLICT(name) DO UPDATE SET current = excluded.current',
      [counter, n],
    );
    return n;
  }

  Future<int> _maxCode(String t, String codePrefix) async {
    final r = await d.db
        .customSelect('SELECT code FROM $t WHERE code LIKE ?',
            variables: [Variable.withString('$codePrefix%')])
        .get();
    var m = 0;
    for (final x in r) {
      final n = int.tryParse('${x.data['code']}'.substring(codePrefix.length));
      if (n != null && n > m) m = n;
    }
    return m;
  }

  /// بعد از ادغام، شمارنده‌ها از بزرگ‌ترین کد موجود عقب نباشند
  Future<void> bumpCounters() async {
    final cats = await d.rows('categories');
    for (final c in cats) {
      final prefix = '${c['prefix']}';
      final m = await _maxCode('devices', '$prefix-');
      if (m > 0) await _raise('device-$prefix', m);
    }
    final years = await d.db
        .customSelect('SELECT DISTINCT substr(code, 1, 2) AS yy FROM repair_cases')
        .get();
    for (final y in years) {
      final yy = '${y.data['yy']}';
      final yn = int.tryParse(yy);
      if (yn == null) continue;
      final m = await _maxCode('repair_cases', '$yy-');
      if (m > 0) await _raise('case-${1400 + yn}', m);
    }
  }

  Future<void> _raise(String counter, int atLeast) => d.db.customStatement(
        'INSERT INTO counters (name, current) VALUES (?, ?) '
        'ON CONFLICT(name) DO UPDATE SET current = max(current, excluded.current)',
        [counter, atLeast],
      );

  Future<void> apply(Map<String, dynamic> tables) async {
    Map<String, dynamic> part(String t) =>
        (tables[t] as Map?)?.cast<String, dynamic>() ?? const {};

    // ۱) ردیف‌های تازه، والد قبل از فرزند
    for (final t in _tables) {
      for (final raw in (part(t)['new'] as List?) ?? const []) {
        final clientId = (raw as Map)['id'] as int;
        final v = await _clean(t, raw);
        if (v == null) {
          stats.conflicts.add('یک ردیف از «${_label(t)}» به‌خاطر حذف والدش اضافه نشد');
          continue;
        }
        final existing = await _existing(t, v);
        if (existing != null) {
          idMap.putIfAbsent(t, () => {})[clientId] = existing;
          stats.merged++;
          continue;
        }
        await _uniqueCode(t, v);
        final id = await d.insert(t, v);
        idMap.putIfAbsent(t, () => {})[clientId] = id;
        stats.inserted++;
      }
    }

    // ۲) ویرایش‌ها: فقط اگر گوشی اصلی همان ردیف را عوض نکرده باشد
    for (final t in _tables) {
      for (final c in (part(t)['changed'] as List?) ?? const []) {
        final raw = (c as Map)['row'] as Map;
        final base = c['base'] as String;
        final id = raw['id'] as int;
        final cur = await d.row(t, id);
        if (cur == null) {
          stats.conflicts.add('یک «${_label(t)}» در گوشی اصلی حذف شده بود؛ ویرایش همکار اعمال نشد');
          continue;
        }
        if (rowHash(t, cur) != base) {
          stats.conflicts.add(
              '${_describe(t, cur)} در هر دو گوشی ویرایش شده بود؛ نسخه‌ی گوشی اصلی ماند');
          continue;
        }
        final v = await _clean(t, raw);
        if (v == null) continue;
        await d.update(t, id, v);
        stats.updated++;
      }
    }

    // ۳) حذف‌ها: فرزند قبل از والد
    for (final t in _tables.reversed) {
      for (final x in (part(t)['deleted'] as List?) ?? const []) {
        final id = (x as Map)['id'] as int;
        final cur = await d.row(t, id);
        if (cur == null) continue;
        if (rowHash(t, cur) != x['base']) {
          stats.conflicts.add('${_describe(t, cur)} در گوشی اصلی عوض شده بود؛ حذف نشد');
          continue;
        }
        try {
          await d.delete(t, id);
          stats.deleted++;
        } catch (_) {
          stats.conflicts.add('${_describe(t, cur)} در گوشی اصلی اطلاعات وابسته دارد؛ حذف نشد');
        }
      }
    }
    await bumpCounters();
  }
}

String _label(String t) => switch (t) {
      'categories' => 'دسته',
      'customers' => 'مشتری',
      'devices' => 'دستگاه',
      'repair_cases' => 'پرونده',
      'case_parts' => 'قطعه',
      'case_photos' => 'عکس',
      'status_events' => 'تاریخچه‌ی وضعیت',
      'payments' => 'پرداخت',
      'price_items' => 'نرخ‌نامه',
      'kb_notes' => 'یادداشت فنی',
      _ => 'قطعه‌ی معادل',
    };

String _describe(String t, SyncRow r) => switch (t) {
      'customers' => 'مشتری «${r['name']}»',
      'devices' => 'دستگاه ${r['code']}',
      'repair_cases' => 'پرونده‌ی ${r['code']}',
      _ => 'یک «${_label(t)}»',
    };

int _jalaliYear(Object? receivedAt) {
  DateTime? dt;
  if (receivedAt is int) {
    dt = DateTime.fromMillisecondsSinceEpoch(receivedAt * 1000);
  } else if (receivedAt is String) {
    dt = DateTime.tryParse(receivedAt);
  }
  return Jalali.fromDateTime(dt ?? DateTime.now()).year;
}

/// گوشی اصلی: ادغام تغییرات همکار
Future<SyncStats> applyPush(AppDatabase db, Map<String, dynamic> push) async {
  final d = _Db(db);
  await _writePhotos((push['photos'] as Map?)?.cast<String, dynamic>() ?? const {});
  final merger = _Merger(d, push['first'] == true);
  await db.transaction(() async {
    await merger.apply((push['tables'] as Map).cast<String, dynamic>());
  });
  db.markTablesUpdated(db.allTables);
  return merger.stats;
}

/// گوشی اصلی: کل دفتر برای همکار
Future<Map<String, dynamic>> buildSnapshot(AppDatabase db, Set<String> have) async {
  final d = _Db(db);
  final tables = <String, List<SyncRow>>{};
  final photoPaths = <String>[];
  for (final t in _tables) {
    final rows = await d.rows(t);
    tables[t] = rows;
    final col = _photoCols[t];
    if (col != null) {
      for (final r in rows) {
        final path = r[col];
        if (path is String && !have.contains(p.basename(path))) photoPaths.add(path);
      }
    }
  }
  final counters = (await db.customSelect('SELECT name, current FROM counters').get())
      .map((r) => SyncRow.of(r.data))
      .toList();
  return {
    'v': _protocol,
    'id': await _ownId(d),
    'tables': tables,
    'counters': counters,
    'settings': {for (final k in _sharedSettings) k: await d.setting(k)},
    'photos': await _readPhotos(photoPaths),
  };
}

// ───────────────────────── گوشی همکار ─────────────────────────

/// تغییرات این گوشی از آخرین همگام‌سازی
Future<Map<String, dynamic>> buildPush(AppDatabase db, {required bool first}) async {
  final d = _Db(db);
  final base = first ? <String, Map<int, String>>{} : await d.loadBaseline();
  final out = <String, dynamic>{};
  final photoPaths = <String>[];
  for (final t in _tables) {
    final baseT = base[t] ?? const <int, String>{};
    final added = <SyncRow>[], changed = <Map<String, Object?>>[], deleted = <Map<String, Object?>>[];
    final seen = <int>{};
    for (final r in await d.rows(t)) {
      final id = r['id'] as int;
      seen.add(id);
      final b = baseT[id];
      final isNew = b == null;
      final isChanged = !isNew && rowHash(t, r) != b;
      if (isNew) added.add(r);
      if (isChanged) changed.add({'row': r, 'base': b});
      final col = _photoCols[t];
      if ((isNew || isChanged) && col != null && r[col] is String) {
        photoPaths.add(r[col]! as String);
      }
    }
    for (final e in baseT.entries) {
      if (!seen.contains(e.key)) deleted.add({'id': e.key, 'base': e.value});
    }
    out[t] = {'new': added, 'changed': changed, 'deleted': deleted};
  }
  return {
    'v': _protocol,
    'first': first,
    'tables': out,
    'photos': await _readPhotos(photoPaths),
  };
}

/// جایگزینی دفتر این گوشی با نسخه‌ی گوشی اصلی
Future<void> applySnapshot(AppDatabase db, Map<String, dynamic> snap) async {
  final d = _Db(db);
  await _writePhotos((snap['photos'] as Map?)?.cast<String, dynamic>() ?? const {});
  final tables = (snap['tables'] as Map).cast<String, dynamic>();
  final typed = <String, List<SyncRow>>{};
  await db.transaction(() async {
    for (final t in _tables.reversed) {
      await db.customStatement('DELETE FROM $t');
    }
    await db.customStatement('DELETE FROM counters');
    for (final t in _tables) {
      final cols = await d.columns(t);
      final rows = <SyncRow>[];
      for (final raw in (tables[t] as List?) ?? const []) {
        final v = <String, Object?>{};
        (raw as Map).forEach((k, val) {
          final key = '$k';
          if (_ident.hasMatch(key) && cols.contains(key)) v[key] = val;
        });
        rows.add(SyncRow.of(v));
        await d.insert(t, await _localizePhoto(t, SyncRow.of(v)));
      }
      typed[t] = rows;
    }
    for (final c in (snap['counters'] as List?) ?? const []) {
      await db.customStatement(
        'INSERT INTO counters (name, current) VALUES (?, ?)',
        [(c as Map)['name'], c['current']],
      );
    }
    final settings = (snap['settings'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final e in settings.entries) {
      if (_sharedSettings.contains(e.key) && '${e.value}'.isNotEmpty) {
        await d.setSetting(e.key, '${e.value}');
      }
    }
    // اثر انگشت‌ها از نسخه‌ی دریافتی (قبل از تبدیل مسیر عکس) ساخته می‌شود
    await d.saveBaseline(typed);
    await d.setSetting(SyncKeys.peerId, '${snap['id']}');
    await d.setSetting(SyncKeys.lastAt, DateTime.now().toIso8601String());
  });
  db.markTablesUpdated(db.allTables);
}

/// نسخه‌ی پشتیبان از تغییرات همکار، پیش از جایگزینی دفتر (۳ نسخه‌ی آخر)
Future<void> _backupPush(Map<String, dynamic> push) async {
  try {
    final dir = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'sync_backup'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final f = File(p.join(dir.path, 'push-${DateTime.now().millisecondsSinceEpoch}.json'));
    await f.writeAsString(jsonEncode(push));
    final files = (await dir.list().toList()).whereType<File>().toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final old in files.skip(3)) {
      await old.delete();
    }
  } catch (_) {
    // پشتیبان نشدن نباید جلوی همگام‌سازی را بگیرد
  }
}

/// پیام‌های مرحله‌ای برای نمایش در صفحه
typedef SyncProgress = void Function(String step);

/// گوشی همکار: کل فرایند همگام‌سازی با گوشی اصلی
Future<SyncStats> syncWithHost({
  required AppDatabase db,
  required String host,
  int port = syncPort,
  required String code,
  SyncProgress? onStep,
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
  Future<Map<String, dynamic>> call(String path, [Object? body]) async {
    final HttpClientRequest req;
    try {
      req = await client.postUrl(Uri(scheme: 'http', host: host, port: port, path: path));
    } on SocketException {
      throw SyncException(
          'به گوشی اصلی وصل نشد. هر دو گوشی باید به یک Wi‑Fi وصل باشند و صفحه‌ی همگام‌سازی در گوشی اصلی باز باشد.');
    } on TimeoutException {
      throw SyncException('گوشی اصلی پاسخ نداد.');
    }
    req.headers.set('x-kahroba-code', code);
    req.headers.contentType = ContentType.json;
    if (body != null) req.add(utf8.encode(jsonEncode(body)));
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    if (res.statusCode == 403) throw SyncException('کد همگام‌سازی اشتباه است.');
    if (res.statusCode != 200) {
      throw SyncException('گوشی اصلی خطا داد: $text');
    }
    return (jsonDecode(text) as Map).cast<String, dynamic>();
  }

  try {
    onStep?.call('اتصال به گوشی اصلی…');
    final hello = await call('/hello');
    if ((hello['v'] as num?)?.toInt() != _protocol) {
      throw SyncException('نسخه‌ی برنامه‌ی دو گوشی یکی نیست؛ هر دو را به‌روز کنید.');
    }
    final d = _Db(db);
    final peer = await d.setting(SyncKeys.peerId);
    final baseline = await d.loadBaseline();
    final first = peer != hello['id'] || baseline.isEmpty;

    onStep?.call('ارسال کارهای این گوشی…');
    final push = await buildPush(db, first: first);
    await _backupPush(push);
    final stats = SyncStats.fromJson(await call('/push', push));

    onStep?.call('دریافت دفتر به‌روز…');
    final dir = await PhotoStore.photosDir();
    final have = (await dir.list().toList())
        .whereType<File>()
        .map((f) => p.basename(f.path))
        .toList();
    final snap = await call('/snapshot', {'have': have});
    onStep?.call('ذخیره…');
    await applySnapshot(db, snap);
    await d.setSetting(SyncKeys.lastHost, host);
    return stats;
  } finally {
    client.close(force: true);
  }
}

// ───────────────────────── گوشی اصلی: سرویس محلی ─────────────────────────

class SyncHost {
  SyncHost(this.db, {required this.onLog});
  final AppDatabase db;
  final void Function(String) onLog;

  HttpServer? _server;
  final String code =
      (100000 + math.Random.secure().nextInt(900000)).toString();

  int get port => _server?.port ?? 0;
  bool get running => _server != null;

  /// سرویس را روشن می‌کند و نشانی‌های این گوشی در شبکه را برمی‌گرداند
  Future<List<String>> start() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, syncPort);
    } on SocketException {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    }
    _server!.listen(_handle, onError: (_) {});
    return localAddresses();
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    try {
      if (req.method != 'POST' || req.headers.value('x-kahroba-code') != code) {
        res.statusCode = 403;
        await res.close();
        return;
      }
      final text = await utf8.decoder.bind(req).join();
      final body = text.isEmpty
          ? const <String, dynamic>{}
          : (jsonDecode(text) as Map).cast<String, dynamic>();
      final Object reply;
      switch (req.uri.path) {
        case '/hello':
          reply = {'v': _protocol, 'id': await _ownId(_Db(db)), 'app': 'kahroba'};
        case '/push':
          final stats = await applyPush(db, body);
          onLog('دریافت از همکار: ${toFaDigitsSafe(stats.inserted)} مورد جدید، '
              '${toFaDigitsSafe(stats.updated)} ویرایش، ${toFaDigitsSafe(stats.deleted)} حذف'
              '${stats.conflicts.isEmpty ? '' : '، ${toFaDigitsSafe(stats.conflicts.length)} تعارض'}');
          reply = stats.toJson();
        case '/snapshot':
          final have = ((body['have'] as List?) ?? const []).map((e) => '$e').toSet();
          reply = await buildSnapshot(db, have);
          onLog('دفتر به‌روز برای همکار فرستاده شد');
        default:
          res.statusCode = 404;
          await res.close();
          return;
      }
      res.headers.contentType = ContentType.json;
      res.add(utf8.encode(jsonEncode(reply)));
      await res.close();
    } catch (e) {
      onLog('خطا: $e');
      try {
        res.statusCode = 500;
        res.write('$e');
        await res.close();
      } catch (_) {}
    }
  }
}

String toFaDigitsSafe(int n) {
  const fa = '۰۱۲۳۴۵۶۷۸۹';
  return n.toString().split('').map((c) {
    final i = int.tryParse(c);
    return i == null ? c : fa[i];
  }).join();
}

/// نشانی‌های IPv4 این گوشی در شبکه‌ی محلی (Wi‑Fi یا هات‌اسپات)
Future<List<String>> localAddresses() async {
  final out = <String>[];
  try {
    for (final ni in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
      for (final a in ni.addresses) {
        if (!a.isLoopback) out.add(a.address);
      }
    }
  } catch (_) {}
  // اول نشانی‌های شبکه‌ی خانگی/هات‌اسپات
  int rank(String a) => a.startsWith('192.168.')
      ? 0
      : a.startsWith('10.')
          ? 1
          : a.startsWith('172.')
              ? 2
              : 3;
  out.sort((a, b) => rank(a).compareTo(rank(b)));
  return out;
}

// ───────────────────────── پشتیبان‌گیری ─────────────────────────
// همان «کل دفتر» همگام‌سازی، به‌علاوه‌ی همه‌ی تنظیمات (جز رمز قفل و
// شناسه‌های همگام‌سازی)، در یک فایل JSON.

/// نشانه‌ی فایل پشتیبان کهربا
const backupFormat = 'kahroba-backup';

/// تنظیماتی که در پشتیبان نمی‌روند و با بازیابی عوض نمی‌شوند
const _privateSettings = {
  SettingKeys.lockPin,
  SettingKeys.lastBackupAt,
  SettingKeys.firstOpenAt,
  SettingKeys.rateState,
  SettingKeys.rateNextAt,
  SyncKeys.ownId,
  SyncKeys.peerId,
  SyncKeys.lastHost,
  SyncKeys.lastAt,
};

/// کل دفتر (با عکس‌ها) برای فایل پشتیبان
Future<Map<String, dynamic>> buildBackup(AppDatabase db) async {
  final snap = await buildSnapshot(db, const {});
  final rows =
      await db.customSelect('SELECT name, content FROM app_settings').get();
  return {
    ...snap,
    'format': backupFormat,
    'created': DateTime.now().toIso8601String(),
    'settings': {
      for (final r in rows)
        if (!_privateSettings.contains(r.data['name']))
          '${r.data['name']}': '${r.data['content']}',
    },
  };
}

/// خلاصه‌ی یک فایل پشتیبان برای نمایش پیش از بازیابی
({DateTime? created, int cases, int customers}) describeBackup(
    Map<String, dynamic> b) {
  final t = (b['tables'] as Map?) ?? const {};
  return (
    created: DateTime.tryParse('${b['created']}'),
    cases: ((t['repair_cases'] as List?) ?? const []).length,
    customers: ((t['customers'] as List?) ?? const []).length,
  );
}

/// جایگزینی کامل دفتر این گوشی با فایل پشتیبان
Future<void> applyBackup(AppDatabase db, Map<String, dynamic> b) async {
  if (b['format'] != backupFormat || b['tables'] is! Map) {
    throw const FormatException('این فایل، پشتیبان کهربا نیست.');
  }
  final d = _Db(db);
  if (!kIsWeb) {
    await _writePhotos(
        (b['photos'] as Map?)?.cast<String, dynamic>() ?? const {});
  }
  final tables = (b['tables'] as Map).cast<String, dynamic>();
  await d.ensureBaseline();
  await db.transaction(() async {
    for (final t in _tables.reversed) {
      await db.customStatement('DELETE FROM $t');
    }
    await db.customStatement('DELETE FROM counters');
    for (final t in _tables) {
      final cols = await d.columns(t);
      for (final raw in (tables[t] as List?) ?? const []) {
        final v = <String, Object?>{};
        (raw as Map).forEach((k, val) {
          final key = '$k';
          if (_ident.hasMatch(key) && cols.contains(key)) v[key] = val;
        });
        final row = SyncRow.of(v);
        await d.insert(t, kIsWeb ? row : await _localizePhoto(t, row));
      }
    }
    for (final c in (b['counters'] as List?) ?? const []) {
      await db.customStatement(
        'INSERT INTO counters (name, current) VALUES (?, ?)',
        [(c as Map)['name'], c['current']],
      );
    }
    final settings = (b['settings'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final e in settings.entries) {
      if (_privateSettings.contains(e.key) || !_ident.hasMatch(e.key)) continue;
      await d.setSetting(e.key, '${e.value}');
    }
    // دفتر عوض شد: همگام‌سازی با همکار از نو شروع می‌شود
    await db.customStatement('DELETE FROM kahroba_sync_baseline');
    await d.setSetting(SyncKeys.peerId, '');
  });
  db.markTablesUpdated(db.allTables);
}
