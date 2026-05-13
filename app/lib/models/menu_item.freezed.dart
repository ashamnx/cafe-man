// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) {
  return _MenuItem.fromJson(json);
}

/// @nodoc
mixin _$MenuItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_path')
  String get imagePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'selling_price')
  double get sellingPrice => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'preparation_notes')
  String get preparationNotes => throw _privateConstructorUsedError;
  List<String> get allergens => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  MenuCategory? get category => throw _privateConstructorUsedError;
  List<RecipeIngredient> get ingredients => throw _privateConstructorUsedError;
  @JsonKey(name: 'utility_costs')
  List<RecipeUtilityCost> get utilityCosts =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'total_cost')
  double get totalCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'cost_margin')
  double get costMargin => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_profit')
  double get netProfit => throw _privateConstructorUsedError;

  /// Serializes this MenuItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuItemCopyWith<MenuItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuItemCopyWith<$Res> {
  factory $MenuItemCopyWith(MenuItem value, $Res Function(MenuItem) then) =
      _$MenuItemCopyWithImpl<$Res, MenuItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'category_id') String? categoryId,
    String name,
    String description,
    @JsonKey(name: 'image_path') String imagePath,
    @JsonKey(name: 'selling_price') double sellingPrice,
    String status,
    @JsonKey(name: 'preparation_notes') String preparationNotes,
    List<String> allergens,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    MenuCategory? category,
    List<RecipeIngredient> ingredients,
    @JsonKey(name: 'utility_costs') List<RecipeUtilityCost> utilityCosts,
    @JsonKey(name: 'total_cost') double totalCost,
    @JsonKey(name: 'cost_margin') double costMargin,
    @JsonKey(name: 'net_profit') double netProfit,
  });

  $MenuCategoryCopyWith<$Res>? get category;
}

/// @nodoc
class _$MenuItemCopyWithImpl<$Res, $Val extends MenuItem>
    implements $MenuItemCopyWith<$Res> {
  _$MenuItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = freezed,
    Object? name = null,
    Object? description = null,
    Object? imagePath = null,
    Object? sellingPrice = null,
    Object? status = null,
    Object? preparationNotes = null,
    Object? allergens = null,
    Object? createdAt = freezed,
    Object? category = freezed,
    Object? ingredients = null,
    Object? utilityCosts = null,
    Object? totalCost = null,
    Object? costMargin = null,
    Object? netProfit = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            sellingPrice: null == sellingPrice
                ? _value.sellingPrice
                : sellingPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            preparationNotes: null == preparationNotes
                ? _value.preparationNotes
                : preparationNotes // ignore: cast_nullable_to_non_nullable
                      as String,
            allergens: null == allergens
                ? _value.allergens
                : allergens // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as MenuCategory?,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as List<RecipeIngredient>,
            utilityCosts: null == utilityCosts
                ? _value.utilityCosts
                : utilityCosts // ignore: cast_nullable_to_non_nullable
                      as List<RecipeUtilityCost>,
            totalCost: null == totalCost
                ? _value.totalCost
                : totalCost // ignore: cast_nullable_to_non_nullable
                      as double,
            costMargin: null == costMargin
                ? _value.costMargin
                : costMargin // ignore: cast_nullable_to_non_nullable
                      as double,
            netProfit: null == netProfit
                ? _value.netProfit
                : netProfit // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MenuCategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $MenuCategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MenuItemImplCopyWith<$Res>
    implements $MenuItemCopyWith<$Res> {
  factory _$$MenuItemImplCopyWith(
    _$MenuItemImpl value,
    $Res Function(_$MenuItemImpl) then,
  ) = __$$MenuItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'category_id') String? categoryId,
    String name,
    String description,
    @JsonKey(name: 'image_path') String imagePath,
    @JsonKey(name: 'selling_price') double sellingPrice,
    String status,
    @JsonKey(name: 'preparation_notes') String preparationNotes,
    List<String> allergens,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    MenuCategory? category,
    List<RecipeIngredient> ingredients,
    @JsonKey(name: 'utility_costs') List<RecipeUtilityCost> utilityCosts,
    @JsonKey(name: 'total_cost') double totalCost,
    @JsonKey(name: 'cost_margin') double costMargin,
    @JsonKey(name: 'net_profit') double netProfit,
  });

  @override
  $MenuCategoryCopyWith<$Res>? get category;
}

/// @nodoc
class __$$MenuItemImplCopyWithImpl<$Res>
    extends _$MenuItemCopyWithImpl<$Res, _$MenuItemImpl>
    implements _$$MenuItemImplCopyWith<$Res> {
  __$$MenuItemImplCopyWithImpl(
    _$MenuItemImpl _value,
    $Res Function(_$MenuItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = freezed,
    Object? name = null,
    Object? description = null,
    Object? imagePath = null,
    Object? sellingPrice = null,
    Object? status = null,
    Object? preparationNotes = null,
    Object? allergens = null,
    Object? createdAt = freezed,
    Object? category = freezed,
    Object? ingredients = null,
    Object? utilityCosts = null,
    Object? totalCost = null,
    Object? costMargin = null,
    Object? netProfit = null,
  }) {
    return _then(
      _$MenuItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        sellingPrice: null == sellingPrice
            ? _value.sellingPrice
            : sellingPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        preparationNotes: null == preparationNotes
            ? _value.preparationNotes
            : preparationNotes // ignore: cast_nullable_to_non_nullable
                  as String,
        allergens: null == allergens
            ? _value._allergens
            : allergens // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as MenuCategory?,
        ingredients: null == ingredients
            ? _value._ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as List<RecipeIngredient>,
        utilityCosts: null == utilityCosts
            ? _value._utilityCosts
            : utilityCosts // ignore: cast_nullable_to_non_nullable
                  as List<RecipeUtilityCost>,
        totalCost: null == totalCost
            ? _value.totalCost
            : totalCost // ignore: cast_nullable_to_non_nullable
                  as double,
        costMargin: null == costMargin
            ? _value.costMargin
            : costMargin // ignore: cast_nullable_to_non_nullable
                  as double,
        netProfit: null == netProfit
            ? _value.netProfit
            : netProfit // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuItemImpl implements _MenuItem {
  const _$MenuItemImpl({
    required this.id,
    @JsonKey(name: 'category_id') this.categoryId,
    required this.name,
    this.description = '',
    @JsonKey(name: 'image_path') this.imagePath = '',
    @JsonKey(name: 'selling_price') this.sellingPrice = 0,
    this.status = 'active',
    @JsonKey(name: 'preparation_notes') this.preparationNotes = '',
    final List<String> allergens = const [],
    @JsonKey(name: 'created_at') this.createdAt,
    this.category,
    final List<RecipeIngredient> ingredients = const [],
    @JsonKey(name: 'utility_costs')
    final List<RecipeUtilityCost> utilityCosts = const [],
    @JsonKey(name: 'total_cost') this.totalCost = 0,
    @JsonKey(name: 'cost_margin') this.costMargin = 0,
    @JsonKey(name: 'net_profit') this.netProfit = 0,
  }) : _allergens = allergens,
       _ingredients = ingredients,
       _utilityCosts = utilityCosts;

  factory _$MenuItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'image_path')
  final String imagePath;
  @override
  @JsonKey(name: 'selling_price')
  final double sellingPrice;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'preparation_notes')
  final String preparationNotes;
  final List<String> _allergens;
  @override
  @JsonKey()
  List<String> get allergens {
    if (_allergens is EqualUnmodifiableListView) return _allergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergens);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  final MenuCategory? category;
  final List<RecipeIngredient> _ingredients;
  @override
  @JsonKey()
  List<RecipeIngredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<RecipeUtilityCost> _utilityCosts;
  @override
  @JsonKey(name: 'utility_costs')
  List<RecipeUtilityCost> get utilityCosts {
    if (_utilityCosts is EqualUnmodifiableListView) return _utilityCosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_utilityCosts);
  }

  @override
  @JsonKey(name: 'total_cost')
  final double totalCost;
  @override
  @JsonKey(name: 'cost_margin')
  final double costMargin;
  @override
  @JsonKey(name: 'net_profit')
  final double netProfit;

  @override
  String toString() {
    return 'MenuItem(id: $id, categoryId: $categoryId, name: $name, description: $description, imagePath: $imagePath, sellingPrice: $sellingPrice, status: $status, preparationNotes: $preparationNotes, allergens: $allergens, createdAt: $createdAt, category: $category, ingredients: $ingredients, utilityCosts: $utilityCosts, totalCost: $totalCost, costMargin: $costMargin, netProfit: $netProfit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.preparationNotes, preparationNotes) ||
                other.preparationNotes == preparationNotes) &&
            const DeepCollectionEquality().equals(
              other._allergens,
              _allergens,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            const DeepCollectionEquality().equals(
              other._utilityCosts,
              _utilityCosts,
            ) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.costMargin, costMargin) ||
                other.costMargin == costMargin) &&
            (identical(other.netProfit, netProfit) ||
                other.netProfit == netProfit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    categoryId,
    name,
    description,
    imagePath,
    sellingPrice,
    status,
    preparationNotes,
    const DeepCollectionEquality().hash(_allergens),
    createdAt,
    category,
    const DeepCollectionEquality().hash(_ingredients),
    const DeepCollectionEquality().hash(_utilityCosts),
    totalCost,
    costMargin,
    netProfit,
  );

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuItemImplCopyWith<_$MenuItemImpl> get copyWith =>
      __$$MenuItemImplCopyWithImpl<_$MenuItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuItemImplToJson(this);
  }
}

abstract class _MenuItem implements MenuItem {
  const factory _MenuItem({
    required final String id,
    @JsonKey(name: 'category_id') final String? categoryId,
    required final String name,
    final String description,
    @JsonKey(name: 'image_path') final String imagePath,
    @JsonKey(name: 'selling_price') final double sellingPrice,
    final String status,
    @JsonKey(name: 'preparation_notes') final String preparationNotes,
    final List<String> allergens,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    final MenuCategory? category,
    final List<RecipeIngredient> ingredients,
    @JsonKey(name: 'utility_costs') final List<RecipeUtilityCost> utilityCosts,
    @JsonKey(name: 'total_cost') final double totalCost,
    @JsonKey(name: 'cost_margin') final double costMargin,
    @JsonKey(name: 'net_profit') final double netProfit,
  }) = _$MenuItemImpl;

  factory _MenuItem.fromJson(Map<String, dynamic> json) =
      _$MenuItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'image_path')
  String get imagePath;
  @override
  @JsonKey(name: 'selling_price')
  double get sellingPrice;
  @override
  String get status;
  @override
  @JsonKey(name: 'preparation_notes')
  String get preparationNotes;
  @override
  List<String> get allergens;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  MenuCategory? get category;
  @override
  List<RecipeIngredient> get ingredients;
  @override
  @JsonKey(name: 'utility_costs')
  List<RecipeUtilityCost> get utilityCosts;
  @override
  @JsonKey(name: 'total_cost')
  double get totalCost;
  @override
  @JsonKey(name: 'cost_margin')
  double get costMargin;
  @override
  @JsonKey(name: 'net_profit')
  double get netProfit;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuItemImplCopyWith<_$MenuItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MenuCategory _$MenuCategoryFromJson(Map<String, dynamic> json) {
  return _MenuCategory.fromJson(json);
}

/// @nodoc
mixin _$MenuCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this MenuCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuCategoryCopyWith<MenuCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuCategoryCopyWith<$Res> {
  factory $MenuCategoryCopyWith(
    MenuCategory value,
    $Res Function(MenuCategory) then,
  ) = _$MenuCategoryCopyWithImpl<$Res, MenuCategory>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'sort_order') int sortOrder,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class _$MenuCategoryCopyWithImpl<$Res, $Val extends MenuCategory>
    implements $MenuCategoryCopyWith<$Res> {
  _$MenuCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MenuCategoryImplCopyWith<$Res>
    implements $MenuCategoryCopyWith<$Res> {
  factory _$$MenuCategoryImplCopyWith(
    _$MenuCategoryImpl value,
    $Res Function(_$MenuCategoryImpl) then,
  ) = __$$MenuCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'sort_order') int sortOrder,
    @JsonKey(name: 'is_active') bool isActive,
  });
}

/// @nodoc
class __$$MenuCategoryImplCopyWithImpl<$Res>
    extends _$MenuCategoryCopyWithImpl<$Res, _$MenuCategoryImpl>
    implements _$$MenuCategoryImplCopyWith<$Res> {
  __$$MenuCategoryImplCopyWithImpl(
    _$MenuCategoryImpl _value,
    $Res Function(_$MenuCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(
      _$MenuCategoryImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuCategoryImpl implements _MenuCategory {
  const _$MenuCategoryImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'sort_order') this.sortOrder = 0,
    @JsonKey(name: 'is_active') this.isActive = true,
  });

  factory _$MenuCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuCategoryImplFromJson(json);

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
  String toString() {
    return 'MenuCategory(id: $id, name: $name, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, sortOrder, isActive);

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuCategoryImplCopyWith<_$MenuCategoryImpl> get copyWith =>
      __$$MenuCategoryImplCopyWithImpl<_$MenuCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuCategoryImplToJson(this);
  }
}

abstract class _MenuCategory implements MenuCategory {
  const factory _MenuCategory({
    required final String id,
    required final String name,
    @JsonKey(name: 'sort_order') final int sortOrder,
    @JsonKey(name: 'is_active') final bool isActive,
  }) = _$MenuCategoryImpl;

  factory _MenuCategory.fromJson(Map<String, dynamic> json) =
      _$MenuCategoryImpl.fromJson;

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

  /// Create a copy of MenuCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuCategoryImplCopyWith<_$MenuCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) {
  return _RecipeIngredient.fromJson(json);
}

/// @nodoc
mixin _$RecipeIngredient {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'menu_item_id')
  String get menuItemId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_id')
  String get ingredientId => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_type')
  String get ingredientType => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'line_cost')
  double get lineCost => throw _privateConstructorUsedError;

  /// Serializes this RecipeIngredient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeIngredientCopyWith<RecipeIngredient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeIngredientCopyWith<$Res> {
  factory $RecipeIngredientCopyWith(
    RecipeIngredient value,
    $Res Function(RecipeIngredient) then,
  ) = _$RecipeIngredientCopyWithImpl<$Res, RecipeIngredient>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'menu_item_id') String menuItemId,
    @JsonKey(name: 'ingredient_id') String ingredientId,
    double quantity,
    @JsonKey(name: 'ingredient_type') String ingredientType,
    String notes,
    @JsonKey(name: 'line_cost') double lineCost,
  });
}

/// @nodoc
class _$RecipeIngredientCopyWithImpl<$Res, $Val extends RecipeIngredient>
    implements $RecipeIngredientCopyWith<$Res> {
  _$RecipeIngredientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? ingredientId = null,
    Object? quantity = null,
    Object? ingredientType = null,
    Object? notes = null,
    Object? lineCost = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            menuItemId: null == menuItemId
                ? _value.menuItemId
                : menuItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            ingredientId: null == ingredientId
                ? _value.ingredientId
                : ingredientId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            ingredientType: null == ingredientType
                ? _value.ingredientType
                : ingredientType // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            lineCost: null == lineCost
                ? _value.lineCost
                : lineCost // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeIngredientImplCopyWith<$Res>
    implements $RecipeIngredientCopyWith<$Res> {
  factory _$$RecipeIngredientImplCopyWith(
    _$RecipeIngredientImpl value,
    $Res Function(_$RecipeIngredientImpl) then,
  ) = __$$RecipeIngredientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'menu_item_id') String menuItemId,
    @JsonKey(name: 'ingredient_id') String ingredientId,
    double quantity,
    @JsonKey(name: 'ingredient_type') String ingredientType,
    String notes,
    @JsonKey(name: 'line_cost') double lineCost,
  });
}

/// @nodoc
class __$$RecipeIngredientImplCopyWithImpl<$Res>
    extends _$RecipeIngredientCopyWithImpl<$Res, _$RecipeIngredientImpl>
    implements _$$RecipeIngredientImplCopyWith<$Res> {
  __$$RecipeIngredientImplCopyWithImpl(
    _$RecipeIngredientImpl _value,
    $Res Function(_$RecipeIngredientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? ingredientId = null,
    Object? quantity = null,
    Object? ingredientType = null,
    Object? notes = null,
    Object? lineCost = null,
  }) {
    return _then(
      _$RecipeIngredientImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        menuItemId: null == menuItemId
            ? _value.menuItemId
            : menuItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        ingredientId: null == ingredientId
            ? _value.ingredientId
            : ingredientId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        ingredientType: null == ingredientType
            ? _value.ingredientType
            : ingredientType // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        lineCost: null == lineCost
            ? _value.lineCost
            : lineCost // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeIngredientImpl implements _RecipeIngredient {
  const _$RecipeIngredientImpl({
    required this.id,
    @JsonKey(name: 'menu_item_id') required this.menuItemId,
    @JsonKey(name: 'ingredient_id') required this.ingredientId,
    required this.quantity,
    @JsonKey(name: 'ingredient_type') this.ingredientType = 'primary',
    this.notes = '',
    @JsonKey(name: 'line_cost') this.lineCost = 0,
  });

  factory _$RecipeIngredientImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeIngredientImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'menu_item_id')
  final String menuItemId;
  @override
  @JsonKey(name: 'ingredient_id')
  final String ingredientId;
  @override
  final double quantity;
  @override
  @JsonKey(name: 'ingredient_type')
  final String ingredientType;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'line_cost')
  final double lineCost;

  @override
  String toString() {
    return 'RecipeIngredient(id: $id, menuItemId: $menuItemId, ingredientId: $ingredientId, quantity: $quantity, ingredientType: $ingredientType, notes: $notes, lineCost: $lineCost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeIngredientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.ingredientId, ingredientId) ||
                other.ingredientId == ingredientId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.ingredientType, ingredientType) ||
                other.ingredientType == ingredientType) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.lineCost, lineCost) ||
                other.lineCost == lineCost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    menuItemId,
    ingredientId,
    quantity,
    ingredientType,
    notes,
    lineCost,
  );

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeIngredientImplCopyWith<_$RecipeIngredientImpl> get copyWith =>
      __$$RecipeIngredientImplCopyWithImpl<_$RecipeIngredientImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeIngredientImplToJson(this);
  }
}

abstract class _RecipeIngredient implements RecipeIngredient {
  const factory _RecipeIngredient({
    required final String id,
    @JsonKey(name: 'menu_item_id') required final String menuItemId,
    @JsonKey(name: 'ingredient_id') required final String ingredientId,
    required final double quantity,
    @JsonKey(name: 'ingredient_type') final String ingredientType,
    final String notes,
    @JsonKey(name: 'line_cost') final double lineCost,
  }) = _$RecipeIngredientImpl;

  factory _RecipeIngredient.fromJson(Map<String, dynamic> json) =
      _$RecipeIngredientImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'menu_item_id')
  String get menuItemId;
  @override
  @JsonKey(name: 'ingredient_id')
  String get ingredientId;
  @override
  double get quantity;
  @override
  @JsonKey(name: 'ingredient_type')
  String get ingredientType;
  @override
  String get notes;
  @override
  @JsonKey(name: 'line_cost')
  double get lineCost;

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeIngredientImplCopyWith<_$RecipeIngredientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecipeUtilityCost _$RecipeUtilityCostFromJson(Map<String, dynamic> json) {
  return _RecipeUtilityCost.fromJson(json);
}

/// @nodoc
mixin _$RecipeUtilityCost {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'menu_item_id')
  String get menuItemId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get cost => throw _privateConstructorUsedError;

  /// Serializes this RecipeUtilityCost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecipeUtilityCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeUtilityCostCopyWith<RecipeUtilityCost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeUtilityCostCopyWith<$Res> {
  factory $RecipeUtilityCostCopyWith(
    RecipeUtilityCost value,
    $Res Function(RecipeUtilityCost) then,
  ) = _$RecipeUtilityCostCopyWithImpl<$Res, RecipeUtilityCost>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'menu_item_id') String menuItemId,
    String name,
    double cost,
  });
}

/// @nodoc
class _$RecipeUtilityCostCopyWithImpl<$Res, $Val extends RecipeUtilityCost>
    implements $RecipeUtilityCostCopyWith<$Res> {
  _$RecipeUtilityCostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeUtilityCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? name = null,
    Object? cost = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            menuItemId: null == menuItemId
                ? _value.menuItemId
                : menuItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            cost: null == cost
                ? _value.cost
                : cost // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeUtilityCostImplCopyWith<$Res>
    implements $RecipeUtilityCostCopyWith<$Res> {
  factory _$$RecipeUtilityCostImplCopyWith(
    _$RecipeUtilityCostImpl value,
    $Res Function(_$RecipeUtilityCostImpl) then,
  ) = __$$RecipeUtilityCostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'menu_item_id') String menuItemId,
    String name,
    double cost,
  });
}

/// @nodoc
class __$$RecipeUtilityCostImplCopyWithImpl<$Res>
    extends _$RecipeUtilityCostCopyWithImpl<$Res, _$RecipeUtilityCostImpl>
    implements _$$RecipeUtilityCostImplCopyWith<$Res> {
  __$$RecipeUtilityCostImplCopyWithImpl(
    _$RecipeUtilityCostImpl _value,
    $Res Function(_$RecipeUtilityCostImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecipeUtilityCost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? name = null,
    Object? cost = null,
  }) {
    return _then(
      _$RecipeUtilityCostImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        menuItemId: null == menuItemId
            ? _value.menuItemId
            : menuItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        cost: null == cost
            ? _value.cost
            : cost // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeUtilityCostImpl implements _RecipeUtilityCost {
  const _$RecipeUtilityCostImpl({
    required this.id,
    @JsonKey(name: 'menu_item_id') required this.menuItemId,
    required this.name,
    required this.cost,
  });

  factory _$RecipeUtilityCostImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeUtilityCostImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'menu_item_id')
  final String menuItemId;
  @override
  final String name;
  @override
  final double cost;

  @override
  String toString() {
    return 'RecipeUtilityCost(id: $id, menuItemId: $menuItemId, name: $name, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeUtilityCostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.cost, cost) || other.cost == cost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, menuItemId, name, cost);

  /// Create a copy of RecipeUtilityCost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeUtilityCostImplCopyWith<_$RecipeUtilityCostImpl> get copyWith =>
      __$$RecipeUtilityCostImplCopyWithImpl<_$RecipeUtilityCostImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeUtilityCostImplToJson(this);
  }
}

abstract class _RecipeUtilityCost implements RecipeUtilityCost {
  const factory _RecipeUtilityCost({
    required final String id,
    @JsonKey(name: 'menu_item_id') required final String menuItemId,
    required final String name,
    required final double cost,
  }) = _$RecipeUtilityCostImpl;

  factory _RecipeUtilityCost.fromJson(Map<String, dynamic> json) =
      _$RecipeUtilityCostImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'menu_item_id')
  String get menuItemId;
  @override
  String get name;
  @override
  double get cost;

  /// Create a copy of RecipeUtilityCost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeUtilityCostImplCopyWith<_$RecipeUtilityCostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
