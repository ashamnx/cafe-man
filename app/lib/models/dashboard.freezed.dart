// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) {
  return _DashboardData.fromJson(json);
}

/// @nodoc
mixin _$DashboardData {
  @JsonKey(name: 'ingredient_count')
  int get ingredientCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipe_count')
  int get recipeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_count')
  int get vendorCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_count')
  int get lowStockCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_alerts')
  int get unreadAlerts => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock')
  List<LowStockItem> get lowStock => throw _privateConstructorUsedError;
  @JsonKey(name: 'recent_movements')
  List<StockMovementBrief> get recentMovements =>
      throw _privateConstructorUsedError;

  /// Serializes this DashboardData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardDataCopyWith<DashboardData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDataCopyWith<$Res> {
  factory $DashboardDataCopyWith(
    DashboardData value,
    $Res Function(DashboardData) then,
  ) = _$DashboardDataCopyWithImpl<$Res, DashboardData>;
  @useResult
  $Res call({
    @JsonKey(name: 'ingredient_count') int ingredientCount,
    @JsonKey(name: 'recipe_count') int recipeCount,
    @JsonKey(name: 'vendor_count') int vendorCount,
    @JsonKey(name: 'low_stock_count') int lowStockCount,
    @JsonKey(name: 'unread_alerts') int unreadAlerts,
    @JsonKey(name: 'low_stock') List<LowStockItem> lowStock,
    @JsonKey(name: 'recent_movements') List<StockMovementBrief> recentMovements,
  });
}

/// @nodoc
class _$DashboardDataCopyWithImpl<$Res, $Val extends DashboardData>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ingredientCount = null,
    Object? recipeCount = null,
    Object? vendorCount = null,
    Object? lowStockCount = null,
    Object? unreadAlerts = null,
    Object? lowStock = null,
    Object? recentMovements = null,
  }) {
    return _then(
      _value.copyWith(
            ingredientCount: null == ingredientCount
                ? _value.ingredientCount
                : ingredientCount // ignore: cast_nullable_to_non_nullable
                      as int,
            recipeCount: null == recipeCount
                ? _value.recipeCount
                : recipeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            vendorCount: null == vendorCount
                ? _value.vendorCount
                : vendorCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lowStockCount: null == lowStockCount
                ? _value.lowStockCount
                : lowStockCount // ignore: cast_nullable_to_non_nullable
                      as int,
            unreadAlerts: null == unreadAlerts
                ? _value.unreadAlerts
                : unreadAlerts // ignore: cast_nullable_to_non_nullable
                      as int,
            lowStock: null == lowStock
                ? _value.lowStock
                : lowStock // ignore: cast_nullable_to_non_nullable
                      as List<LowStockItem>,
            recentMovements: null == recentMovements
                ? _value.recentMovements
                : recentMovements // ignore: cast_nullable_to_non_nullable
                      as List<StockMovementBrief>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardDataImplCopyWith<$Res>
    implements $DashboardDataCopyWith<$Res> {
  factory _$$DashboardDataImplCopyWith(
    _$DashboardDataImpl value,
    $Res Function(_$DashboardDataImpl) then,
  ) = __$$DashboardDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'ingredient_count') int ingredientCount,
    @JsonKey(name: 'recipe_count') int recipeCount,
    @JsonKey(name: 'vendor_count') int vendorCount,
    @JsonKey(name: 'low_stock_count') int lowStockCount,
    @JsonKey(name: 'unread_alerts') int unreadAlerts,
    @JsonKey(name: 'low_stock') List<LowStockItem> lowStock,
    @JsonKey(name: 'recent_movements') List<StockMovementBrief> recentMovements,
  });
}

/// @nodoc
class __$$DashboardDataImplCopyWithImpl<$Res>
    extends _$DashboardDataCopyWithImpl<$Res, _$DashboardDataImpl>
    implements _$$DashboardDataImplCopyWith<$Res> {
  __$$DashboardDataImplCopyWithImpl(
    _$DashboardDataImpl _value,
    $Res Function(_$DashboardDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ingredientCount = null,
    Object? recipeCount = null,
    Object? vendorCount = null,
    Object? lowStockCount = null,
    Object? unreadAlerts = null,
    Object? lowStock = null,
    Object? recentMovements = null,
  }) {
    return _then(
      _$DashboardDataImpl(
        ingredientCount: null == ingredientCount
            ? _value.ingredientCount
            : ingredientCount // ignore: cast_nullable_to_non_nullable
                  as int,
        recipeCount: null == recipeCount
            ? _value.recipeCount
            : recipeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        vendorCount: null == vendorCount
            ? _value.vendorCount
            : vendorCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lowStockCount: null == lowStockCount
            ? _value.lowStockCount
            : lowStockCount // ignore: cast_nullable_to_non_nullable
                  as int,
        unreadAlerts: null == unreadAlerts
            ? _value.unreadAlerts
            : unreadAlerts // ignore: cast_nullable_to_non_nullable
                  as int,
        lowStock: null == lowStock
            ? _value._lowStock
            : lowStock // ignore: cast_nullable_to_non_nullable
                  as List<LowStockItem>,
        recentMovements: null == recentMovements
            ? _value._recentMovements
            : recentMovements // ignore: cast_nullable_to_non_nullable
                  as List<StockMovementBrief>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardDataImpl implements _DashboardData {
  const _$DashboardDataImpl({
    @JsonKey(name: 'ingredient_count') this.ingredientCount = 0,
    @JsonKey(name: 'recipe_count') this.recipeCount = 0,
    @JsonKey(name: 'vendor_count') this.vendorCount = 0,
    @JsonKey(name: 'low_stock_count') this.lowStockCount = 0,
    @JsonKey(name: 'unread_alerts') this.unreadAlerts = 0,
    @JsonKey(name: 'low_stock') final List<LowStockItem> lowStock = const [],
    @JsonKey(name: 'recent_movements')
    final List<StockMovementBrief> recentMovements = const [],
  }) : _lowStock = lowStock,
       _recentMovements = recentMovements;

  factory _$DashboardDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardDataImplFromJson(json);

  @override
  @JsonKey(name: 'ingredient_count')
  final int ingredientCount;
  @override
  @JsonKey(name: 'recipe_count')
  final int recipeCount;
  @override
  @JsonKey(name: 'vendor_count')
  final int vendorCount;
  @override
  @JsonKey(name: 'low_stock_count')
  final int lowStockCount;
  @override
  @JsonKey(name: 'unread_alerts')
  final int unreadAlerts;
  final List<LowStockItem> _lowStock;
  @override
  @JsonKey(name: 'low_stock')
  List<LowStockItem> get lowStock {
    if (_lowStock is EqualUnmodifiableListView) return _lowStock;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lowStock);
  }

  final List<StockMovementBrief> _recentMovements;
  @override
  @JsonKey(name: 'recent_movements')
  List<StockMovementBrief> get recentMovements {
    if (_recentMovements is EqualUnmodifiableListView) return _recentMovements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentMovements);
  }

  @override
  String toString() {
    return 'DashboardData(ingredientCount: $ingredientCount, recipeCount: $recipeCount, vendorCount: $vendorCount, lowStockCount: $lowStockCount, unreadAlerts: $unreadAlerts, lowStock: $lowStock, recentMovements: $recentMovements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataImpl &&
            (identical(other.ingredientCount, ingredientCount) ||
                other.ingredientCount == ingredientCount) &&
            (identical(other.recipeCount, recipeCount) ||
                other.recipeCount == recipeCount) &&
            (identical(other.vendorCount, vendorCount) ||
                other.vendorCount == vendorCount) &&
            (identical(other.lowStockCount, lowStockCount) ||
                other.lowStockCount == lowStockCount) &&
            (identical(other.unreadAlerts, unreadAlerts) ||
                other.unreadAlerts == unreadAlerts) &&
            const DeepCollectionEquality().equals(other._lowStock, _lowStock) &&
            const DeepCollectionEquality().equals(
              other._recentMovements,
              _recentMovements,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    ingredientCount,
    recipeCount,
    vendorCount,
    lowStockCount,
    unreadAlerts,
    const DeepCollectionEquality().hash(_lowStock),
    const DeepCollectionEquality().hash(_recentMovements),
  );

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      __$$DashboardDataImplCopyWithImpl<_$DashboardDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardDataImplToJson(this);
  }
}

abstract class _DashboardData implements DashboardData {
  const factory _DashboardData({
    @JsonKey(name: 'ingredient_count') final int ingredientCount,
    @JsonKey(name: 'recipe_count') final int recipeCount,
    @JsonKey(name: 'vendor_count') final int vendorCount,
    @JsonKey(name: 'low_stock_count') final int lowStockCount,
    @JsonKey(name: 'unread_alerts') final int unreadAlerts,
    @JsonKey(name: 'low_stock') final List<LowStockItem> lowStock,
    @JsonKey(name: 'recent_movements')
    final List<StockMovementBrief> recentMovements,
  }) = _$DashboardDataImpl;

  factory _DashboardData.fromJson(Map<String, dynamic> json) =
      _$DashboardDataImpl.fromJson;

  @override
  @JsonKey(name: 'ingredient_count')
  int get ingredientCount;
  @override
  @JsonKey(name: 'recipe_count')
  int get recipeCount;
  @override
  @JsonKey(name: 'vendor_count')
  int get vendorCount;
  @override
  @JsonKey(name: 'low_stock_count')
  int get lowStockCount;
  @override
  @JsonKey(name: 'unread_alerts')
  int get unreadAlerts;
  @override
  @JsonKey(name: 'low_stock')
  List<LowStockItem> get lowStock;
  @override
  @JsonKey(name: 'recent_movements')
  List<StockMovementBrief> get recentMovements;

  /// Create a copy of DashboardData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDataImplCopyWith<_$DashboardDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LowStockItem _$LowStockItemFromJson(Map<String, dynamic> json) {
  return _LowStockItem.fromJson(json);
}

/// @nodoc
mixin _$LowStockItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_stock')
  double get currentStock => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  double? get lowStockThreshold => throw _privateConstructorUsedError;
  LowStockUnit? get unit => throw _privateConstructorUsedError;

  /// Serializes this LowStockItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LowStockItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LowStockItemCopyWith<LowStockItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LowStockItemCopyWith<$Res> {
  factory $LowStockItemCopyWith(
    LowStockItem value,
    $Res Function(LowStockItem) then,
  ) = _$LowStockItemCopyWithImpl<$Res, LowStockItem>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'current_stock') double currentStock,
    @JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,
    LowStockUnit? unit,
  });

  $LowStockUnitCopyWith<$Res>? get unit;
}

/// @nodoc
class _$LowStockItemCopyWithImpl<$Res, $Val extends LowStockItem>
    implements $LowStockItemCopyWith<$Res> {
  _$LowStockItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LowStockItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? currentStock = null,
    Object? lowStockThreshold = freezed,
    Object? unit = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            currentStock: null == currentStock
                ? _value.currentStock
                : currentStock // ignore: cast_nullable_to_non_nullable
                      as double,
            lowStockThreshold: freezed == lowStockThreshold
                ? _value.lowStockThreshold
                : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                      as double?,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as LowStockUnit?,
          )
          as $Val,
    );
  }

  /// Create a copy of LowStockItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LowStockUnitCopyWith<$Res>? get unit {
    if (_value.unit == null) {
      return null;
    }

    return $LowStockUnitCopyWith<$Res>(_value.unit!, (value) {
      return _then(_value.copyWith(unit: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LowStockItemImplCopyWith<$Res>
    implements $LowStockItemCopyWith<$Res> {
  factory _$$LowStockItemImplCopyWith(
    _$LowStockItemImpl value,
    $Res Function(_$LowStockItemImpl) then,
  ) = __$$LowStockItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'current_stock') double currentStock,
    @JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,
    LowStockUnit? unit,
  });

  @override
  $LowStockUnitCopyWith<$Res>? get unit;
}

/// @nodoc
class __$$LowStockItemImplCopyWithImpl<$Res>
    extends _$LowStockItemCopyWithImpl<$Res, _$LowStockItemImpl>
    implements _$$LowStockItemImplCopyWith<$Res> {
  __$$LowStockItemImplCopyWithImpl(
    _$LowStockItemImpl _value,
    $Res Function(_$LowStockItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LowStockItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? currentStock = null,
    Object? lowStockThreshold = freezed,
    Object? unit = freezed,
  }) {
    return _then(
      _$LowStockItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        currentStock: null == currentStock
            ? _value.currentStock
            : currentStock // ignore: cast_nullable_to_non_nullable
                  as double,
        lowStockThreshold: freezed == lowStockThreshold
            ? _value.lowStockThreshold
            : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                  as double?,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as LowStockUnit?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LowStockItemImpl implements _LowStockItem {
  const _$LowStockItemImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'current_stock') this.currentStock = 0,
    @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold,
    this.unit,
  });

  factory _$LowStockItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LowStockItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'current_stock')
  final double currentStock;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final double? lowStockThreshold;
  @override
  final LowStockUnit? unit;

  @override
  String toString() {
    return 'LowStockItem(id: $id, name: $name, currentStock: $currentStock, lowStockThreshold: $lowStockThreshold, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LowStockItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.currentStock, currentStock) ||
                other.currentStock == currentStock) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, currentStock, lowStockThreshold, unit);

  /// Create a copy of LowStockItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LowStockItemImplCopyWith<_$LowStockItemImpl> get copyWith =>
      __$$LowStockItemImplCopyWithImpl<_$LowStockItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LowStockItemImplToJson(this);
  }
}

abstract class _LowStockItem implements LowStockItem {
  const factory _LowStockItem({
    required final String id,
    required final String name,
    @JsonKey(name: 'current_stock') final double currentStock,
    @JsonKey(name: 'low_stock_threshold') final double? lowStockThreshold,
    final LowStockUnit? unit,
  }) = _$LowStockItemImpl;

  factory _LowStockItem.fromJson(Map<String, dynamic> json) =
      _$LowStockItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'current_stock')
  double get currentStock;
  @override
  @JsonKey(name: 'low_stock_threshold')
  double? get lowStockThreshold;
  @override
  LowStockUnit? get unit;

  /// Create a copy of LowStockItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LowStockItemImplCopyWith<_$LowStockItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LowStockUnit _$LowStockUnitFromJson(Map<String, dynamic> json) {
  return _LowStockUnit.fromJson(json);
}

/// @nodoc
mixin _$LowStockUnit {
  String get abbreviation => throw _privateConstructorUsedError;

  /// Serializes this LowStockUnit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LowStockUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LowStockUnitCopyWith<LowStockUnit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LowStockUnitCopyWith<$Res> {
  factory $LowStockUnitCopyWith(
    LowStockUnit value,
    $Res Function(LowStockUnit) then,
  ) = _$LowStockUnitCopyWithImpl<$Res, LowStockUnit>;
  @useResult
  $Res call({String abbreviation});
}

/// @nodoc
class _$LowStockUnitCopyWithImpl<$Res, $Val extends LowStockUnit>
    implements $LowStockUnitCopyWith<$Res> {
  _$LowStockUnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LowStockUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? abbreviation = null}) {
    return _then(
      _value.copyWith(
            abbreviation: null == abbreviation
                ? _value.abbreviation
                : abbreviation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LowStockUnitImplCopyWith<$Res>
    implements $LowStockUnitCopyWith<$Res> {
  factory _$$LowStockUnitImplCopyWith(
    _$LowStockUnitImpl value,
    $Res Function(_$LowStockUnitImpl) then,
  ) = __$$LowStockUnitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String abbreviation});
}

/// @nodoc
class __$$LowStockUnitImplCopyWithImpl<$Res>
    extends _$LowStockUnitCopyWithImpl<$Res, _$LowStockUnitImpl>
    implements _$$LowStockUnitImplCopyWith<$Res> {
  __$$LowStockUnitImplCopyWithImpl(
    _$LowStockUnitImpl _value,
    $Res Function(_$LowStockUnitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LowStockUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? abbreviation = null}) {
    return _then(
      _$LowStockUnitImpl(
        abbreviation: null == abbreviation
            ? _value.abbreviation
            : abbreviation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LowStockUnitImpl implements _LowStockUnit {
  const _$LowStockUnitImpl({required this.abbreviation});

  factory _$LowStockUnitImpl.fromJson(Map<String, dynamic> json) =>
      _$$LowStockUnitImplFromJson(json);

  @override
  final String abbreviation;

  @override
  String toString() {
    return 'LowStockUnit(abbreviation: $abbreviation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LowStockUnitImpl &&
            (identical(other.abbreviation, abbreviation) ||
                other.abbreviation == abbreviation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, abbreviation);

  /// Create a copy of LowStockUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LowStockUnitImplCopyWith<_$LowStockUnitImpl> get copyWith =>
      __$$LowStockUnitImplCopyWithImpl<_$LowStockUnitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LowStockUnitImplToJson(this);
  }
}

abstract class _LowStockUnit implements LowStockUnit {
  const factory _LowStockUnit({required final String abbreviation}) =
      _$LowStockUnitImpl;

  factory _LowStockUnit.fromJson(Map<String, dynamic> json) =
      _$LowStockUnitImpl.fromJson;

  @override
  String get abbreviation;

  /// Create a copy of LowStockUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LowStockUnitImplCopyWith<_$LowStockUnitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StockMovementBrief _$StockMovementBriefFromJson(Map<String, dynamic> json) {
  return _StockMovementBrief.fromJson(json);
}

/// @nodoc
mixin _$StockMovementBrief {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_name')
  String get ingredientName => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_abbr')
  String get unitAbbr => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'movement_type')
  String get movementType => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StockMovementBrief to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockMovementBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockMovementBriefCopyWith<StockMovementBrief> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockMovementBriefCopyWith<$Res> {
  factory $StockMovementBriefCopyWith(
    StockMovementBrief value,
    $Res Function(StockMovementBrief) then,
  ) = _$StockMovementBriefCopyWithImpl<$Res, StockMovementBrief>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'ingredient_name') String ingredientName,
    @JsonKey(name: 'unit_abbr') String unitAbbr,
    double quantity,
    @JsonKey(name: 'movement_type') String movementType,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$StockMovementBriefCopyWithImpl<$Res, $Val extends StockMovementBrief>
    implements $StockMovementBriefCopyWith<$Res> {
  _$StockMovementBriefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockMovementBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientName = null,
    Object? unitAbbr = null,
    Object? quantity = null,
    Object? movementType = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ingredientName: null == ingredientName
                ? _value.ingredientName
                : ingredientName // ignore: cast_nullable_to_non_nullable
                      as String,
            unitAbbr: null == unitAbbr
                ? _value.unitAbbr
                : unitAbbr // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            movementType: null == movementType
                ? _value.movementType
                : movementType // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StockMovementBriefImplCopyWith<$Res>
    implements $StockMovementBriefCopyWith<$Res> {
  factory _$$StockMovementBriefImplCopyWith(
    _$StockMovementBriefImpl value,
    $Res Function(_$StockMovementBriefImpl) then,
  ) = __$$StockMovementBriefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'ingredient_name') String ingredientName,
    @JsonKey(name: 'unit_abbr') String unitAbbr,
    double quantity,
    @JsonKey(name: 'movement_type') String movementType,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$StockMovementBriefImplCopyWithImpl<$Res>
    extends _$StockMovementBriefCopyWithImpl<$Res, _$StockMovementBriefImpl>
    implements _$$StockMovementBriefImplCopyWith<$Res> {
  __$$StockMovementBriefImplCopyWithImpl(
    _$StockMovementBriefImpl _value,
    $Res Function(_$StockMovementBriefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockMovementBrief
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientName = null,
    Object? unitAbbr = null,
    Object? quantity = null,
    Object? movementType = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$StockMovementBriefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ingredientName: null == ingredientName
            ? _value.ingredientName
            : ingredientName // ignore: cast_nullable_to_non_nullable
                  as String,
        unitAbbr: null == unitAbbr
            ? _value.unitAbbr
            : unitAbbr // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        movementType: null == movementType
            ? _value.movementType
            : movementType // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StockMovementBriefImpl implements _StockMovementBrief {
  const _$StockMovementBriefImpl({
    required this.id,
    @JsonKey(name: 'ingredient_name') this.ingredientName = '',
    @JsonKey(name: 'unit_abbr') this.unitAbbr = '',
    this.quantity = 0,
    @JsonKey(name: 'movement_type') this.movementType = '',
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$StockMovementBriefImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockMovementBriefImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'ingredient_name')
  final String ingredientName;
  @override
  @JsonKey(name: 'unit_abbr')
  final String unitAbbr;
  @override
  @JsonKey()
  final double quantity;
  @override
  @JsonKey(name: 'movement_type')
  final String movementType;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'StockMovementBrief(id: $id, ingredientName: $ingredientName, unitAbbr: $unitAbbr, quantity: $quantity, movementType: $movementType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockMovementBriefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ingredientName, ingredientName) ||
                other.ingredientName == ingredientName) &&
            (identical(other.unitAbbr, unitAbbr) ||
                other.unitAbbr == unitAbbr) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.movementType, movementType) ||
                other.movementType == movementType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ingredientName,
    unitAbbr,
    quantity,
    movementType,
    createdAt,
  );

  /// Create a copy of StockMovementBrief
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockMovementBriefImplCopyWith<_$StockMovementBriefImpl> get copyWith =>
      __$$StockMovementBriefImplCopyWithImpl<_$StockMovementBriefImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StockMovementBriefImplToJson(this);
  }
}

abstract class _StockMovementBrief implements StockMovementBrief {
  const factory _StockMovementBrief({
    required final String id,
    @JsonKey(name: 'ingredient_name') final String ingredientName,
    @JsonKey(name: 'unit_abbr') final String unitAbbr,
    final double quantity,
    @JsonKey(name: 'movement_type') final String movementType,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$StockMovementBriefImpl;

  factory _StockMovementBrief.fromJson(Map<String, dynamic> json) =
      _$StockMovementBriefImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'ingredient_name')
  String get ingredientName;
  @override
  @JsonKey(name: 'unit_abbr')
  String get unitAbbr;
  @override
  double get quantity;
  @override
  @JsonKey(name: 'movement_type')
  String get movementType;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of StockMovementBrief
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockMovementBriefImplCopyWith<_$StockMovementBriefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
