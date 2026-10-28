// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, DeviceCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prefixMeta = const VerificationMeta('prefix');
  @override
  late final GeneratedColumn<String> prefix = GeneratedColumn<String>(
    'prefix',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 4,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, prefix, icon, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('prefix')) {
      context.handle(
        _prefixMeta,
        prefix.isAcceptableOrUnknown(data['prefix']!, _prefixMeta),
      );
    } else if (isInserting) {
      context.missing(_prefixMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      prefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prefix'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class DeviceCategory extends DataClass implements Insertable<DeviceCategory> {
  final int id;
  final String name;

  /// پیشوند کد دستگاه، مثل BK
  final String prefix;

  /// کلید آیکن (به core/widgets/category_icon.dart نگاه کنید)
  final String icon;
  final int sortOrder;
  const DeviceCategory({
    required this.id,
    required this.name,
    required this.prefix,
    required this.icon,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['prefix'] = Variable<String>(prefix);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      prefix: Value(prefix),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
    );
  }

  factory DeviceCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      prefix: serializer.fromJson<String>(json['prefix']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'prefix': serializer.toJson<String>(prefix),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DeviceCategory copyWith({
    int? id,
    String? name,
    String? prefix,
    String? icon,
    int? sortOrder,
  }) => DeviceCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    prefix: prefix ?? this.prefix,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  DeviceCategory copyWithCompanion(CategoriesCompanion data) {
    return DeviceCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      prefix: data.prefix.present ? data.prefix.value : this.prefix,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('prefix: $prefix, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, prefix, icon, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.prefix == this.prefix &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<DeviceCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> prefix;
  final Value<String> icon;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.prefix = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String prefix,
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       prefix = Value(prefix);
  static Insertable<DeviceCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? prefix,
    Expression<String>? icon,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (prefix != null) 'prefix': prefix,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? prefix,
    Value<String>? icon,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      prefix: prefix ?? this.prefix,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (prefix.present) {
      map['prefix'] = Variable<String>(prefix.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('prefix: $prefix, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phone2Meta = const VerificationMeta('phone2');
  @override
  late final GeneratedColumn<String> phone2 = GeneratedColumn<String>(
    'phone2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    phone2,
    address,
    latitude,
    longitude,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('phone2')) {
      context.handle(
        _phone2Meta,
        phone2.isAcceptableOrUnknown(data['phone2']!, _phone2Meta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      phone2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone2'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String name;

  /// همیشه یکسان‌شده با normalizePhone ذخیره می‌شود.
  final String phone;
  final String phone2;
  final String address;
  final double? latitude;
  final double? longitude;

  /// مثل «زنگ طبقه دوم خراب است»
  final String note;
  final DateTime createdAt;
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.phone2,
    required this.address,
    this.latitude,
    this.longitude,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['phone2'] = Variable<String>(phone2);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      phone2: Value(phone2),
      address: Value(address),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      phone2: serializer.fromJson<String>(json['phone2']),
      address: serializer.fromJson<String>(json['address']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'phone2': serializer.toJson<String>(phone2),
      'address': serializer.toJson<String>(address),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? phone2,
    String? address,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    String? note,
    DateTime? createdAt,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    phone2: phone2 ?? this.phone2,
    address: address ?? this.address,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      phone2: data.phone2.present ? data.phone2.value : this.phone2,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('phone2: $phone2, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    phone2,
    address,
    latitude,
    longitude,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.phone2 == this.phone2 &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> phone2;
  final Value<String> address;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> note;
  final Value<DateTime> createdAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.phone2 = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.phone2 = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? phone2,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (phone2 != null) 'phone2': phone2,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String>? phone2,
    Value<String>? address,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String>? note,
    Value<DateTime>? createdAt,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (phone2.present) {
      map['phone2'] = Variable<String>(phone2.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('phone2: $phone2, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<String> serial = GeneratedColumn<String>(
    'serial',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _purchaseYearMeta = const VerificationMeta(
    'purchaseYear',
  );
  @override
  late final GeneratedColumn<int> purchaseYear = GeneratedColumn<int>(
    'purchase_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameplatePhotoMeta = const VerificationMeta(
    'nameplatePhoto',
  );
  @override
  late final GeneratedColumn<String> nameplatePhoto = GeneratedColumn<String>(
    'nameplate_photo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newPriceMeta = const VerificationMeta(
    'newPrice',
  );
  @override
  late final GeneratedColumn<int> newPrice = GeneratedColumn<int>(
    'new_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    customerId,
    categoryId,
    brand,
    model,
    serial,
    purchaseYear,
    nameplatePhoto,
    newPrice,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['serial']!, _serialMeta),
      );
    }
    if (data.containsKey('purchase_year')) {
      context.handle(
        _purchaseYearMeta,
        purchaseYear.isAcceptableOrUnknown(
          data['purchase_year']!,
          _purchaseYearMeta,
        ),
      );
    }
    if (data.containsKey('nameplate_photo')) {
      context.handle(
        _nameplatePhotoMeta,
        nameplatePhoto.isAcceptableOrUnknown(
          data['nameplate_photo']!,
          _nameplatePhotoMeta,
        ),
      );
    }
    if (data.containsKey('new_price')) {
      context.handle(
        _newPriceMeta,
        newPrice.isAcceptableOrUnknown(data['new_price']!, _newPriceMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serial'],
      )!,
      purchaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_year'],
      ),
      nameplatePhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nameplate_photo'],
      ),
      newPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_price'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final int id;

  /// کد ثابت دستگاه، مثل BK-0037. روی برچسب QR می‌رود و هیچ‌وقت عوض نمی‌شود.
  final String code;
  final int customerId;
  final int categoryId;
  final String brand;
  final String model;
  final String serial;
  final int? purchaseYear;

  /// مسیر عکس پلاک مشخصات
  final String? nameplatePhoto;

  /// قیمت تقریبی دستگاه نو (تومان)؛ برای «ارزش تعمیر دارد؟»
  final int? newPrice;
  final String note;
  final DateTime createdAt;
  const Device({
    required this.id,
    required this.code,
    required this.customerId,
    required this.categoryId,
    required this.brand,
    required this.model,
    required this.serial,
    this.purchaseYear,
    this.nameplatePhoto,
    this.newPrice,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['customer_id'] = Variable<int>(customerId);
    map['category_id'] = Variable<int>(categoryId);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    map['serial'] = Variable<String>(serial);
    if (!nullToAbsent || purchaseYear != null) {
      map['purchase_year'] = Variable<int>(purchaseYear);
    }
    if (!nullToAbsent || nameplatePhoto != null) {
      map['nameplate_photo'] = Variable<String>(nameplatePhoto);
    }
    if (!nullToAbsent || newPrice != null) {
      map['new_price'] = Variable<int>(newPrice);
    }
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      code: Value(code),
      customerId: Value(customerId),
      categoryId: Value(categoryId),
      brand: Value(brand),
      model: Value(model),
      serial: Value(serial),
      purchaseYear: purchaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseYear),
      nameplatePhoto: nameplatePhoto == null && nullToAbsent
          ? const Value.absent()
          : Value(nameplatePhoto),
      newPrice: newPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(newPrice),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      customerId: serializer.fromJson<int>(json['customerId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      serial: serializer.fromJson<String>(json['serial']),
      purchaseYear: serializer.fromJson<int?>(json['purchaseYear']),
      nameplatePhoto: serializer.fromJson<String?>(json['nameplatePhoto']),
      newPrice: serializer.fromJson<int?>(json['newPrice']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'customerId': serializer.toJson<int>(customerId),
      'categoryId': serializer.toJson<int>(categoryId),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'serial': serializer.toJson<String>(serial),
      'purchaseYear': serializer.toJson<int?>(purchaseYear),
      'nameplatePhoto': serializer.toJson<String?>(nameplatePhoto),
      'newPrice': serializer.toJson<int?>(newPrice),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Device copyWith({
    int? id,
    String? code,
    int? customerId,
    int? categoryId,
    String? brand,
    String? model,
    String? serial,
    Value<int?> purchaseYear = const Value.absent(),
    Value<String?> nameplatePhoto = const Value.absent(),
    Value<int?> newPrice = const Value.absent(),
    String? note,
    DateTime? createdAt,
  }) => Device(
    id: id ?? this.id,
    code: code ?? this.code,
    customerId: customerId ?? this.customerId,
    categoryId: categoryId ?? this.categoryId,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    serial: serial ?? this.serial,
    purchaseYear: purchaseYear.present ? purchaseYear.value : this.purchaseYear,
    nameplatePhoto: nameplatePhoto.present
        ? nameplatePhoto.value
        : this.nameplatePhoto,
    newPrice: newPrice.present ? newPrice.value : this.newPrice,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      serial: data.serial.present ? data.serial.value : this.serial,
      purchaseYear: data.purchaseYear.present
          ? data.purchaseYear.value
          : this.purchaseYear,
      nameplatePhoto: data.nameplatePhoto.present
          ? data.nameplatePhoto.value
          : this.nameplatePhoto,
      newPrice: data.newPrice.present ? data.newPrice.value : this.newPrice,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('customerId: $customerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('serial: $serial, ')
          ..write('purchaseYear: $purchaseYear, ')
          ..write('nameplatePhoto: $nameplatePhoto, ')
          ..write('newPrice: $newPrice, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    customerId,
    categoryId,
    brand,
    model,
    serial,
    purchaseYear,
    nameplatePhoto,
    newPrice,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.code == this.code &&
          other.customerId == this.customerId &&
          other.categoryId == this.categoryId &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.serial == this.serial &&
          other.purchaseYear == this.purchaseYear &&
          other.nameplatePhoto == this.nameplatePhoto &&
          other.newPrice == this.newPrice &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<int> id;
  final Value<String> code;
  final Value<int> customerId;
  final Value<int> categoryId;
  final Value<String> brand;
  final Value<String> model;
  final Value<String> serial;
  final Value<int?> purchaseYear;
  final Value<String?> nameplatePhoto;
  final Value<int?> newPrice;
  final Value<String> note;
  final Value<DateTime> createdAt;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.customerId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.serial = const Value.absent(),
    this.purchaseYear = const Value.absent(),
    this.nameplatePhoto = const Value.absent(),
    this.newPrice = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required int customerId,
    required int categoryId,
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.serial = const Value.absent(),
    this.purchaseYear = const Value.absent(),
    this.nameplatePhoto = const Value.absent(),
    this.newPrice = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : code = Value(code),
       customerId = Value(customerId),
       categoryId = Value(categoryId);
  static Insertable<Device> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<int>? customerId,
    Expression<int>? categoryId,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? serial,
    Expression<int>? purchaseYear,
    Expression<String>? nameplatePhoto,
    Expression<int>? newPrice,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (customerId != null) 'customer_id': customerId,
      if (categoryId != null) 'category_id': categoryId,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (serial != null) 'serial': serial,
      if (purchaseYear != null) 'purchase_year': purchaseYear,
      if (nameplatePhoto != null) 'nameplate_photo': nameplatePhoto,
      if (newPrice != null) 'new_price': newPrice,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DevicesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<int>? customerId,
    Value<int>? categoryId,
    Value<String>? brand,
    Value<String>? model,
    Value<String>? serial,
    Value<int?>? purchaseYear,
    Value<String?>? nameplatePhoto,
    Value<int?>? newPrice,
    Value<String>? note,
    Value<DateTime>? createdAt,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      customerId: customerId ?? this.customerId,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serial: serial ?? this.serial,
      purchaseYear: purchaseYear ?? this.purchaseYear,
      nameplatePhoto: nameplatePhoto ?? this.nameplatePhoto,
      newPrice: newPrice ?? this.newPrice,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (serial.present) {
      map['serial'] = Variable<String>(serial.value);
    }
    if (purchaseYear.present) {
      map['purchase_year'] = Variable<int>(purchaseYear.value);
    }
    if (nameplatePhoto.present) {
      map['nameplate_photo'] = Variable<String>(nameplatePhoto.value);
    }
    if (newPrice.present) {
      map['new_price'] = Variable<int>(newPrice.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('customerId: $customerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('serial: $serial, ')
          ..write('purchaseYear: $purchaseYear, ')
          ..write('nameplatePhoto: $nameplatePhoto, ')
          ..write('newPrice: $newPrice, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RepairCasesTable extends RepairCases
    with TableInfo<$RepairCasesTable, RepairCase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepairCasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<JobType, String> jobType =
      GeneratedColumn<String>(
        'job_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<JobType>($RepairCasesTable.$converterjobType);
  @override
  late final GeneratedColumnWithTypeConverter<CaseStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CaseStatus>($RepairCasesTable.$converterstatus);
  static const VerificationMeta _reportedProblemMeta = const VerificationMeta(
    'reportedProblem',
  );
  @override
  late final GeneratedColumn<String> reportedProblem = GeneratedColumn<String>(
    'reported_problem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _actualFaultMeta = const VerificationMeta(
    'actualFault',
  );
  @override
  late final GeneratedColumn<String> actualFault = GeneratedColumn<String>(
    'actual_fault',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kbRefMeta = const VerificationMeta('kbRef');
  @override
  late final GeneratedColumn<String> kbRef = GeneratedColumn<String>(
    'kb_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _laborMeta = const VerificationMeta('labor');
  @override
  late final GeneratedColumn<int> labor = GeneratedColumn<int>(
    'labor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warrantyDaysMeta = const VerificationMeta(
    'warrantyDays',
  );
  @override
  late final GeneratedColumn<int> warrantyDays = GeneratedColumn<int>(
    'warranty_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _privateNoteMeta = const VerificationMeta(
    'privateNote',
  );
  @override
  late final GeneratedColumn<String> privateNote = GeneratedColumn<String>(
    'private_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _readyAtMeta = const VerificationMeta(
    'readyAt',
  );
  @override
  late final GeneratedColumn<DateTime> readyAt = GeneratedColumn<DateTime>(
    'ready_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> deliveredAt = GeneratedColumn<DateTime>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appointmentAtMeta = const VerificationMeta(
    'appointmentAt',
  );
  @override
  late final GeneratedColumn<DateTime> appointmentAt =
      GeneratedColumn<DateTime>(
        'appointment_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    deviceId,
    customerId,
    jobType,
    status,
    reportedProblem,
    actualFault,
    kbRef,
    labor,
    warrantyDays,
    privateNote,
    receivedAt,
    readyAt,
    deliveredAt,
    appointmentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repair_cases';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepairCase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('reported_problem')) {
      context.handle(
        _reportedProblemMeta,
        reportedProblem.isAcceptableOrUnknown(
          data['reported_problem']!,
          _reportedProblemMeta,
        ),
      );
    }
    if (data.containsKey('actual_fault')) {
      context.handle(
        _actualFaultMeta,
        actualFault.isAcceptableOrUnknown(
          data['actual_fault']!,
          _actualFaultMeta,
        ),
      );
    }
    if (data.containsKey('kb_ref')) {
      context.handle(
        _kbRefMeta,
        kbRef.isAcceptableOrUnknown(data['kb_ref']!, _kbRefMeta),
      );
    }
    if (data.containsKey('labor')) {
      context.handle(
        _laborMeta,
        labor.isAcceptableOrUnknown(data['labor']!, _laborMeta),
      );
    }
    if (data.containsKey('warranty_days')) {
      context.handle(
        _warrantyDaysMeta,
        warrantyDays.isAcceptableOrUnknown(
          data['warranty_days']!,
          _warrantyDaysMeta,
        ),
      );
    }
    if (data.containsKey('private_note')) {
      context.handle(
        _privateNoteMeta,
        privateNote.isAcceptableOrUnknown(
          data['private_note']!,
          _privateNoteMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    }
    if (data.containsKey('ready_at')) {
      context.handle(
        _readyAtMeta,
        readyAt.isAcceptableOrUnknown(data['ready_at']!, _readyAtMeta),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    if (data.containsKey('appointment_at')) {
      context.handle(
        _appointmentAtMeta,
        appointmentAt.isAcceptableOrUnknown(
          data['appointment_at']!,
          _appointmentAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepairCase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepairCase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      jobType: $RepairCasesTable.$converterjobType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}job_type'],
        )!,
      ),
      status: $RepairCasesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      reportedProblem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reported_problem'],
      )!,
      actualFault: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_fault'],
      )!,
      kbRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kb_ref'],
      )!,
      labor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}labor'],
      )!,
      warrantyDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warranty_days'],
      )!,
      privateNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}private_note'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      readyAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ready_at'],
      ),
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivered_at'],
      ),
      appointmentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}appointment_at'],
      ),
    );
  }

  @override
  $RepairCasesTable createAlias(String alias) {
    return $RepairCasesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<JobType, String, String> $converterjobType =
      const EnumNameConverter<JobType>(JobType.values);
  static JsonTypeConverter2<CaseStatus, String, String> $converterstatus =
      const EnumNameConverter<CaseStatus>(CaseStatus.values);
}

class RepairCase extends DataClass implements Insertable<RepairCase> {
  final int id;

  /// کد پرونده، مثل 05-0142 (سال ۱۴۰۵، پرونده‌ی ۱۴۲ام)
  final String code;
  final int deviceId;
  final int customerId;
  final JobType jobType;
  final CaseStatus status;

  /// ایراد از زبان مشتری
  final String reportedProblem;

  /// عیبی که تعمیرکار واقعاً پیدا کرد
  final String actualFault;

  /// شناسه‌ی مورد بانک فنی که به این پرونده وصل شده
  final String kbRef;

  /// اجرت به تومان (قیمت قطعات جداست)
  final int labor;
  final int warrantyDays;

  /// یادداشت فنی که مشتری نمی‌بیند
  final String privateNote;
  final DateTime receivedAt;
  final DateTime? readyAt;
  final DateTime? deliveredAt;

  /// زمان قرار برای کار در محل
  final DateTime? appointmentAt;
  const RepairCase({
    required this.id,
    required this.code,
    required this.deviceId,
    required this.customerId,
    required this.jobType,
    required this.status,
    required this.reportedProblem,
    required this.actualFault,
    required this.kbRef,
    required this.labor,
    required this.warrantyDays,
    required this.privateNote,
    required this.receivedAt,
    this.readyAt,
    this.deliveredAt,
    this.appointmentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['device_id'] = Variable<int>(deviceId);
    map['customer_id'] = Variable<int>(customerId);
    {
      map['job_type'] = Variable<String>(
        $RepairCasesTable.$converterjobType.toSql(jobType),
      );
    }
    {
      map['status'] = Variable<String>(
        $RepairCasesTable.$converterstatus.toSql(status),
      );
    }
    map['reported_problem'] = Variable<String>(reportedProblem);
    map['actual_fault'] = Variable<String>(actualFault);
    map['kb_ref'] = Variable<String>(kbRef);
    map['labor'] = Variable<int>(labor);
    map['warranty_days'] = Variable<int>(warrantyDays);
    map['private_note'] = Variable<String>(privateNote);
    map['received_at'] = Variable<DateTime>(receivedAt);
    if (!nullToAbsent || readyAt != null) {
      map['ready_at'] = Variable<DateTime>(readyAt);
    }
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt);
    }
    if (!nullToAbsent || appointmentAt != null) {
      map['appointment_at'] = Variable<DateTime>(appointmentAt);
    }
    return map;
  }

  RepairCasesCompanion toCompanion(bool nullToAbsent) {
    return RepairCasesCompanion(
      id: Value(id),
      code: Value(code),
      deviceId: Value(deviceId),
      customerId: Value(customerId),
      jobType: Value(jobType),
      status: Value(status),
      reportedProblem: Value(reportedProblem),
      actualFault: Value(actualFault),
      kbRef: Value(kbRef),
      labor: Value(labor),
      warrantyDays: Value(warrantyDays),
      privateNote: Value(privateNote),
      receivedAt: Value(receivedAt),
      readyAt: readyAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readyAt),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      appointmentAt: appointmentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(appointmentAt),
    );
  }

  factory RepairCase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepairCase(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      jobType: $RepairCasesTable.$converterjobType.fromJson(
        serializer.fromJson<String>(json['jobType']),
      ),
      status: $RepairCasesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      reportedProblem: serializer.fromJson<String>(json['reportedProblem']),
      actualFault: serializer.fromJson<String>(json['actualFault']),
      kbRef: serializer.fromJson<String>(json['kbRef']),
      labor: serializer.fromJson<int>(json['labor']),
      warrantyDays: serializer.fromJson<int>(json['warrantyDays']),
      privateNote: serializer.fromJson<String>(json['privateNote']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      readyAt: serializer.fromJson<DateTime?>(json['readyAt']),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
      appointmentAt: serializer.fromJson<DateTime?>(json['appointmentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'deviceId': serializer.toJson<int>(deviceId),
      'customerId': serializer.toJson<int>(customerId),
      'jobType': serializer.toJson<String>(
        $RepairCasesTable.$converterjobType.toJson(jobType),
      ),
      'status': serializer.toJson<String>(
        $RepairCasesTable.$converterstatus.toJson(status),
      ),
      'reportedProblem': serializer.toJson<String>(reportedProblem),
      'actualFault': serializer.toJson<String>(actualFault),
      'kbRef': serializer.toJson<String>(kbRef),
      'labor': serializer.toJson<int>(labor),
      'warrantyDays': serializer.toJson<int>(warrantyDays),
      'privateNote': serializer.toJson<String>(privateNote),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'readyAt': serializer.toJson<DateTime?>(readyAt),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
      'appointmentAt': serializer.toJson<DateTime?>(appointmentAt),
    };
  }

  RepairCase copyWith({
    int? id,
    String? code,
    int? deviceId,
    int? customerId,
    JobType? jobType,
    CaseStatus? status,
    String? reportedProblem,
    String? actualFault,
    String? kbRef,
    int? labor,
    int? warrantyDays,
    String? privateNote,
    DateTime? receivedAt,
    Value<DateTime?> readyAt = const Value.absent(),
    Value<DateTime?> deliveredAt = const Value.absent(),
    Value<DateTime?> appointmentAt = const Value.absent(),
  }) => RepairCase(
    id: id ?? this.id,
    code: code ?? this.code,
    deviceId: deviceId ?? this.deviceId,
    customerId: customerId ?? this.customerId,
    jobType: jobType ?? this.jobType,
    status: status ?? this.status,
    reportedProblem: reportedProblem ?? this.reportedProblem,
    actualFault: actualFault ?? this.actualFault,
    kbRef: kbRef ?? this.kbRef,
    labor: labor ?? this.labor,
    warrantyDays: warrantyDays ?? this.warrantyDays,
    privateNote: privateNote ?? this.privateNote,
    receivedAt: receivedAt ?? this.receivedAt,
    readyAt: readyAt.present ? readyAt.value : this.readyAt,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    appointmentAt: appointmentAt.present
        ? appointmentAt.value
        : this.appointmentAt,
  );
  RepairCase copyWithCompanion(RepairCasesCompanion data) {
    return RepairCase(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      status: data.status.present ? data.status.value : this.status,
      reportedProblem: data.reportedProblem.present
          ? data.reportedProblem.value
          : this.reportedProblem,
      actualFault: data.actualFault.present
          ? data.actualFault.value
          : this.actualFault,
      kbRef: data.kbRef.present ? data.kbRef.value : this.kbRef,
      labor: data.labor.present ? data.labor.value : this.labor,
      warrantyDays: data.warrantyDays.present
          ? data.warrantyDays.value
          : this.warrantyDays,
      privateNote: data.privateNote.present
          ? data.privateNote.value
          : this.privateNote,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      readyAt: data.readyAt.present ? data.readyAt.value : this.readyAt,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      appointmentAt: data.appointmentAt.present
          ? data.appointmentAt.value
          : this.appointmentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepairCase(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('deviceId: $deviceId, ')
          ..write('customerId: $customerId, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('reportedProblem: $reportedProblem, ')
          ..write('actualFault: $actualFault, ')
          ..write('kbRef: $kbRef, ')
          ..write('labor: $labor, ')
          ..write('warrantyDays: $warrantyDays, ')
          ..write('privateNote: $privateNote, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('readyAt: $readyAt, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('appointmentAt: $appointmentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    deviceId,
    customerId,
    jobType,
    status,
    reportedProblem,
    actualFault,
    kbRef,
    labor,
    warrantyDays,
    privateNote,
    receivedAt,
    readyAt,
    deliveredAt,
    appointmentAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepairCase &&
          other.id == this.id &&
          other.code == this.code &&
          other.deviceId == this.deviceId &&
          other.customerId == this.customerId &&
          other.jobType == this.jobType &&
          other.status == this.status &&
          other.reportedProblem == this.reportedProblem &&
          other.actualFault == this.actualFault &&
          other.kbRef == this.kbRef &&
          other.labor == this.labor &&
          other.warrantyDays == this.warrantyDays &&
          other.privateNote == this.privateNote &&
          other.receivedAt == this.receivedAt &&
          other.readyAt == this.readyAt &&
          other.deliveredAt == this.deliveredAt &&
          other.appointmentAt == this.appointmentAt);
}

class RepairCasesCompanion extends UpdateCompanion<RepairCase> {
  final Value<int> id;
  final Value<String> code;
  final Value<int> deviceId;
  final Value<int> customerId;
  final Value<JobType> jobType;
  final Value<CaseStatus> status;
  final Value<String> reportedProblem;
  final Value<String> actualFault;
  final Value<String> kbRef;
  final Value<int> labor;
  final Value<int> warrantyDays;
  final Value<String> privateNote;
  final Value<DateTime> receivedAt;
  final Value<DateTime?> readyAt;
  final Value<DateTime?> deliveredAt;
  final Value<DateTime?> appointmentAt;
  const RepairCasesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.jobType = const Value.absent(),
    this.status = const Value.absent(),
    this.reportedProblem = const Value.absent(),
    this.actualFault = const Value.absent(),
    this.kbRef = const Value.absent(),
    this.labor = const Value.absent(),
    this.warrantyDays = const Value.absent(),
    this.privateNote = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.readyAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.appointmentAt = const Value.absent(),
  });
  RepairCasesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required int deviceId,
    required int customerId,
    required JobType jobType,
    required CaseStatus status,
    this.reportedProblem = const Value.absent(),
    this.actualFault = const Value.absent(),
    this.kbRef = const Value.absent(),
    this.labor = const Value.absent(),
    this.warrantyDays = const Value.absent(),
    this.privateNote = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.readyAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.appointmentAt = const Value.absent(),
  }) : code = Value(code),
       deviceId = Value(deviceId),
       customerId = Value(customerId),
       jobType = Value(jobType),
       status = Value(status);
  static Insertable<RepairCase> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<int>? deviceId,
    Expression<int>? customerId,
    Expression<String>? jobType,
    Expression<String>? status,
    Expression<String>? reportedProblem,
    Expression<String>? actualFault,
    Expression<String>? kbRef,
    Expression<int>? labor,
    Expression<int>? warrantyDays,
    Expression<String>? privateNote,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? readyAt,
    Expression<DateTime>? deliveredAt,
    Expression<DateTime>? appointmentAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (deviceId != null) 'device_id': deviceId,
      if (customerId != null) 'customer_id': customerId,
      if (jobType != null) 'job_type': jobType,
      if (status != null) 'status': status,
      if (reportedProblem != null) 'reported_problem': reportedProblem,
      if (actualFault != null) 'actual_fault': actualFault,
      if (kbRef != null) 'kb_ref': kbRef,
      if (labor != null) 'labor': labor,
      if (warrantyDays != null) 'warranty_days': warrantyDays,
      if (privateNote != null) 'private_note': privateNote,
      if (receivedAt != null) 'received_at': receivedAt,
      if (readyAt != null) 'ready_at': readyAt,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (appointmentAt != null) 'appointment_at': appointmentAt,
    });
  }

  RepairCasesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<int>? deviceId,
    Value<int>? customerId,
    Value<JobType>? jobType,
    Value<CaseStatus>? status,
    Value<String>? reportedProblem,
    Value<String>? actualFault,
    Value<String>? kbRef,
    Value<int>? labor,
    Value<int>? warrantyDays,
    Value<String>? privateNote,
    Value<DateTime>? receivedAt,
    Value<DateTime?>? readyAt,
    Value<DateTime?>? deliveredAt,
    Value<DateTime?>? appointmentAt,
  }) {
    return RepairCasesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      deviceId: deviceId ?? this.deviceId,
      customerId: customerId ?? this.customerId,
      jobType: jobType ?? this.jobType,
      status: status ?? this.status,
      reportedProblem: reportedProblem ?? this.reportedProblem,
      actualFault: actualFault ?? this.actualFault,
      kbRef: kbRef ?? this.kbRef,
      labor: labor ?? this.labor,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      privateNote: privateNote ?? this.privateNote,
      receivedAt: receivedAt ?? this.receivedAt,
      readyAt: readyAt ?? this.readyAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      appointmentAt: appointmentAt ?? this.appointmentAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(
        $RepairCasesTable.$converterjobType.toSql(jobType.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RepairCasesTable.$converterstatus.toSql(status.value),
      );
    }
    if (reportedProblem.present) {
      map['reported_problem'] = Variable<String>(reportedProblem.value);
    }
    if (actualFault.present) {
      map['actual_fault'] = Variable<String>(actualFault.value);
    }
    if (kbRef.present) {
      map['kb_ref'] = Variable<String>(kbRef.value);
    }
    if (labor.present) {
      map['labor'] = Variable<int>(labor.value);
    }
    if (warrantyDays.present) {
      map['warranty_days'] = Variable<int>(warrantyDays.value);
    }
    if (privateNote.present) {
      map['private_note'] = Variable<String>(privateNote.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (readyAt.present) {
      map['ready_at'] = Variable<DateTime>(readyAt.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt.value);
    }
    if (appointmentAt.present) {
      map['appointment_at'] = Variable<DateTime>(appointmentAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepairCasesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('deviceId: $deviceId, ')
          ..write('customerId: $customerId, ')
          ..write('jobType: $jobType, ')
          ..write('status: $status, ')
          ..write('reportedProblem: $reportedProblem, ')
          ..write('actualFault: $actualFault, ')
          ..write('kbRef: $kbRef, ')
          ..write('labor: $labor, ')
          ..write('warrantyDays: $warrantyDays, ')
          ..write('privateNote: $privateNote, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('readyAt: $readyAt, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('appointmentAt: $appointmentAt')
          ..write(')'))
        .toString();
  }
}

class $CasePartsTable extends CaseParts
    with TableInfo<$CasePartsTable, CasePart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CasePartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<int> caseId = GeneratedColumn<int>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<int> unitPrice = GeneratedColumn<int>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, caseId, name, qty, unitPrice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CasePart> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CasePart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CasePart(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}case_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price'],
      )!,
    );
  }

  @override
  $CasePartsTable createAlias(String alias) {
    return $CasePartsTable(attachedDatabase, alias);
  }
}

class CasePart extends DataClass implements Insertable<CasePart> {
  final int id;
  final int caseId;
  final String name;
  final int qty;

  /// قیمت واحد به تومان
  final int unitPrice;
  const CasePart({
    required this.id,
    required this.caseId,
    required this.name,
    required this.qty,
    required this.unitPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['case_id'] = Variable<int>(caseId);
    map['name'] = Variable<String>(name);
    map['qty'] = Variable<int>(qty);
    map['unit_price'] = Variable<int>(unitPrice);
    return map;
  }

  CasePartsCompanion toCompanion(bool nullToAbsent) {
    return CasePartsCompanion(
      id: Value(id),
      caseId: Value(caseId),
      name: Value(name),
      qty: Value(qty),
      unitPrice: Value(unitPrice),
    );
  }

  factory CasePart.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CasePart(
      id: serializer.fromJson<int>(json['id']),
      caseId: serializer.fromJson<int>(json['caseId']),
      name: serializer.fromJson<String>(json['name']),
      qty: serializer.fromJson<int>(json['qty']),
      unitPrice: serializer.fromJson<int>(json['unitPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'caseId': serializer.toJson<int>(caseId),
      'name': serializer.toJson<String>(name),
      'qty': serializer.toJson<int>(qty),
      'unitPrice': serializer.toJson<int>(unitPrice),
    };
  }

  CasePart copyWith({
    int? id,
    int? caseId,
    String? name,
    int? qty,
    int? unitPrice,
  }) => CasePart(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    name: name ?? this.name,
    qty: qty ?? this.qty,
    unitPrice: unitPrice ?? this.unitPrice,
  );
  CasePart copyWithCompanion(CasePartsCompanion data) {
    return CasePart(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      name: data.name.present ? data.name.value : this.name,
      qty: data.qty.present ? data.qty.value : this.qty,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CasePart(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('unitPrice: $unitPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, caseId, name, qty, unitPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CasePart &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.name == this.name &&
          other.qty == this.qty &&
          other.unitPrice == this.unitPrice);
}

class CasePartsCompanion extends UpdateCompanion<CasePart> {
  final Value<int> id;
  final Value<int> caseId;
  final Value<String> name;
  final Value<int> qty;
  final Value<int> unitPrice;
  const CasePartsCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.name = const Value.absent(),
    this.qty = const Value.absent(),
    this.unitPrice = const Value.absent(),
  });
  CasePartsCompanion.insert({
    this.id = const Value.absent(),
    required int caseId,
    required String name,
    this.qty = const Value.absent(),
    this.unitPrice = const Value.absent(),
  }) : caseId = Value(caseId),
       name = Value(name);
  static Insertable<CasePart> custom({
    Expression<int>? id,
    Expression<int>? caseId,
    Expression<String>? name,
    Expression<int>? qty,
    Expression<int>? unitPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (name != null) 'name': name,
      if (qty != null) 'qty': qty,
      if (unitPrice != null) 'unit_price': unitPrice,
    });
  }

  CasePartsCompanion copyWith({
    Value<int>? id,
    Value<int>? caseId,
    Value<String>? name,
    Value<int>? qty,
    Value<int>? unitPrice,
  }) {
    return CasePartsCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<int>(caseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<int>(unitPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CasePartsCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('unitPrice: $unitPrice')
          ..write(')'))
        .toString();
  }
}

class $CasePhotosTable extends CasePhotos
    with TableInfo<$CasePhotosTable, CasePhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CasePhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<int> caseId = GeneratedColumn<int>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PhotoKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PhotoKind>($CasePhotosTable.$converterkind);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, caseId, path, kind, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'case_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CasePhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CasePhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CasePhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}case_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      kind: $CasePhotosTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CasePhotosTable createAlias(String alias) {
    return $CasePhotosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PhotoKind, String, String> $converterkind =
      const EnumNameConverter<PhotoKind>(PhotoKind.values);
}

class CasePhoto extends DataClass implements Insertable<CasePhoto> {
  final int id;
  final int caseId;
  final String path;
  final PhotoKind kind;
  final DateTime createdAt;
  const CasePhoto({
    required this.id,
    required this.caseId,
    required this.path,
    required this.kind,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['case_id'] = Variable<int>(caseId);
    map['path'] = Variable<String>(path);
    {
      map['kind'] = Variable<String>(
        $CasePhotosTable.$converterkind.toSql(kind),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CasePhotosCompanion toCompanion(bool nullToAbsent) {
    return CasePhotosCompanion(
      id: Value(id),
      caseId: Value(caseId),
      path: Value(path),
      kind: Value(kind),
      createdAt: Value(createdAt),
    );
  }

  factory CasePhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CasePhoto(
      id: serializer.fromJson<int>(json['id']),
      caseId: serializer.fromJson<int>(json['caseId']),
      path: serializer.fromJson<String>(json['path']),
      kind: $CasePhotosTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'caseId': serializer.toJson<int>(caseId),
      'path': serializer.toJson<String>(path),
      'kind': serializer.toJson<String>(
        $CasePhotosTable.$converterkind.toJson(kind),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CasePhoto copyWith({
    int? id,
    int? caseId,
    String? path,
    PhotoKind? kind,
    DateTime? createdAt,
  }) => CasePhoto(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    path: path ?? this.path,
    kind: kind ?? this.kind,
    createdAt: createdAt ?? this.createdAt,
  );
  CasePhoto copyWithCompanion(CasePhotosCompanion data) {
    return CasePhoto(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      path: data.path.present ? data.path.value : this.path,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CasePhoto(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('path: $path, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, caseId, path, kind, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CasePhoto &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.path == this.path &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt);
}

class CasePhotosCompanion extends UpdateCompanion<CasePhoto> {
  final Value<int> id;
  final Value<int> caseId;
  final Value<String> path;
  final Value<PhotoKind> kind;
  final Value<DateTime> createdAt;
  const CasePhotosCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.path = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CasePhotosCompanion.insert({
    this.id = const Value.absent(),
    required int caseId,
    required String path,
    required PhotoKind kind,
    this.createdAt = const Value.absent(),
  }) : caseId = Value(caseId),
       path = Value(path),
       kind = Value(kind);
  static Insertable<CasePhoto> custom({
    Expression<int>? id,
    Expression<int>? caseId,
    Expression<String>? path,
    Expression<String>? kind,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (path != null) 'path': path,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CasePhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? caseId,
    Value<String>? path,
    Value<PhotoKind>? kind,
    Value<DateTime>? createdAt,
  }) {
    return CasePhotosCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      path: path ?? this.path,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<int>(caseId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CasePhotosTable.$converterkind.toSql(kind.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CasePhotosCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('path: $path, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StatusEventsTable extends StatusEvents
    with TableInfo<$StatusEventsTable, StatusEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatusEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<int> caseId = GeneratedColumn<int>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CaseStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CaseStatus>($StatusEventsTable.$converterstatus);
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, caseId, status, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'status_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatusEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatusEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatusEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}case_id'],
      )!,
      status: $StatusEventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $StatusEventsTable createAlias(String alias) {
    return $StatusEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CaseStatus, String, String> $converterstatus =
      const EnumNameConverter<CaseStatus>(CaseStatus.values);
}

class StatusEvent extends DataClass implements Insertable<StatusEvent> {
  final int id;
  final int caseId;
  final CaseStatus status;
  final DateTime at;
  const StatusEvent({
    required this.id,
    required this.caseId,
    required this.status,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['case_id'] = Variable<int>(caseId);
    {
      map['status'] = Variable<String>(
        $StatusEventsTable.$converterstatus.toSql(status),
      );
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  StatusEventsCompanion toCompanion(bool nullToAbsent) {
    return StatusEventsCompanion(
      id: Value(id),
      caseId: Value(caseId),
      status: Value(status),
      at: Value(at),
    );
  }

  factory StatusEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatusEvent(
      id: serializer.fromJson<int>(json['id']),
      caseId: serializer.fromJson<int>(json['caseId']),
      status: $StatusEventsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'caseId': serializer.toJson<int>(caseId),
      'status': serializer.toJson<String>(
        $StatusEventsTable.$converterstatus.toJson(status),
      ),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  StatusEvent copyWith({
    int? id,
    int? caseId,
    CaseStatus? status,
    DateTime? at,
  }) => StatusEvent(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    status: status ?? this.status,
    at: at ?? this.at,
  );
  StatusEvent copyWithCompanion(StatusEventsCompanion data) {
    return StatusEvent(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      status: data.status.present ? data.status.value : this.status,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatusEvent(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('status: $status, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, caseId, status, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusEvent &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.status == this.status &&
          other.at == this.at);
}

class StatusEventsCompanion extends UpdateCompanion<StatusEvent> {
  final Value<int> id;
  final Value<int> caseId;
  final Value<CaseStatus> status;
  final Value<DateTime> at;
  const StatusEventsCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.status = const Value.absent(),
    this.at = const Value.absent(),
  });
  StatusEventsCompanion.insert({
    this.id = const Value.absent(),
    required int caseId,
    required CaseStatus status,
    this.at = const Value.absent(),
  }) : caseId = Value(caseId),
       status = Value(status);
  static Insertable<StatusEvent> custom({
    Expression<int>? id,
    Expression<int>? caseId,
    Expression<String>? status,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (status != null) 'status': status,
      if (at != null) 'at': at,
    });
  }

  StatusEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? caseId,
    Value<CaseStatus>? status,
    Value<DateTime>? at,
  }) {
    return StatusEventsCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      status: status ?? this.status,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<int>(caseId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $StatusEventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatusEventsCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('status: $status, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $CountersTable extends Counters
    with TableInfo<$CountersTable, CounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentMeta = const VerificationMeta(
    'current',
  );
  @override
  late final GeneratedColumn<int> current = GeneratedColumn<int>(
    'current',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, current];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CounterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('current')) {
      context.handle(
        _currentMeta,
        current.isAcceptableOrUnknown(data['current']!, _currentMeta),
      );
    } else if (isInserting) {
      context.missing(_currentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  CounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CounterRow(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      current: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current'],
      )!,
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }
}

class CounterRow extends DataClass implements Insertable<CounterRow> {
  final String name;
  final int current;
  const CounterRow({required this.name, required this.current});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['current'] = Variable<int>(current);
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(name: Value(name), current: Value(current));
  }

  factory CounterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CounterRow(
      name: serializer.fromJson<String>(json['name']),
      current: serializer.fromJson<int>(json['current']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'current': serializer.toJson<int>(current),
    };
  }

  CounterRow copyWith({String? name, int? current}) =>
      CounterRow(name: name ?? this.name, current: current ?? this.current);
  CounterRow copyWithCompanion(CountersCompanion data) {
    return CounterRow(
      name: data.name.present ? data.name.value : this.name,
      current: data.current.present ? data.current.value : this.current,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CounterRow(')
          ..write('name: $name, ')
          ..write('current: $current')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, current);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CounterRow &&
          other.name == this.name &&
          other.current == this.current);
}

class CountersCompanion extends UpdateCompanion<CounterRow> {
  final Value<String> name;
  final Value<int> current;
  final Value<int> rowid;
  const CountersCompanion({
    this.name = const Value.absent(),
    this.current = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountersCompanion.insert({
    required String name,
    required int current,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       current = Value(current);
  static Insertable<CounterRow> custom({
    Expression<String>? name,
    Expression<int>? current,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (current != null) 'current': current,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountersCompanion copyWith({
    Value<String>? name,
    Value<int>? current,
    Value<int>? rowid,
  }) {
    return CountersCompanion(
      name: name ?? this.name,
      current: current ?? this.current,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (current.present) {
      map['current'] = Variable<int>(current.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('name: $name, ')
          ..write('current: $current, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String name;
  final String content;
  const AppSetting({required this.name, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(name: Value(name), content: Value(content));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
    };
  }

  AppSetting copyWith({String? name, String? content}) =>
      AppSetting(name: name ?? this.name, content: content ?? this.content);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('name: $name, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.name == this.name &&
          other.content == this.content);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> name;
  final Value<String> content;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String name,
    required String content,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       content = Value(content);
  static Insertable<AppSetting> custom({
    Expression<String>? name,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? name,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      name: name ?? this.name,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KbNotesTable extends KbNotes with TableInfo<$KbNotesTable, KbNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KbNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, entryId, body, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kb_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<KbNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KbNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KbNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KbNotesTable createAlias(String alias) {
    return $KbNotesTable(attachedDatabase, alias);
  }
}

class KbNote extends DataClass implements Insertable<KbNote> {
  final int id;
  final String entryId;
  final String body;
  final DateTime updatedAt;
  const KbNote({
    required this.id,
    required this.entryId,
    required this.body,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['body'] = Variable<String>(body);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  KbNotesCompanion toCompanion(bool nullToAbsent) {
    return KbNotesCompanion(
      id: Value(id),
      entryId: Value(entryId),
      body: Value(body),
      updatedAt: Value(updatedAt),
    );
  }

  factory KbNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KbNote(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      body: serializer.fromJson<String>(json['body']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<String>(entryId),
      'body': serializer.toJson<String>(body),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  KbNote copyWith({
    int? id,
    String? entryId,
    String? body,
    DateTime? updatedAt,
  }) => KbNote(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    body: body ?? this.body,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KbNote copyWithCompanion(KbNotesCompanion data) {
    return KbNote(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      body: data.body.present ? data.body.value : this.body,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KbNote(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('body: $body, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entryId, body, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KbNote &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.body == this.body &&
          other.updatedAt == this.updatedAt);
}

class KbNotesCompanion extends UpdateCompanion<KbNote> {
  final Value<int> id;
  final Value<String> entryId;
  final Value<String> body;
  final Value<DateTime> updatedAt;
  const KbNotesCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.body = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  KbNotesCompanion.insert({
    this.id = const Value.absent(),
    required String entryId,
    required String body,
    this.updatedAt = const Value.absent(),
  }) : entryId = Value(entryId),
       body = Value(body);
  static Insertable<KbNote> custom({
    Expression<int>? id,
    Expression<String>? entryId,
    Expression<String>? body,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (body != null) 'body': body,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  KbNotesCompanion copyWith({
    Value<int>? id,
    Value<String>? entryId,
    Value<String>? body,
    Value<DateTime>? updatedAt,
  }) {
    return KbNotesCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KbNotesCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('body: $body, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PartEquivalentsTable extends PartEquivalents
    with TableInfo<$PartEquivalentsTable, PartEquivalent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartEquivalentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _partNameMeta = const VerificationMeta(
    'partName',
  );
  @override
  late final GeneratedColumn<String> partName = GeneratedColumn<String>(
    'part_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equivalentMeta = const VerificationMeta(
    'equivalent',
  );
  @override
  late final GeneratedColumn<String> equivalent = GeneratedColumn<String>(
    'equivalent',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    partName,
    equivalent,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'part_equivalents';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartEquivalent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('part_name')) {
      context.handle(
        _partNameMeta,
        partName.isAcceptableOrUnknown(data['part_name']!, _partNameMeta),
      );
    } else if (isInserting) {
      context.missing(_partNameMeta);
    }
    if (data.containsKey('equivalent')) {
      context.handle(
        _equivalentMeta,
        equivalent.isAcceptableOrUnknown(data['equivalent']!, _equivalentMeta),
      );
    } else if (isInserting) {
      context.missing(_equivalentMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartEquivalent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartEquivalent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      partName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_name'],
      )!,
      equivalent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equivalent'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PartEquivalentsTable createAlias(String alias) {
    return $PartEquivalentsTable(attachedDatabase, alias);
  }
}

class PartEquivalent extends DataClass implements Insertable<PartEquivalent> {
  final int id;
  final String partName;
  final String equivalent;
  final String note;
  final DateTime createdAt;
  const PartEquivalent({
    required this.id,
    required this.partName,
    required this.equivalent,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['part_name'] = Variable<String>(partName);
    map['equivalent'] = Variable<String>(equivalent);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PartEquivalentsCompanion toCompanion(bool nullToAbsent) {
    return PartEquivalentsCompanion(
      id: Value(id),
      partName: Value(partName),
      equivalent: Value(equivalent),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory PartEquivalent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartEquivalent(
      id: serializer.fromJson<int>(json['id']),
      partName: serializer.fromJson<String>(json['partName']),
      equivalent: serializer.fromJson<String>(json['equivalent']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partName': serializer.toJson<String>(partName),
      'equivalent': serializer.toJson<String>(equivalent),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PartEquivalent copyWith({
    int? id,
    String? partName,
    String? equivalent,
    String? note,
    DateTime? createdAt,
  }) => PartEquivalent(
    id: id ?? this.id,
    partName: partName ?? this.partName,
    equivalent: equivalent ?? this.equivalent,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  PartEquivalent copyWithCompanion(PartEquivalentsCompanion data) {
    return PartEquivalent(
      id: data.id.present ? data.id.value : this.id,
      partName: data.partName.present ? data.partName.value : this.partName,
      equivalent: data.equivalent.present
          ? data.equivalent.value
          : this.equivalent,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartEquivalent(')
          ..write('id: $id, ')
          ..write('partName: $partName, ')
          ..write('equivalent: $equivalent, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, partName, equivalent, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartEquivalent &&
          other.id == this.id &&
          other.partName == this.partName &&
          other.equivalent == this.equivalent &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class PartEquivalentsCompanion extends UpdateCompanion<PartEquivalent> {
  final Value<int> id;
  final Value<String> partName;
  final Value<String> equivalent;
  final Value<String> note;
  final Value<DateTime> createdAt;
  const PartEquivalentsCompanion({
    this.id = const Value.absent(),
    this.partName = const Value.absent(),
    this.equivalent = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PartEquivalentsCompanion.insert({
    this.id = const Value.absent(),
    required String partName,
    required String equivalent,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : partName = Value(partName),
       equivalent = Value(equivalent);
  static Insertable<PartEquivalent> custom({
    Expression<int>? id,
    Expression<String>? partName,
    Expression<String>? equivalent,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partName != null) 'part_name': partName,
      if (equivalent != null) 'equivalent': equivalent,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PartEquivalentsCompanion copyWith({
    Value<int>? id,
    Value<String>? partName,
    Value<String>? equivalent,
    Value<String>? note,
    Value<DateTime>? createdAt,
  }) {
    return PartEquivalentsCompanion(
      id: id ?? this.id,
      partName: partName ?? this.partName,
      equivalent: equivalent ?? this.equivalent,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partName.present) {
      map['part_name'] = Variable<String>(partName.value);
    }
    if (equivalent.present) {
      map['equivalent'] = Variable<String>(equivalent.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartEquivalentsCompanion(')
          ..write('id: $id, ')
          ..write('partName: $partName, ')
          ..write('equivalent: $equivalent, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<int> caseId = GeneratedColumn<int>(
    'case_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, caseId, amount, note, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('case_id')) {
      context.handle(
        _caseIdMeta,
        caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      caseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}case_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int caseId;

  /// مبلغ به تومان
  final int amount;
  final String note;
  final DateTime at;
  const Payment({
    required this.id,
    required this.caseId,
    required this.amount,
    required this.note,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['case_id'] = Variable<int>(caseId);
    map['amount'] = Variable<int>(amount);
    map['note'] = Variable<String>(note);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      caseId: Value(caseId),
      amount: Value(amount),
      note: Value(note),
      at: Value(at),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      caseId: serializer.fromJson<int>(json['caseId']),
      amount: serializer.fromJson<int>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'caseId': serializer.toJson<int>(caseId),
      'amount': serializer.toJson<int>(amount),
      'note': serializer.toJson<String>(note),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  Payment copyWith({
    int? id,
    int? caseId,
    int? amount,
    String? note,
    DateTime? at,
  }) => Payment(
    id: id ?? this.id,
    caseId: caseId ?? this.caseId,
    amount: amount ?? this.amount,
    note: note ?? this.note,
    at: at ?? this.at,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, caseId, amount, note, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.at == this.at);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> caseId;
  final Value<int> amount;
  final Value<String> note;
  final Value<DateTime> at;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.at = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int caseId,
    required int amount,
    this.note = const Value.absent(),
    this.at = const Value.absent(),
  }) : caseId = Value(caseId),
       amount = Value(amount);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? caseId,
    Expression<int>? amount,
    Expression<String>? note,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (at != null) 'at': at,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? caseId,
    Value<int>? amount,
    Value<String>? note,
    Value<DateTime>? at,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<int>(caseId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $PriceItemsTable extends PriceItems
    with TableInfo<$PriceItemsTable, PriceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPartMeta = const VerificationMeta('isPart');
  @override
  late final GeneratedColumn<bool> isPart = GeneratedColumn<bool>(
    'is_part',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_part" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, price, isPart];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('is_part')) {
      context.handle(
        _isPartMeta,
        isPart.isAcceptableOrUnknown(data['is_part']!, _isPartMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PriceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      isPart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_part'],
      )!,
    );
  }

  @override
  $PriceItemsTable createAlias(String alias) {
    return $PriceItemsTable(attachedDatabase, alias);
  }
}

class PriceItem extends DataClass implements Insertable<PriceItem> {
  final int id;
  final String name;

  /// قیمت به تومان
  final int price;

  /// true یعنی قطعه است (به فهرست قطعات اضافه می‌شود)، false یعنی اجرت
  final bool isPart;
  const PriceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isPart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<int>(price);
    map['is_part'] = Variable<bool>(isPart);
    return map;
  }

  PriceItemsCompanion toCompanion(bool nullToAbsent) {
    return PriceItemsCompanion(
      id: Value(id),
      name: Value(name),
      price: Value(price),
      isPart: Value(isPart),
    );
  }

  factory PriceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceItem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<int>(json['price']),
      isPart: serializer.fromJson<bool>(json['isPart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<int>(price),
      'isPart': serializer.toJson<bool>(isPart),
    };
  }

  PriceItem copyWith({int? id, String? name, int? price, bool? isPart}) =>
      PriceItem(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        isPart: isPart ?? this.isPart,
      );
  PriceItem copyWithCompanion(PriceItemsCompanion data) {
    return PriceItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      isPart: data.isPart.present ? data.isPart.value : this.isPart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('isPart: $isPart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, price, isPart);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.isPart == this.isPart);
}

class PriceItemsCompanion extends UpdateCompanion<PriceItem> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> price;
  final Value<bool> isPart;
  const PriceItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.isPart = const Value.absent(),
  });
  PriceItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.price = const Value.absent(),
    this.isPart = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PriceItem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? price,
    Expression<bool>? isPart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (isPart != null) 'is_part': isPart,
    });
  }

  PriceItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? price,
    Value<bool>? isPart,
  }) {
    return PriceItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isPart: isPart ?? this.isPart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (isPart.present) {
      map['is_part'] = Variable<bool>(isPart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('isPart: $isPart')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $RepairCasesTable repairCases = $RepairCasesTable(this);
  late final $CasePartsTable caseParts = $CasePartsTable(this);
  late final $CasePhotosTable casePhotos = $CasePhotosTable(this);
  late final $StatusEventsTable statusEvents = $StatusEventsTable(this);
  late final $CountersTable counters = $CountersTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $KbNotesTable kbNotes = $KbNotesTable(this);
  late final $PartEquivalentsTable partEquivalents = $PartEquivalentsTable(
    this,
  );
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PriceItemsTable priceItems = $PriceItemsTable(this);
  late final Index customersPhone = Index(
    'customers_phone',
    'CREATE INDEX customers_phone ON customers (phone)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    customers,
    devices,
    repairCases,
    caseParts,
    casePhotos,
    statusEvents,
    counters,
    appSettings,
    kbNotes,
    partEquivalents,
    payments,
    priceItems,
    customersPhone,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String prefix,
      Value<String> icon,
      Value<int> sortOrder,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> prefix,
      Value<String> icon,
      Value<int> sortOrder,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prefix => $composableBuilder(
    column: $table.prefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prefix => $composableBuilder(
    column: $table.prefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get prefix =>
      $composableBuilder(column: $table.prefix, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          DeviceCategory,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            DeviceCategory,
            BaseReferences<_$AppDatabase, $CategoriesTable, DeviceCategory>,
          ),
          DeviceCategory,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> prefix = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                prefix: prefix,
                icon: icon,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String prefix,
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                prefix: prefix,
                icon: icon,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      DeviceCategory,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        DeviceCategory,
        BaseReferences<_$AppDatabase, $CategoriesTable, DeviceCategory>,
      ),
      DeviceCategory,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required String name,
      Value<String> phone,
      Value<String> phone2,
      Value<String> address,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> note,
      Value<DateTime> createdAt,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> phone,
      Value<String> phone2,
      Value<String> address,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> note,
      Value<DateTime> createdAt,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone2 => $composableBuilder(
    column: $table.phone2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone2 => $composableBuilder(
    column: $table.phone2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get phone2 =>
      $composableBuilder(column: $table.phone2, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> phone2 = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                phone2: phone2,
                address: address,
                latitude: latitude,
                longitude: longitude,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> phone = const Value.absent(),
                Value<String> phone2 = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                phone2: phone2,
                address: address,
                latitude: latitude,
                longitude: longitude,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      Value<int> id,
      required String code,
      required int customerId,
      required int categoryId,
      Value<String> brand,
      Value<String> model,
      Value<String> serial,
      Value<int?> purchaseYear,
      Value<String?> nameplatePhoto,
      Value<int?> newPrice,
      Value<String> note,
      Value<DateTime> createdAt,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<int> customerId,
      Value<int> categoryId,
      Value<String> brand,
      Value<String> model,
      Value<String> serial,
      Value<int?> purchaseYear,
      Value<String?> nameplatePhoto,
      Value<int?> newPrice,
      Value<String> note,
      Value<DateTime> createdAt,
    });

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchaseYear => $composableBuilder(
    column: $table.purchaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameplatePhoto => $composableBuilder(
    column: $table.nameplatePhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newPrice => $composableBuilder(
    column: $table.newPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchaseYear => $composableBuilder(
    column: $table.purchaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameplatePhoto => $composableBuilder(
    column: $table.nameplatePhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newPrice => $composableBuilder(
    column: $table.newPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<int> get purchaseYear => $composableBuilder(
    column: $table.purchaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameplatePhoto => $composableBuilder(
    column: $table.nameplatePhoto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newPrice =>
      $composableBuilder(column: $table.newPrice, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
          Device,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> serial = const Value.absent(),
                Value<int?> purchaseYear = const Value.absent(),
                Value<String?> nameplatePhoto = const Value.absent(),
                Value<int?> newPrice = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                code: code,
                customerId: customerId,
                categoryId: categoryId,
                brand: brand,
                model: model,
                serial: serial,
                purchaseYear: purchaseYear,
                nameplatePhoto: nameplatePhoto,
                newPrice: newPrice,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required int customerId,
                required int categoryId,
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> serial = const Value.absent(),
                Value<int?> purchaseYear = const Value.absent(),
                Value<String?> nameplatePhoto = const Value.absent(),
                Value<int?> newPrice = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                code: code,
                customerId: customerId,
                categoryId: categoryId,
                brand: brand,
                model: model,
                serial: serial,
                purchaseYear: purchaseYear,
                nameplatePhoto: nameplatePhoto,
                newPrice: newPrice,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, BaseReferences<_$AppDatabase, $DevicesTable, Device>),
      Device,
      PrefetchHooks Function()
    >;
typedef $$RepairCasesTableCreateCompanionBuilder =
    RepairCasesCompanion Function({
      Value<int> id,
      required String code,
      required int deviceId,
      required int customerId,
      required JobType jobType,
      required CaseStatus status,
      Value<String> reportedProblem,
      Value<String> actualFault,
      Value<String> kbRef,
      Value<int> labor,
      Value<int> warrantyDays,
      Value<String> privateNote,
      Value<DateTime> receivedAt,
      Value<DateTime?> readyAt,
      Value<DateTime?> deliveredAt,
      Value<DateTime?> appointmentAt,
    });
typedef $$RepairCasesTableUpdateCompanionBuilder =
    RepairCasesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<int> deviceId,
      Value<int> customerId,
      Value<JobType> jobType,
      Value<CaseStatus> status,
      Value<String> reportedProblem,
      Value<String> actualFault,
      Value<String> kbRef,
      Value<int> labor,
      Value<int> warrantyDays,
      Value<String> privateNote,
      Value<DateTime> receivedAt,
      Value<DateTime?> readyAt,
      Value<DateTime?> deliveredAt,
      Value<DateTime?> appointmentAt,
    });

class $$RepairCasesTableFilterComposer
    extends Composer<_$AppDatabase, $RepairCasesTable> {
  $$RepairCasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<JobType, JobType, String> get jobType =>
      $composableBuilder(
        column: $table.jobType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CaseStatus, CaseStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get reportedProblem => $composableBuilder(
    column: $table.reportedProblem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualFault => $composableBuilder(
    column: $table.actualFault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kbRef => $composableBuilder(
    column: $table.kbRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get labor => $composableBuilder(
    column: $table.labor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warrantyDays => $composableBuilder(
    column: $table.warrantyDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get privateNote => $composableBuilder(
    column: $table.privateNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readyAt => $composableBuilder(
    column: $table.readyAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appointmentAt => $composableBuilder(
    column: $table.appointmentAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RepairCasesTableOrderingComposer
    extends Composer<_$AppDatabase, $RepairCasesTable> {
  $$RepairCasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportedProblem => $composableBuilder(
    column: $table.reportedProblem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualFault => $composableBuilder(
    column: $table.actualFault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kbRef => $composableBuilder(
    column: $table.kbRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get labor => $composableBuilder(
    column: $table.labor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warrantyDays => $composableBuilder(
    column: $table.warrantyDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get privateNote => $composableBuilder(
    column: $table.privateNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readyAt => $composableBuilder(
    column: $table.readyAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appointmentAt => $composableBuilder(
    column: $table.appointmentAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RepairCasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepairCasesTable> {
  $$RepairCasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<JobType, String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CaseStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reportedProblem => $composableBuilder(
    column: $table.reportedProblem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actualFault => $composableBuilder(
    column: $table.actualFault,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kbRef =>
      $composableBuilder(column: $table.kbRef, builder: (column) => column);

  GeneratedColumn<int> get labor =>
      $composableBuilder(column: $table.labor, builder: (column) => column);

  GeneratedColumn<int> get warrantyDays => $composableBuilder(
    column: $table.warrantyDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get privateNote => $composableBuilder(
    column: $table.privateNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readyAt =>
      $composableBuilder(column: $table.readyAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get appointmentAt => $composableBuilder(
    column: $table.appointmentAt,
    builder: (column) => column,
  );
}

class $$RepairCasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepairCasesTable,
          RepairCase,
          $$RepairCasesTableFilterComposer,
          $$RepairCasesTableOrderingComposer,
          $$RepairCasesTableAnnotationComposer,
          $$RepairCasesTableCreateCompanionBuilder,
          $$RepairCasesTableUpdateCompanionBuilder,
          (
            RepairCase,
            BaseReferences<_$AppDatabase, $RepairCasesTable, RepairCase>,
          ),
          RepairCase,
          PrefetchHooks Function()
        > {
  $$RepairCasesTableTableManager(_$AppDatabase db, $RepairCasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepairCasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepairCasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepairCasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<JobType> jobType = const Value.absent(),
                Value<CaseStatus> status = const Value.absent(),
                Value<String> reportedProblem = const Value.absent(),
                Value<String> actualFault = const Value.absent(),
                Value<String> kbRef = const Value.absent(),
                Value<int> labor = const Value.absent(),
                Value<int> warrantyDays = const Value.absent(),
                Value<String> privateNote = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<DateTime?> readyAt = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<DateTime?> appointmentAt = const Value.absent(),
              }) => RepairCasesCompanion(
                id: id,
                code: code,
                deviceId: deviceId,
                customerId: customerId,
                jobType: jobType,
                status: status,
                reportedProblem: reportedProblem,
                actualFault: actualFault,
                kbRef: kbRef,
                labor: labor,
                warrantyDays: warrantyDays,
                privateNote: privateNote,
                receivedAt: receivedAt,
                readyAt: readyAt,
                deliveredAt: deliveredAt,
                appointmentAt: appointmentAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required int deviceId,
                required int customerId,
                required JobType jobType,
                required CaseStatus status,
                Value<String> reportedProblem = const Value.absent(),
                Value<String> actualFault = const Value.absent(),
                Value<String> kbRef = const Value.absent(),
                Value<int> labor = const Value.absent(),
                Value<int> warrantyDays = const Value.absent(),
                Value<String> privateNote = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<DateTime?> readyAt = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<DateTime?> appointmentAt = const Value.absent(),
              }) => RepairCasesCompanion.insert(
                id: id,
                code: code,
                deviceId: deviceId,
                customerId: customerId,
                jobType: jobType,
                status: status,
                reportedProblem: reportedProblem,
                actualFault: actualFault,
                kbRef: kbRef,
                labor: labor,
                warrantyDays: warrantyDays,
                privateNote: privateNote,
                receivedAt: receivedAt,
                readyAt: readyAt,
                deliveredAt: deliveredAt,
                appointmentAt: appointmentAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RepairCasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepairCasesTable,
      RepairCase,
      $$RepairCasesTableFilterComposer,
      $$RepairCasesTableOrderingComposer,
      $$RepairCasesTableAnnotationComposer,
      $$RepairCasesTableCreateCompanionBuilder,
      $$RepairCasesTableUpdateCompanionBuilder,
      (
        RepairCase,
        BaseReferences<_$AppDatabase, $RepairCasesTable, RepairCase>,
      ),
      RepairCase,
      PrefetchHooks Function()
    >;
typedef $$CasePartsTableCreateCompanionBuilder =
    CasePartsCompanion Function({
      Value<int> id,
      required int caseId,
      required String name,
      Value<int> qty,
      Value<int> unitPrice,
    });
typedef $$CasePartsTableUpdateCompanionBuilder =
    CasePartsCompanion Function({
      Value<int> id,
      Value<int> caseId,
      Value<String> name,
      Value<int> qty,
      Value<int> unitPrice,
    });

class $$CasePartsTableFilterComposer
    extends Composer<_$AppDatabase, $CasePartsTable> {
  $$CasePartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CasePartsTableOrderingComposer
    extends Composer<_$AppDatabase, $CasePartsTable> {
  $$CasePartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CasePartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CasePartsTable> {
  $$CasePartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);
}

class $$CasePartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CasePartsTable,
          CasePart,
          $$CasePartsTableFilterComposer,
          $$CasePartsTableOrderingComposer,
          $$CasePartsTableAnnotationComposer,
          $$CasePartsTableCreateCompanionBuilder,
          $$CasePartsTableUpdateCompanionBuilder,
          (CasePart, BaseReferences<_$AppDatabase, $CasePartsTable, CasePart>),
          CasePart,
          PrefetchHooks Function()
        > {
  $$CasePartsTableTableManager(_$AppDatabase db, $CasePartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CasePartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CasePartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CasePartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> caseId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<int> unitPrice = const Value.absent(),
              }) => CasePartsCompanion(
                id: id,
                caseId: caseId,
                name: name,
                qty: qty,
                unitPrice: unitPrice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int caseId,
                required String name,
                Value<int> qty = const Value.absent(),
                Value<int> unitPrice = const Value.absent(),
              }) => CasePartsCompanion.insert(
                id: id,
                caseId: caseId,
                name: name,
                qty: qty,
                unitPrice: unitPrice,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CasePartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CasePartsTable,
      CasePart,
      $$CasePartsTableFilterComposer,
      $$CasePartsTableOrderingComposer,
      $$CasePartsTableAnnotationComposer,
      $$CasePartsTableCreateCompanionBuilder,
      $$CasePartsTableUpdateCompanionBuilder,
      (CasePart, BaseReferences<_$AppDatabase, $CasePartsTable, CasePart>),
      CasePart,
      PrefetchHooks Function()
    >;
typedef $$CasePhotosTableCreateCompanionBuilder =
    CasePhotosCompanion Function({
      Value<int> id,
      required int caseId,
      required String path,
      required PhotoKind kind,
      Value<DateTime> createdAt,
    });
typedef $$CasePhotosTableUpdateCompanionBuilder =
    CasePhotosCompanion Function({
      Value<int> id,
      Value<int> caseId,
      Value<String> path,
      Value<PhotoKind> kind,
      Value<DateTime> createdAt,
    });

class $$CasePhotosTableFilterComposer
    extends Composer<_$AppDatabase, $CasePhotosTable> {
  $$CasePhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PhotoKind, PhotoKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CasePhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $CasePhotosTable> {
  $$CasePhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CasePhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CasePhotosTable> {
  $$CasePhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PhotoKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CasePhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CasePhotosTable,
          CasePhoto,
          $$CasePhotosTableFilterComposer,
          $$CasePhotosTableOrderingComposer,
          $$CasePhotosTableAnnotationComposer,
          $$CasePhotosTableCreateCompanionBuilder,
          $$CasePhotosTableUpdateCompanionBuilder,
          (
            CasePhoto,
            BaseReferences<_$AppDatabase, $CasePhotosTable, CasePhoto>,
          ),
          CasePhoto,
          PrefetchHooks Function()
        > {
  $$CasePhotosTableTableManager(_$AppDatabase db, $CasePhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CasePhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CasePhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CasePhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> caseId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<PhotoKind> kind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CasePhotosCompanion(
                id: id,
                caseId: caseId,
                path: path,
                kind: kind,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int caseId,
                required String path,
                required PhotoKind kind,
                Value<DateTime> createdAt = const Value.absent(),
              }) => CasePhotosCompanion.insert(
                id: id,
                caseId: caseId,
                path: path,
                kind: kind,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CasePhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CasePhotosTable,
      CasePhoto,
      $$CasePhotosTableFilterComposer,
      $$CasePhotosTableOrderingComposer,
      $$CasePhotosTableAnnotationComposer,
      $$CasePhotosTableCreateCompanionBuilder,
      $$CasePhotosTableUpdateCompanionBuilder,
      (CasePhoto, BaseReferences<_$AppDatabase, $CasePhotosTable, CasePhoto>),
      CasePhoto,
      PrefetchHooks Function()
    >;
typedef $$StatusEventsTableCreateCompanionBuilder =
    StatusEventsCompanion Function({
      Value<int> id,
      required int caseId,
      required CaseStatus status,
      Value<DateTime> at,
    });
typedef $$StatusEventsTableUpdateCompanionBuilder =
    StatusEventsCompanion Function({
      Value<int> id,
      Value<int> caseId,
      Value<CaseStatus> status,
      Value<DateTime> at,
    });

class $$StatusEventsTableFilterComposer
    extends Composer<_$AppDatabase, $StatusEventsTable> {
  $$StatusEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CaseStatus, CaseStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatusEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $StatusEventsTable> {
  $$StatusEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatusEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatusEventsTable> {
  $$StatusEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CaseStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$StatusEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatusEventsTable,
          StatusEvent,
          $$StatusEventsTableFilterComposer,
          $$StatusEventsTableOrderingComposer,
          $$StatusEventsTableAnnotationComposer,
          $$StatusEventsTableCreateCompanionBuilder,
          $$StatusEventsTableUpdateCompanionBuilder,
          (
            StatusEvent,
            BaseReferences<_$AppDatabase, $StatusEventsTable, StatusEvent>,
          ),
          StatusEvent,
          PrefetchHooks Function()
        > {
  $$StatusEventsTableTableManager(_$AppDatabase db, $StatusEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatusEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatusEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatusEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> caseId = const Value.absent(),
                Value<CaseStatus> status = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => StatusEventsCompanion(
                id: id,
                caseId: caseId,
                status: status,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int caseId,
                required CaseStatus status,
                Value<DateTime> at = const Value.absent(),
              }) => StatusEventsCompanion.insert(
                id: id,
                caseId: caseId,
                status: status,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatusEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatusEventsTable,
      StatusEvent,
      $$StatusEventsTableFilterComposer,
      $$StatusEventsTableOrderingComposer,
      $$StatusEventsTableAnnotationComposer,
      $$StatusEventsTableCreateCompanionBuilder,
      $$StatusEventsTableUpdateCompanionBuilder,
      (
        StatusEvent,
        BaseReferences<_$AppDatabase, $StatusEventsTable, StatusEvent>,
      ),
      StatusEvent,
      PrefetchHooks Function()
    >;
typedef $$CountersTableCreateCompanionBuilder =
    CountersCompanion Function({
      required String name,
      required int current,
      Value<int> rowid,
    });
typedef $$CountersTableUpdateCompanionBuilder =
    CountersCompanion Function({
      Value<String> name,
      Value<int> current,
      Value<int> rowid,
    });

class $$CountersTableFilterComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get current => $composableBuilder(
    column: $table.current,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get current => $composableBuilder(
    column: $table.current,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get current =>
      $composableBuilder(column: $table.current, builder: (column) => column);
}

class $$CountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountersTable,
          CounterRow,
          $$CountersTableFilterComposer,
          $$CountersTableOrderingComposer,
          $$CountersTableAnnotationComposer,
          $$CountersTableCreateCompanionBuilder,
          $$CountersTableUpdateCompanionBuilder,
          (
            CounterRow,
            BaseReferences<_$AppDatabase, $CountersTable, CounterRow>,
          ),
          CounterRow,
          PrefetchHooks Function()
        > {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<int> current = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  CountersCompanion(name: name, current: current, rowid: rowid),
          createCompanionCallback:
              ({
                required String name,
                required int current,
                Value<int> rowid = const Value.absent(),
              }) => CountersCompanion.insert(
                name: name,
                current: current,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountersTable,
      CounterRow,
      $$CountersTableFilterComposer,
      $$CountersTableOrderingComposer,
      $$CountersTableAnnotationComposer,
      $$CountersTableCreateCompanionBuilder,
      $$CountersTableUpdateCompanionBuilder,
      (CounterRow, BaseReferences<_$AppDatabase, $CountersTable, CounterRow>),
      CounterRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String name,
      required String content,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> name,
      Value<String> content,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                name: name,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                name: name,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$KbNotesTableCreateCompanionBuilder =
    KbNotesCompanion Function({
      Value<int> id,
      required String entryId,
      required String body,
      Value<DateTime> updatedAt,
    });
typedef $$KbNotesTableUpdateCompanionBuilder =
    KbNotesCompanion Function({
      Value<int> id,
      Value<String> entryId,
      Value<String> body,
      Value<DateTime> updatedAt,
    });

class $$KbNotesTableFilterComposer
    extends Composer<_$AppDatabase, $KbNotesTable> {
  $$KbNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KbNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $KbNotesTable> {
  $$KbNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KbNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KbNotesTable> {
  $$KbNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KbNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KbNotesTable,
          KbNote,
          $$KbNotesTableFilterComposer,
          $$KbNotesTableOrderingComposer,
          $$KbNotesTableAnnotationComposer,
          $$KbNotesTableCreateCompanionBuilder,
          $$KbNotesTableUpdateCompanionBuilder,
          (KbNote, BaseReferences<_$AppDatabase, $KbNotesTable, KbNote>),
          KbNote,
          PrefetchHooks Function()
        > {
  $$KbNotesTableTableManager(_$AppDatabase db, $KbNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KbNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KbNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KbNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => KbNotesCompanion(
                id: id,
                entryId: entryId,
                body: body,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entryId,
                required String body,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => KbNotesCompanion.insert(
                id: id,
                entryId: entryId,
                body: body,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KbNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KbNotesTable,
      KbNote,
      $$KbNotesTableFilterComposer,
      $$KbNotesTableOrderingComposer,
      $$KbNotesTableAnnotationComposer,
      $$KbNotesTableCreateCompanionBuilder,
      $$KbNotesTableUpdateCompanionBuilder,
      (KbNote, BaseReferences<_$AppDatabase, $KbNotesTable, KbNote>),
      KbNote,
      PrefetchHooks Function()
    >;
typedef $$PartEquivalentsTableCreateCompanionBuilder =
    PartEquivalentsCompanion Function({
      Value<int> id,
      required String partName,
      required String equivalent,
      Value<String> note,
      Value<DateTime> createdAt,
    });
typedef $$PartEquivalentsTableUpdateCompanionBuilder =
    PartEquivalentsCompanion Function({
      Value<int> id,
      Value<String> partName,
      Value<String> equivalent,
      Value<String> note,
      Value<DateTime> createdAt,
    });

class $$PartEquivalentsTableFilterComposer
    extends Composer<_$AppDatabase, $PartEquivalentsTable> {
  $$PartEquivalentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partName => $composableBuilder(
    column: $table.partName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equivalent => $composableBuilder(
    column: $table.equivalent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartEquivalentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartEquivalentsTable> {
  $$PartEquivalentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partName => $composableBuilder(
    column: $table.partName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equivalent => $composableBuilder(
    column: $table.equivalent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartEquivalentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartEquivalentsTable> {
  $$PartEquivalentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partName =>
      $composableBuilder(column: $table.partName, builder: (column) => column);

  GeneratedColumn<String> get equivalent => $composableBuilder(
    column: $table.equivalent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PartEquivalentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartEquivalentsTable,
          PartEquivalent,
          $$PartEquivalentsTableFilterComposer,
          $$PartEquivalentsTableOrderingComposer,
          $$PartEquivalentsTableAnnotationComposer,
          $$PartEquivalentsTableCreateCompanionBuilder,
          $$PartEquivalentsTableUpdateCompanionBuilder,
          (
            PartEquivalent,
            BaseReferences<
              _$AppDatabase,
              $PartEquivalentsTable,
              PartEquivalent
            >,
          ),
          PartEquivalent,
          PrefetchHooks Function()
        > {
  $$PartEquivalentsTableTableManager(
    _$AppDatabase db,
    $PartEquivalentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartEquivalentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartEquivalentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartEquivalentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> partName = const Value.absent(),
                Value<String> equivalent = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PartEquivalentsCompanion(
                id: id,
                partName: partName,
                equivalent: equivalent,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String partName,
                required String equivalent,
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PartEquivalentsCompanion.insert(
                id: id,
                partName: partName,
                equivalent: equivalent,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartEquivalentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartEquivalentsTable,
      PartEquivalent,
      $$PartEquivalentsTableFilterComposer,
      $$PartEquivalentsTableOrderingComposer,
      $$PartEquivalentsTableAnnotationComposer,
      $$PartEquivalentsTableCreateCompanionBuilder,
      $$PartEquivalentsTableUpdateCompanionBuilder,
      (
        PartEquivalent,
        BaseReferences<_$AppDatabase, $PartEquivalentsTable, PartEquivalent>,
      ),
      PartEquivalent,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      required int caseId,
      required int amount,
      Value<String> note,
      Value<DateTime> at,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      Value<int> caseId,
      Value<int> amount,
      Value<String> note,
      Value<DateTime> at,
    });

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caseId => $composableBuilder(
    column: $table.caseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get caseId =>
      $composableBuilder(column: $table.caseId, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
          Payment,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> caseId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                caseId: caseId,
                amount: amount,
                note: note,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int caseId,
                required int amount,
                Value<String> note = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                caseId: caseId,
                amount: amount,
                note: note,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
      Payment,
      PrefetchHooks Function()
    >;
typedef $$PriceItemsTableCreateCompanionBuilder =
    PriceItemsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> price,
      Value<bool> isPart,
    });
typedef $$PriceItemsTableUpdateCompanionBuilder =
    PriceItemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> price,
      Value<bool> isPart,
    });

class $$PriceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PriceItemsTable> {
  $$PriceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPart => $composableBuilder(
    column: $table.isPart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceItemsTable> {
  $$PriceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPart => $composableBuilder(
    column: $table.isPart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceItemsTable> {
  $$PriceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<bool> get isPart =>
      $composableBuilder(column: $table.isPart, builder: (column) => column);
}

class $$PriceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceItemsTable,
          PriceItem,
          $$PriceItemsTableFilterComposer,
          $$PriceItemsTableOrderingComposer,
          $$PriceItemsTableAnnotationComposer,
          $$PriceItemsTableCreateCompanionBuilder,
          $$PriceItemsTableUpdateCompanionBuilder,
          (
            PriceItem,
            BaseReferences<_$AppDatabase, $PriceItemsTable, PriceItem>,
          ),
          PriceItem,
          PrefetchHooks Function()
        > {
  $$PriceItemsTableTableManager(_$AppDatabase db, $PriceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<bool> isPart = const Value.absent(),
              }) => PriceItemsCompanion(
                id: id,
                name: name,
                price: price,
                isPart: isPart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> price = const Value.absent(),
                Value<bool> isPart = const Value.absent(),
              }) => PriceItemsCompanion.insert(
                id: id,
                name: name,
                price: price,
                isPart: isPart,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceItemsTable,
      PriceItem,
      $$PriceItemsTableFilterComposer,
      $$PriceItemsTableOrderingComposer,
      $$PriceItemsTableAnnotationComposer,
      $$PriceItemsTableCreateCompanionBuilder,
      $$PriceItemsTableUpdateCompanionBuilder,
      (PriceItem, BaseReferences<_$AppDatabase, $PriceItemsTable, PriceItem>),
      PriceItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$RepairCasesTableTableManager get repairCases =>
      $$RepairCasesTableTableManager(_db, _db.repairCases);
  $$CasePartsTableTableManager get caseParts =>
      $$CasePartsTableTableManager(_db, _db.caseParts);
  $$CasePhotosTableTableManager get casePhotos =>
      $$CasePhotosTableTableManager(_db, _db.casePhotos);
  $$StatusEventsTableTableManager get statusEvents =>
      $$StatusEventsTableTableManager(_db, _db.statusEvents);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$KbNotesTableTableManager get kbNotes =>
      $$KbNotesTableTableManager(_db, _db.kbNotes);
  $$PartEquivalentsTableTableManager get partEquivalents =>
      $$PartEquivalentsTableTableManager(_db, _db.partEquivalents);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PriceItemsTableTableManager get priceItems =>
      $$PriceItemsTableTableManager(_db, _db.priceItems);
}
