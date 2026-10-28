import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../core/utils/format.dart';
import '../core/utils/text_utils.dart';
import 'defaults.dart';
import 'enums.dart';

export 'enums.dart';

part 'database.g.dart';

// ───────────────────────────── جدول‌ها ─────────────────────────────
// ساختار: مشتری ← دستگاه ← پرونده.
// یک مشتری چند دستگاه دارد و هر دستگاه چند بار تعمیر می‌شود.

/// دسته‌ی دستگاه‌ها: بخاری، سماور، لباسشویی و... (قابل افزودن توسط کاربر)
@DataClassName('DeviceCategory')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// پیشوند کد دستگاه، مثل BK
  TextColumn get prefix => text().withLength(min: 1, max: 4).unique()();

  /// کلید آیکن (به core/widgets/category_icon.dart نگاه کنید)
  TextColumn get icon => text().withDefault(const Constant('other'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@TableIndex(name: 'customers_phone', columns: {#phone})
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// همیشه یکسان‌شده با normalizePhone ذخیره می‌شود.
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get phone2 => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  /// مثل «زنگ طبقه دوم خراب است»
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// کد ثابت دستگاه، مثل BK-0037. روی برچسب QR می‌رود و هیچ‌وقت عوض نمی‌شود.
  TextColumn get code => text().unique()();
  IntColumn get customerId => integer().references(Customers, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get model => text().withDefault(const Constant(''))();
  TextColumn get serial => text().withDefault(const Constant(''))();
  IntColumn get purchaseYear => integer().nullable()();

  /// مسیر عکس پلاک مشخصات
  TextColumn get nameplatePhoto => text().nullable()();

  /// قیمت تقریبی دستگاه نو (تومان)؛ برای «ارزش تعمیر دارد؟»
  IntColumn get newPrice => integer().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RepairCases extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// کد پرونده، مثل 05-0142 (سال ۱۴۰۵، پرونده‌ی ۱۴۲ام)
  TextColumn get code => text().unique()();
  IntColumn get deviceId => integer().references(Devices, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get jobType => textEnum<JobType>()();
  TextColumn get status => textEnum<CaseStatus>()();

  /// ایراد از زبان مشتری
  TextColumn get reportedProblem => text().withDefault(const Constant(''))();

  /// عیبی که تعمیرکار واقعاً پیدا کرد
  TextColumn get actualFault => text().withDefault(const Constant(''))();

  /// شناسه‌ی مورد بانک فنی که به این پرونده وصل شده
  TextColumn get kbRef => text().withDefault(const Constant(''))();

  /// اجرت به تومان (قیمت قطعات جداست)
  IntColumn get labor => integer().withDefault(const Constant(0))();
  IntColumn get warrantyDays => integer().withDefault(const Constant(0))();

  /// یادداشت فنی که مشتری نمی‌بیند
  TextColumn get privateNote => text().withDefault(const Constant(''))();
  DateTimeColumn get receivedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get readyAt => dateTime().nullable()();
  DateTimeColumn get deliveredAt => dateTime().nullable()();

  /// زمان قرار برای کار در محل
  DateTimeColumn get appointmentAt => dateTime().nullable()();
}

class CaseParts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get caseId => integer().references(RepairCases, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get qty => integer().withDefault(const Constant(1))();

  /// قیمت واحد به تومان
  IntColumn get unitPrice => integer().withDefault(const Constant(0))();
}

class CasePhotos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get caseId => integer().references(RepairCases, #id)();
  TextColumn get path => text()();
  TextColumn get kind => textEnum<PhotoKind>()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// تاریخچه‌ی تغییر وضعیت هر پرونده
@DataClassName('StatusEvent')
class StatusEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get caseId => integer().references(RepairCases, #id)();
  TextColumn get status => textEnum<CaseStatus>()();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
}

/// شمارنده‌ها برای ساخت کد. شمارنده هیچ‌وقت عقب نمی‌رود، حتی اگر پرونده‌ای
/// پاک شود؛ پس دو مشتری هیچ‌وقت رسید با کد یکسان نمی‌گیرند.
@DataClassName('CounterRow')
class Counters extends Table {
  TextColumn get name => text()();
  IntColumn get current => integer()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get name => text()();
  TextColumn get content => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

/// یادداشت شخصی تعمیرکار روی یک مورد بانک فنی
/// پرداخت‌های هر پرونده (بیعانه، قسط، تسویه)
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get caseId => integer().references(RepairCases, #id)();

  /// مبلغ به تومان
  IntColumn get amount => integer()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
}

/// نرخ‌نامه‌ی شخصی: کارها و قطعات پرتکرار با قیمت
class PriceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// قیمت به تومان
  IntColumn get price => integer().withDefault(const Constant(0))();

  /// true یعنی قطعه است (به فهرست قطعات اضافه می‌شود)، false یعنی اجرت
  BoolColumn get isPart => boolean().withDefault(const Constant(false))();
}

class KbNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entryId => text().unique()();
  TextColumn get body => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// قطعه‌های معادل که تعمیرکار خودش ثبت می‌کند
class PartEquivalents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get partName => text().withLength(min: 1, max: 100)();
  TextColumn get equivalent => text().withLength(min: 1, max: 100)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ───────────────────────────── مدل‌های ترکیبی ─────────────────────────────

String _joinNonEmpty(Iterable<String> parts) =>
    parts.map((s) => s.trim()).where((s) => s.isNotEmpty).join(' ');

/// دستگاه همراه با دسته‌اش
class DeviceInfo {
  DeviceInfo(this.device, this.category);
  final Device device;
  final DeviceCategory category;

  /// مثل «بخاری بوتان»
  String get title =>
      _joinNonEmpty([category.name, device.brand, device.model]);
}

/// پرونده همراه با دستگاه، دسته و مشتری؛ برای فهرست‌ها و صفحه‌ی پرونده.
class CaseRow {
  CaseRow(this.repairCase, this.device, this.category, this.customer);
  final RepairCase repairCase;
  final Device device;
  final DeviceCategory category;
  final Customer customer;

  String get deviceTitle =>
      _joinNonEmpty([category.name, device.brand, device.model]);

  /// متنی که جستجو روی آن انجام می‌شود (یک بار ساخته و نگه داشته می‌شود)
  late final String searchText = normalizeForSearch([
    repairCase.code,
    device.code,
    customer.name,
    customer.phone,
    customer.phone2,
    category.name,
    device.brand,
    device.model,
    repairCase.reportedProblem,
  ].join(' '));
}

/// وضعیت مالی یک پرونده
class CaseMoney {
  const CaseMoney({
    required this.caseId,
    required this.customerId,
    required this.status,
    required this.total,
    required this.paid,
  });
  final int caseId;
  final int customerId;
  final CaseStatus status;
  final int total;
  final int paid;

  int get due => total - paid;

  /// بدهی واقعی: دستگاه تحویل شده و هنوز مانده دارد
  bool get isDebt => status == CaseStatus.delivered && due > 0;
}

// ───────────────────────────── پایگاه داده ─────────────────────────────

@DriftDatabase(tables: [
  Categories,
  Customers,
  Devices,
  RepairCases,
  CaseParts,
  CasePhotos,
  StatusEvents,
  Counters,
  AppSettings,
  KbNotes,
  PartEquivalents,
  Payments,
  PriceItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(driftDatabase(
    // نام فایل پایگاه داده (kahroba.sqlite). عوض کردنش یعنی دفتر خالی تازه.
    name: 'kahroba',
    // نسخه‌ی وب: SQLite به‌صورت WebAssembly در خود مرورگر
    // (فایل‌های web/sqlite3.wasm و web/drift_worker.js)
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  ));

  /// برای تست‌ها
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // نسخه‌ی ۱ فقط نسخه‌ی آزمایشی بود و داده‌ی واقعی نداشت؛
        // پس جدول‌ها را از نو می‌سازیم. از این به بعد مهاجرت‌ها باید
        // داده را نگه دارند.
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
        await _seed();
        return;
      }
      if (from < 3) {
        // نسخه‌ی ۳: پرداخت‌ها، نرخ‌نامه، زمان قرار، قیمت دستگاه نو
        await m.createTable(payments);
        await m.createTable(priceItems);
        await m.addColumn(repairCases, repairCases.appointmentAt);
        await m.addColumn(devices, devices.newPrice);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _ensureDefaultCategories();
    },
  );

  /// دسته‌هایی که بعداً به فهرست پیش‌فرض اضافه شده‌اند (مثل خشک‌کن و هود)
  /// برای کاربرهای قبلی هم ساخته شوند. دسته‌ی موجود دست نمی‌خورد.
  Future<void> _ensureDefaultCategories() async {
    // فقط یک بار برای هر نسخه‌ی فهرست؛ اگر کاربر دسته‌ای را عمداً حذف کند
    // دوباره ساخته نمی‌شود.
    const version = '3';
    final done = await customSelect(
      "SELECT content FROM app_settings WHERE name = 'categories_version'",
    ).getSingleOrNull();
    if (done?.data['content'] == version) return;
    var order = 0;
    for (final (name, prefix, icon) in defaultCategories) {
      await customStatement(
        'INSERT OR IGNORE INTO categories (name, prefix, icon, sort_order) '
            'VALUES (?, ?, ?, ?)',
        [name, prefix, icon, order++],
      );
    }
    // «سایر» همیشه آخر فهرست
    await customStatement(
      "UPDATE categories SET sort_order = 999 WHERE prefix = 'OT'",
    );
    await customStatement(
      'INSERT INTO app_settings (name, content) VALUES (?, ?) '
          'ON CONFLICT(name) DO UPDATE SET content = excluded.content',
      ['categories_version', version],
    );
  }

  Future<void> _seed() async {
    var order = 0;
    for (final (name, prefix, icon) in defaultCategories) {
      await into(categories).insert(CategoriesCompanion.insert(
        name: name,
        prefix: prefix,
        icon: Value(icon),
        sortOrder: Value(order++),
      ));
    }
  }

  // ─────────── شمارنده‌ها ───────────

  Future<int> _nextCounter(String name) async {
    final row = await (select(counters)..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    final next = (row?.current ?? 0) + 1;
    await into(counters).insertOnConflictUpdate(
      CountersCompanion.insert(name: name, current: next),
    );
    return next;
  }

  // ─────────── دسته‌ها ───────────

  Stream<List<DeviceCategory>> watchCategories() => (select(categories)
    ..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.id),
    ]))
      .watch();

  Future<List<DeviceCategory>> getCategories() => (select(categories)
    ..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.id),
    ]))
      .get();

  Future<int> addCategory({
    required String name,
    required String prefix,
    required String icon,
  }) async {
    final count = await categories.count().getSingle();
    return into(categories).insert(CategoriesCompanion.insert(
      name: name,
      prefix: prefix.toUpperCase(),
      icon: Value(icon),
      sortOrder: Value(count),
    ));
  }

  Future<void> updateCategory(int id, {required String name, required String icon}) =>
      (update(categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(name: Value(name), icon: Value(icon)),
      );

  // ─────────── مشتری‌ها ───────────

  Stream<List<Customer>> watchCustomers() =>
      (select(customers)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Stream<Customer?> watchCustomer(int id) =>
      (select(customers)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<Customer?> findCustomerByPhone(String phone) async {
    final p = normalizePhone(phone);
    if (p.isEmpty) return null;
    final rows = await (select(customers)
      ..where((t) => t.phone.equals(p) | t.phone2.equals(p))
      ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> insertCustomer({
    required String name,
    String phone = '',
    String phone2 = '',
    String address = '',
    String note = '',
  }) =>
      into(customers).insert(CustomersCompanion.insert(
        name: name,
        phone: Value(normalizePhone(phone)),
        phone2: Value(normalizePhone(phone2)),
        address: Value(address),
        note: Value(note),
      ));

  Future<void> updateCustomer(
      int id, {
        required String name,
        required String phone,
        required String phone2,
        required String address,
        required String note,
      }) =>
      (update(customers)..where((t) => t.id.equals(id))).write(
        CustomersCompanion(
          name: Value(name),
          phone: Value(normalizePhone(phone)),
          phone2: Value(normalizePhone(phone2)),
          address: Value(address),
          note: Value(note),
        ),
      );

  Future<void> setCustomerLocation(int id, double? lat, double? lng) =>
      (update(customers)..where((t) => t.id.equals(id))).write(
        CustomersCompanion(latitude: Value(lat), longitude: Value(lng)),
      );

  // ─────────── دستگاه‌ها ───────────

  DeviceInfo _toDeviceInfo(TypedResult r) =>
      DeviceInfo(r.readTable(devices), r.readTable(categories));

  Stream<List<DeviceInfo>> watchDevicesOfCustomer(int customerId) {
    final q = select(devices).join([
      innerJoin(categories, categories.id.equalsExp(devices.categoryId)),
    ])
      ..where(devices.customerId.equals(customerId))
      ..orderBy([OrderingTerm.desc(devices.id)]);
    return q.watch().map((rows) => rows.map(_toDeviceInfo).toList());
  }

  Future<List<DeviceInfo>> getDevicesOfCustomer(int customerId) {
    final q = select(devices).join([
      innerJoin(categories, categories.id.equalsExp(devices.categoryId)),
    ])
      ..where(devices.customerId.equals(customerId))
      ..orderBy([OrderingTerm.desc(devices.id)]);
    return q.get().then((rows) => rows.map(_toDeviceInfo).toList());
  }

  Stream<DeviceInfo?> watchDevice(int id) {
    final q = select(devices).join([
      innerJoin(categories, categories.id.equalsExp(devices.categoryId)),
    ])
      ..where(devices.id.equals(id));
    return q.watch().map(
            (rows) => rows.isEmpty ? null : _toDeviceInfo(rows.first));
  }

  Future<Device?> findDeviceByCode(String code) =>
      (select(devices)..where((t) => t.code.equals(code.trim().toUpperCase())))
          .getSingleOrNull();

  Future<int> _createDevice({
    required int customerId,
    required int categoryId,
    String brand = '',
    String model = '',
  }) async {
    final category = await (select(categories)
      ..where((t) => t.id.equals(categoryId)))
        .getSingle();
    final n = await _nextCounter('device-${category.prefix}');
    return into(devices).insert(DevicesCompanion.insert(
      code: formatDeviceCode(category.prefix, n),
      customerId: customerId,
      categoryId: categoryId,
      brand: Value(brand),
      model: Value(model),
    ));
  }

  Future<void> updateDevice(
      int id, {
        required String brand,
        required String model,
        required String serial,
        required int? purchaseYear,
        required String note,
      }) =>
      (update(devices)..where((t) => t.id.equals(id))).write(
        DevicesCompanion(
          brand: Value(brand),
          model: Value(model),
          serial: Value(serial),
          purchaseYear: Value(purchaseYear),
          note: Value(note),
        ),
      );

  Future<void> setNameplatePhoto(int deviceId, String? path) =>
      (update(devices)..where((t) => t.id.equals(deviceId)))
          .write(DevicesCompanion(nameplatePhoto: Value(path)));

  // ─────────── پرونده‌ها ───────────

  CaseRow _toCaseRow(TypedResult r) => CaseRow(
    r.readTable(repairCases),
    r.readTable(devices),
    r.readTable(categories),
    r.readTable(customers),
  );

  JoinedSelectStatement<HasResultSet, dynamic> _caseQuery(
      [Expression<bool>? filter]) {
    final q = select(repairCases).join([
      innerJoin(devices, devices.id.equalsExp(repairCases.deviceId)),
      innerJoin(categories, categories.id.equalsExp(devices.categoryId)),
      innerJoin(customers, customers.id.equalsExp(repairCases.customerId)),
    ]);
    if (filter != null) q.where(filter);
    q.orderBy([
      OrderingTerm.desc(repairCases.receivedAt),
      OrderingTerm.desc(repairCases.id),
    ]);
    return q;
  }

  /// همه‌ی پرونده‌ها، جدیدترین اول. فیلتر وضعیت و جستجو در صفحه انجام می‌شود.
  Stream<List<CaseRow>> watchCases() =>
      _caseQuery().watch().map((rows) => rows.map(_toCaseRow).toList());

  Future<List<CaseRow>> getCases() =>
      _caseQuery().get().then((rows) => rows.map(_toCaseRow).toList());

  Stream<CaseRow?> watchCase(int id) => _caseQuery(repairCases.id.equals(id))
      .watch()
      .map((rows) => rows.isEmpty ? null : _toCaseRow(rows.first));

  Stream<List<CaseRow>> watchCasesOfDevice(int deviceId) =>
      _caseQuery(repairCases.deviceId.equals(deviceId))
          .watch()
          .map((rows) => rows.map(_toCaseRow).toList());

  Stream<List<CaseRow>> watchCasesOfCustomer(int customerId) =>
      _caseQuery(repairCases.customerId.equals(customerId))
          .watch()
          .map((rows) => rows.map(_toCaseRow).toList());

  /// ثبت سریع پرونده. اگر مشتری یا دستگاه وجود نداشته باشد، ساخته می‌شود.
  /// یا [deviceId] را بدهید (دستگاه قبلی)، یا [categoryId] (دستگاه جدید).
  Future<({int id, String code})> createCase({
    int? customerId,
    required String customerName,
    String phone = '',
    int? deviceId,
    int? categoryId,
    String brand = '',
    String model = '',
    required JobType jobType,
    String problem = '',
    String? photoPath,
    CaseStatus status = CaseStatus.received,
    int deposit = 0,
    DateTime? appointmentAt,
  }) {
    assert(deviceId != null || categoryId != null);
    return transaction(() async {
      var existingCustomerId = customerId;
      if (existingCustomerId == null && phone.trim().isNotEmpty) {
        existingCustomerId = (await findCustomerByPhone(phone))?.id;
      }
      final cid = existingCustomerId ??
          await insertCustomer(name: customerName, phone: phone);

      final did = deviceId ??
          await _createDevice(
            customerId: cid,
            categoryId: categoryId!,
            brand: brand,
            model: model,
          );

      final year = Jalali.now().year;
      final n = await _nextCounter('case-$year');
      final code = formatCaseCode(year, n);

      final settingsRows = await select(appSettings).get();
      final settings =
      ShopSettings({for (final r in settingsRows) r.name: r.content});

      final id = await into(repairCases).insert(RepairCasesCompanion.insert(
        code: code,
        deviceId: did,
        customerId: cid,
        jobType: jobType,
        status: status,
        reportedProblem: Value(problem),
        warrantyDays: Value(settings.defaultWarrantyDays),
        appointmentAt: Value(appointmentAt),
      ));
      await into(statusEvents).insert(
        StatusEventsCompanion.insert(caseId: id, status: status),
      );
      if (deposit > 0) {
        await into(payments).insert(PaymentsCompanion.insert(
          caseId: id,
          amount: deposit,
          note: const Value('بیعانه'),
        ));
      }
      if (photoPath != null) {
        await into(casePhotos).insert(CasePhotosCompanion.insert(
          caseId: id,
          path: photoPath,
          kind: PhotoKind.before,
        ));
      }
      return (id: id, code: code);
    });
  }

  Future<void> setStatus(int caseId, CaseStatus status) {
    return transaction(() async {
      final now = DateTime.now();
      await (update(repairCases)..where((t) => t.id.equals(caseId))).write(
        RepairCasesCompanion(
          status: Value(status),
          readyAt: status == CaseStatus.ready
              ? Value(now)
              : const Value.absent(),
          deliveredAt: status == CaseStatus.delivered
              ? Value(now)
              : const Value.absent(),
        ),
      );
      await into(statusEvents).insert(
        StatusEventsCompanion.insert(caseId: caseId, status: status),
      );
    });
  }

  Future<void> updateCaseFields(int caseId, RepairCasesCompanion fields) =>
      (update(repairCases)..where((t) => t.id.equals(caseId))).write(fields);

  /// پرونده را پاک می‌کند و مسیر عکس‌هایش را برمی‌گرداند تا فایل‌ها هم پاک شوند.
  Future<List<String>> deleteCase(int caseId) {
    return transaction(() async {
      final photos = await (select(casePhotos)
        ..where((t) => t.caseId.equals(caseId)))
          .get();
      await (delete(caseParts)..where((t) => t.caseId.equals(caseId))).go();
      await (delete(payments)..where((t) => t.caseId.equals(caseId))).go();
      await (delete(casePhotos)..where((t) => t.caseId.equals(caseId))).go();
      await (delete(statusEvents)..where((t) => t.caseId.equals(caseId))).go();
      await (delete(repairCases)..where((t) => t.id.equals(caseId))).go();
      return photos.map((p) => p.path).toList();
    });
  }

  // ─────────── قطعات، عکس‌ها، تاریخچه ───────────

  Stream<List<CasePart>> watchParts(int caseId) =>
      (select(caseParts)..where((t) => t.caseId.equals(caseId))).watch();

  Future<List<CasePart>> getAllParts() => select(caseParts).get();

  Future<int> addPart(int caseId, String name, int qty, int unitPrice) =>
      into(caseParts).insert(CasePartsCompanion.insert(
        caseId: caseId,
        name: name,
        qty: Value(qty),
        unitPrice: Value(unitPrice),
      ));

  Future<void> deletePart(int partId) =>
      (delete(caseParts)..where((t) => t.id.equals(partId))).go();

  Stream<List<CasePhoto>> watchPhotos(int caseId) =>
      (select(casePhotos)
        ..where((t) => t.caseId.equals(caseId))
        ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<int> addPhoto(int caseId, String path, PhotoKind kind) =>
      into(casePhotos).insert(
        CasePhotosCompanion.insert(caseId: caseId, path: path, kind: kind),
      );

  Future<void> deletePhoto(int photoId) =>
      (delete(casePhotos)..where((t) => t.id.equals(photoId))).go();

  Stream<List<StatusEvent>> watchEvents(int caseId) =>
      (select(statusEvents)
        ..where((t) => t.caseId.equals(caseId))
        ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  // ─────────── تنظیمات ───────────

  Stream<ShopSettings> watchSettings() => select(appSettings).watch().map(
          (rows) => ShopSettings({for (final r in rows) r.name: r.content}));

  Future<ShopSettings> getSettings() => select(appSettings).get().then(
          (rows) => ShopSettings({for (final r in rows) r.name: r.content}));

  Future<void> setSetting(String name, String content) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(name: name, content: content),
      );

  // ─────────── بانک فنی ───────────

  Stream<KbNote?> watchKbNote(String entryId) =>
      (select(kbNotes)..where((t) => t.entryId.equals(entryId)))
          .watchSingleOrNull();

  Future<void> saveKbNote(String entryId, String body) async {
    if (body.trim().isEmpty) {
      await (delete(kbNotes)..where((t) => t.entryId.equals(entryId))).go();
      return;
    }
    await into(kbNotes).insert(
      KbNotesCompanion.insert(
        entryId: entryId,
        body: body.trim(),
        updatedAt: Value(DateTime.now()),
      ),
      onConflict: DoUpdate(
            (old) => KbNotesCompanion(
          body: Value(body.trim()),
          updatedAt: Value(DateTime.now()),
        ),
        target: [kbNotes.entryId],
      ),
    );
  }

  /// آمار شخصی: در پرونده‌هایی که به این مورد بانک وصل شده‌اند،
  /// عیب واقعی چه بوده و چند بار.
  Future<Map<String, int>> faultStatsForKb(String entryId) async {
    final rows = await (select(repairCases)
      ..where((t) => t.kbRef.equals(entryId)))
        .get();
    final stats = <String, int>{};
    for (final r in rows) {
      final f = r.actualFault.trim();
      if (f.isEmpty) continue;
      stats[f] = (stats[f] ?? 0) + 1;
    }
    return stats;
  }

  // ─────────── پول: پرداخت‌ها و مانده ───────────

  Stream<List<Payment>> watchPayments(int caseId) => (select(payments)
    ..where((t) => t.caseId.equals(caseId))
    ..orderBy([(t) => OrderingTerm.asc(t.id)]))
      .watch();

  Future<List<Payment>> getAllPayments() => select(payments).get();

  Future<int> addPayment(int caseId, int amount, {String note = ''}) =>
      into(payments).insert(PaymentsCompanion.insert(
        caseId: caseId,
        amount: amount,
        note: Value(note),
      ));

  Future<void> deletePayment(int id) =>
      (delete(payments)..where((t) => t.id.equals(id))).go();

  /// جمع هزینه (اجرت + قطعات) و جمع پرداختی هر پرونده، به‌صورت زنده.
  Stream<Map<int, CaseMoney>> watchMoney() {
    return customSelect(
      'SELECT c.id AS id, c.customer_id AS customer_id, c.status AS status, '
          'c.labor + COALESCE((SELECT SUM(p.qty * p.unit_price) FROM case_parts p '
          'WHERE p.case_id = c.id), 0) AS total, '
          'COALESCE((SELECT SUM(y.amount) FROM payments y WHERE y.case_id = c.id), 0) '
          'AS paid FROM repair_cases c',
      readsFrom: {repairCases, caseParts, payments},
    ).watch().map((rows) => {
      for (final r in rows)
        r.read<int>('id'): CaseMoney(
          caseId: r.read<int>('id'),
          customerId: r.read<int>('customer_id'),
          status: CaseStatus.values.firstWhere(
                (s) => s.name == r.read<String>('status'),
            orElse: () => CaseStatus.received,
          ),
          total: r.read<int>('total'),
          paid: r.read<int>('paid'),
        ),
    });
  }

  // ─────────── نرخ‌نامه ───────────

  Stream<List<PriceItem>> watchPriceItems() => (select(priceItems)
    ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<int> addPriceItem(String name, int price, bool isPart) =>
      into(priceItems).insert(PriceItemsCompanion.insert(
        name: name,
        price: Value(price),
        isPart: Value(isPart),
      ));

  Future<void> updatePriceItem(int id, String name, int price, bool isPart) =>
      (update(priceItems)..where((t) => t.id.equals(id))).write(
        PriceItemsCompanion(
          name: Value(name),
          price: Value(price),
          isPart: Value(isPart),
        ),
      );

  Future<void> deletePriceItem(int id) =>
      (delete(priceItems)..where((t) => t.id.equals(id))).go();

  /// افزایش همه‌ی قیمت‌ها به درصد؛ به نزدیک‌ترین هزار تومان گرد می‌شود.
  Future<void> increaseAllPrices(double percent) {
    return transaction(() async {
      final items = await select(priceItems).get();
      for (final it in items) {
        final raw = it.price * (1 + percent / 100);
        final rounded = ((raw / 1000).round() * 1000);
        await (update(priceItems)..where((t) => t.id.equals(it.id)))
            .write(PriceItemsCompanion(price: Value(rounded)));
      }
    });
  }

  /// افزودن به اجرت پرونده (با خبر دادن به استریم‌ها تا صفحه به‌روز شود)
  Future<void> addLabor(int caseId, int amount) => customUpdate(
    'UPDATE repair_cases SET labor = labor + ? WHERE id = ?',
    variables: [Variable.withInt(amount), Variable.withInt(caseId)],
    updates: {repairCases},
  );

  // ─────────── برگشتی و تکرار ───────────

  /// اگر دستگاه هنوز در گارانتی تعمیر قبلی است، آن پرونده را برمی‌گرداند.
  Future<RepairCase?> activeWarrantyCase(int deviceId) async {
    final cases = await (select(repairCases)
      ..where((t) =>
      t.deviceId.equals(deviceId) & t.deliveredAt.isNotNull())
      ..orderBy([(t) => OrderingTerm.desc(t.deliveredAt)])
      ..limit(1))
        .get();
    if (cases.isEmpty) return null;
    final last = cases.first;
    if (last.warrantyDays <= 0) return null;
    final end = last.deliveredAt!.add(Duration(days: last.warrantyDays));
    return DateTime.now().isBefore(end) ? last : null;
  }

  /// تعداد پرونده‌های یک دستگاه در [days] روز اخیر
  Future<int> recentVisits(int deviceId, {int days = 180}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await (select(repairCases)
      ..where((t) =>
      t.deviceId.equals(deviceId) &
      t.receivedAt.isBiggerOrEqualValue(since)))
        .get();
    return rows.length;
  }

  Future<void> setDeviceNewPrice(int deviceId, int? price) =>
      (update(devices)..where((t) => t.id.equals(deviceId)))
          .write(DevicesCompanion(newPrice: Value(price)));

  // ─────────── قطعات معادل ───────────

  Stream<List<PartEquivalent>> watchEquivalents() => (select(partEquivalents)
    ..orderBy([(t) => OrderingTerm.asc(t.partName)]))
      .watch();

  Future<int> addEquivalent(String part, String equivalent, String note) =>
      into(partEquivalents).insert(PartEquivalentsCompanion.insert(
        partName: part,
        equivalent: equivalent,
        note: Value(note),
      ));

  Future<void> deleteEquivalent(int id) =>
      (delete(partEquivalents)..where((t) => t.id.equals(id))).go();
}

/// یک نمونه‌ی مشترک برای کل برنامه.
final appDb = AppDatabase();