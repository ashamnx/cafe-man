// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wastage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WastageRecord _$WastageRecordFromJson(Map<String, dynamic> json) {
  return _WastageRecord.fromJson(json);
}

/// @nodoc
mixin _$WastageRecord {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_id')
  String get ingredientId => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'wastage_type')
  String get wastageType => throw _privateConstructorUsedError;
  @JsonKey(name: 'wastage_date')
  DateTime? get wastageDate => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_name')
  String get ingredientName => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_abbr')
  String get unitAbbr => throw _privateConstructorUsedError;

  /// Serializes this WastageRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WastageRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WastageRecordCopyWith<WastageRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WastageRecordCopyWith<$Res> {
  factory $WastageRecordCopyWith(
    WastageRecord value,
    $Res Function(WastageRecord) then,
  ) = _$WastageRecordCopyWithImpl<$Res, WastageRecord>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'ingredient_id') String ingredientId,
    double quantity,
    @JsonKey(name: 'wastage_type') String wastageType,
    @JsonKey(name: 'wastage_date') DateTime? wastageDate,
    String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'ingredient_name') String ingredientName,
    @JsonKey(name: 'unit_abbr') String unitAbbr,
  });
}

/// @nodoc
class _$WastageRecordCopyWithImpl<$Res, $Val extends WastageRecord>
    implements $WastageRecordCopyWith<$Res> {
  _$WastageRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WastageRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientId = null,
    Object? quantity = null,
    Object? wastageType = null,
    Object? wastageDate = freezed,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? ingredientName = null,
    Object? unitAbbr = null,
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
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as double,
            wastageType: null == wastageType
                ? _value.wastageType
                : wastageType // ignore: cast_nullable_to_non_nullable
                      as String,
            wastageDate: freezed == wastageDate
                ? _value.wastageDate
                : wastageDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ingredientName: null == ingredientName
                ? _value.ingredientName
                : ingredientName // ignore: cast_nullable_to_non_nullable
                      as String,
            unitAbbr: null == unitAbbr
                ? _value.unitAbbr
                : unitAbbr // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WastageRecordImplCopyWith<$Res>
    implements $WastageRecordCopyWith<$Res> {
  factory _$$WastageRecordImplCopyWith(
    _$WastageRecordImpl value,
    $Res Function(_$WastageRecordImpl) then,
  ) = __$$WastageRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'ingredient_id') String ingredientId,
    double quantity,
    @JsonKey(name: 'wastage_type') String wastageType,
    @JsonKey(name: 'wastage_date') DateTime? wastageDate,
    String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'ingredient_name') String ingredientName,
    @JsonKey(name: 'unit_abbr') String unitAbbr,
  });
}

/// @nodoc
class __$$WastageRecordImplCopyWithImpl<$Res>
    extends _$WastageRecordCopyWithImpl<$Res, _$WastageRecordImpl>
    implements _$$WastageRecordImplCopyWith<$Res> {
  __$$WastageRecordImplCopyWithImpl(
    _$WastageRecordImpl _value,
    $Res Function(_$WastageRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WastageRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientId = null,
    Object? quantity = null,
    Object? wastageType = null,
    Object? wastageDate = freezed,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? ingredientName = null,
    Object? unitAbbr = null,
  }) {
    return _then(
      _$WastageRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ingredientId: null == ingredientId
            ? _value.ingredientId
            : ingredientId // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as double,
        wastageType: null == wastageType
            ? _value.wastageType
            : wastageType // ignore: cast_nullable_to_non_nullable
                  as String,
        wastageDate: freezed == wastageDate
            ? _value.wastageDate
            : wastageDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ingredientName: null == ingredientName
            ? _value.ingredientName
            : ingredientName // ignore: cast_nullable_to_non_nullable
                  as String,
        unitAbbr: null == unitAbbr
            ? _value.unitAbbr
            : unitAbbr // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WastageRecordImpl implements _WastageRecord {
  const _$WastageRecordImpl({
    required this.id,
    @JsonKey(name: 'ingredient_id') required this.ingredientId,
    required this.quantity,
    @JsonKey(name: 'wastage_type') this.wastageType = '',
    @JsonKey(name: 'wastage_date') this.wastageDate,
    this.notes = '',
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'ingredient_name') this.ingredientName = '',
    @JsonKey(name: 'unit_abbr') this.unitAbbr = '',
  });

  factory _$WastageRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$WastageRecordImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'ingredient_id')
  final String ingredientId;
  @override
  final double quantity;
  @override
  @JsonKey(name: 'wastage_type')
  final String wastageType;
  @override
  @JsonKey(name: 'wastage_date')
  final DateTime? wastageDate;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'ingredient_name')
  final String ingredientName;
  @override
  @JsonKey(name: 'unit_abbr')
  final String unitAbbr;

  @override
  String toString() {
    return 'WastageRecord(id: $id, ingredientId: $ingredientId, quantity: $quantity, wastageType: $wastageType, wastageDate: $wastageDate, notes: $notes, createdAt: $createdAt, ingredientName: $ingredientName, unitAbbr: $unitAbbr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WastageRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ingredientId, ingredientId) ||
                other.ingredientId == ingredientId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.wastageType, wastageType) ||
                other.wastageType == wastageType) &&
            (identical(other.wastageDate, wastageDate) ||
                other.wastageDate == wastageDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.ingredientName, ingredientName) ||
                other.ingredientName == ingredientName) &&
            (identical(other.unitAbbr, unitAbbr) ||
                other.unitAbbr == unitAbbr));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    ingredientId,
    quantity,
    wastageType,
    wastageDate,
    notes,
    createdAt,
    ingredientName,
    unitAbbr,
  );

  /// Create a copy of WastageRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WastageRecordImplCopyWith<_$WastageRecordImpl> get copyWith =>
      __$$WastageRecordImplCopyWithImpl<_$WastageRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WastageRecordImplToJson(this);
  }
}

abstract class _WastageRecord implements WastageRecord {
  const factory _WastageRecord({
    required final String id,
    @JsonKey(name: 'ingredient_id') required final String ingredientId,
    required final double quantity,
    @JsonKey(name: 'wastage_type') final String wastageType,
    @JsonKey(name: 'wastage_date') final DateTime? wastageDate,
    final String notes,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'ingredient_name') final String ingredientName,
    @JsonKey(name: 'unit_abbr') final String unitAbbr,
  }) = _$WastageRecordImpl;

  factory _WastageRecord.fromJson(Map<String, dynamic> json) =
      _$WastageRecordImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'ingredient_id')
  String get ingredientId;
  @override
  double get quantity;
  @override
  @JsonKey(name: 'wastage_type')
  String get wastageType;
  @override
  @JsonKey(name: 'wastage_date')
  DateTime? get wastageDate;
  @override
  String get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'ingredient_name')
  String get ingredientName;
  @override
  @JsonKey(name: 'unit_abbr')
  String get unitAbbr;

  /// Create a copy of WastageRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WastageRecordImplCopyWith<_$WastageRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
