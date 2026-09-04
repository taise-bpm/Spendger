// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    type,
    iconCode,
    colorValue,
    isCustom,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
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
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String type;
  final int iconCode;
  final int colorValue;
  final bool isCustom;
  final DateTime createdAt;
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorValue,
    required this.isCustom,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon_code'] = Variable<int>(iconCode);
    map['color_value'] = Variable<int>(colorValue);
    map['is_custom'] = Variable<bool>(isCustom);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      iconCode: Value(iconCode),
      colorValue: Value(colorValue),
      isCustom: Value(isCustom),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'iconCode': serializer.toJson<int>(iconCode),
      'colorValue': serializer.toJson<int>(colorValue),
      'isCustom': serializer.toJson<bool>(isCustom),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? type,
    int? iconCode,
    int? colorValue,
    bool? isCustom,
    DateTime? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    iconCode: iconCode ?? this.iconCode,
    colorValue: colorValue ?? this.colorValue,
    isCustom: isCustom ?? this.isCustom,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, iconCode, colorValue, isCustom, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.iconCode == this.iconCode &&
          other.colorValue == this.colorValue &&
          other.isCustom == this.isCustom &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<int> iconCode;
  final Value<int> colorValue;
  final Value<bool> isCustom;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required int iconCode,
    required int colorValue,
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       iconCode = Value(iconCode),
       colorValue = Value(colorValue);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? iconCode,
    Expression<int>? colorValue,
    Expression<bool>? isCustom,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorValue != null) 'color_value': colorValue,
      if (isCustom != null) 'is_custom': isCustom,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<int>? iconCode,
    Value<int>? colorValue,
    Value<bool>? isCustom,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountTypeMeta = const VerificationMeta(
    'accountType',
  );
  @override
  late final GeneratedColumn<String> accountType = GeneratedColumn<String>(
    'account_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    accountType,
    currentBalance,
    creditLimit,
    iconCode,
    colorValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('account_type')) {
      context.handle(
        _accountTypeMeta,
        accountType.isAcceptableOrUnknown(
          data['account_type']!,
          _accountTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountTypeMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_type'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      ),
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final String accountType;
  final double currentBalance;
  final double? creditLimit;
  final int iconCode;
  final int colorValue;
  const Account({
    required this.id,
    required this.name,
    required this.accountType,
    required this.currentBalance,
    this.creditLimit,
    required this.iconCode,
    required this.colorValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['account_type'] = Variable<String>(accountType);
    map['current_balance'] = Variable<double>(currentBalance);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    map['icon_code'] = Variable<int>(iconCode);
    map['color_value'] = Variable<int>(colorValue);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      accountType: Value(accountType),
      currentBalance: Value(currentBalance),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      iconCode: Value(iconCode),
      colorValue: Value(colorValue),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accountType: serializer.fromJson<String>(json['accountType']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'accountType': serializer.toJson<String>(accountType),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'iconCode': serializer.toJson<int>(iconCode),
      'colorValue': serializer.toJson<int>(colorValue),
    };
  }

  Account copyWith({
    String? id,
    String? name,
    String? accountType,
    double? currentBalance,
    Value<double?> creditLimit = const Value.absent(),
    int? iconCode,
    int? colorValue,
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    accountType: accountType ?? this.accountType,
    currentBalance: currentBalance ?? this.currentBalance,
    creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
    iconCode: iconCode ?? this.iconCode,
    colorValue: colorValue ?? this.colorValue,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accountType: data.accountType.present
          ? data.accountType.value
          : this.accountType,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    accountType,
    currentBalance,
    creditLimit,
    iconCode,
    colorValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.accountType == this.accountType &&
          other.currentBalance == this.currentBalance &&
          other.creditLimit == this.creditLimit &&
          other.iconCode == this.iconCode &&
          other.colorValue == this.colorValue);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> accountType;
  final Value<double> currentBalance;
  final Value<double?> creditLimit;
  final Value<int> iconCode;
  final Value<int> colorValue;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accountType = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required String accountType,
    this.currentBalance = const Value.absent(),
    this.creditLimit = const Value.absent(),
    required int iconCode,
    required int colorValue,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       accountType = Value(accountType),
       iconCode = Value(iconCode),
       colorValue = Value(colorValue);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? accountType,
    Expression<double>? currentBalance,
    Expression<double>? creditLimit,
    Expression<int>? iconCode,
    Expression<int>? colorValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accountType != null) 'account_type': accountType,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (iconCode != null) 'icon_code': iconCode,
      if (colorValue != null) 'color_value': colorValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? accountType,
    Value<double>? currentBalance,
    Value<double?>? creditLimit,
    Value<int>? iconCode,
    Value<int>? colorValue,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      currentBalance: currentBalance ?? this.currentBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(accountType.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('iconCode: $iconCode, ')
          ..write('colorValue: $colorValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    accountId,
    toAccountId,
    amount,
    type,
    transactionDate,
    notes,
    tag,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_account_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String categoryId;
  final String? accountId;
  final String? toAccountId;
  final double amount;
  final String type;
  final DateTime transactionDate;
  final String? notes;
  final String? tag;
  final DateTime createdAt;
  const Transaction({
    required this.id,
    required this.categoryId,
    this.accountId,
    this.toAccountId,
    required this.amount,
    required this.type,
    required this.transactionDate,
    this.notes,
    this.tag,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      amount: Value(amount),
      type: Value(type),
      transactionDate: Value(transactionDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      tag: serializer.fromJson<String?>(json['tag']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'accountId': serializer.toJson<String?>(accountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'notes': serializer.toJson<String?>(notes),
      'tag': serializer.toJson<String?>(tag),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaction copyWith({
    String? id,
    String? categoryId,
    Value<String?> accountId = const Value.absent(),
    Value<String?> toAccountId = const Value.absent(),
    double? amount,
    String? type,
    DateTime? transactionDate,
    Value<String?> notes = const Value.absent(),
    Value<String?> tag = const Value.absent(),
    DateTime? createdAt,
  }) => Transaction(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    transactionDate: transactionDate ?? this.transactionDate,
    notes: notes.present ? notes.value : this.notes,
    tag: tag.present ? tag.value : this.tag,
    createdAt: createdAt ?? this.createdAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      tag: data.tag.present ? data.tag.value : this.tag,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('notes: $notes, ')
          ..write('tag: $tag, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    accountId,
    toAccountId,
    amount,
    type,
    transactionDate,
    notes,
    tag,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.transactionDate == this.transactionDate &&
          other.notes == this.notes &&
          other.tag == this.tag &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String?> accountId;
  final Value<String?> toAccountId;
  final Value<double> amount;
  final Value<String> type;
  final Value<DateTime> transactionDate;
  final Value<String?> notes;
  final Value<String?> tag;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.tag = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String categoryId,
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    required double amount,
    required String type,
    required DateTime transactionDate,
    this.notes = const Value.absent(),
    this.tag = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       amount = Value(amount),
       type = Value(type),
       transactionDate = Value(transactionDate),
       createdAt = Value(createdAt);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? accountId,
    Expression<String>? toAccountId,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<DateTime>? transactionDate,
    Expression<String>? notes,
    Expression<String>? tag,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (notes != null) 'notes': notes,
      if (tag != null) 'tag': tag,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String?>? accountId,
    Value<String?>? toAccountId,
    Value<double>? amount,
    Value<String>? type,
    Value<DateTime>? transactionDate,
    Value<String?>? notes,
    Value<String?>? tag,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('notes: $notes, ')
          ..write('tag: $tag, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _allocatedAmountMeta = const VerificationMeta(
    'allocatedAmount',
  );
  @override
  late final GeneratedColumn<double> allocatedAmount = GeneratedColumn<double>(
    'allocated_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMonthMeta = const VerificationMeta(
    'periodMonth',
  );
  @override
  late final GeneratedColumn<int> periodMonth = GeneratedColumn<int>(
    'period_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodYearMeta = const VerificationMeta(
    'periodYear',
  );
  @override
  late final GeneratedColumn<int> periodYear = GeneratedColumn<int>(
    'period_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolloverEnabledMeta = const VerificationMeta(
    'rolloverEnabled',
  );
  @override
  late final GeneratedColumn<bool> rolloverEnabled = GeneratedColumn<bool>(
    'rollover_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rollover_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    allocatedAmount,
    periodMonth,
    periodYear,
    rolloverEnabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('allocated_amount')) {
      context.handle(
        _allocatedAmountMeta,
        allocatedAmount.isAcceptableOrUnknown(
          data['allocated_amount']!,
          _allocatedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allocatedAmountMeta);
    }
    if (data.containsKey('period_month')) {
      context.handle(
        _periodMonthMeta,
        periodMonth.isAcceptableOrUnknown(
          data['period_month']!,
          _periodMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodMonthMeta);
    }
    if (data.containsKey('period_year')) {
      context.handle(
        _periodYearMeta,
        periodYear.isAcceptableOrUnknown(data['period_year']!, _periodYearMeta),
      );
    } else if (isInserting) {
      context.missing(_periodYearMeta);
    }
    if (data.containsKey('rollover_enabled')) {
      context.handle(
        _rolloverEnabledMeta,
        rolloverEnabled.isAcceptableOrUnknown(
          data['rollover_enabled']!,
          _rolloverEnabledMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      allocatedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}allocated_amount'],
      )!,
      periodMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_month'],
      )!,
      periodYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_year'],
      )!,
      rolloverEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rollover_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String id;
  final String categoryId;
  final double allocatedAmount;
  final int periodMonth;
  final int periodYear;
  final bool rolloverEnabled;
  final DateTime createdAt;
  const Budget({
    required this.id,
    required this.categoryId,
    required this.allocatedAmount,
    required this.periodMonth,
    required this.periodYear,
    required this.rolloverEnabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['allocated_amount'] = Variable<double>(allocatedAmount);
    map['period_month'] = Variable<int>(periodMonth);
    map['period_year'] = Variable<int>(periodYear);
    map['rollover_enabled'] = Variable<bool>(rolloverEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      allocatedAmount: Value(allocatedAmount),
      periodMonth: Value(periodMonth),
      periodYear: Value(periodYear),
      rolloverEnabled: Value(rolloverEnabled),
      createdAt: Value(createdAt),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      allocatedAmount: serializer.fromJson<double>(json['allocatedAmount']),
      periodMonth: serializer.fromJson<int>(json['periodMonth']),
      periodYear: serializer.fromJson<int>(json['periodYear']),
      rolloverEnabled: serializer.fromJson<bool>(json['rolloverEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'allocatedAmount': serializer.toJson<double>(allocatedAmount),
      'periodMonth': serializer.toJson<int>(periodMonth),
      'periodYear': serializer.toJson<int>(periodYear),
      'rolloverEnabled': serializer.toJson<bool>(rolloverEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    double? allocatedAmount,
    int? periodMonth,
    int? periodYear,
    bool? rolloverEnabled,
    DateTime? createdAt,
  }) => Budget(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    allocatedAmount: allocatedAmount ?? this.allocatedAmount,
    periodMonth: periodMonth ?? this.periodMonth,
    periodYear: periodYear ?? this.periodYear,
    rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
    createdAt: createdAt ?? this.createdAt,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      allocatedAmount: data.allocatedAmount.present
          ? data.allocatedAmount.value
          : this.allocatedAmount,
      periodMonth: data.periodMonth.present
          ? data.periodMonth.value
          : this.periodMonth,
      periodYear: data.periodYear.present
          ? data.periodYear.value
          : this.periodYear,
      rolloverEnabled: data.rolloverEnabled.present
          ? data.rolloverEnabled.value
          : this.rolloverEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodYear: $periodYear, ')
          ..write('rolloverEnabled: $rolloverEnabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    allocatedAmount,
    periodMonth,
    periodYear,
    rolloverEnabled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.allocatedAmount == this.allocatedAmount &&
          other.periodMonth == this.periodMonth &&
          other.periodYear == this.periodYear &&
          other.rolloverEnabled == this.rolloverEnabled &&
          other.createdAt == this.createdAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<double> allocatedAmount;
  final Value<int> periodMonth;
  final Value<int> periodYear;
  final Value<bool> rolloverEnabled;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.allocatedAmount = const Value.absent(),
    this.periodMonth = const Value.absent(),
    this.periodYear = const Value.absent(),
    this.rolloverEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String categoryId,
    required double allocatedAmount,
    required int periodMonth,
    required int periodYear,
    this.rolloverEnabled = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       allocatedAmount = Value(allocatedAmount),
       periodMonth = Value(periodMonth),
       periodYear = Value(periodYear),
       createdAt = Value(createdAt);
  static Insertable<Budget> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<double>? allocatedAmount,
    Expression<int>? periodMonth,
    Expression<int>? periodYear,
    Expression<bool>? rolloverEnabled,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (allocatedAmount != null) 'allocated_amount': allocatedAmount,
      if (periodMonth != null) 'period_month': periodMonth,
      if (periodYear != null) 'period_year': periodYear,
      if (rolloverEnabled != null) 'rollover_enabled': rolloverEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<double>? allocatedAmount,
    Value<int>? periodMonth,
    Value<int>? periodYear,
    Value<bool>? rolloverEnabled,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (allocatedAmount.present) {
      map['allocated_amount'] = Variable<double>(allocatedAmount.value);
    }
    if (periodMonth.present) {
      map['period_month'] = Variable<int>(periodMonth.value);
    }
    if (periodYear.present) {
      map['period_year'] = Variable<int>(periodYear.value);
    }
    if (rolloverEnabled.present) {
      map['rollover_enabled'] = Variable<bool>(rolloverEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodYear: $periodYear, ')
          ..write('rolloverEnabled: $rolloverEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmiLoansTable extends EmiLoans with TableInfo<$EmiLoansTable, EmiLoan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmiLoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lenderNameMeta = const VerificationMeta(
    'lenderName',
  );
  @override
  late final GeneratedColumn<String> lenderName = GeneratedColumn<String>(
    'lender_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _principalAmountMeta = const VerificationMeta(
    'principalAmount',
  );
  @override
  late final GeneratedColumn<double> principalAmount = GeneratedColumn<double>(
    'principal_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualInterestRateMeta =
      const VerificationMeta('annualInterestRate');
  @override
  late final GeneratedColumn<double> annualInterestRate =
      GeneratedColumn<double>(
        'annual_interest_rate',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _tenureMonthsMeta = const VerificationMeta(
    'tenureMonths',
  );
  @override
  late final GeneratedColumn<int> tenureMonths = GeneratedColumn<int>(
    'tenure_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyEmiMeta = const VerificationMeta(
    'monthlyEmi',
  );
  @override
  late final GeneratedColumn<double> monthlyEmi = GeneratedColumn<double>(
    'monthly_emi',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstRateOnInterestMeta = const VerificationMeta(
    'gstRateOnInterest',
  );
  @override
  late final GeneratedColumn<double> gstRateOnInterest =
      GeneratedColumn<double>(
        'gst_rate_on_interest',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _expenseCategoryIdMeta = const VerificationMeta(
    'expenseCategoryId',
  );
  @override
  late final GeneratedColumn<String> expenseCategoryId =
      GeneratedColumn<String>(
        'expense_category_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _defaultAccountIdMeta = const VerificationMeta(
    'defaultAccountId',
  );
  @override
  late final GeneratedColumn<String> defaultAccountId = GeneratedColumn<String>(
    'default_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _autoLogExpenseMeta = const VerificationMeta(
    'autoLogExpense',
  );
  @override
  late final GeneratedColumn<bool> autoLogExpense = GeneratedColumn<bool>(
    'auto_log_expense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_log_expense" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productName,
    lenderName,
    principalAmount,
    annualInterestRate,
    tenureMonths,
    monthlyEmi,
    startDate,
    gstRateOnInterest,
    expenseCategoryId,
    defaultAccountId,
    autoLogExpense,
    status,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emi_loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmiLoan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('lender_name')) {
      context.handle(
        _lenderNameMeta,
        lenderName.isAcceptableOrUnknown(data['lender_name']!, _lenderNameMeta),
      );
    }
    if (data.containsKey('principal_amount')) {
      context.handle(
        _principalAmountMeta,
        principalAmount.isAcceptableOrUnknown(
          data['principal_amount']!,
          _principalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalAmountMeta);
    }
    if (data.containsKey('annual_interest_rate')) {
      context.handle(
        _annualInterestRateMeta,
        annualInterestRate.isAcceptableOrUnknown(
          data['annual_interest_rate']!,
          _annualInterestRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_annualInterestRateMeta);
    }
    if (data.containsKey('tenure_months')) {
      context.handle(
        _tenureMonthsMeta,
        tenureMonths.isAcceptableOrUnknown(
          data['tenure_months']!,
          _tenureMonthsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tenureMonthsMeta);
    }
    if (data.containsKey('monthly_emi')) {
      context.handle(
        _monthlyEmiMeta,
        monthlyEmi.isAcceptableOrUnknown(data['monthly_emi']!, _monthlyEmiMeta),
      );
    } else if (isInserting) {
      context.missing(_monthlyEmiMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('gst_rate_on_interest')) {
      context.handle(
        _gstRateOnInterestMeta,
        gstRateOnInterest.isAcceptableOrUnknown(
          data['gst_rate_on_interest']!,
          _gstRateOnInterestMeta,
        ),
      );
    }
    if (data.containsKey('expense_category_id')) {
      context.handle(
        _expenseCategoryIdMeta,
        expenseCategoryId.isAcceptableOrUnknown(
          data['expense_category_id']!,
          _expenseCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('default_account_id')) {
      context.handle(
        _defaultAccountIdMeta,
        defaultAccountId.isAcceptableOrUnknown(
          data['default_account_id']!,
          _defaultAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('auto_log_expense')) {
      context.handle(
        _autoLogExpenseMeta,
        autoLogExpense.isAcceptableOrUnknown(
          data['auto_log_expense']!,
          _autoLogExpenseMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmiLoan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmiLoan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      lenderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lender_name'],
      ),
      principalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}principal_amount'],
      )!,
      annualInterestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_interest_rate'],
      )!,
      tenureMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tenure_months'],
      )!,
      monthlyEmi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_emi'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      gstRateOnInterest: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_rate_on_interest'],
      )!,
      expenseCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_category_id'],
      ),
      defaultAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_account_id'],
      ),
      autoLogExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_log_expense'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EmiLoansTable createAlias(String alias) {
    return $EmiLoansTable(attachedDatabase, alias);
  }
}

class EmiLoan extends DataClass implements Insertable<EmiLoan> {
  final String id;
  final String productName;
  final String? lenderName;
  final double principalAmount;
  final double annualInterestRate;
  final int tenureMonths;
  final double monthlyEmi;
  final DateTime startDate;
  final double gstRateOnInterest;
  final String? expenseCategoryId;
  final String? defaultAccountId;
  final bool autoLogExpense;
  final String status;
  final String? notes;
  final DateTime createdAt;
  const EmiLoan({
    required this.id,
    required this.productName,
    this.lenderName,
    required this.principalAmount,
    required this.annualInterestRate,
    required this.tenureMonths,
    required this.monthlyEmi,
    required this.startDate,
    required this.gstRateOnInterest,
    this.expenseCategoryId,
    this.defaultAccountId,
    required this.autoLogExpense,
    required this.status,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || lenderName != null) {
      map['lender_name'] = Variable<String>(lenderName);
    }
    map['principal_amount'] = Variable<double>(principalAmount);
    map['annual_interest_rate'] = Variable<double>(annualInterestRate);
    map['tenure_months'] = Variable<int>(tenureMonths);
    map['monthly_emi'] = Variable<double>(monthlyEmi);
    map['start_date'] = Variable<DateTime>(startDate);
    map['gst_rate_on_interest'] = Variable<double>(gstRateOnInterest);
    if (!nullToAbsent || expenseCategoryId != null) {
      map['expense_category_id'] = Variable<String>(expenseCategoryId);
    }
    if (!nullToAbsent || defaultAccountId != null) {
      map['default_account_id'] = Variable<String>(defaultAccountId);
    }
    map['auto_log_expense'] = Variable<bool>(autoLogExpense);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EmiLoansCompanion toCompanion(bool nullToAbsent) {
    return EmiLoansCompanion(
      id: Value(id),
      productName: Value(productName),
      lenderName: lenderName == null && nullToAbsent
          ? const Value.absent()
          : Value(lenderName),
      principalAmount: Value(principalAmount),
      annualInterestRate: Value(annualInterestRate),
      tenureMonths: Value(tenureMonths),
      monthlyEmi: Value(monthlyEmi),
      startDate: Value(startDate),
      gstRateOnInterest: Value(gstRateOnInterest),
      expenseCategoryId: expenseCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseCategoryId),
      defaultAccountId: defaultAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultAccountId),
      autoLogExpense: Value(autoLogExpense),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory EmiLoan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmiLoan(
      id: serializer.fromJson<String>(json['id']),
      productName: serializer.fromJson<String>(json['productName']),
      lenderName: serializer.fromJson<String?>(json['lenderName']),
      principalAmount: serializer.fromJson<double>(json['principalAmount']),
      annualInterestRate: serializer.fromJson<double>(
        json['annualInterestRate'],
      ),
      tenureMonths: serializer.fromJson<int>(json['tenureMonths']),
      monthlyEmi: serializer.fromJson<double>(json['monthlyEmi']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      gstRateOnInterest: serializer.fromJson<double>(json['gstRateOnInterest']),
      expenseCategoryId: serializer.fromJson<String?>(
        json['expenseCategoryId'],
      ),
      defaultAccountId: serializer.fromJson<String?>(json['defaultAccountId']),
      autoLogExpense: serializer.fromJson<bool>(json['autoLogExpense']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productName': serializer.toJson<String>(productName),
      'lenderName': serializer.toJson<String?>(lenderName),
      'principalAmount': serializer.toJson<double>(principalAmount),
      'annualInterestRate': serializer.toJson<double>(annualInterestRate),
      'tenureMonths': serializer.toJson<int>(tenureMonths),
      'monthlyEmi': serializer.toJson<double>(monthlyEmi),
      'startDate': serializer.toJson<DateTime>(startDate),
      'gstRateOnInterest': serializer.toJson<double>(gstRateOnInterest),
      'expenseCategoryId': serializer.toJson<String?>(expenseCategoryId),
      'defaultAccountId': serializer.toJson<String?>(defaultAccountId),
      'autoLogExpense': serializer.toJson<bool>(autoLogExpense),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EmiLoan copyWith({
    String? id,
    String? productName,
    Value<String?> lenderName = const Value.absent(),
    double? principalAmount,
    double? annualInterestRate,
    int? tenureMonths,
    double? monthlyEmi,
    DateTime? startDate,
    double? gstRateOnInterest,
    Value<String?> expenseCategoryId = const Value.absent(),
    Value<String?> defaultAccountId = const Value.absent(),
    bool? autoLogExpense,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => EmiLoan(
    id: id ?? this.id,
    productName: productName ?? this.productName,
    lenderName: lenderName.present ? lenderName.value : this.lenderName,
    principalAmount: principalAmount ?? this.principalAmount,
    annualInterestRate: annualInterestRate ?? this.annualInterestRate,
    tenureMonths: tenureMonths ?? this.tenureMonths,
    monthlyEmi: monthlyEmi ?? this.monthlyEmi,
    startDate: startDate ?? this.startDate,
    gstRateOnInterest: gstRateOnInterest ?? this.gstRateOnInterest,
    expenseCategoryId: expenseCategoryId.present
        ? expenseCategoryId.value
        : this.expenseCategoryId,
    defaultAccountId: defaultAccountId.present
        ? defaultAccountId.value
        : this.defaultAccountId,
    autoLogExpense: autoLogExpense ?? this.autoLogExpense,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  EmiLoan copyWithCompanion(EmiLoansCompanion data) {
    return EmiLoan(
      id: data.id.present ? data.id.value : this.id,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      lenderName: data.lenderName.present
          ? data.lenderName.value
          : this.lenderName,
      principalAmount: data.principalAmount.present
          ? data.principalAmount.value
          : this.principalAmount,
      annualInterestRate: data.annualInterestRate.present
          ? data.annualInterestRate.value
          : this.annualInterestRate,
      tenureMonths: data.tenureMonths.present
          ? data.tenureMonths.value
          : this.tenureMonths,
      monthlyEmi: data.monthlyEmi.present
          ? data.monthlyEmi.value
          : this.monthlyEmi,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      gstRateOnInterest: data.gstRateOnInterest.present
          ? data.gstRateOnInterest.value
          : this.gstRateOnInterest,
      expenseCategoryId: data.expenseCategoryId.present
          ? data.expenseCategoryId.value
          : this.expenseCategoryId,
      defaultAccountId: data.defaultAccountId.present
          ? data.defaultAccountId.value
          : this.defaultAccountId,
      autoLogExpense: data.autoLogExpense.present
          ? data.autoLogExpense.value
          : this.autoLogExpense,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmiLoan(')
          ..write('id: $id, ')
          ..write('productName: $productName, ')
          ..write('lenderName: $lenderName, ')
          ..write('principalAmount: $principalAmount, ')
          ..write('annualInterestRate: $annualInterestRate, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('monthlyEmi: $monthlyEmi, ')
          ..write('startDate: $startDate, ')
          ..write('gstRateOnInterest: $gstRateOnInterest, ')
          ..write('expenseCategoryId: $expenseCategoryId, ')
          ..write('defaultAccountId: $defaultAccountId, ')
          ..write('autoLogExpense: $autoLogExpense, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productName,
    lenderName,
    principalAmount,
    annualInterestRate,
    tenureMonths,
    monthlyEmi,
    startDate,
    gstRateOnInterest,
    expenseCategoryId,
    defaultAccountId,
    autoLogExpense,
    status,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmiLoan &&
          other.id == this.id &&
          other.productName == this.productName &&
          other.lenderName == this.lenderName &&
          other.principalAmount == this.principalAmount &&
          other.annualInterestRate == this.annualInterestRate &&
          other.tenureMonths == this.tenureMonths &&
          other.monthlyEmi == this.monthlyEmi &&
          other.startDate == this.startDate &&
          other.gstRateOnInterest == this.gstRateOnInterest &&
          other.expenseCategoryId == this.expenseCategoryId &&
          other.defaultAccountId == this.defaultAccountId &&
          other.autoLogExpense == this.autoLogExpense &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class EmiLoansCompanion extends UpdateCompanion<EmiLoan> {
  final Value<String> id;
  final Value<String> productName;
  final Value<String?> lenderName;
  final Value<double> principalAmount;
  final Value<double> annualInterestRate;
  final Value<int> tenureMonths;
  final Value<double> monthlyEmi;
  final Value<DateTime> startDate;
  final Value<double> gstRateOnInterest;
  final Value<String?> expenseCategoryId;
  final Value<String?> defaultAccountId;
  final Value<bool> autoLogExpense;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EmiLoansCompanion({
    this.id = const Value.absent(),
    this.productName = const Value.absent(),
    this.lenderName = const Value.absent(),
    this.principalAmount = const Value.absent(),
    this.annualInterestRate = const Value.absent(),
    this.tenureMonths = const Value.absent(),
    this.monthlyEmi = const Value.absent(),
    this.startDate = const Value.absent(),
    this.gstRateOnInterest = const Value.absent(),
    this.expenseCategoryId = const Value.absent(),
    this.defaultAccountId = const Value.absent(),
    this.autoLogExpense = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmiLoansCompanion.insert({
    required String id,
    required String productName,
    this.lenderName = const Value.absent(),
    required double principalAmount,
    required double annualInterestRate,
    required int tenureMonths,
    required double monthlyEmi,
    required DateTime startDate,
    this.gstRateOnInterest = const Value.absent(),
    this.expenseCategoryId = const Value.absent(),
    this.defaultAccountId = const Value.absent(),
    this.autoLogExpense = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productName = Value(productName),
       principalAmount = Value(principalAmount),
       annualInterestRate = Value(annualInterestRate),
       tenureMonths = Value(tenureMonths),
       monthlyEmi = Value(monthlyEmi),
       startDate = Value(startDate),
       createdAt = Value(createdAt);
  static Insertable<EmiLoan> custom({
    Expression<String>? id,
    Expression<String>? productName,
    Expression<String>? lenderName,
    Expression<double>? principalAmount,
    Expression<double>? annualInterestRate,
    Expression<int>? tenureMonths,
    Expression<double>? monthlyEmi,
    Expression<DateTime>? startDate,
    Expression<double>? gstRateOnInterest,
    Expression<String>? expenseCategoryId,
    Expression<String>? defaultAccountId,
    Expression<bool>? autoLogExpense,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productName != null) 'product_name': productName,
      if (lenderName != null) 'lender_name': lenderName,
      if (principalAmount != null) 'principal_amount': principalAmount,
      if (annualInterestRate != null)
        'annual_interest_rate': annualInterestRate,
      if (tenureMonths != null) 'tenure_months': tenureMonths,
      if (monthlyEmi != null) 'monthly_emi': monthlyEmi,
      if (startDate != null) 'start_date': startDate,
      if (gstRateOnInterest != null) 'gst_rate_on_interest': gstRateOnInterest,
      if (expenseCategoryId != null) 'expense_category_id': expenseCategoryId,
      if (defaultAccountId != null) 'default_account_id': defaultAccountId,
      if (autoLogExpense != null) 'auto_log_expense': autoLogExpense,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmiLoansCompanion copyWith({
    Value<String>? id,
    Value<String>? productName,
    Value<String?>? lenderName,
    Value<double>? principalAmount,
    Value<double>? annualInterestRate,
    Value<int>? tenureMonths,
    Value<double>? monthlyEmi,
    Value<DateTime>? startDate,
    Value<double>? gstRateOnInterest,
    Value<String?>? expenseCategoryId,
    Value<String?>? defaultAccountId,
    Value<bool>? autoLogExpense,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EmiLoansCompanion(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      lenderName: lenderName ?? this.lenderName,
      principalAmount: principalAmount ?? this.principalAmount,
      annualInterestRate: annualInterestRate ?? this.annualInterestRate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      monthlyEmi: monthlyEmi ?? this.monthlyEmi,
      startDate: startDate ?? this.startDate,
      gstRateOnInterest: gstRateOnInterest ?? this.gstRateOnInterest,
      expenseCategoryId: expenseCategoryId ?? this.expenseCategoryId,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      autoLogExpense: autoLogExpense ?? this.autoLogExpense,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (lenderName.present) {
      map['lender_name'] = Variable<String>(lenderName.value);
    }
    if (principalAmount.present) {
      map['principal_amount'] = Variable<double>(principalAmount.value);
    }
    if (annualInterestRate.present) {
      map['annual_interest_rate'] = Variable<double>(annualInterestRate.value);
    }
    if (tenureMonths.present) {
      map['tenure_months'] = Variable<int>(tenureMonths.value);
    }
    if (monthlyEmi.present) {
      map['monthly_emi'] = Variable<double>(monthlyEmi.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (gstRateOnInterest.present) {
      map['gst_rate_on_interest'] = Variable<double>(gstRateOnInterest.value);
    }
    if (expenseCategoryId.present) {
      map['expense_category_id'] = Variable<String>(expenseCategoryId.value);
    }
    if (defaultAccountId.present) {
      map['default_account_id'] = Variable<String>(defaultAccountId.value);
    }
    if (autoLogExpense.present) {
      map['auto_log_expense'] = Variable<bool>(autoLogExpense.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmiLoansCompanion(')
          ..write('id: $id, ')
          ..write('productName: $productName, ')
          ..write('lenderName: $lenderName, ')
          ..write('principalAmount: $principalAmount, ')
          ..write('annualInterestRate: $annualInterestRate, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('monthlyEmi: $monthlyEmi, ')
          ..write('startDate: $startDate, ')
          ..write('gstRateOnInterest: $gstRateOnInterest, ')
          ..write('expenseCategoryId: $expenseCategoryId, ')
          ..write('defaultAccountId: $defaultAccountId, ')
          ..write('autoLogExpense: $autoLogExpense, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmiPaymentsTable extends EmiPayments
    with TableInfo<$EmiPaymentsTable, EmiPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmiPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<String> loanId = GeneratedColumn<String>(
    'loan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emi_loans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principalPaidMeta = const VerificationMeta(
    'principalPaid',
  );
  @override
  late final GeneratedColumn<double> principalPaid = GeneratedColumn<double>(
    'principal_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interestPaidMeta = const VerificationMeta(
    'interestPaid',
  );
  @override
  late final GeneratedColumn<double> interestPaid = GeneratedColumn<double>(
    'interest_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstPaidMeta = const VerificationMeta(
    'gstPaid',
  );
  @override
  late final GeneratedColumn<double> gstPaid = GeneratedColumn<double>(
    'gst_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalAmountPaidMeta = const VerificationMeta(
    'totalAmountPaid',
  );
  @override
  late final GeneratedColumn<double> totalAmountPaid = GeneratedColumn<double>(
    'total_amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrepaymentMeta = const VerificationMeta(
    'isPrepayment',
  );
  @override
  late final GeneratedColumn<bool> isPrepayment = GeneratedColumn<bool>(
    'is_prepayment',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_prepayment" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    loanId,
    installmentNumber,
    paymentDate,
    principalPaid,
    interestPaid,
    gstPaid,
    totalAmountPaid,
    isPrepayment,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emi_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmiPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('loan_id')) {
      context.handle(
        _loanIdMeta,
        loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta),
      );
    } else if (isInserting) {
      context.missing(_loanIdMeta);
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installmentNumberMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('principal_paid')) {
      context.handle(
        _principalPaidMeta,
        principalPaid.isAcceptableOrUnknown(
          data['principal_paid']!,
          _principalPaidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalPaidMeta);
    }
    if (data.containsKey('interest_paid')) {
      context.handle(
        _interestPaidMeta,
        interestPaid.isAcceptableOrUnknown(
          data['interest_paid']!,
          _interestPaidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interestPaidMeta);
    }
    if (data.containsKey('gst_paid')) {
      context.handle(
        _gstPaidMeta,
        gstPaid.isAcceptableOrUnknown(data['gst_paid']!, _gstPaidMeta),
      );
    }
    if (data.containsKey('total_amount_paid')) {
      context.handle(
        _totalAmountPaidMeta,
        totalAmountPaid.isAcceptableOrUnknown(
          data['total_amount_paid']!,
          _totalAmountPaidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountPaidMeta);
    }
    if (data.containsKey('is_prepayment')) {
      context.handle(
        _isPrepaymentMeta,
        isPrepayment.isAcceptableOrUnknown(
          data['is_prepayment']!,
          _isPrepaymentMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmiPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmiPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      loanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_id'],
      )!,
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      principalPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}principal_paid'],
      )!,
      interestPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_paid'],
      )!,
      gstPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_paid'],
      )!,
      totalAmountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount_paid'],
      )!,
      isPrepayment: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_prepayment'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $EmiPaymentsTable createAlias(String alias) {
    return $EmiPaymentsTable(attachedDatabase, alias);
  }
}

class EmiPayment extends DataClass implements Insertable<EmiPayment> {
  final String id;
  final String loanId;
  final int installmentNumber;
  final DateTime paymentDate;
  final double principalPaid;
  final double interestPaid;
  final double gstPaid;
  final double totalAmountPaid;
  final bool isPrepayment;
  final String? notes;
  const EmiPayment({
    required this.id,
    required this.loanId,
    required this.installmentNumber,
    required this.paymentDate,
    required this.principalPaid,
    required this.interestPaid,
    required this.gstPaid,
    required this.totalAmountPaid,
    required this.isPrepayment,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['loan_id'] = Variable<String>(loanId);
    map['installment_number'] = Variable<int>(installmentNumber);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['principal_paid'] = Variable<double>(principalPaid);
    map['interest_paid'] = Variable<double>(interestPaid);
    map['gst_paid'] = Variable<double>(gstPaid);
    map['total_amount_paid'] = Variable<double>(totalAmountPaid);
    map['is_prepayment'] = Variable<bool>(isPrepayment);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  EmiPaymentsCompanion toCompanion(bool nullToAbsent) {
    return EmiPaymentsCompanion(
      id: Value(id),
      loanId: Value(loanId),
      installmentNumber: Value(installmentNumber),
      paymentDate: Value(paymentDate),
      principalPaid: Value(principalPaid),
      interestPaid: Value(interestPaid),
      gstPaid: Value(gstPaid),
      totalAmountPaid: Value(totalAmountPaid),
      isPrepayment: Value(isPrepayment),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory EmiPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmiPayment(
      id: serializer.fromJson<String>(json['id']),
      loanId: serializer.fromJson<String>(json['loanId']),
      installmentNumber: serializer.fromJson<int>(json['installmentNumber']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      principalPaid: serializer.fromJson<double>(json['principalPaid']),
      interestPaid: serializer.fromJson<double>(json['interestPaid']),
      gstPaid: serializer.fromJson<double>(json['gstPaid']),
      totalAmountPaid: serializer.fromJson<double>(json['totalAmountPaid']),
      isPrepayment: serializer.fromJson<bool>(json['isPrepayment']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'loanId': serializer.toJson<String>(loanId),
      'installmentNumber': serializer.toJson<int>(installmentNumber),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'principalPaid': serializer.toJson<double>(principalPaid),
      'interestPaid': serializer.toJson<double>(interestPaid),
      'gstPaid': serializer.toJson<double>(gstPaid),
      'totalAmountPaid': serializer.toJson<double>(totalAmountPaid),
      'isPrepayment': serializer.toJson<bool>(isPrepayment),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  EmiPayment copyWith({
    String? id,
    String? loanId,
    int? installmentNumber,
    DateTime? paymentDate,
    double? principalPaid,
    double? interestPaid,
    double? gstPaid,
    double? totalAmountPaid,
    bool? isPrepayment,
    Value<String?> notes = const Value.absent(),
  }) => EmiPayment(
    id: id ?? this.id,
    loanId: loanId ?? this.loanId,
    installmentNumber: installmentNumber ?? this.installmentNumber,
    paymentDate: paymentDate ?? this.paymentDate,
    principalPaid: principalPaid ?? this.principalPaid,
    interestPaid: interestPaid ?? this.interestPaid,
    gstPaid: gstPaid ?? this.gstPaid,
    totalAmountPaid: totalAmountPaid ?? this.totalAmountPaid,
    isPrepayment: isPrepayment ?? this.isPrepayment,
    notes: notes.present ? notes.value : this.notes,
  );
  EmiPayment copyWithCompanion(EmiPaymentsCompanion data) {
    return EmiPayment(
      id: data.id.present ? data.id.value : this.id,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      principalPaid: data.principalPaid.present
          ? data.principalPaid.value
          : this.principalPaid,
      interestPaid: data.interestPaid.present
          ? data.interestPaid.value
          : this.interestPaid,
      gstPaid: data.gstPaid.present ? data.gstPaid.value : this.gstPaid,
      totalAmountPaid: data.totalAmountPaid.present
          ? data.totalAmountPaid.value
          : this.totalAmountPaid,
      isPrepayment: data.isPrepayment.present
          ? data.isPrepayment.value
          : this.isPrepayment,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmiPayment(')
          ..write('id: $id, ')
          ..write('loanId: $loanId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('principalPaid: $principalPaid, ')
          ..write('interestPaid: $interestPaid, ')
          ..write('gstPaid: $gstPaid, ')
          ..write('totalAmountPaid: $totalAmountPaid, ')
          ..write('isPrepayment: $isPrepayment, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    loanId,
    installmentNumber,
    paymentDate,
    principalPaid,
    interestPaid,
    gstPaid,
    totalAmountPaid,
    isPrepayment,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmiPayment &&
          other.id == this.id &&
          other.loanId == this.loanId &&
          other.installmentNumber == this.installmentNumber &&
          other.paymentDate == this.paymentDate &&
          other.principalPaid == this.principalPaid &&
          other.interestPaid == this.interestPaid &&
          other.gstPaid == this.gstPaid &&
          other.totalAmountPaid == this.totalAmountPaid &&
          other.isPrepayment == this.isPrepayment &&
          other.notes == this.notes);
}

class EmiPaymentsCompanion extends UpdateCompanion<EmiPayment> {
  final Value<String> id;
  final Value<String> loanId;
  final Value<int> installmentNumber;
  final Value<DateTime> paymentDate;
  final Value<double> principalPaid;
  final Value<double> interestPaid;
  final Value<double> gstPaid;
  final Value<double> totalAmountPaid;
  final Value<bool> isPrepayment;
  final Value<String?> notes;
  final Value<int> rowid;
  const EmiPaymentsCompanion({
    this.id = const Value.absent(),
    this.loanId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.principalPaid = const Value.absent(),
    this.interestPaid = const Value.absent(),
    this.gstPaid = const Value.absent(),
    this.totalAmountPaid = const Value.absent(),
    this.isPrepayment = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmiPaymentsCompanion.insert({
    required String id,
    required String loanId,
    required int installmentNumber,
    required DateTime paymentDate,
    required double principalPaid,
    required double interestPaid,
    this.gstPaid = const Value.absent(),
    required double totalAmountPaid,
    this.isPrepayment = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       loanId = Value(loanId),
       installmentNumber = Value(installmentNumber),
       paymentDate = Value(paymentDate),
       principalPaid = Value(principalPaid),
       interestPaid = Value(interestPaid),
       totalAmountPaid = Value(totalAmountPaid);
  static Insertable<EmiPayment> custom({
    Expression<String>? id,
    Expression<String>? loanId,
    Expression<int>? installmentNumber,
    Expression<DateTime>? paymentDate,
    Expression<double>? principalPaid,
    Expression<double>? interestPaid,
    Expression<double>? gstPaid,
    Expression<double>? totalAmountPaid,
    Expression<bool>? isPrepayment,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (loanId != null) 'loan_id': loanId,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (principalPaid != null) 'principal_paid': principalPaid,
      if (interestPaid != null) 'interest_paid': interestPaid,
      if (gstPaid != null) 'gst_paid': gstPaid,
      if (totalAmountPaid != null) 'total_amount_paid': totalAmountPaid,
      if (isPrepayment != null) 'is_prepayment': isPrepayment,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmiPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? loanId,
    Value<int>? installmentNumber,
    Value<DateTime>? paymentDate,
    Value<double>? principalPaid,
    Value<double>? interestPaid,
    Value<double>? gstPaid,
    Value<double>? totalAmountPaid,
    Value<bool>? isPrepayment,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return EmiPaymentsCompanion(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      paymentDate: paymentDate ?? this.paymentDate,
      principalPaid: principalPaid ?? this.principalPaid,
      interestPaid: interestPaid ?? this.interestPaid,
      gstPaid: gstPaid ?? this.gstPaid,
      totalAmountPaid: totalAmountPaid ?? this.totalAmountPaid,
      isPrepayment: isPrepayment ?? this.isPrepayment,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<String>(loanId.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (principalPaid.present) {
      map['principal_paid'] = Variable<double>(principalPaid.value);
    }
    if (interestPaid.present) {
      map['interest_paid'] = Variable<double>(interestPaid.value);
    }
    if (gstPaid.present) {
      map['gst_paid'] = Variable<double>(gstPaid.value);
    }
    if (totalAmountPaid.present) {
      map['total_amount_paid'] = Variable<double>(totalAmountPaid.value);
    }
    if (isPrepayment.present) {
      map['is_prepayment'] = Variable<bool>(isPrepayment.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmiPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('loanId: $loanId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('principalPaid: $principalPaid, ')
          ..write('interestPaid: $interestPaid, ')
          ..write('gstPaid: $gstPaid, ')
          ..write('totalAmountPaid: $totalAmountPaid, ')
          ..write('isPrepayment: $isPrepayment, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentsTable extends Investments
    with TableInfo<$InvestmentsTable, Investment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maturityDateMeta = const VerificationMeta(
    'maturityDate',
  );
  @override
  late final GeneratedColumn<DateTime> maturityDate = GeneratedColumn<DateTime>(
    'maturity_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCommittedAmountMeta =
      const VerificationMeta('totalCommittedAmount');
  @override
  late final GeneratedColumn<double> totalCommittedAmount =
      GeneratedColumn<double>(
        'total_committed_amount',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentValuationMeta = const VerificationMeta(
    'currentValuation',
  );
  @override
  late final GeneratedColumn<double> currentValuation = GeneratedColumn<double>(
    'current_valuation',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    startDate,
    maturityDate,
    totalCommittedAmount,
    quantity,
    purchasePrice,
    currentValuation,
    status,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('maturity_date')) {
      context.handle(
        _maturityDateMeta,
        maturityDate.isAcceptableOrUnknown(
          data['maturity_date']!,
          _maturityDateMeta,
        ),
      );
    }
    if (data.containsKey('total_committed_amount')) {
      context.handle(
        _totalCommittedAmountMeta,
        totalCommittedAmount.isAcceptableOrUnknown(
          data['total_committed_amount']!,
          _totalCommittedAmountMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('current_valuation')) {
      context.handle(
        _currentValuationMeta,
        currentValuation.isAcceptableOrUnknown(
          data['current_valuation']!,
          _currentValuationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentValuationMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      maturityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maturity_date'],
      ),
      totalCommittedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_committed_amount'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      ),
      currentValuation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_valuation'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvestmentsTable createAlias(String alias) {
    return $InvestmentsTable(attachedDatabase, alias);
  }
}

class Investment extends DataClass implements Insertable<Investment> {
  final String id;
  final String name;
  final String type;
  final DateTime startDate;
  final DateTime? maturityDate;
  final double? totalCommittedAmount;
  final double? quantity;
  final double? purchasePrice;
  final double currentValuation;
  final String status;
  final String? notes;
  final DateTime createdAt;
  const Investment({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    this.maturityDate,
    this.totalCommittedAmount,
    this.quantity,
    this.purchasePrice,
    required this.currentValuation,
    required this.status,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || maturityDate != null) {
      map['maturity_date'] = Variable<DateTime>(maturityDate);
    }
    if (!nullToAbsent || totalCommittedAmount != null) {
      map['total_committed_amount'] = Variable<double>(totalCommittedAmount);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || purchasePrice != null) {
      map['purchase_price'] = Variable<double>(purchasePrice);
    }
    map['current_valuation'] = Variable<double>(currentValuation);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvestmentsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      startDate: Value(startDate),
      maturityDate: maturityDate == null && nullToAbsent
          ? const Value.absent()
          : Value(maturityDate),
      totalCommittedAmount: totalCommittedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(totalCommittedAmount),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      purchasePrice: purchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePrice),
      currentValuation: Value(currentValuation),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Investment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investment(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      maturityDate: serializer.fromJson<DateTime?>(json['maturityDate']),
      totalCommittedAmount: serializer.fromJson<double?>(
        json['totalCommittedAmount'],
      ),
      quantity: serializer.fromJson<double?>(json['quantity']),
      purchasePrice: serializer.fromJson<double?>(json['purchasePrice']),
      currentValuation: serializer.fromJson<double>(json['currentValuation']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'startDate': serializer.toJson<DateTime>(startDate),
      'maturityDate': serializer.toJson<DateTime?>(maturityDate),
      'totalCommittedAmount': serializer.toJson<double?>(totalCommittedAmount),
      'quantity': serializer.toJson<double?>(quantity),
      'purchasePrice': serializer.toJson<double?>(purchasePrice),
      'currentValuation': serializer.toJson<double>(currentValuation),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Investment copyWith({
    String? id,
    String? name,
    String? type,
    DateTime? startDate,
    Value<DateTime?> maturityDate = const Value.absent(),
    Value<double?> totalCommittedAmount = const Value.absent(),
    Value<double?> quantity = const Value.absent(),
    Value<double?> purchasePrice = const Value.absent(),
    double? currentValuation,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Investment(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    startDate: startDate ?? this.startDate,
    maturityDate: maturityDate.present ? maturityDate.value : this.maturityDate,
    totalCommittedAmount: totalCommittedAmount.present
        ? totalCommittedAmount.value
        : this.totalCommittedAmount,
    quantity: quantity.present ? quantity.value : this.quantity,
    purchasePrice: purchasePrice.present
        ? purchasePrice.value
        : this.purchasePrice,
    currentValuation: currentValuation ?? this.currentValuation,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Investment copyWithCompanion(InvestmentsCompanion data) {
    return Investment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      maturityDate: data.maturityDate.present
          ? data.maturityDate.value
          : this.maturityDate,
      totalCommittedAmount: data.totalCommittedAmount.present
          ? data.totalCommittedAmount.value
          : this.totalCommittedAmount,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      currentValuation: data.currentValuation.present
          ? data.currentValuation.value
          : this.currentValuation,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('startDate: $startDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('totalCommittedAmount: $totalCommittedAmount, ')
          ..write('quantity: $quantity, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currentValuation: $currentValuation, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    startDate,
    maturityDate,
    totalCommittedAmount,
    quantity,
    purchasePrice,
    currentValuation,
    status,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investment &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.startDate == this.startDate &&
          other.maturityDate == this.maturityDate &&
          other.totalCommittedAmount == this.totalCommittedAmount &&
          other.quantity == this.quantity &&
          other.purchasePrice == this.purchasePrice &&
          other.currentValuation == this.currentValuation &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class InvestmentsCompanion extends UpdateCompanion<Investment> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<DateTime> startDate;
  final Value<DateTime?> maturityDate;
  final Value<double?> totalCommittedAmount;
  final Value<double?> quantity;
  final Value<double?> purchasePrice;
  final Value<double> currentValuation;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvestmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.startDate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.totalCommittedAmount = const Value.absent(),
    this.quantity = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.currentValuation = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentsCompanion.insert({
    required String id,
    required String name,
    required String type,
    required DateTime startDate,
    this.maturityDate = const Value.absent(),
    this.totalCommittedAmount = const Value.absent(),
    this.quantity = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    required double currentValuation,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       startDate = Value(startDate),
       currentValuation = Value(currentValuation),
       createdAt = Value(createdAt);
  static Insertable<Investment> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<DateTime>? startDate,
    Expression<DateTime>? maturityDate,
    Expression<double>? totalCommittedAmount,
    Expression<double>? quantity,
    Expression<double>? purchasePrice,
    Expression<double>? currentValuation,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (startDate != null) 'start_date': startDate,
      if (maturityDate != null) 'maturity_date': maturityDate,
      if (totalCommittedAmount != null)
        'total_committed_amount': totalCommittedAmount,
      if (quantity != null) 'quantity': quantity,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (currentValuation != null) 'current_valuation': currentValuation,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<DateTime>? startDate,
    Value<DateTime?>? maturityDate,
    Value<double?>? totalCommittedAmount,
    Value<double?>? quantity,
    Value<double?>? purchasePrice,
    Value<double>? currentValuation,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvestmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      maturityDate: maturityDate ?? this.maturityDate,
      totalCommittedAmount: totalCommittedAmount ?? this.totalCommittedAmount,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentValuation: currentValuation ?? this.currentValuation,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (maturityDate.present) {
      map['maturity_date'] = Variable<DateTime>(maturityDate.value);
    }
    if (totalCommittedAmount.present) {
      map['total_committed_amount'] = Variable<double>(
        totalCommittedAmount.value,
      );
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (currentValuation.present) {
      map['current_valuation'] = Variable<double>(currentValuation.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('startDate: $startDate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('totalCommittedAmount: $totalCommittedAmount, ')
          ..write('quantity: $quantity, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currentValuation: $currentValuation, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChittyInstallmentsTable extends ChittyInstallments
    with TableInfo<$ChittyInstallmentsTable, ChittyInstallment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChittyInstallmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _investmentIdMeta = const VerificationMeta(
    'investmentId',
  );
  @override
  late final GeneratedColumn<String> investmentId = GeneratedColumn<String>(
    'investment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossInstallmentMeta = const VerificationMeta(
    'grossInstallment',
  );
  @override
  late final GeneratedColumn<double> grossInstallment = GeneratedColumn<double>(
    'gross_installment',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dividendEarnedMeta = const VerificationMeta(
    'dividendEarned',
  );
  @override
  late final GeneratedColumn<double> dividendEarned = GeneratedColumn<double>(
    'dividend_earned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _netAmountPaidMeta = const VerificationMeta(
    'netAmountPaid',
  );
  @override
  late final GeneratedColumn<double> netAmountPaid = GeneratedColumn<double>(
    'net_amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPrizedMonthMeta = const VerificationMeta(
    'isPrizedMonth',
  );
  @override
  late final GeneratedColumn<bool> isPrizedMonth = GeneratedColumn<bool>(
    'is_prized_month',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_prized_month" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _prizeAmountReceivedMeta =
      const VerificationMeta('prizeAmountReceived');
  @override
  late final GeneratedColumn<double> prizeAmountReceived =
      GeneratedColumn<double>(
        'prize_amount_received',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    investmentId,
    installmentNumber,
    dueDate,
    grossInstallment,
    dividendEarned,
    netAmountPaid,
    paymentDate,
    isPaid,
    isPrizedMonth,
    prizeAmountReceived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chitty_installments';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChittyInstallment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('investment_id')) {
      context.handle(
        _investmentIdMeta,
        investmentId.isAcceptableOrUnknown(
          data['investment_id']!,
          _investmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investmentIdMeta);
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installmentNumberMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('gross_installment')) {
      context.handle(
        _grossInstallmentMeta,
        grossInstallment.isAcceptableOrUnknown(
          data['gross_installment']!,
          _grossInstallmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossInstallmentMeta);
    }
    if (data.containsKey('dividend_earned')) {
      context.handle(
        _dividendEarnedMeta,
        dividendEarned.isAcceptableOrUnknown(
          data['dividend_earned']!,
          _dividendEarnedMeta,
        ),
      );
    }
    if (data.containsKey('net_amount_paid')) {
      context.handle(
        _netAmountPaidMeta,
        netAmountPaid.isAcceptableOrUnknown(
          data['net_amount_paid']!,
          _netAmountPaidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_netAmountPaidMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    if (data.containsKey('is_prized_month')) {
      context.handle(
        _isPrizedMonthMeta,
        isPrizedMonth.isAcceptableOrUnknown(
          data['is_prized_month']!,
          _isPrizedMonthMeta,
        ),
      );
    }
    if (data.containsKey('prize_amount_received')) {
      context.handle(
        _prizeAmountReceivedMeta,
        prizeAmountReceived.isAcceptableOrUnknown(
          data['prize_amount_received']!,
          _prizeAmountReceivedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChittyInstallment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChittyInstallment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      investmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investment_id'],
      )!,
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      grossInstallment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gross_installment'],
      )!,
      dividendEarned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dividend_earned'],
      )!,
      netAmountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_amount_paid'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      ),
      isPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paid'],
      )!,
      isPrizedMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_prized_month'],
      )!,
      prizeAmountReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prize_amount_received'],
      )!,
    );
  }

  @override
  $ChittyInstallmentsTable createAlias(String alias) {
    return $ChittyInstallmentsTable(attachedDatabase, alias);
  }
}

class ChittyInstallment extends DataClass
    implements Insertable<ChittyInstallment> {
  final String id;
  final String investmentId;
  final int installmentNumber;
  final DateTime dueDate;
  final double grossInstallment;
  final double dividendEarned;
  final double netAmountPaid;
  final DateTime? paymentDate;
  final bool isPaid;
  final bool isPrizedMonth;
  final double prizeAmountReceived;
  const ChittyInstallment({
    required this.id,
    required this.investmentId,
    required this.installmentNumber,
    required this.dueDate,
    required this.grossInstallment,
    required this.dividendEarned,
    required this.netAmountPaid,
    this.paymentDate,
    required this.isPaid,
    required this.isPrizedMonth,
    required this.prizeAmountReceived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['investment_id'] = Variable<String>(investmentId);
    map['installment_number'] = Variable<int>(installmentNumber);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['gross_installment'] = Variable<double>(grossInstallment);
    map['dividend_earned'] = Variable<double>(dividendEarned);
    map['net_amount_paid'] = Variable<double>(netAmountPaid);
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<DateTime>(paymentDate);
    }
    map['is_paid'] = Variable<bool>(isPaid);
    map['is_prized_month'] = Variable<bool>(isPrizedMonth);
    map['prize_amount_received'] = Variable<double>(prizeAmountReceived);
    return map;
  }

  ChittyInstallmentsCompanion toCompanion(bool nullToAbsent) {
    return ChittyInstallmentsCompanion(
      id: Value(id),
      investmentId: Value(investmentId),
      installmentNumber: Value(installmentNumber),
      dueDate: Value(dueDate),
      grossInstallment: Value(grossInstallment),
      dividendEarned: Value(dividendEarned),
      netAmountPaid: Value(netAmountPaid),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      isPaid: Value(isPaid),
      isPrizedMonth: Value(isPrizedMonth),
      prizeAmountReceived: Value(prizeAmountReceived),
    );
  }

  factory ChittyInstallment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChittyInstallment(
      id: serializer.fromJson<String>(json['id']),
      investmentId: serializer.fromJson<String>(json['investmentId']),
      installmentNumber: serializer.fromJson<int>(json['installmentNumber']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      grossInstallment: serializer.fromJson<double>(json['grossInstallment']),
      dividendEarned: serializer.fromJson<double>(json['dividendEarned']),
      netAmountPaid: serializer.fromJson<double>(json['netAmountPaid']),
      paymentDate: serializer.fromJson<DateTime?>(json['paymentDate']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      isPrizedMonth: serializer.fromJson<bool>(json['isPrizedMonth']),
      prizeAmountReceived: serializer.fromJson<double>(
        json['prizeAmountReceived'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'investmentId': serializer.toJson<String>(investmentId),
      'installmentNumber': serializer.toJson<int>(installmentNumber),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'grossInstallment': serializer.toJson<double>(grossInstallment),
      'dividendEarned': serializer.toJson<double>(dividendEarned),
      'netAmountPaid': serializer.toJson<double>(netAmountPaid),
      'paymentDate': serializer.toJson<DateTime?>(paymentDate),
      'isPaid': serializer.toJson<bool>(isPaid),
      'isPrizedMonth': serializer.toJson<bool>(isPrizedMonth),
      'prizeAmountReceived': serializer.toJson<double>(prizeAmountReceived),
    };
  }

  ChittyInstallment copyWith({
    String? id,
    String? investmentId,
    int? installmentNumber,
    DateTime? dueDate,
    double? grossInstallment,
    double? dividendEarned,
    double? netAmountPaid,
    Value<DateTime?> paymentDate = const Value.absent(),
    bool? isPaid,
    bool? isPrizedMonth,
    double? prizeAmountReceived,
  }) => ChittyInstallment(
    id: id ?? this.id,
    investmentId: investmentId ?? this.investmentId,
    installmentNumber: installmentNumber ?? this.installmentNumber,
    dueDate: dueDate ?? this.dueDate,
    grossInstallment: grossInstallment ?? this.grossInstallment,
    dividendEarned: dividendEarned ?? this.dividendEarned,
    netAmountPaid: netAmountPaid ?? this.netAmountPaid,
    paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
    isPaid: isPaid ?? this.isPaid,
    isPrizedMonth: isPrizedMonth ?? this.isPrizedMonth,
    prizeAmountReceived: prizeAmountReceived ?? this.prizeAmountReceived,
  );
  ChittyInstallment copyWithCompanion(ChittyInstallmentsCompanion data) {
    return ChittyInstallment(
      id: data.id.present ? data.id.value : this.id,
      investmentId: data.investmentId.present
          ? data.investmentId.value
          : this.investmentId,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      grossInstallment: data.grossInstallment.present
          ? data.grossInstallment.value
          : this.grossInstallment,
      dividendEarned: data.dividendEarned.present
          ? data.dividendEarned.value
          : this.dividendEarned,
      netAmountPaid: data.netAmountPaid.present
          ? data.netAmountPaid.value
          : this.netAmountPaid,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      isPrizedMonth: data.isPrizedMonth.present
          ? data.isPrizedMonth.value
          : this.isPrizedMonth,
      prizeAmountReceived: data.prizeAmountReceived.present
          ? data.prizeAmountReceived.value
          : this.prizeAmountReceived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChittyInstallment(')
          ..write('id: $id, ')
          ..write('investmentId: $investmentId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('grossInstallment: $grossInstallment, ')
          ..write('dividendEarned: $dividendEarned, ')
          ..write('netAmountPaid: $netAmountPaid, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('isPaid: $isPaid, ')
          ..write('isPrizedMonth: $isPrizedMonth, ')
          ..write('prizeAmountReceived: $prizeAmountReceived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    investmentId,
    installmentNumber,
    dueDate,
    grossInstallment,
    dividendEarned,
    netAmountPaid,
    paymentDate,
    isPaid,
    isPrizedMonth,
    prizeAmountReceived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChittyInstallment &&
          other.id == this.id &&
          other.investmentId == this.investmentId &&
          other.installmentNumber == this.installmentNumber &&
          other.dueDate == this.dueDate &&
          other.grossInstallment == this.grossInstallment &&
          other.dividendEarned == this.dividendEarned &&
          other.netAmountPaid == this.netAmountPaid &&
          other.paymentDate == this.paymentDate &&
          other.isPaid == this.isPaid &&
          other.isPrizedMonth == this.isPrizedMonth &&
          other.prizeAmountReceived == this.prizeAmountReceived);
}

class ChittyInstallmentsCompanion extends UpdateCompanion<ChittyInstallment> {
  final Value<String> id;
  final Value<String> investmentId;
  final Value<int> installmentNumber;
  final Value<DateTime> dueDate;
  final Value<double> grossInstallment;
  final Value<double> dividendEarned;
  final Value<double> netAmountPaid;
  final Value<DateTime?> paymentDate;
  final Value<bool> isPaid;
  final Value<bool> isPrizedMonth;
  final Value<double> prizeAmountReceived;
  final Value<int> rowid;
  const ChittyInstallmentsCompanion({
    this.id = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.grossInstallment = const Value.absent(),
    this.dividendEarned = const Value.absent(),
    this.netAmountPaid = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.isPrizedMonth = const Value.absent(),
    this.prizeAmountReceived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChittyInstallmentsCompanion.insert({
    required String id,
    required String investmentId,
    required int installmentNumber,
    required DateTime dueDate,
    required double grossInstallment,
    this.dividendEarned = const Value.absent(),
    required double netAmountPaid,
    this.paymentDate = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.isPrizedMonth = const Value.absent(),
    this.prizeAmountReceived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       investmentId = Value(investmentId),
       installmentNumber = Value(installmentNumber),
       dueDate = Value(dueDate),
       grossInstallment = Value(grossInstallment),
       netAmountPaid = Value(netAmountPaid);
  static Insertable<ChittyInstallment> custom({
    Expression<String>? id,
    Expression<String>? investmentId,
    Expression<int>? installmentNumber,
    Expression<DateTime>? dueDate,
    Expression<double>? grossInstallment,
    Expression<double>? dividendEarned,
    Expression<double>? netAmountPaid,
    Expression<DateTime>? paymentDate,
    Expression<bool>? isPaid,
    Expression<bool>? isPrizedMonth,
    Expression<double>? prizeAmountReceived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (investmentId != null) 'investment_id': investmentId,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (dueDate != null) 'due_date': dueDate,
      if (grossInstallment != null) 'gross_installment': grossInstallment,
      if (dividendEarned != null) 'dividend_earned': dividendEarned,
      if (netAmountPaid != null) 'net_amount_paid': netAmountPaid,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (isPaid != null) 'is_paid': isPaid,
      if (isPrizedMonth != null) 'is_prized_month': isPrizedMonth,
      if (prizeAmountReceived != null)
        'prize_amount_received': prizeAmountReceived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChittyInstallmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? investmentId,
    Value<int>? installmentNumber,
    Value<DateTime>? dueDate,
    Value<double>? grossInstallment,
    Value<double>? dividendEarned,
    Value<double>? netAmountPaid,
    Value<DateTime?>? paymentDate,
    Value<bool>? isPaid,
    Value<bool>? isPrizedMonth,
    Value<double>? prizeAmountReceived,
    Value<int>? rowid,
  }) {
    return ChittyInstallmentsCompanion(
      id: id ?? this.id,
      investmentId: investmentId ?? this.investmentId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      dueDate: dueDate ?? this.dueDate,
      grossInstallment: grossInstallment ?? this.grossInstallment,
      dividendEarned: dividendEarned ?? this.dividendEarned,
      netAmountPaid: netAmountPaid ?? this.netAmountPaid,
      paymentDate: paymentDate ?? this.paymentDate,
      isPaid: isPaid ?? this.isPaid,
      isPrizedMonth: isPrizedMonth ?? this.isPrizedMonth,
      prizeAmountReceived: prizeAmountReceived ?? this.prizeAmountReceived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (investmentId.present) {
      map['investment_id'] = Variable<String>(investmentId.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (grossInstallment.present) {
      map['gross_installment'] = Variable<double>(grossInstallment.value);
    }
    if (dividendEarned.present) {
      map['dividend_earned'] = Variable<double>(dividendEarned.value);
    }
    if (netAmountPaid.present) {
      map['net_amount_paid'] = Variable<double>(netAmountPaid.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (isPrizedMonth.present) {
      map['is_prized_month'] = Variable<bool>(isPrizedMonth.value);
    }
    if (prizeAmountReceived.present) {
      map['prize_amount_received'] = Variable<double>(
        prizeAmountReceived.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChittyInstallmentsCompanion(')
          ..write('id: $id, ')
          ..write('investmentId: $investmentId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('grossInstallment: $grossInstallment, ')
          ..write('dividendEarned: $dividendEarned, ')
          ..write('netAmountPaid: $netAmountPaid, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('isPaid: $isPaid, ')
          ..write('isPrizedMonth: $isPrizedMonth, ')
          ..write('prizeAmountReceived: $prizeAmountReceived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderTypeMeta = const VerificationMeta(
    'reminderType',
  );
  @override
  late final GeneratedColumn<String> reminderType = GeneratedColumn<String>(
    'reminder_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceIdMeta = const VerificationMeta(
    'referenceId',
  );
  @override
  late final GeneratedColumn<String> referenceId = GeneratedColumn<String>(
    'reference_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatFrequencyMeta = const VerificationMeta(
    'repeatFrequency',
  );
  @override
  late final GeneratedColumn<String> repeatFrequency = GeneratedColumn<String>(
    'repeat_frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    reminderType,
    referenceId,
    dueDate,
    repeatFrequency,
    amount,
    isActive,
    notificationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reminder_type')) {
      context.handle(
        _reminderTypeMeta,
        reminderType.isAcceptableOrUnknown(
          data['reminder_type']!,
          _reminderTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderTypeMeta);
    }
    if (data.containsKey('reference_id')) {
      context.handle(
        _referenceIdMeta,
        referenceId.isAcceptableOrUnknown(
          data['reference_id']!,
          _referenceIdMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('repeat_frequency')) {
      context.handle(
        _repeatFrequencyMeta,
        repeatFrequency.isAcceptableOrUnknown(
          data['repeat_frequency']!,
          _repeatFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      reminderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_type'],
      )!,
      referenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_id'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      repeatFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_frequency'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String title;
  final String reminderType;
  final String? referenceId;
  final DateTime dueDate;
  final String repeatFrequency;
  final double? amount;
  final bool isActive;
  final int notificationId;
  const Reminder({
    required this.id,
    required this.title,
    required this.reminderType,
    this.referenceId,
    required this.dueDate,
    required this.repeatFrequency,
    this.amount,
    required this.isActive,
    required this.notificationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['reminder_type'] = Variable<String>(reminderType);
    if (!nullToAbsent || referenceId != null) {
      map['reference_id'] = Variable<String>(referenceId);
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['repeat_frequency'] = Variable<String>(repeatFrequency);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['notification_id'] = Variable<int>(notificationId);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      reminderType: Value(reminderType),
      referenceId: referenceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceId),
      dueDate: Value(dueDate),
      repeatFrequency: Value(repeatFrequency),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      isActive: Value(isActive),
      notificationId: Value(notificationId),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      reminderType: serializer.fromJson<String>(json['reminderType']),
      referenceId: serializer.fromJson<String?>(json['referenceId']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      repeatFrequency: serializer.fromJson<String>(json['repeatFrequency']),
      amount: serializer.fromJson<double?>(json['amount']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'reminderType': serializer.toJson<String>(reminderType),
      'referenceId': serializer.toJson<String?>(referenceId),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'repeatFrequency': serializer.toJson<String>(repeatFrequency),
      'amount': serializer.toJson<double?>(amount),
      'isActive': serializer.toJson<bool>(isActive),
      'notificationId': serializer.toJson<int>(notificationId),
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? reminderType,
    Value<String?> referenceId = const Value.absent(),
    DateTime? dueDate,
    String? repeatFrequency,
    Value<double?> amount = const Value.absent(),
    bool? isActive,
    int? notificationId,
  }) => Reminder(
    id: id ?? this.id,
    title: title ?? this.title,
    reminderType: reminderType ?? this.reminderType,
    referenceId: referenceId.present ? referenceId.value : this.referenceId,
    dueDate: dueDate ?? this.dueDate,
    repeatFrequency: repeatFrequency ?? this.repeatFrequency,
    amount: amount.present ? amount.value : this.amount,
    isActive: isActive ?? this.isActive,
    notificationId: notificationId ?? this.notificationId,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      reminderType: data.reminderType.present
          ? data.reminderType.value
          : this.reminderType,
      referenceId: data.referenceId.present
          ? data.referenceId.value
          : this.referenceId,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      repeatFrequency: data.repeatFrequency.present
          ? data.repeatFrequency.value
          : this.repeatFrequency,
      amount: data.amount.present ? data.amount.value : this.amount,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('reminderType: $reminderType, ')
          ..write('referenceId: $referenceId, ')
          ..write('dueDate: $dueDate, ')
          ..write('repeatFrequency: $repeatFrequency, ')
          ..write('amount: $amount, ')
          ..write('isActive: $isActive, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    reminderType,
    referenceId,
    dueDate,
    repeatFrequency,
    amount,
    isActive,
    notificationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.title == this.title &&
          other.reminderType == this.reminderType &&
          other.referenceId == this.referenceId &&
          other.dueDate == this.dueDate &&
          other.repeatFrequency == this.repeatFrequency &&
          other.amount == this.amount &&
          other.isActive == this.isActive &&
          other.notificationId == this.notificationId);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> reminderType;
  final Value<String?> referenceId;
  final Value<DateTime> dueDate;
  final Value<String> repeatFrequency;
  final Value<double?> amount;
  final Value<bool> isActive;
  final Value<int> notificationId;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.reminderType = const Value.absent(),
    this.referenceId = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.repeatFrequency = const Value.absent(),
    this.amount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String title,
    required String reminderType,
    this.referenceId = const Value.absent(),
    required DateTime dueDate,
    this.repeatFrequency = const Value.absent(),
    this.amount = const Value.absent(),
    this.isActive = const Value.absent(),
    required int notificationId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       reminderType = Value(reminderType),
       dueDate = Value(dueDate),
       notificationId = Value(notificationId);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? reminderType,
    Expression<String>? referenceId,
    Expression<DateTime>? dueDate,
    Expression<String>? repeatFrequency,
    Expression<double>? amount,
    Expression<bool>? isActive,
    Expression<int>? notificationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (reminderType != null) 'reminder_type': reminderType,
      if (referenceId != null) 'reference_id': referenceId,
      if (dueDate != null) 'due_date': dueDate,
      if (repeatFrequency != null) 'repeat_frequency': repeatFrequency,
      if (amount != null) 'amount': amount,
      if (isActive != null) 'is_active': isActive,
      if (notificationId != null) 'notification_id': notificationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? reminderType,
    Value<String?>? referenceId,
    Value<DateTime>? dueDate,
    Value<String>? repeatFrequency,
    Value<double?>? amount,
    Value<bool>? isActive,
    Value<int>? notificationId,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      reminderType: reminderType ?? this.reminderType,
      referenceId: referenceId ?? this.referenceId,
      dueDate: dueDate ?? this.dueDate,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      amount: amount ?? this.amount,
      isActive: isActive ?? this.isActive,
      notificationId: notificationId ?? this.notificationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (reminderType.present) {
      map['reminder_type'] = Variable<String>(reminderType.value);
    }
    if (referenceId.present) {
      map['reference_id'] = Variable<String>(referenceId.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (repeatFrequency.present) {
      map['repeat_frequency'] = Variable<String>(repeatFrequency.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('reminderType: $reminderType, ')
          ..write('referenceId: $referenceId, ')
          ..write('dueDate: $dueDate, ')
          ..write('repeatFrequency: $repeatFrequency, ')
          ..write('amount: $amount, ')
          ..write('isActive: $isActive, ')
          ..write('notificationId: $notificationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $EmiLoansTable emiLoans = $EmiLoansTable(this);
  late final $EmiPaymentsTable emiPayments = $EmiPaymentsTable(this);
  late final $InvestmentsTable investments = $InvestmentsTable(this);
  late final $ChittyInstallmentsTable chittyInstallments =
      $ChittyInstallmentsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    accounts,
    transactions,
    budgets,
    emiLoans,
    emiPayments,
    investments,
    chittyInstallments,
    reminders,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budgets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('emi_loans', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('emi_loans', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'emi_loans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('emi_payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'investments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chitty_installments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String type,
      required int iconCode,
      required int colorValue,
      Value<bool> isCustom,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<int> iconCode,
      Value<int> colorValue,
      Value<bool> isCustom,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: 'categories__id__budgets__category_id',
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EmiLoansTable, List<EmiLoan>> _emiLoansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.emiLoans,
    aliasName: 'categories__id__emi_loans__expense_category_id',
  );

  $$EmiLoansTableProcessedTableManager get emiLoansRefs {
    final manager = $$EmiLoansTableTableManager($_db, $_db.emiLoans).filter(
      (f) => f.expenseCategoryId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_emiLoansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> emiLoansRefs(
    Expression<bool> Function($$EmiLoansTableFilterComposer f) f,
  ) {
    final $$EmiLoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emiLoans,
      getReferencedColumn: (t) => t.expenseCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiLoansTableFilterComposer(
            $db: $db,
            $table: $db.emiLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> emiLoansRefs<T extends Object>(
    Expression<T> Function($$EmiLoansTableAnnotationComposer a) f,
  ) {
    final $$EmiLoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emiLoans,
      getReferencedColumn: (t) => t.expenseCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiLoansTableAnnotationComposer(
            $db: $db,
            $table: $db.emiLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool transactionsRefs,
            bool budgetsRefs,
            bool emiLoansRefs,
          })
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
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                iconCode: iconCode,
                colorValue: colorValue,
                isCustom: isCustom,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required int iconCode,
                required int colorValue,
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                iconCode: iconCode,
                colorValue: colorValue,
                isCustom: isCustom,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                transactionsRefs = false,
                budgetsRefs = false,
                emiLoansRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (budgetsRefs) db.budgets,
                    if (emiLoansRefs) db.emiLoans,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (budgetsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Budget
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._budgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).budgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (emiLoansRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          EmiLoan
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._emiLoansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).emiLoansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.expenseCategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool transactionsRefs,
        bool budgetsRefs,
        bool emiLoansRefs,
      })
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      required String name,
      required String accountType,
      Value<double> currentBalance,
      Value<double?> creditLimit,
      required int iconCode,
      required int colorValue,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> accountType,
      Value<double> currentBalance,
      Value<double?> creditLimit,
      Value<int> iconCode,
      Value<int> colorValue,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EmiLoansTable, List<EmiLoan>> _emiLoansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.emiLoans,
    aliasName: 'accounts__id__emi_loans__default_account_id',
  );

  $$EmiLoansTableProcessedTableManager get emiLoansRefs {
    final manager = $$EmiLoansTableTableManager($_db, $_db.emiLoans).filter(
      (f) => f.defaultAccountId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_emiLoansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> emiLoansRefs(
    Expression<bool> Function($$EmiLoansTableFilterComposer f) f,
  ) {
    final $$EmiLoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emiLoans,
      getReferencedColumn: (t) => t.defaultAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiLoansTableFilterComposer(
            $db: $db,
            $table: $db.emiLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  Expression<T> emiLoansRefs<T extends Object>(
    Expression<T> Function($$EmiLoansTableAnnotationComposer a) f,
  ) {
    final $$EmiLoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emiLoans,
      getReferencedColumn: (t) => t.defaultAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiLoansTableAnnotationComposer(
            $db: $db,
            $table: $db.emiLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({bool emiLoansRefs})
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> accountType = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                accountType: accountType,
                currentBalance: currentBalance,
                creditLimit: creditLimit,
                iconCode: iconCode,
                colorValue: colorValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String accountType,
                Value<double> currentBalance = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                required int iconCode,
                required int colorValue,
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                accountType: accountType,
                currentBalance: currentBalance,
                creditLimit: creditLimit,
                iconCode: iconCode,
                colorValue: colorValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({emiLoansRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (emiLoansRefs) db.emiLoans],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (emiLoansRefs)
                    await $_getPrefetchedData<Account, $AccountsTable, EmiLoan>(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._emiLoansRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AccountsTableReferences(db, table, p0).emiLoansRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.defaultAccountId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({bool emiLoansRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String categoryId,
      Value<String?> accountId,
      Value<String?> toAccountId,
      required double amount,
      required String type,
      required DateTime transactionDate,
      Value<String?> notes,
      Value<String?> tag,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String?> accountId,
      Value<String?> toAccountId,
      Value<double> amount,
      Value<String> type,
      Value<DateTime> transactionDate,
      Value<String?> notes,
      Value<String?> tag,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('transactions__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<String>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _toAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('transactions__to_account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get toAccountId {
    final $_column = $_itemColumn<String>('to_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({
            bool categoryId,
            bool accountId,
            bool toAccountId,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                categoryId: categoryId,
                accountId: accountId,
                toAccountId: toAccountId,
                amount: amount,
                type: type,
                transactionDate: transactionDate,
                notes: notes,
                tag: tag,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                Value<String?> accountId = const Value.absent(),
                Value<String?> toAccountId = const Value.absent(),
                required double amount,
                required String type,
                required DateTime transactionDate,
                Value<String?> notes = const Value.absent(),
                Value<String?> tag = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                categoryId: categoryId,
                accountId: accountId,
                toAccountId: toAccountId,
                amount: amount,
                type: type,
                transactionDate: transactionDate,
                notes: notes,
                tag: tag,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, accountId = false, toAccountId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._accountIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._accountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (toAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.toAccountId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._toAccountIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._toAccountIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({
        bool categoryId,
        bool accountId,
        bool toAccountId,
      })
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String categoryId,
      required double allocatedAmount,
      required int periodMonth,
      required int periodYear,
      Value<bool> rolloverEnabled,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<double> allocatedAmount,
      Value<int> periodMonth,
      Value<int> periodYear,
      Value<bool> rolloverEnabled,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('budgets__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get allocatedAmount => $composableBuilder(
    column: $table.allocatedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodYear => $composableBuilder(
    column: $table.periodYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rolloverEnabled => $composableBuilder(
    column: $table.rolloverEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get allocatedAmount => $composableBuilder(
    column: $table.allocatedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodYear => $composableBuilder(
    column: $table.periodYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rolloverEnabled => $composableBuilder(
    column: $table.rolloverEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get allocatedAmount => $composableBuilder(
    column: $table.allocatedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodYear => $composableBuilder(
    column: $table.periodYear,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rolloverEnabled => $composableBuilder(
    column: $table.rolloverEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, $$BudgetsTableReferences),
          Budget,
          PrefetchHooks Function({bool categoryId})
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<double> allocatedAmount = const Value.absent(),
                Value<int> periodMonth = const Value.absent(),
                Value<int> periodYear = const Value.absent(),
                Value<bool> rolloverEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                categoryId: categoryId,
                allocatedAmount: allocatedAmount,
                periodMonth: periodMonth,
                periodYear: periodYear,
                rolloverEnabled: rolloverEnabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required double allocatedAmount,
                required int periodMonth,
                required int periodYear,
                Value<bool> rolloverEnabled = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                categoryId: categoryId,
                allocatedAmount: allocatedAmount,
                periodMonth: periodMonth,
                periodYear: periodYear,
                rolloverEnabled: rolloverEnabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$BudgetsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$BudgetsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, $$BudgetsTableReferences),
      Budget,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$EmiLoansTableCreateCompanionBuilder =
    EmiLoansCompanion Function({
      required String id,
      required String productName,
      Value<String?> lenderName,
      required double principalAmount,
      required double annualInterestRate,
      required int tenureMonths,
      required double monthlyEmi,
      required DateTime startDate,
      Value<double> gstRateOnInterest,
      Value<String?> expenseCategoryId,
      Value<String?> defaultAccountId,
      Value<bool> autoLogExpense,
      Value<String> status,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$EmiLoansTableUpdateCompanionBuilder =
    EmiLoansCompanion Function({
      Value<String> id,
      Value<String> productName,
      Value<String?> lenderName,
      Value<double> principalAmount,
      Value<double> annualInterestRate,
      Value<int> tenureMonths,
      Value<double> monthlyEmi,
      Value<DateTime> startDate,
      Value<double> gstRateOnInterest,
      Value<String?> expenseCategoryId,
      Value<String?> defaultAccountId,
      Value<bool> autoLogExpense,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$EmiLoansTableReferences
    extends BaseReferences<_$AppDatabase, $EmiLoansTable, EmiLoan> {
  $$EmiLoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _expenseCategoryIdTable(_$AppDatabase db) => db
      .categories
      .createAlias('emi_loans__expense_category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get expenseCategoryId {
    final $_column = $_itemColumn<String>('expense_category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _defaultAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('emi_loans__default_account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get defaultAccountId {
    final $_column = $_itemColumn<String>('default_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defaultAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EmiPaymentsTable, List<EmiPayment>>
  _emiPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.emiPayments,
    aliasName: 'emi_loans__id__emi_payments__loan_id',
  );

  $$EmiPaymentsTableProcessedTableManager get emiPaymentsRefs {
    final manager = $$EmiPaymentsTableTableManager(
      $_db,
      $_db.emiPayments,
    ).filter((f) => f.loanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_emiPaymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmiLoansTableFilterComposer
    extends Composer<_$AppDatabase, $EmiLoansTable> {
  $$EmiLoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lenderName => $composableBuilder(
    column: $table.lenderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get principalAmount => $composableBuilder(
    column: $table.principalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualInterestRate => $composableBuilder(
    column: $table.annualInterestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyEmi => $composableBuilder(
    column: $table.monthlyEmi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstRateOnInterest => $composableBuilder(
    column: $table.gstRateOnInterest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoLogExpense => $composableBuilder(
    column: $table.autoLogExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get expenseCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get defaultAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> emiPaymentsRefs(
    Expression<bool> Function($$EmiPaymentsTableFilterComposer f) f,
  ) {
    final $$EmiPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emiPayments,
      getReferencedColumn: (t) => t.loanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.emiPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmiLoansTableOrderingComposer
    extends Composer<_$AppDatabase, $EmiLoansTable> {
  $$EmiLoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lenderName => $composableBuilder(
    column: $table.lenderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get principalAmount => $composableBuilder(
    column: $table.principalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualInterestRate => $composableBuilder(
    column: $table.annualInterestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyEmi => $composableBuilder(
    column: $table.monthlyEmi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstRateOnInterest => $composableBuilder(
    column: $table.gstRateOnInterest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoLogExpense => $composableBuilder(
    column: $table.autoLogExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get expenseCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get defaultAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmiLoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmiLoansTable> {
  $$EmiLoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lenderName => $composableBuilder(
    column: $table.lenderName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get principalAmount => $composableBuilder(
    column: $table.principalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get annualInterestRate => $composableBuilder(
    column: $table.annualInterestRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyEmi => $composableBuilder(
    column: $table.monthlyEmi,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<double> get gstRateOnInterest => $composableBuilder(
    column: $table.gstRateOnInterest,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoLogExpense => $composableBuilder(
    column: $table.autoLogExpense,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get expenseCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseCategoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get defaultAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> emiPaymentsRefs<T extends Object>(
    Expression<T> Function($$EmiPaymentsTableAnnotationComposer a) f,
  ) {
    final $$EmiPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.emiPayments,
      getReferencedColumn: (t) => t.loanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.emiPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmiLoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmiLoansTable,
          EmiLoan,
          $$EmiLoansTableFilterComposer,
          $$EmiLoansTableOrderingComposer,
          $$EmiLoansTableAnnotationComposer,
          $$EmiLoansTableCreateCompanionBuilder,
          $$EmiLoansTableUpdateCompanionBuilder,
          (EmiLoan, $$EmiLoansTableReferences),
          EmiLoan,
          PrefetchHooks Function({
            bool expenseCategoryId,
            bool defaultAccountId,
            bool emiPaymentsRefs,
          })
        > {
  $$EmiLoansTableTableManager(_$AppDatabase db, $EmiLoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmiLoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmiLoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmiLoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String?> lenderName = const Value.absent(),
                Value<double> principalAmount = const Value.absent(),
                Value<double> annualInterestRate = const Value.absent(),
                Value<int> tenureMonths = const Value.absent(),
                Value<double> monthlyEmi = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<double> gstRateOnInterest = const Value.absent(),
                Value<String?> expenseCategoryId = const Value.absent(),
                Value<String?> defaultAccountId = const Value.absent(),
                Value<bool> autoLogExpense = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmiLoansCompanion(
                id: id,
                productName: productName,
                lenderName: lenderName,
                principalAmount: principalAmount,
                annualInterestRate: annualInterestRate,
                tenureMonths: tenureMonths,
                monthlyEmi: monthlyEmi,
                startDate: startDate,
                gstRateOnInterest: gstRateOnInterest,
                expenseCategoryId: expenseCategoryId,
                defaultAccountId: defaultAccountId,
                autoLogExpense: autoLogExpense,
                status: status,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productName,
                Value<String?> lenderName = const Value.absent(),
                required double principalAmount,
                required double annualInterestRate,
                required int tenureMonths,
                required double monthlyEmi,
                required DateTime startDate,
                Value<double> gstRateOnInterest = const Value.absent(),
                Value<String?> expenseCategoryId = const Value.absent(),
                Value<String?> defaultAccountId = const Value.absent(),
                Value<bool> autoLogExpense = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EmiLoansCompanion.insert(
                id: id,
                productName: productName,
                lenderName: lenderName,
                principalAmount: principalAmount,
                annualInterestRate: annualInterestRate,
                tenureMonths: tenureMonths,
                monthlyEmi: monthlyEmi,
                startDate: startDate,
                gstRateOnInterest: gstRateOnInterest,
                expenseCategoryId: expenseCategoryId,
                defaultAccountId: defaultAccountId,
                autoLogExpense: autoLogExpense,
                status: status,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmiLoansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                expenseCategoryId = false,
                defaultAccountId = false,
                emiPaymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (emiPaymentsRefs) db.emiPayments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (expenseCategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.expenseCategoryId,
                                    referencedTable: $$EmiLoansTableReferences
                                        ._expenseCategoryIdTable(db),
                                    referencedColumn: $$EmiLoansTableReferences
                                        ._expenseCategoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (defaultAccountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.defaultAccountId,
                                    referencedTable: $$EmiLoansTableReferences
                                        ._defaultAccountIdTable(db),
                                    referencedColumn: $$EmiLoansTableReferences
                                        ._defaultAccountIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (emiPaymentsRefs)
                        await $_getPrefetchedData<
                          EmiLoan,
                          $EmiLoansTable,
                          EmiPayment
                        >(
                          currentTable: table,
                          referencedTable: $$EmiLoansTableReferences
                              ._emiPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmiLoansTableReferences(
                                db,
                                table,
                                p0,
                              ).emiPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.loanId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EmiLoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmiLoansTable,
      EmiLoan,
      $$EmiLoansTableFilterComposer,
      $$EmiLoansTableOrderingComposer,
      $$EmiLoansTableAnnotationComposer,
      $$EmiLoansTableCreateCompanionBuilder,
      $$EmiLoansTableUpdateCompanionBuilder,
      (EmiLoan, $$EmiLoansTableReferences),
      EmiLoan,
      PrefetchHooks Function({
        bool expenseCategoryId,
        bool defaultAccountId,
        bool emiPaymentsRefs,
      })
    >;
typedef $$EmiPaymentsTableCreateCompanionBuilder =
    EmiPaymentsCompanion Function({
      required String id,
      required String loanId,
      required int installmentNumber,
      required DateTime paymentDate,
      required double principalPaid,
      required double interestPaid,
      Value<double> gstPaid,
      required double totalAmountPaid,
      Value<bool> isPrepayment,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$EmiPaymentsTableUpdateCompanionBuilder =
    EmiPaymentsCompanion Function({
      Value<String> id,
      Value<String> loanId,
      Value<int> installmentNumber,
      Value<DateTime> paymentDate,
      Value<double> principalPaid,
      Value<double> interestPaid,
      Value<double> gstPaid,
      Value<double> totalAmountPaid,
      Value<bool> isPrepayment,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$EmiPaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $EmiPaymentsTable, EmiPayment> {
  $$EmiPaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EmiLoansTable _loanIdTable(_$AppDatabase db) =>
      db.emiLoans.createAlias('emi_payments__loan_id__emi_loans__id');

  $$EmiLoansTableProcessedTableManager get loanId {
    final $_column = $_itemColumn<String>('loan_id')!;

    final manager = $$EmiLoansTableTableManager(
      $_db,
      $_db.emiLoans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EmiPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $EmiPaymentsTable> {
  $$EmiPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get principalPaid => $composableBuilder(
    column: $table.principalPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestPaid => $composableBuilder(
    column: $table.interestPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstPaid => $composableBuilder(
    column: $table.gstPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmountPaid => $composableBuilder(
    column: $table.totalAmountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrepayment => $composableBuilder(
    column: $table.isPrepayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$EmiLoansTableFilterComposer get loanId {
    final $$EmiLoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loanId,
      referencedTable: $db.emiLoans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiLoansTableFilterComposer(
            $db: $db,
            $table: $db.emiLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmiPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmiPaymentsTable> {
  $$EmiPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get principalPaid => $composableBuilder(
    column: $table.principalPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestPaid => $composableBuilder(
    column: $table.interestPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstPaid => $composableBuilder(
    column: $table.gstPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmountPaid => $composableBuilder(
    column: $table.totalAmountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrepayment => $composableBuilder(
    column: $table.isPrepayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmiLoansTableOrderingComposer get loanId {
    final $$EmiLoansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loanId,
      referencedTable: $db.emiLoans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiLoansTableOrderingComposer(
            $db: $db,
            $table: $db.emiLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmiPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmiPaymentsTable> {
  $$EmiPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get principalPaid => $composableBuilder(
    column: $table.principalPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestPaid => $composableBuilder(
    column: $table.interestPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstPaid =>
      $composableBuilder(column: $table.gstPaid, builder: (column) => column);

  GeneratedColumn<double> get totalAmountPaid => $composableBuilder(
    column: $table.totalAmountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrepayment => $composableBuilder(
    column: $table.isPrepayment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$EmiLoansTableAnnotationComposer get loanId {
    final $$EmiLoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loanId,
      referencedTable: $db.emiLoans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmiLoansTableAnnotationComposer(
            $db: $db,
            $table: $db.emiLoans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmiPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmiPaymentsTable,
          EmiPayment,
          $$EmiPaymentsTableFilterComposer,
          $$EmiPaymentsTableOrderingComposer,
          $$EmiPaymentsTableAnnotationComposer,
          $$EmiPaymentsTableCreateCompanionBuilder,
          $$EmiPaymentsTableUpdateCompanionBuilder,
          (EmiPayment, $$EmiPaymentsTableReferences),
          EmiPayment,
          PrefetchHooks Function({bool loanId})
        > {
  $$EmiPaymentsTableTableManager(_$AppDatabase db, $EmiPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmiPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmiPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmiPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> loanId = const Value.absent(),
                Value<int> installmentNumber = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<double> principalPaid = const Value.absent(),
                Value<double> interestPaid = const Value.absent(),
                Value<double> gstPaid = const Value.absent(),
                Value<double> totalAmountPaid = const Value.absent(),
                Value<bool> isPrepayment = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmiPaymentsCompanion(
                id: id,
                loanId: loanId,
                installmentNumber: installmentNumber,
                paymentDate: paymentDate,
                principalPaid: principalPaid,
                interestPaid: interestPaid,
                gstPaid: gstPaid,
                totalAmountPaid: totalAmountPaid,
                isPrepayment: isPrepayment,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String loanId,
                required int installmentNumber,
                required DateTime paymentDate,
                required double principalPaid,
                required double interestPaid,
                Value<double> gstPaid = const Value.absent(),
                required double totalAmountPaid,
                Value<bool> isPrepayment = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmiPaymentsCompanion.insert(
                id: id,
                loanId: loanId,
                installmentNumber: installmentNumber,
                paymentDate: paymentDate,
                principalPaid: principalPaid,
                interestPaid: interestPaid,
                gstPaid: gstPaid,
                totalAmountPaid: totalAmountPaid,
                isPrepayment: isPrepayment,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmiPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({loanId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (loanId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.loanId,
                                referencedTable: $$EmiPaymentsTableReferences
                                    ._loanIdTable(db),
                                referencedColumn: $$EmiPaymentsTableReferences
                                    ._loanIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EmiPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmiPaymentsTable,
      EmiPayment,
      $$EmiPaymentsTableFilterComposer,
      $$EmiPaymentsTableOrderingComposer,
      $$EmiPaymentsTableAnnotationComposer,
      $$EmiPaymentsTableCreateCompanionBuilder,
      $$EmiPaymentsTableUpdateCompanionBuilder,
      (EmiPayment, $$EmiPaymentsTableReferences),
      EmiPayment,
      PrefetchHooks Function({bool loanId})
    >;
typedef $$InvestmentsTableCreateCompanionBuilder =
    InvestmentsCompanion Function({
      required String id,
      required String name,
      required String type,
      required DateTime startDate,
      Value<DateTime?> maturityDate,
      Value<double?> totalCommittedAmount,
      Value<double?> quantity,
      Value<double?> purchasePrice,
      required double currentValuation,
      Value<String> status,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$InvestmentsTableUpdateCompanionBuilder =
    InvestmentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<DateTime> startDate,
      Value<DateTime?> maturityDate,
      Value<double?> totalCommittedAmount,
      Value<double?> quantity,
      Value<double?> purchasePrice,
      Value<double> currentValuation,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InvestmentsTableReferences
    extends BaseReferences<_$AppDatabase, $InvestmentsTable, Investment> {
  $$InvestmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChittyInstallmentsTable, List<ChittyInstallment>>
  _chittyInstallmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.chittyInstallments,
        aliasName: 'investments__id__chitty_installments__investment_id',
      );

  $$ChittyInstallmentsTableProcessedTableManager get chittyInstallmentsRefs {
    final manager = $$ChittyInstallmentsTableTableManager(
      $_db,
      $_db.chittyInstallments,
    ).filter((f) => f.investmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chittyInstallmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvestmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCommittedAmount => $composableBuilder(
    column: $table.totalCommittedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValuation => $composableBuilder(
    column: $table.currentValuation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chittyInstallmentsRefs(
    Expression<bool> Function($$ChittyInstallmentsTableFilterComposer f) f,
  ) {
    final $$ChittyInstallmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chittyInstallments,
      getReferencedColumn: (t) => t.investmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChittyInstallmentsTableFilterComposer(
            $db: $db,
            $table: $db.chittyInstallments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCommittedAmount => $composableBuilder(
    column: $table.totalCommittedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValuation => $composableBuilder(
    column: $table.currentValuation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalCommittedAmount => $composableBuilder(
    column: $table.totalCommittedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValuation => $composableBuilder(
    column: $table.currentValuation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> chittyInstallmentsRefs<T extends Object>(
    Expression<T> Function($$ChittyInstallmentsTableAnnotationComposer a) f,
  ) {
    final $$ChittyInstallmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.chittyInstallments,
          getReferencedColumn: (t) => t.investmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ChittyInstallmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.chittyInstallments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InvestmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentsTable,
          Investment,
          $$InvestmentsTableFilterComposer,
          $$InvestmentsTableOrderingComposer,
          $$InvestmentsTableAnnotationComposer,
          $$InvestmentsTableCreateCompanionBuilder,
          $$InvestmentsTableUpdateCompanionBuilder,
          (Investment, $$InvestmentsTableReferences),
          Investment,
          PrefetchHooks Function({bool chittyInstallmentsRefs})
        > {
  $$InvestmentsTableTableManager(_$AppDatabase db, $InvestmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> maturityDate = const Value.absent(),
                Value<double?> totalCommittedAmount = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<double> currentValuation = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion(
                id: id,
                name: name,
                type: type,
                startDate: startDate,
                maturityDate: maturityDate,
                totalCommittedAmount: totalCommittedAmount,
                quantity: quantity,
                purchasePrice: purchasePrice,
                currentValuation: currentValuation,
                status: status,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String type,
                required DateTime startDate,
                Value<DateTime?> maturityDate = const Value.absent(),
                Value<double?> totalCommittedAmount = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                required double currentValuation,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InvestmentsCompanion.insert(
                id: id,
                name: name,
                type: type,
                startDate: startDate,
                maturityDate: maturityDate,
                totalCommittedAmount: totalCommittedAmount,
                quantity: quantity,
                purchasePrice: purchasePrice,
                currentValuation: currentValuation,
                status: status,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chittyInstallmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (chittyInstallmentsRefs) db.chittyInstallments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chittyInstallmentsRefs)
                    await $_getPrefetchedData<
                      Investment,
                      $InvestmentsTable,
                      ChittyInstallment
                    >(
                      currentTable: table,
                      referencedTable: $$InvestmentsTableReferences
                          ._chittyInstallmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$InvestmentsTableReferences(
                            db,
                            table,
                            p0,
                          ).chittyInstallmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.investmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$InvestmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentsTable,
      Investment,
      $$InvestmentsTableFilterComposer,
      $$InvestmentsTableOrderingComposer,
      $$InvestmentsTableAnnotationComposer,
      $$InvestmentsTableCreateCompanionBuilder,
      $$InvestmentsTableUpdateCompanionBuilder,
      (Investment, $$InvestmentsTableReferences),
      Investment,
      PrefetchHooks Function({bool chittyInstallmentsRefs})
    >;
typedef $$ChittyInstallmentsTableCreateCompanionBuilder =
    ChittyInstallmentsCompanion Function({
      required String id,
      required String investmentId,
      required int installmentNumber,
      required DateTime dueDate,
      required double grossInstallment,
      Value<double> dividendEarned,
      required double netAmountPaid,
      Value<DateTime?> paymentDate,
      Value<bool> isPaid,
      Value<bool> isPrizedMonth,
      Value<double> prizeAmountReceived,
      Value<int> rowid,
    });
typedef $$ChittyInstallmentsTableUpdateCompanionBuilder =
    ChittyInstallmentsCompanion Function({
      Value<String> id,
      Value<String> investmentId,
      Value<int> installmentNumber,
      Value<DateTime> dueDate,
      Value<double> grossInstallment,
      Value<double> dividendEarned,
      Value<double> netAmountPaid,
      Value<DateTime?> paymentDate,
      Value<bool> isPaid,
      Value<bool> isPrizedMonth,
      Value<double> prizeAmountReceived,
      Value<int> rowid,
    });

final class $$ChittyInstallmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ChittyInstallmentsTable,
          ChittyInstallment
        > {
  $$ChittyInstallmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InvestmentsTable _investmentIdTable(_$AppDatabase db) => db
      .investments
      .createAlias('chitty_installments__investment_id__investments__id');

  $$InvestmentsTableProcessedTableManager get investmentId {
    final $_column = $_itemColumn<String>('investment_id')!;

    final manager = $$InvestmentsTableTableManager(
      $_db,
      $_db.investments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChittyInstallmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ChittyInstallmentsTable> {
  $$ChittyInstallmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grossInstallment => $composableBuilder(
    column: $table.grossInstallment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dividendEarned => $composableBuilder(
    column: $table.dividendEarned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netAmountPaid => $composableBuilder(
    column: $table.netAmountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrizedMonth => $composableBuilder(
    column: $table.isPrizedMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prizeAmountReceived => $composableBuilder(
    column: $table.prizeAmountReceived,
    builder: (column) => ColumnFilters(column),
  );

  $$InvestmentsTableFilterComposer get investmentId {
    final $$InvestmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableFilterComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChittyInstallmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChittyInstallmentsTable> {
  $$ChittyInstallmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grossInstallment => $composableBuilder(
    column: $table.grossInstallment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dividendEarned => $composableBuilder(
    column: $table.dividendEarned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netAmountPaid => $composableBuilder(
    column: $table.netAmountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrizedMonth => $composableBuilder(
    column: $table.isPrizedMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prizeAmountReceived => $composableBuilder(
    column: $table.prizeAmountReceived,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvestmentsTableOrderingComposer get investmentId {
    final $$InvestmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableOrderingComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChittyInstallmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChittyInstallmentsTable> {
  $$ChittyInstallmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get grossInstallment => $composableBuilder(
    column: $table.grossInstallment,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dividendEarned => $composableBuilder(
    column: $table.dividendEarned,
    builder: (column) => column,
  );

  GeneratedColumn<double> get netAmountPaid => $composableBuilder(
    column: $table.netAmountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<bool> get isPrizedMonth => $composableBuilder(
    column: $table.isPrizedMonth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get prizeAmountReceived => $composableBuilder(
    column: $table.prizeAmountReceived,
    builder: (column) => column,
  );

  $$InvestmentsTableAnnotationComposer get investmentId {
    final $$InvestmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investmentId,
      referencedTable: $db.investments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.investments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChittyInstallmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChittyInstallmentsTable,
          ChittyInstallment,
          $$ChittyInstallmentsTableFilterComposer,
          $$ChittyInstallmentsTableOrderingComposer,
          $$ChittyInstallmentsTableAnnotationComposer,
          $$ChittyInstallmentsTableCreateCompanionBuilder,
          $$ChittyInstallmentsTableUpdateCompanionBuilder,
          (ChittyInstallment, $$ChittyInstallmentsTableReferences),
          ChittyInstallment,
          PrefetchHooks Function({bool investmentId})
        > {
  $$ChittyInstallmentsTableTableManager(
    _$AppDatabase db,
    $ChittyInstallmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChittyInstallmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChittyInstallmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChittyInstallmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> investmentId = const Value.absent(),
                Value<int> installmentNumber = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<double> grossInstallment = const Value.absent(),
                Value<double> dividendEarned = const Value.absent(),
                Value<double> netAmountPaid = const Value.absent(),
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<bool> isPrizedMonth = const Value.absent(),
                Value<double> prizeAmountReceived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChittyInstallmentsCompanion(
                id: id,
                investmentId: investmentId,
                installmentNumber: installmentNumber,
                dueDate: dueDate,
                grossInstallment: grossInstallment,
                dividendEarned: dividendEarned,
                netAmountPaid: netAmountPaid,
                paymentDate: paymentDate,
                isPaid: isPaid,
                isPrizedMonth: isPrizedMonth,
                prizeAmountReceived: prizeAmountReceived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String investmentId,
                required int installmentNumber,
                required DateTime dueDate,
                required double grossInstallment,
                Value<double> dividendEarned = const Value.absent(),
                required double netAmountPaid,
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<bool> isPrizedMonth = const Value.absent(),
                Value<double> prizeAmountReceived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChittyInstallmentsCompanion.insert(
                id: id,
                investmentId: investmentId,
                installmentNumber: installmentNumber,
                dueDate: dueDate,
                grossInstallment: grossInstallment,
                dividendEarned: dividendEarned,
                netAmountPaid: netAmountPaid,
                paymentDate: paymentDate,
                isPaid: isPaid,
                isPrizedMonth: isPrizedMonth,
                prizeAmountReceived: prizeAmountReceived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChittyInstallmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({investmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (investmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.investmentId,
                                referencedTable:
                                    $$ChittyInstallmentsTableReferences
                                        ._investmentIdTable(db),
                                referencedColumn:
                                    $$ChittyInstallmentsTableReferences
                                        ._investmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChittyInstallmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChittyInstallmentsTable,
      ChittyInstallment,
      $$ChittyInstallmentsTableFilterComposer,
      $$ChittyInstallmentsTableOrderingComposer,
      $$ChittyInstallmentsTableAnnotationComposer,
      $$ChittyInstallmentsTableCreateCompanionBuilder,
      $$ChittyInstallmentsTableUpdateCompanionBuilder,
      (ChittyInstallment, $$ChittyInstallmentsTableReferences),
      ChittyInstallment,
      PrefetchHooks Function({bool investmentId})
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      required String title,
      required String reminderType,
      Value<String?> referenceId,
      required DateTime dueDate,
      Value<String> repeatFrequency,
      Value<double?> amount,
      Value<bool> isActive,
      required int notificationId,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> reminderType,
      Value<String?> referenceId,
      Value<DateTime> dueDate,
      Value<String> repeatFrequency,
      Value<double?> amount,
      Value<bool> isActive,
      Value<int> notificationId,
      Value<int> rowid,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatFrequency => $composableBuilder(
    column: $table.repeatFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatFrequency => $composableBuilder(
    column: $table.repeatFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceId => $composableBuilder(
    column: $table.referenceId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get repeatFrequency => $composableBuilder(
    column: $table.repeatFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> reminderType = const Value.absent(),
                Value<String?> referenceId = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> repeatFrequency = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                title: title,
                reminderType: reminderType,
                referenceId: referenceId,
                dueDate: dueDate,
                repeatFrequency: repeatFrequency,
                amount: amount,
                isActive: isActive,
                notificationId: notificationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String reminderType,
                Value<String?> referenceId = const Value.absent(),
                required DateTime dueDate,
                Value<String> repeatFrequency = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required int notificationId,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                title: title,
                reminderType: reminderType,
                referenceId: referenceId,
                dueDate: dueDate,
                repeatFrequency: repeatFrequency,
                amount: amount,
                isActive: isActive,
                notificationId: notificationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$EmiLoansTableTableManager get emiLoans =>
      $$EmiLoansTableTableManager(_db, _db.emiLoans);
  $$EmiPaymentsTableTableManager get emiPayments =>
      $$EmiPaymentsTableTableManager(_db, _db.emiPayments);
  $$InvestmentsTableTableManager get investments =>
      $$InvestmentsTableTableManager(_db, _db.investments);
  $$ChittyInstallmentsTableTableManager get chittyInstallments =>
      $$ChittyInstallmentsTableTableManager(_db, _db.chittyInstallments);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
