// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StockMovement _$StockMovementFromJson(Map<String, dynamic> json) {
  return _StockMovement.fromJson(json);
}

/// @nodoc
mixin _$StockMovement {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_id')
  String get ingredientId => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'movement_type')
  String get movementType => throw _privateConstructorUsedError;
  @JsonKey(name: 'reference_type')
  String get referenceType => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_name')
  String get ingredientName => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_abbr')
  String get unitAbbr => throw _privateConstructorUsedError;

  /// Serializes this StockMovement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StockMovementCopyWith<StockMovement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StockMovementCopyWith<$Res> {
  factory $StockMovementCopyWith(
    StockMovement value,
    $Res Function(StockMovement) then,
  ) = _$StockMovementCopyWithImpl<$Res, StockMovement>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'ingredient_id') String ingredientId,
    double quantity,
    @JsonKey(name: 'movement_type') String movementType,
    @JsonKey(name: 'reference_type') String referenceType,
    String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'ingredient_name') String ingredientName,
    @JsonKey(name: 'unit_abbr') String unitAbbr,
  });
}

/// @nodoc
class _$StockMovementCopyWithImpl<$Res, $Val extends StockMovement>
    implements $StockMovementCopyWith<$Res> {
  _$StockMovementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientId = null,
    Object? quantity = null,
    Object? movementType = null,
    Object? referenceType = null,
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
            movementType: null == movementType
                ? _value.movementType
                : movementType // ignore: cast_nullable_to_non_nullable
                      as String,
            referenceType: null == referenceType
                ? _value.referenceType
                : referenceType // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$StockMovementImplCopyWith<$Res>
    implements $StockMovementCopyWith<$Res> {
  factory _$$StockMovementImplCopyWith(
    _$StockMovementImpl value,
    $Res Function(_$StockMovementImpl) then,
  ) = __$$StockMovementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'ingredient_id') String ingredientId,
    double quantity,
    @JsonKey(name: 'movement_type') String movementType,
    @JsonKey(name: 'reference_type') String referenceType,
    String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'ingredient_name') String ingredientName,
    @JsonKey(name: 'unit_abbr') String unitAbbr,
  });
}

/// @nodoc
class __$$StockMovementImplCopyWithImpl<$Res>
    extends _$StockMovementCopyWithImpl<$Res, _$StockMovementImpl>
    implements _$$StockMovementImplCopyWith<$Res> {
  __$$StockMovementImplCopyWithImpl(
    _$StockMovementImpl _value,
    $Res Function(_$StockMovementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientId = null,
    Object? quantity = null,
    Object? movementType = null,
    Object? referenceType = null,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? ingredientName = null,
    Object? unitAbbr = null,
  }) {
    return _then(
      _$StockMovementImpl(
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
        movementType: null == movementType
            ? _value.movementType
            : movementType // ignore: cast_nullable_to_non_nullable
                  as String,
        referenceType: null == referenceType
            ? _value.referenceType
            : referenceType // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$StockMovementImpl implements _StockMovement {
  const _$StockMovementImpl({
    required this.id,
    @JsonKey(name: 'ingredient_id') required this.ingredientId,
    required this.quantity,
    @JsonKey(name: 'movement_type') this.movementType = '',
    @JsonKey(name: 'reference_type') this.referenceType = '',
    this.notes = '',
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'ingredient_name') this.ingredientName = '',
    @JsonKey(name: 'unit_abbr') this.unitAbbr = '',
  });

  factory _$StockMovementImpl.fromJson(Map<String, dynamic> json) =>
      _$$StockMovementImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'ingredient_id')
  final String ingredientId;
  @override
  final double quantity;
  @override
  @JsonKey(name: 'movement_type')
  final String movementType;
  @override
  @JsonKey(name: 'reference_type')
  final String referenceType;
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
    return 'StockMovement(id: $id, ingredientId: $ingredientId, quantity: $quantity, movementType: $movementType, referenceType: $referenceType, notes: $notes, createdAt: $createdAt, ingredientName: $ingredientName, unitAbbr: $unitAbbr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StockMovementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ingredientId, ingredientId) ||
                other.ingredientId == ingredientId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.movementType, movementType) ||
                other.movementType == movementType) &&
            (identical(other.referenceType, referenceType) ||
                other.referenceType == referenceType) &&
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
    movementType,
    referenceType,
    notes,
    createdAt,
    ingredientName,
    unitAbbr,
  );

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StockMovementImplCopyWith<_$StockMovementImpl> get copyWith =>
      __$$StockMovementImplCopyWithImpl<_$StockMovementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StockMovementImplToJson(this);
  }
}

abstract class _StockMovement implements StockMovement {
  const factory _StockMovement({
    required final String id,
    @JsonKey(name: 'ingredient_id') required final String ingredientId,
    required final double quantity,
    @JsonKey(name: 'movement_type') final String movementType,
    @JsonKey(name: 'reference_type') final String referenceType,
    final String notes,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'ingredient_name') final String ingredientName,
    @JsonKey(name: 'unit_abbr') final String unitAbbr,
  }) = _$StockMovementImpl;

  factory _StockMovement.fromJson(Map<String, dynamic> json) =
      _$StockMovementImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'ingredient_id')
  String get ingredientId;
  @override
  double get quantity;
  @override
  @JsonKey(name: 'movement_type')
  String get movementType;
  @override
  @JsonKey(name: 'reference_type')
  String get referenceType;
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

  /// Create a copy of StockMovement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StockMovementImplCopyWith<_$StockMovementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
