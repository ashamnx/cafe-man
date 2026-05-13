// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VendorBill _$VendorBillFromJson(Map<String, dynamic> json) {
  return _VendorBill.fromJson(json);
}

/// @nodoc
mixin _$VendorBill {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_id')
  String? get vendorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'bill_number')
  String get billNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'bill_date')
  String? get billDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  double? get totalAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_path')
  String? get imagePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'entry_type')
  String get entryType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  List<VendorBillItem> get items => throw _privateConstructorUsedError;

  /// Serializes this VendorBill to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorBill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorBillCopyWith<VendorBill> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorBillCopyWith<$Res> {
  factory $VendorBillCopyWith(
    VendorBill value,
    $Res Function(VendorBill) then,
  ) = _$VendorBillCopyWithImpl<$Res, VendorBill>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'vendor_id') String? vendorId,
    @JsonKey(name: 'bill_number') String billNumber,
    @JsonKey(name: 'bill_date') String? billDate,
    @JsonKey(name: 'total_amount') double? totalAmount,
    @JsonKey(name: 'image_path') String? imagePath,
    @JsonKey(name: 'entry_type') String entryType,
    String status,
    String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<VendorBillItem> items,
  });
}

/// @nodoc
class _$VendorBillCopyWithImpl<$Res, $Val extends VendorBill>
    implements $VendorBillCopyWith<$Res> {
  _$VendorBillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorBill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = freezed,
    Object? billNumber = null,
    Object? billDate = freezed,
    Object? totalAmount = freezed,
    Object? imagePath = freezed,
    Object? entryType = null,
    Object? status = null,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            vendorId: freezed == vendorId
                ? _value.vendorId
                : vendorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            billNumber: null == billNumber
                ? _value.billNumber
                : billNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            billDate: freezed == billDate
                ? _value.billDate
                : billDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalAmount: freezed == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            entryType: null == entryType
                ? _value.entryType
                : entryType // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<VendorBillItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorBillImplCopyWith<$Res>
    implements $VendorBillCopyWith<$Res> {
  factory _$$VendorBillImplCopyWith(
    _$VendorBillImpl value,
    $Res Function(_$VendorBillImpl) then,
  ) = __$$VendorBillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'vendor_id') String? vendorId,
    @JsonKey(name: 'bill_number') String billNumber,
    @JsonKey(name: 'bill_date') String? billDate,
    @JsonKey(name: 'total_amount') double? totalAmount,
    @JsonKey(name: 'image_path') String? imagePath,
    @JsonKey(name: 'entry_type') String entryType,
    String status,
    String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    List<VendorBillItem> items,
  });
}

/// @nodoc
class __$$VendorBillImplCopyWithImpl<$Res>
    extends _$VendorBillCopyWithImpl<$Res, _$VendorBillImpl>
    implements _$$VendorBillImplCopyWith<$Res> {
  __$$VendorBillImplCopyWithImpl(
    _$VendorBillImpl _value,
    $Res Function(_$VendorBillImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VendorBill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = freezed,
    Object? billNumber = null,
    Object? billDate = freezed,
    Object? totalAmount = freezed,
    Object? imagePath = freezed,
    Object? entryType = null,
    Object? status = null,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? items = null,
  }) {
    return _then(
      _$VendorBillImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        vendorId: freezed == vendorId
            ? _value.vendorId
            : vendorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        billNumber: null == billNumber
            ? _value.billNumber
            : billNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        billDate: freezed == billDate
            ? _value.billDate
            : billDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalAmount: freezed == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        entryType: null == entryType
            ? _value.entryType
            : entryType // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<VendorBillItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorBillImpl implements _VendorBill {
  const _$VendorBillImpl({
    required this.id,
    @JsonKey(name: 'vendor_id') this.vendorId,
    @JsonKey(name: 'bill_number') this.billNumber = '',
    @JsonKey(name: 'bill_date') this.billDate,
    @JsonKey(name: 'total_amount') this.totalAmount,
    @JsonKey(name: 'image_path') this.imagePath,
    @JsonKey(name: 'entry_type') this.entryType = 'scan',
    this.status = 'pending',
    this.notes = '',
    @JsonKey(name: 'created_at') this.createdAt,
    final List<VendorBillItem> items = const [],
  }) : _items = items;

  factory _$VendorBillImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorBillImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'vendor_id')
  final String? vendorId;
  @override
  @JsonKey(name: 'bill_number')
  final String billNumber;
  @override
  @JsonKey(name: 'bill_date')
  final String? billDate;
  @override
  @JsonKey(name: 'total_amount')
  final double? totalAmount;
  @override
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @override
  @JsonKey(name: 'entry_type')
  final String entryType;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  final List<VendorBillItem> _items;
  @override
  @JsonKey()
  List<VendorBillItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'VendorBill(id: $id, vendorId: $vendorId, billNumber: $billNumber, billDate: $billDate, totalAmount: $totalAmount, imagePath: $imagePath, entryType: $entryType, status: $status, notes: $notes, createdAt: $createdAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorBillImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.billNumber, billNumber) ||
                other.billNumber == billNumber) &&
            (identical(other.billDate, billDate) ||
                other.billDate == billDate) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.entryType, entryType) ||
                other.entryType == entryType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    vendorId,
    billNumber,
    billDate,
    totalAmount,
    imagePath,
    entryType,
    status,
    notes,
    createdAt,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of VendorBill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorBillImplCopyWith<_$VendorBillImpl> get copyWith =>
      __$$VendorBillImplCopyWithImpl<_$VendorBillImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorBillImplToJson(this);
  }
}

abstract class _VendorBill implements VendorBill {
  const factory _VendorBill({
    required final String id,
    @JsonKey(name: 'vendor_id') final String? vendorId,
    @JsonKey(name: 'bill_number') final String billNumber,
    @JsonKey(name: 'bill_date') final String? billDate,
    @JsonKey(name: 'total_amount') final double? totalAmount,
    @JsonKey(name: 'image_path') final String? imagePath,
    @JsonKey(name: 'entry_type') final String entryType,
    final String status,
    final String notes,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    final List<VendorBillItem> items,
  }) = _$VendorBillImpl;

  factory _VendorBill.fromJson(Map<String, dynamic> json) =
      _$VendorBillImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'vendor_id')
  String? get vendorId;
  @override
  @JsonKey(name: 'bill_number')
  String get billNumber;
  @override
  @JsonKey(name: 'bill_date')
  String? get billDate;
  @override
  @JsonKey(name: 'total_amount')
  double? get totalAmount;
  @override
  @JsonKey(name: 'image_path')
  String? get imagePath;
  @override
  @JsonKey(name: 'entry_type')
  String get entryType;
  @override
  String get status;
  @override
  String get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  List<VendorBillItem> get items;

  /// Create a copy of VendorBill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorBillImplCopyWith<_$VendorBillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VendorBillItem _$VendorBillItemFromJson(Map<String, dynamic> json) {
  return _VendorBillItem.fromJson(json);
}

/// @nodoc
mixin _$VendorBillItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'bill_id')
  String get billId => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_item_name')
  String get rawItemName => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_quantity')
  double? get rawQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_unit')
  String get rawUnit => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_unit_price')
  double? get rawUnitPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'raw_total_price')
  double? get rawTotalPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_id')
  String? get ingredientId => throw _privateConstructorUsedError;
  @JsonKey(name: 'mapped_quantity')
  double? get mappedQuantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'mapped_unit_price')
  double? get mappedUnitPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'mapping_status')
  String get mappingStatus => throw _privateConstructorUsedError;

  /// Serializes this VendorBillItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorBillItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorBillItemCopyWith<VendorBillItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorBillItemCopyWith<$Res> {
  factory $VendorBillItemCopyWith(
    VendorBillItem value,
    $Res Function(VendorBillItem) then,
  ) = _$VendorBillItemCopyWithImpl<$Res, VendorBillItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'bill_id') String billId,
    @JsonKey(name: 'raw_item_name') String rawItemName,
    @JsonKey(name: 'raw_quantity') double? rawQuantity,
    @JsonKey(name: 'raw_unit') String rawUnit,
    @JsonKey(name: 'raw_unit_price') double? rawUnitPrice,
    @JsonKey(name: 'raw_total_price') double? rawTotalPrice,
    @JsonKey(name: 'ingredient_id') String? ingredientId,
    @JsonKey(name: 'mapped_quantity') double? mappedQuantity,
    @JsonKey(name: 'mapped_unit_price') double? mappedUnitPrice,
    @JsonKey(name: 'mapping_status') String mappingStatus,
  });
}

/// @nodoc
class _$VendorBillItemCopyWithImpl<$Res, $Val extends VendorBillItem>
    implements $VendorBillItemCopyWith<$Res> {
  _$VendorBillItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorBillItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? billId = null,
    Object? rawItemName = null,
    Object? rawQuantity = freezed,
    Object? rawUnit = null,
    Object? rawUnitPrice = freezed,
    Object? rawTotalPrice = freezed,
    Object? ingredientId = freezed,
    Object? mappedQuantity = freezed,
    Object? mappedUnitPrice = freezed,
    Object? mappingStatus = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            billId: null == billId
                ? _value.billId
                : billId // ignore: cast_nullable_to_non_nullable
                      as String,
            rawItemName: null == rawItemName
                ? _value.rawItemName
                : rawItemName // ignore: cast_nullable_to_non_nullable
                      as String,
            rawQuantity: freezed == rawQuantity
                ? _value.rawQuantity
                : rawQuantity // ignore: cast_nullable_to_non_nullable
                      as double?,
            rawUnit: null == rawUnit
                ? _value.rawUnit
                : rawUnit // ignore: cast_nullable_to_non_nullable
                      as String,
            rawUnitPrice: freezed == rawUnitPrice
                ? _value.rawUnitPrice
                : rawUnitPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            rawTotalPrice: freezed == rawTotalPrice
                ? _value.rawTotalPrice
                : rawTotalPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            ingredientId: freezed == ingredientId
                ? _value.ingredientId
                : ingredientId // ignore: cast_nullable_to_non_nullable
                      as String?,
            mappedQuantity: freezed == mappedQuantity
                ? _value.mappedQuantity
                : mappedQuantity // ignore: cast_nullable_to_non_nullable
                      as double?,
            mappedUnitPrice: freezed == mappedUnitPrice
                ? _value.mappedUnitPrice
                : mappedUnitPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            mappingStatus: null == mappingStatus
                ? _value.mappingStatus
                : mappingStatus // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorBillItemImplCopyWith<$Res>
    implements $VendorBillItemCopyWith<$Res> {
  factory _$$VendorBillItemImplCopyWith(
    _$VendorBillItemImpl value,
    $Res Function(_$VendorBillItemImpl) then,
  ) = __$$VendorBillItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'bill_id') String billId,
    @JsonKey(name: 'raw_item_name') String rawItemName,
    @JsonKey(name: 'raw_quantity') double? rawQuantity,
    @JsonKey(name: 'raw_unit') String rawUnit,
    @JsonKey(name: 'raw_unit_price') double? rawUnitPrice,
    @JsonKey(name: 'raw_total_price') double? rawTotalPrice,
    @JsonKey(name: 'ingredient_id') String? ingredientId,
    @JsonKey(name: 'mapped_quantity') double? mappedQuantity,
    @JsonKey(name: 'mapped_unit_price') double? mappedUnitPrice,
    @JsonKey(name: 'mapping_status') String mappingStatus,
  });
}

/// @nodoc
class __$$VendorBillItemImplCopyWithImpl<$Res>
    extends _$VendorBillItemCopyWithImpl<$Res, _$VendorBillItemImpl>
    implements _$$VendorBillItemImplCopyWith<$Res> {
  __$$VendorBillItemImplCopyWithImpl(
    _$VendorBillItemImpl _value,
    $Res Function(_$VendorBillItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VendorBillItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? billId = null,
    Object? rawItemName = null,
    Object? rawQuantity = freezed,
    Object? rawUnit = null,
    Object? rawUnitPrice = freezed,
    Object? rawTotalPrice = freezed,
    Object? ingredientId = freezed,
    Object? mappedQuantity = freezed,
    Object? mappedUnitPrice = freezed,
    Object? mappingStatus = null,
  }) {
    return _then(
      _$VendorBillItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        billId: null == billId
            ? _value.billId
            : billId // ignore: cast_nullable_to_non_nullable
                  as String,
        rawItemName: null == rawItemName
            ? _value.rawItemName
            : rawItemName // ignore: cast_nullable_to_non_nullable
                  as String,
        rawQuantity: freezed == rawQuantity
            ? _value.rawQuantity
            : rawQuantity // ignore: cast_nullable_to_non_nullable
                  as double?,
        rawUnit: null == rawUnit
            ? _value.rawUnit
            : rawUnit // ignore: cast_nullable_to_non_nullable
                  as String,
        rawUnitPrice: freezed == rawUnitPrice
            ? _value.rawUnitPrice
            : rawUnitPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        rawTotalPrice: freezed == rawTotalPrice
            ? _value.rawTotalPrice
            : rawTotalPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        ingredientId: freezed == ingredientId
            ? _value.ingredientId
            : ingredientId // ignore: cast_nullable_to_non_nullable
                  as String?,
        mappedQuantity: freezed == mappedQuantity
            ? _value.mappedQuantity
            : mappedQuantity // ignore: cast_nullable_to_non_nullable
                  as double?,
        mappedUnitPrice: freezed == mappedUnitPrice
            ? _value.mappedUnitPrice
            : mappedUnitPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        mappingStatus: null == mappingStatus
            ? _value.mappingStatus
            : mappingStatus // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorBillItemImpl implements _VendorBillItem {
  const _$VendorBillItemImpl({
    required this.id,
    @JsonKey(name: 'bill_id') required this.billId,
    @JsonKey(name: 'raw_item_name') this.rawItemName = '',
    @JsonKey(name: 'raw_quantity') this.rawQuantity,
    @JsonKey(name: 'raw_unit') this.rawUnit = '',
    @JsonKey(name: 'raw_unit_price') this.rawUnitPrice,
    @JsonKey(name: 'raw_total_price') this.rawTotalPrice,
    @JsonKey(name: 'ingredient_id') this.ingredientId,
    @JsonKey(name: 'mapped_quantity') this.mappedQuantity,
    @JsonKey(name: 'mapped_unit_price') this.mappedUnitPrice,
    @JsonKey(name: 'mapping_status') this.mappingStatus = 'unmapped',
  });

  factory _$VendorBillItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorBillItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'bill_id')
  final String billId;
  @override
  @JsonKey(name: 'raw_item_name')
  final String rawItemName;
  @override
  @JsonKey(name: 'raw_quantity')
  final double? rawQuantity;
  @override
  @JsonKey(name: 'raw_unit')
  final String rawUnit;
  @override
  @JsonKey(name: 'raw_unit_price')
  final double? rawUnitPrice;
  @override
  @JsonKey(name: 'raw_total_price')
  final double? rawTotalPrice;
  @override
  @JsonKey(name: 'ingredient_id')
  final String? ingredientId;
  @override
  @JsonKey(name: 'mapped_quantity')
  final double? mappedQuantity;
  @override
  @JsonKey(name: 'mapped_unit_price')
  final double? mappedUnitPrice;
  @override
  @JsonKey(name: 'mapping_status')
  final String mappingStatus;

  @override
  String toString() {
    return 'VendorBillItem(id: $id, billId: $billId, rawItemName: $rawItemName, rawQuantity: $rawQuantity, rawUnit: $rawUnit, rawUnitPrice: $rawUnitPrice, rawTotalPrice: $rawTotalPrice, ingredientId: $ingredientId, mappedQuantity: $mappedQuantity, mappedUnitPrice: $mappedUnitPrice, mappingStatus: $mappingStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorBillItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.billId, billId) || other.billId == billId) &&
            (identical(other.rawItemName, rawItemName) ||
                other.rawItemName == rawItemName) &&
            (identical(other.rawQuantity, rawQuantity) ||
                other.rawQuantity == rawQuantity) &&
            (identical(other.rawUnit, rawUnit) || other.rawUnit == rawUnit) &&
            (identical(other.rawUnitPrice, rawUnitPrice) ||
                other.rawUnitPrice == rawUnitPrice) &&
            (identical(other.rawTotalPrice, rawTotalPrice) ||
                other.rawTotalPrice == rawTotalPrice) &&
            (identical(other.ingredientId, ingredientId) ||
                other.ingredientId == ingredientId) &&
            (identical(other.mappedQuantity, mappedQuantity) ||
                other.mappedQuantity == mappedQuantity) &&
            (identical(other.mappedUnitPrice, mappedUnitPrice) ||
                other.mappedUnitPrice == mappedUnitPrice) &&
            (identical(other.mappingStatus, mappingStatus) ||
                other.mappingStatus == mappingStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    billId,
    rawItemName,
    rawQuantity,
    rawUnit,
    rawUnitPrice,
    rawTotalPrice,
    ingredientId,
    mappedQuantity,
    mappedUnitPrice,
    mappingStatus,
  );

  /// Create a copy of VendorBillItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorBillItemImplCopyWith<_$VendorBillItemImpl> get copyWith =>
      __$$VendorBillItemImplCopyWithImpl<_$VendorBillItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorBillItemImplToJson(this);
  }
}

abstract class _VendorBillItem implements VendorBillItem {
  const factory _VendorBillItem({
    required final String id,
    @JsonKey(name: 'bill_id') required final String billId,
    @JsonKey(name: 'raw_item_name') final String rawItemName,
    @JsonKey(name: 'raw_quantity') final double? rawQuantity,
    @JsonKey(name: 'raw_unit') final String rawUnit,
    @JsonKey(name: 'raw_unit_price') final double? rawUnitPrice,
    @JsonKey(name: 'raw_total_price') final double? rawTotalPrice,
    @JsonKey(name: 'ingredient_id') final String? ingredientId,
    @JsonKey(name: 'mapped_quantity') final double? mappedQuantity,
    @JsonKey(name: 'mapped_unit_price') final double? mappedUnitPrice,
    @JsonKey(name: 'mapping_status') final String mappingStatus,
  }) = _$VendorBillItemImpl;

  factory _VendorBillItem.fromJson(Map<String, dynamic> json) =
      _$VendorBillItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'bill_id')
  String get billId;
  @override
  @JsonKey(name: 'raw_item_name')
  String get rawItemName;
  @override
  @JsonKey(name: 'raw_quantity')
  double? get rawQuantity;
  @override
  @JsonKey(name: 'raw_unit')
  String get rawUnit;
  @override
  @JsonKey(name: 'raw_unit_price')
  double? get rawUnitPrice;
  @override
  @JsonKey(name: 'raw_total_price')
  double? get rawTotalPrice;
  @override
  @JsonKey(name: 'ingredient_id')
  String? get ingredientId;
  @override
  @JsonKey(name: 'mapped_quantity')
  double? get mappedQuantity;
  @override
  @JsonKey(name: 'mapped_unit_price')
  double? get mappedUnitPrice;
  @override
  @JsonKey(name: 'mapping_status')
  String get mappingStatus;

  /// Create a copy of VendorBillItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorBillItemImplCopyWith<_$VendorBillItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
