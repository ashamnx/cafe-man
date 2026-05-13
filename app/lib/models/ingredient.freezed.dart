// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Ingredient _$IngredientFromJson(Map<String, dynamic> json) {
  return _Ingredient.fromJson(json);
}

/// @nodoc
mixin _$Ingredient {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_path')
  String get imagePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_id')
  String get unitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_stock')
  double get currentStock => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_cost_per_unit')
  double get currentCostPerUnit => throw _privateConstructorUsedError;
  @JsonKey(name: 'low_stock_threshold')
  double? get lowStockThreshold => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_alert_percentage')
  double get priceAlertPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  IngredientUnit? get unit => throw _privateConstructorUsedError;
  IngredientCategory? get category => throw _privateConstructorUsedError;

  /// Serializes this Ingredient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IngredientCopyWith<Ingredient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientCopyWith<$Res> {
  factory $IngredientCopyWith(
    Ingredient value,
    $Res Function(Ingredient) then,
  ) = _$IngredientCopyWithImpl<$Res, Ingredient>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    @JsonKey(name: 'image_path') String imagePath,
    @JsonKey(name: 'unit_id') String unitId,
    @JsonKey(name: 'current_stock') double currentStock,
    @JsonKey(name: 'current_cost_per_unit') double currentCostPerUnit,
    @JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,
    @JsonKey(name: 'price_alert_percentage') double priceAlertPercentage,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    IngredientUnit? unit,
    IngredientCategory? category,
  });

  $IngredientUnitCopyWith<$Res>? get unit;
  $IngredientCategoryCopyWith<$Res>? get category;
}

/// @nodoc
class _$IngredientCopyWithImpl<$Res, $Val extends Ingredient>
    implements $IngredientCopyWith<$Res> {
  _$IngredientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imagePath = null,
    Object? unitId = null,
    Object? currentStock = null,
    Object? currentCostPerUnit = null,
    Object? lowStockThreshold = freezed,
    Object? priceAlertPercentage = null,
    Object? categoryId = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? unit = freezed,
    Object? category = freezed,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            unitId: null == unitId
                ? _value.unitId
                : unitId // ignore: cast_nullable_to_non_nullable
                      as String,
            currentStock: null == currentStock
                ? _value.currentStock
                : currentStock // ignore: cast_nullable_to_non_nullable
                      as double,
            currentCostPerUnit: null == currentCostPerUnit
                ? _value.currentCostPerUnit
                : currentCostPerUnit // ignore: cast_nullable_to_non_nullable
                      as double,
            lowStockThreshold: freezed == lowStockThreshold
                ? _value.lowStockThreshold
                : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                      as double?,
            priceAlertPercentage: null == priceAlertPercentage
                ? _value.priceAlertPercentage
                : priceAlertPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as IngredientUnit?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as IngredientCategory?,
          )
          as $Val,
    );
  }

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IngredientUnitCopyWith<$Res>? get unit {
    if (_value.unit == null) {
      return null;
    }

    return $IngredientUnitCopyWith<$Res>(_value.unit!, (value) {
      return _then(_value.copyWith(unit: value) as $Val);
    });
  }

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IngredientCategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $IngredientCategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IngredientImplCopyWith<$Res>
    implements $IngredientCopyWith<$Res> {
  factory _$$IngredientImplCopyWith(
    _$IngredientImpl value,
    $Res Function(_$IngredientImpl) then,
  ) = __$$IngredientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    @JsonKey(name: 'image_path') String imagePath,
    @JsonKey(name: 'unit_id') String unitId,
    @JsonKey(name: 'current_stock') double currentStock,
    @JsonKey(name: 'current_cost_per_unit') double currentCostPerUnit,
    @JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,
    @JsonKey(name: 'price_alert_percentage') double priceAlertPercentage,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    IngredientUnit? unit,
    IngredientCategory? category,
  });

  @override
  $IngredientUnitCopyWith<$Res>? get unit;
  @override
  $IngredientCategoryCopyWith<$Res>? get category;
}

/// @nodoc
class __$$IngredientImplCopyWithImpl<$Res>
    extends _$IngredientCopyWithImpl<$Res, _$IngredientImpl>
    implements _$$IngredientImplCopyWith<$Res> {
  __$$IngredientImplCopyWithImpl(
    _$IngredientImpl _value,
    $Res Function(_$IngredientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imagePath = null,
    Object? unitId = null,
    Object? currentStock = null,
    Object? currentCostPerUnit = null,
    Object? lowStockThreshold = freezed,
    Object? priceAlertPercentage = null,
    Object? categoryId = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? unit = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _$IngredientImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        unitId: null == unitId
            ? _value.unitId
            : unitId // ignore: cast_nullable_to_non_nullable
                  as String,
        currentStock: null == currentStock
            ? _value.currentStock
            : currentStock // ignore: cast_nullable_to_non_nullable
                  as double,
        currentCostPerUnit: null == currentCostPerUnit
            ? _value.currentCostPerUnit
            : currentCostPerUnit // ignore: cast_nullable_to_non_nullable
                  as double,
        lowStockThreshold: freezed == lowStockThreshold
            ? _value.lowStockThreshold
            : lowStockThreshold // ignore: cast_nullable_to_non_nullable
                  as double?,
        priceAlertPercentage: null == priceAlertPercentage
            ? _value.priceAlertPercentage
            : priceAlertPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as IngredientUnit?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as IngredientCategory?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientImpl implements _Ingredient {
  const _$IngredientImpl({
    required this.id,
    required this.name,
    this.description = '',
    @JsonKey(name: 'image_path') this.imagePath = '',
    @JsonKey(name: 'unit_id') required this.unitId,
    @JsonKey(name: 'current_stock') this.currentStock = 0,
    @JsonKey(name: 'current_cost_per_unit') this.currentCostPerUnit = 0,
    @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold,
    @JsonKey(name: 'price_alert_percentage') this.priceAlertPercentage = 10,
    @JsonKey(name: 'category_id') this.categoryId,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.unit,
    this.category,
  });

  factory _$IngredientImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'image_path')
  final String imagePath;
  @override
  @JsonKey(name: 'unit_id')
  final String unitId;
  @override
  @JsonKey(name: 'current_stock')
  final double currentStock;
  @override
  @JsonKey(name: 'current_cost_per_unit')
  final double currentCostPerUnit;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final double? lowStockThreshold;
  @override
  @JsonKey(name: 'price_alert_percentage')
  final double priceAlertPercentage;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  final IngredientUnit? unit;
  @override
  final IngredientCategory? category;

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, description: $description, imagePath: $imagePath, unitId: $unitId, currentStock: $currentStock, currentCostPerUnit: $currentCostPerUnit, lowStockThreshold: $lowStockThreshold, priceAlertPercentage: $priceAlertPercentage, categoryId: $categoryId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, unit: $unit, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.currentStock, currentStock) ||
                other.currentStock == currentStock) &&
            (identical(other.currentCostPerUnit, currentCostPerUnit) ||
                other.currentCostPerUnit == currentCostPerUnit) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.priceAlertPercentage, priceAlertPercentage) ||
                other.priceAlertPercentage == priceAlertPercentage) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    imagePath,
    unitId,
    currentStock,
    currentCostPerUnit,
    lowStockThreshold,
    priceAlertPercentage,
    categoryId,
    isActive,
    createdAt,
    updatedAt,
    unit,
    category,
  );

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientImplCopyWith<_$IngredientImpl> get copyWith =>
      __$$IngredientImplCopyWithImpl<_$IngredientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientImplToJson(this);
  }
}

abstract class _Ingredient implements Ingredient {
  const factory _Ingredient({
    required final String id,
    required final String name,
    final String description,
    @JsonKey(name: 'image_path') final String imagePath,
    @JsonKey(name: 'unit_id') required final String unitId,
    @JsonKey(name: 'current_stock') final double currentStock,
    @JsonKey(name: 'current_cost_per_unit') final double currentCostPerUnit,
    @JsonKey(name: 'low_stock_threshold') final double? lowStockThreshold,
    @JsonKey(name: 'price_alert_percentage') final double priceAlertPercentage,
    @JsonKey(name: 'category_id') final String? categoryId,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    final IngredientUnit? unit,
    final IngredientCategory? category,
  }) = _$IngredientImpl;

  factory _Ingredient.fromJson(Map<String, dynamic> json) =
      _$IngredientImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'image_path')
  String get imagePath;
  @override
  @JsonKey(name: 'unit_id')
  String get unitId;
  @override
  @JsonKey(name: 'current_stock')
  double get currentStock;
  @override
  @JsonKey(name: 'current_cost_per_unit')
  double get currentCostPerUnit;
  @override
  @JsonKey(name: 'low_stock_threshold')
  double? get lowStockThreshold;
  @override
  @JsonKey(name: 'price_alert_percentage')
  double get priceAlertPercentage;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  IngredientUnit? get unit;
  @override
  IngredientCategory? get category;

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IngredientImplCopyWith<_$IngredientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IngredientCategory _$IngredientCategoryFromJson(Map<String, dynamic> json) {
  return _IngredientCategory.fromJson(json);
}

/// @nodoc
mixin _$IngredientCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this IngredientCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IngredientCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IngredientCategoryCopyWith<IngredientCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientCategoryCopyWith<$Res> {
  factory $IngredientCategoryCopyWith(
    IngredientCategory value,
    $Res Function(IngredientCategory) then,
  ) = _$IngredientCategoryCopyWithImpl<$Res, IngredientCategory>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'sort_order') int sortOrder,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$IngredientCategoryCopyWithImpl<$Res, $Val extends IngredientCategory>
    implements $IngredientCategoryCopyWith<$Res> {
  _$IngredientCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IngredientCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? createdAt = freezed,
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
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$IngredientCategoryImplCopyWith<$Res>
    implements $IngredientCategoryCopyWith<$Res> {
  factory _$$IngredientCategoryImplCopyWith(
    _$IngredientCategoryImpl value,
    $Res Function(_$IngredientCategoryImpl) then,
  ) = __$$IngredientCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'sort_order') int sortOrder,
    @JsonKey(name: 'is_active') bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$IngredientCategoryImplCopyWithImpl<$Res>
    extends _$IngredientCategoryCopyWithImpl<$Res, _$IngredientCategoryImpl>
    implements _$$IngredientCategoryImplCopyWith<$Res> {
  __$$IngredientCategoryImplCopyWithImpl(
    _$IngredientCategoryImpl _value,
    $Res Function(_$IngredientCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IngredientCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$IngredientCategoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$IngredientCategoryImpl implements _IngredientCategory {
  const _$IngredientCategoryImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'sort_order') this.sortOrder = 0,
    @JsonKey(name: 'is_active') this.isActive = true,
    @JsonKey(name: 'created_at') this.createdAt,
  });

  factory _$IngredientCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'IngredientCategory(id: $id, name: $name, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, sortOrder, isActive, createdAt);

  /// Create a copy of IngredientCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientCategoryImplCopyWith<_$IngredientCategoryImpl> get copyWith =>
      __$$IngredientCategoryImplCopyWithImpl<_$IngredientCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientCategoryImplToJson(this);
  }
}

abstract class _IngredientCategory implements IngredientCategory {
  const factory _IngredientCategory({
    required final String id,
    required final String name,
    @JsonKey(name: 'sort_order') final int sortOrder,
    @JsonKey(name: 'is_active') final bool isActive,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$IngredientCategoryImpl;

  factory _IngredientCategory.fromJson(Map<String, dynamic> json) =
      _$IngredientCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of IngredientCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IngredientCategoryImplCopyWith<_$IngredientCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IngredientUnit _$IngredientUnitFromJson(Map<String, dynamic> json) {
  return _IngredientUnit.fromJson(json);
}

/// @nodoc
mixin _$IngredientUnit {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get abbreviation => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_type')
  String get unitType => throw _privateConstructorUsedError;

  /// Serializes this IngredientUnit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IngredientUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IngredientUnitCopyWith<IngredientUnit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientUnitCopyWith<$Res> {
  factory $IngredientUnitCopyWith(
    IngredientUnit value,
    $Res Function(IngredientUnit) then,
  ) = _$IngredientUnitCopyWithImpl<$Res, IngredientUnit>;
  @useResult
  $Res call({
    String id,
    String name,
    String abbreviation,
    @JsonKey(name: 'unit_type') String unitType,
  });
}

/// @nodoc
class _$IngredientUnitCopyWithImpl<$Res, $Val extends IngredientUnit>
    implements $IngredientUnitCopyWith<$Res> {
  _$IngredientUnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IngredientUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? abbreviation = null,
    Object? unitType = null,
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
            abbreviation: null == abbreviation
                ? _value.abbreviation
                : abbreviation // ignore: cast_nullable_to_non_nullable
                      as String,
            unitType: null == unitType
                ? _value.unitType
                : unitType // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IngredientUnitImplCopyWith<$Res>
    implements $IngredientUnitCopyWith<$Res> {
  factory _$$IngredientUnitImplCopyWith(
    _$IngredientUnitImpl value,
    $Res Function(_$IngredientUnitImpl) then,
  ) = __$$IngredientUnitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String abbreviation,
    @JsonKey(name: 'unit_type') String unitType,
  });
}

/// @nodoc
class __$$IngredientUnitImplCopyWithImpl<$Res>
    extends _$IngredientUnitCopyWithImpl<$Res, _$IngredientUnitImpl>
    implements _$$IngredientUnitImplCopyWith<$Res> {
  __$$IngredientUnitImplCopyWithImpl(
    _$IngredientUnitImpl _value,
    $Res Function(_$IngredientUnitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IngredientUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? abbreviation = null,
    Object? unitType = null,
  }) {
    return _then(
      _$IngredientUnitImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        abbreviation: null == abbreviation
            ? _value.abbreviation
            : abbreviation // ignore: cast_nullable_to_non_nullable
                  as String,
        unitType: null == unitType
            ? _value.unitType
            : unitType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientUnitImpl implements _IngredientUnit {
  const _$IngredientUnitImpl({
    required this.id,
    required this.name,
    required this.abbreviation,
    @JsonKey(name: 'unit_type') required this.unitType,
  });

  factory _$IngredientUnitImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientUnitImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String abbreviation;
  @override
  @JsonKey(name: 'unit_type')
  final String unitType;

  @override
  String toString() {
    return 'IngredientUnit(id: $id, name: $name, abbreviation: $abbreviation, unitType: $unitType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientUnitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.abbreviation, abbreviation) ||
                other.abbreviation == abbreviation) &&
            (identical(other.unitType, unitType) ||
                other.unitType == unitType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, abbreviation, unitType);

  /// Create a copy of IngredientUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientUnitImplCopyWith<_$IngredientUnitImpl> get copyWith =>
      __$$IngredientUnitImplCopyWithImpl<_$IngredientUnitImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientUnitImplToJson(this);
  }
}

abstract class _IngredientUnit implements IngredientUnit {
  const factory _IngredientUnit({
    required final String id,
    required final String name,
    required final String abbreviation,
    @JsonKey(name: 'unit_type') required final String unitType,
  }) = _$IngredientUnitImpl;

  factory _IngredientUnit.fromJson(Map<String, dynamic> json) =
      _$IngredientUnitImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get abbreviation;
  @override
  @JsonKey(name: 'unit_type')
  String get unitType;

  /// Create a copy of IngredientUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IngredientUnitImplCopyWith<_$IngredientUnitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceHistory _$PriceHistoryFromJson(Map<String, dynamic> json) {
  return _PriceHistory.fromJson(json);
}

/// @nodoc
mixin _$PriceHistory {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_id')
  String get ingredientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'old_cost_per_unit')
  double get oldCostPerUnit => throw _privateConstructorUsedError;
  @JsonKey(name: 'new_cost_per_unit')
  double get newCostPerUnit => throw _privateConstructorUsedError;
  @JsonKey(name: 'change_percentage')
  double get changePercentage => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  @JsonKey(name: 'recorded_at')
  DateTime? get recordedAt => throw _privateConstructorUsedError;

  /// Serializes this PriceHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceHistoryCopyWith<PriceHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceHistoryCopyWith<$Res> {
  factory $PriceHistoryCopyWith(
    PriceHistory value,
    $Res Function(PriceHistory) then,
  ) = _$PriceHistoryCopyWithImpl<$Res, PriceHistory>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'ingredient_id') String ingredientId,
    @JsonKey(name: 'old_cost_per_unit') double oldCostPerUnit,
    @JsonKey(name: 'new_cost_per_unit') double newCostPerUnit,
    @JsonKey(name: 'change_percentage') double changePercentage,
    String source,
    @JsonKey(name: 'recorded_at') DateTime? recordedAt,
  });
}

/// @nodoc
class _$PriceHistoryCopyWithImpl<$Res, $Val extends PriceHistory>
    implements $PriceHistoryCopyWith<$Res> {
  _$PriceHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientId = null,
    Object? oldCostPerUnit = null,
    Object? newCostPerUnit = null,
    Object? changePercentage = null,
    Object? source = null,
    Object? recordedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ingredientId: null == ingredientId
                ? _value.ingredientId
                : ingredientId // ignore: cast_nullable_to_non_nullable
                      as String,
            oldCostPerUnit: null == oldCostPerUnit
                ? _value.oldCostPerUnit
                : oldCostPerUnit // ignore: cast_nullable_to_non_nullable
                      as double,
            newCostPerUnit: null == newCostPerUnit
                ? _value.newCostPerUnit
                : newCostPerUnit // ignore: cast_nullable_to_non_nullable
                      as double,
            changePercentage: null == changePercentage
                ? _value.changePercentage
                : changePercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            recordedAt: freezed == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PriceHistoryImplCopyWith<$Res>
    implements $PriceHistoryCopyWith<$Res> {
  factory _$$PriceHistoryImplCopyWith(
    _$PriceHistoryImpl value,
    $Res Function(_$PriceHistoryImpl) then,
  ) = __$$PriceHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'ingredient_id') String ingredientId,
    @JsonKey(name: 'old_cost_per_unit') double oldCostPerUnit,
    @JsonKey(name: 'new_cost_per_unit') double newCostPerUnit,
    @JsonKey(name: 'change_percentage') double changePercentage,
    String source,
    @JsonKey(name: 'recorded_at') DateTime? recordedAt,
  });
}

/// @nodoc
class __$$PriceHistoryImplCopyWithImpl<$Res>
    extends _$PriceHistoryCopyWithImpl<$Res, _$PriceHistoryImpl>
    implements _$$PriceHistoryImplCopyWith<$Res> {
  __$$PriceHistoryImplCopyWithImpl(
    _$PriceHistoryImpl _value,
    $Res Function(_$PriceHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PriceHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientId = null,
    Object? oldCostPerUnit = null,
    Object? newCostPerUnit = null,
    Object? changePercentage = null,
    Object? source = null,
    Object? recordedAt = freezed,
  }) {
    return _then(
      _$PriceHistoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ingredientId: null == ingredientId
            ? _value.ingredientId
            : ingredientId // ignore: cast_nullable_to_non_nullable
                  as String,
        oldCostPerUnit: null == oldCostPerUnit
            ? _value.oldCostPerUnit
            : oldCostPerUnit // ignore: cast_nullable_to_non_nullable
                  as double,
        newCostPerUnit: null == newCostPerUnit
            ? _value.newCostPerUnit
            : newCostPerUnit // ignore: cast_nullable_to_non_nullable
                  as double,
        changePercentage: null == changePercentage
            ? _value.changePercentage
            : changePercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        recordedAt: freezed == recordedAt
            ? _value.recordedAt
            : recordedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceHistoryImpl implements _PriceHistory {
  const _$PriceHistoryImpl({
    required this.id,
    @JsonKey(name: 'ingredient_id') required this.ingredientId,
    @JsonKey(name: 'old_cost_per_unit') required this.oldCostPerUnit,
    @JsonKey(name: 'new_cost_per_unit') required this.newCostPerUnit,
    @JsonKey(name: 'change_percentage') required this.changePercentage,
    required this.source,
    @JsonKey(name: 'recorded_at') this.recordedAt,
  });

  factory _$PriceHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceHistoryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'ingredient_id')
  final String ingredientId;
  @override
  @JsonKey(name: 'old_cost_per_unit')
  final double oldCostPerUnit;
  @override
  @JsonKey(name: 'new_cost_per_unit')
  final double newCostPerUnit;
  @override
  @JsonKey(name: 'change_percentage')
  final double changePercentage;
  @override
  final String source;
  @override
  @JsonKey(name: 'recorded_at')
  final DateTime? recordedAt;

  @override
  String toString() {
    return 'PriceHistory(id: $id, ingredientId: $ingredientId, oldCostPerUnit: $oldCostPerUnit, newCostPerUnit: $newCostPerUnit, changePercentage: $changePercentage, source: $source, recordedAt: $recordedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ingredientId, ingredientId) ||
                other.ingredientId == ingredientId) &&
            (identical(other.oldCostPerUnit, oldCostPerUnit) ||
                other.oldCostPerUnit == oldCostPerUnit) &&
            (identical(other.newCostPerUnit, newCostPerUnit) ||
                other.newCostPerUnit == newCostPerUnit) &&
            (identical(other.changePercentage, changePercentage) ||
                other.changePercentage == changePercentage) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ingredientId,
    oldCostPerUnit,
    newCostPerUnit,
    changePercentage,
    source,
    recordedAt,
  );

  /// Create a copy of PriceHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceHistoryImplCopyWith<_$PriceHistoryImpl> get copyWith =>
      __$$PriceHistoryImplCopyWithImpl<_$PriceHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceHistoryImplToJson(this);
  }
}

abstract class _PriceHistory implements PriceHistory {
  const factory _PriceHistory({
    required final String id,
    @JsonKey(name: 'ingredient_id') required final String ingredientId,
    @JsonKey(name: 'old_cost_per_unit') required final double oldCostPerUnit,
    @JsonKey(name: 'new_cost_per_unit') required final double newCostPerUnit,
    @JsonKey(name: 'change_percentage') required final double changePercentage,
    required final String source,
    @JsonKey(name: 'recorded_at') final DateTime? recordedAt,
  }) = _$PriceHistoryImpl;

  factory _PriceHistory.fromJson(Map<String, dynamic> json) =
      _$PriceHistoryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'ingredient_id')
  String get ingredientId;
  @override
  @JsonKey(name: 'old_cost_per_unit')
  double get oldCostPerUnit;
  @override
  @JsonKey(name: 'new_cost_per_unit')
  double get newCostPerUnit;
  @override
  @JsonKey(name: 'change_percentage')
  double get changePercentage;
  @override
  String get source;
  @override
  @JsonKey(name: 'recorded_at')
  DateTime? get recordedAt;

  /// Create a copy of PriceHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceHistoryImplCopyWith<_$PriceHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
