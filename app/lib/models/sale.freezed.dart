// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SaleEntry _$SaleEntryFromJson(Map<String, dynamic> json) {
  return _SaleEntry.fromJson(json);
}

/// @nodoc
mixin _$SaleEntry {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'sale_date')
  DateTime? get saleDate => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  List<SaleEntryItem> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_items')
  int get totalItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_value')
  double get totalValue => throw _privateConstructorUsedError;

  /// Serializes this SaleEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SaleEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaleEntryCopyWith<SaleEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaleEntryCopyWith<$Res> {
  factory $SaleEntryCopyWith(SaleEntry value, $Res Function(SaleEntry) then) =
      _$SaleEntryCopyWithImpl<$Res, SaleEntry>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'sale_date') DateTime? saleDate,
    String notes,
    String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<SaleEntryItem> items,
    @JsonKey(name: 'total_items') int totalItems,
    @JsonKey(name: 'total_value') double totalValue,
  });
}

/// @nodoc
class _$SaleEntryCopyWithImpl<$Res, $Val extends SaleEntry>
    implements $SaleEntryCopyWith<$Res> {
  _$SaleEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SaleEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? saleDate = freezed,
    Object? notes = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? items = null,
    Object? totalItems = null,
    Object? totalValue = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            saleDate: freezed == saleDate
                ? _value.saleDate
                : saleDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<SaleEntryItem>,
            totalItems: null == totalItems
                ? _value.totalItems
                : totalItems // ignore: cast_nullable_to_non_nullable
                      as int,
            totalValue: null == totalValue
                ? _value.totalValue
                : totalValue // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SaleEntryImplCopyWith<$Res>
    implements $SaleEntryCopyWith<$Res> {
  factory _$$SaleEntryImplCopyWith(
    _$SaleEntryImpl value,
    $Res Function(_$SaleEntryImpl) then,
  ) = __$$SaleEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'sale_date') DateTime? saleDate,
    String notes,
    String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<SaleEntryItem> items,
    @JsonKey(name: 'total_items') int totalItems,
    @JsonKey(name: 'total_value') double totalValue,
  });
}

/// @nodoc
class __$$SaleEntryImplCopyWithImpl<$Res>
    extends _$SaleEntryCopyWithImpl<$Res, _$SaleEntryImpl>
    implements _$$SaleEntryImplCopyWith<$Res> {
  __$$SaleEntryImplCopyWithImpl(
    _$SaleEntryImpl _value,
    $Res Function(_$SaleEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SaleEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? saleDate = freezed,
    Object? notes = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? items = null,
    Object? totalItems = null,
    Object? totalValue = null,
  }) {
    return _then(
      _$SaleEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        saleDate: freezed == saleDate
            ? _value.saleDate
            : saleDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<SaleEntryItem>,
        totalItems: null == totalItems
            ? _value.totalItems
            : totalItems // ignore: cast_nullable_to_non_nullable
                  as int,
        totalValue: null == totalValue
            ? _value.totalValue
            : totalValue // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SaleEntryImpl implements _SaleEntry {
  const _$SaleEntryImpl({
    required this.id,
    @JsonKey(name: 'sale_date') this.saleDate,
    this.notes = '',
    this.status = 'draft',
    @JsonKey(name: 'created_at') this.createdAt,
    final List<SaleEntryItem> items = const [],
    @JsonKey(name: 'total_items') this.totalItems = 0,
    @JsonKey(name: 'total_value') this.totalValue = 0,
  }) : _items = items;

  factory _$SaleEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaleEntryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'sale_date')
  final DateTime? saleDate;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  final List<SaleEntryItem> _items;
  @override
  @JsonKey()
  List<SaleEntryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey(name: 'total_items')
  final int totalItems;
  @override
  @JsonKey(name: 'total_value')
  final double totalValue;

  @override
  String toString() {
    return 'SaleEntry(id: $id, saleDate: $saleDate, notes: $notes, status: $status, createdAt: $createdAt, items: $items, totalItems: $totalItems, totalValue: $totalValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.saleDate, saleDate) ||
                other.saleDate == saleDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems) &&
            (identical(other.totalValue, totalValue) ||
                other.totalValue == totalValue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    saleDate,
    notes,
    status,
    createdAt,
    const DeepCollectionEquality().hash(_items),
    totalItems,
    totalValue,
  );

  /// Create a copy of SaleEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleEntryImplCopyWith<_$SaleEntryImpl> get copyWith =>
      __$$SaleEntryImplCopyWithImpl<_$SaleEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaleEntryImplToJson(this);
  }
}

abstract class _SaleEntry implements SaleEntry {
  const factory _SaleEntry({
    required final String id,
    @JsonKey(name: 'sale_date') final DateTime? saleDate,
    final String notes,
    final String status,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    final List<SaleEntryItem> items,
    @JsonKey(name: 'total_items') final int totalItems,
    @JsonKey(name: 'total_value') final double totalValue,
  }) = _$SaleEntryImpl;

  factory _SaleEntry.fromJson(Map<String, dynamic> json) =
      _$SaleEntryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'sale_date')
  DateTime? get saleDate;
  @override
  String get notes;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  List<SaleEntryItem> get items;
  @override
  @JsonKey(name: 'total_items')
  int get totalItems;
  @override
  @JsonKey(name: 'total_value')
  double get totalValue;

  /// Create a copy of SaleEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaleEntryImplCopyWith<_$SaleEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SaleEntryItem _$SaleEntryItemFromJson(Map<String, dynamic> json) {
  return _SaleEntryItem.fromJson(json);
}

/// @nodoc
mixin _$SaleEntryItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'sale_entry_id')
  String get saleEntryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'menu_item_id')
  String get menuItemId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'selling_price')
  double get sellingPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'menu_item_name')
  String get menuItemName => throw _privateConstructorUsedError;

  /// Serializes this SaleEntryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SaleEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SaleEntryItemCopyWith<SaleEntryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaleEntryItemCopyWith<$Res> {
  factory $SaleEntryItemCopyWith(
    SaleEntryItem value,
    $Res Function(SaleEntryItem) then,
  ) = _$SaleEntryItemCopyWithImpl<$Res, SaleEntryItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'sale_entry_id') String saleEntryId,
    @JsonKey(name: 'menu_item_id') String menuItemId,
    int quantity,
    @JsonKey(name: 'selling_price') double sellingPrice,
    @JsonKey(name: 'menu_item_name') String menuItemName,
  });
}

/// @nodoc
class _$SaleEntryItemCopyWithImpl<$Res, $Val extends SaleEntryItem>
    implements $SaleEntryItemCopyWith<$Res> {
  _$SaleEntryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SaleEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? saleEntryId = null,
    Object? menuItemId = null,
    Object? quantity = null,
    Object? sellingPrice = null,
    Object? menuItemName = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            saleEntryId: null == saleEntryId
                ? _value.saleEntryId
                : saleEntryId // ignore: cast_nullable_to_non_nullable
                      as String,
            menuItemId: null == menuItemId
                ? _value.menuItemId
                : menuItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            sellingPrice: null == sellingPrice
                ? _value.sellingPrice
                : sellingPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            menuItemName: null == menuItemName
                ? _value.menuItemName
                : menuItemName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SaleEntryItemImplCopyWith<$Res>
    implements $SaleEntryItemCopyWith<$Res> {
  factory _$$SaleEntryItemImplCopyWith(
    _$SaleEntryItemImpl value,
    $Res Function(_$SaleEntryItemImpl) then,
  ) = __$$SaleEntryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'sale_entry_id') String saleEntryId,
    @JsonKey(name: 'menu_item_id') String menuItemId,
    int quantity,
    @JsonKey(name: 'selling_price') double sellingPrice,
    @JsonKey(name: 'menu_item_name') String menuItemName,
  });
}

/// @nodoc
class __$$SaleEntryItemImplCopyWithImpl<$Res>
    extends _$SaleEntryItemCopyWithImpl<$Res, _$SaleEntryItemImpl>
    implements _$$SaleEntryItemImplCopyWith<$Res> {
  __$$SaleEntryItemImplCopyWithImpl(
    _$SaleEntryItemImpl _value,
    $Res Function(_$SaleEntryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SaleEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? saleEntryId = null,
    Object? menuItemId = null,
    Object? quantity = null,
    Object? sellingPrice = null,
    Object? menuItemName = null,
  }) {
    return _then(
      _$SaleEntryItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        saleEntryId: null == saleEntryId
            ? _value.saleEntryId
            : saleEntryId // ignore: cast_nullable_to_non_nullable
                  as String,
        menuItemId: null == menuItemId
            ? _value.menuItemId
            : menuItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        sellingPrice: null == sellingPrice
            ? _value.sellingPrice
            : sellingPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        menuItemName: null == menuItemName
            ? _value.menuItemName
            : menuItemName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SaleEntryItemImpl implements _SaleEntryItem {
  const _$SaleEntryItemImpl({
    required this.id,
    @JsonKey(name: 'sale_entry_id') required this.saleEntryId,
    @JsonKey(name: 'menu_item_id') required this.menuItemId,
    required this.quantity,
    @JsonKey(name: 'selling_price') this.sellingPrice = 0,
    @JsonKey(name: 'menu_item_name') this.menuItemName = '',
  });

  factory _$SaleEntryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaleEntryItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'sale_entry_id')
  final String saleEntryId;
  @override
  @JsonKey(name: 'menu_item_id')
  final String menuItemId;
  @override
  final int quantity;
  @override
  @JsonKey(name: 'selling_price')
  final double sellingPrice;
  @override
  @JsonKey(name: 'menu_item_name')
  final String menuItemName;

  @override
  String toString() {
    return 'SaleEntryItem(id: $id, saleEntryId: $saleEntryId, menuItemId: $menuItemId, quantity: $quantity, sellingPrice: $sellingPrice, menuItemName: $menuItemName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleEntryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.saleEntryId, saleEntryId) ||
                other.saleEntryId == saleEntryId) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.sellingPrice, sellingPrice) ||
                other.sellingPrice == sellingPrice) &&
            (identical(other.menuItemName, menuItemName) ||
                other.menuItemName == menuItemName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    saleEntryId,
    menuItemId,
    quantity,
    sellingPrice,
    menuItemName,
  );

  /// Create a copy of SaleEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleEntryItemImplCopyWith<_$SaleEntryItemImpl> get copyWith =>
      __$$SaleEntryItemImplCopyWithImpl<_$SaleEntryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaleEntryItemImplToJson(this);
  }
}

abstract class _SaleEntryItem implements SaleEntryItem {
  const factory _SaleEntryItem({
    required final String id,
    @JsonKey(name: 'sale_entry_id') required final String saleEntryId,
    @JsonKey(name: 'menu_item_id') required final String menuItemId,
    required final int quantity,
    @JsonKey(name: 'selling_price') final double sellingPrice,
    @JsonKey(name: 'menu_item_name') final String menuItemName,
  }) = _$SaleEntryItemImpl;

  factory _SaleEntryItem.fromJson(Map<String, dynamic> json) =
      _$SaleEntryItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'sale_entry_id')
  String get saleEntryId;
  @override
  @JsonKey(name: 'menu_item_id')
  String get menuItemId;
  @override
  int get quantity;
  @override
  @JsonKey(name: 'selling_price')
  double get sellingPrice;
  @override
  @JsonKey(name: 'menu_item_name')
  String get menuItemName;

  /// Create a copy of SaleEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SaleEntryItemImplCopyWith<_$SaleEntryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
