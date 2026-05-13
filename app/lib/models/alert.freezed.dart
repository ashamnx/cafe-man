// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AlertItem _$AlertItemFromJson(Map<String, dynamic> json) {
  return _AlertItem.fromJson(json);
}

/// @nodoc
mixin _$AlertItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'alert_type')
  String get alertType => throw _privateConstructorUsedError;
  @JsonKey(name: 'ingredient_name')
  String get ingredientName => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_read')
  bool get isRead => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'affected_recipes')
  int get affectedRecipes => throw _privateConstructorUsedError;

  /// Serializes this AlertItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlertItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlertItemCopyWith<AlertItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertItemCopyWith<$Res> {
  factory $AlertItemCopyWith(AlertItem value, $Res Function(AlertItem) then) =
      _$AlertItemCopyWithImpl<$Res, AlertItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'alert_type') String alertType,
    @JsonKey(name: 'ingredient_name') String ingredientName,
    String message,
    @JsonKey(name: 'is_read') bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'affected_recipes') int affectedRecipes,
  });
}

/// @nodoc
class _$AlertItemCopyWithImpl<$Res, $Val extends AlertItem>
    implements $AlertItemCopyWith<$Res> {
  _$AlertItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlertItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? alertType = null,
    Object? ingredientName = null,
    Object? message = null,
    Object? isRead = null,
    Object? createdAt = freezed,
    Object? affectedRecipes = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            alertType: null == alertType
                ? _value.alertType
                : alertType // ignore: cast_nullable_to_non_nullable
                      as String,
            ingredientName: null == ingredientName
                ? _value.ingredientName
                : ingredientName // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            affectedRecipes: null == affectedRecipes
                ? _value.affectedRecipes
                : affectedRecipes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlertItemImplCopyWith<$Res>
    implements $AlertItemCopyWith<$Res> {
  factory _$$AlertItemImplCopyWith(
    _$AlertItemImpl value,
    $Res Function(_$AlertItemImpl) then,
  ) = __$$AlertItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'alert_type') String alertType,
    @JsonKey(name: 'ingredient_name') String ingredientName,
    String message,
    @JsonKey(name: 'is_read') bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'affected_recipes') int affectedRecipes,
  });
}

/// @nodoc
class __$$AlertItemImplCopyWithImpl<$Res>
    extends _$AlertItemCopyWithImpl<$Res, _$AlertItemImpl>
    implements _$$AlertItemImplCopyWith<$Res> {
  __$$AlertItemImplCopyWithImpl(
    _$AlertItemImpl _value,
    $Res Function(_$AlertItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlertItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? alertType = null,
    Object? ingredientName = null,
    Object? message = null,
    Object? isRead = null,
    Object? createdAt = freezed,
    Object? affectedRecipes = null,
  }) {
    return _then(
      _$AlertItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        alertType: null == alertType
            ? _value.alertType
            : alertType // ignore: cast_nullable_to_non_nullable
                  as String,
        ingredientName: null == ingredientName
            ? _value.ingredientName
            : ingredientName // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        affectedRecipes: null == affectedRecipes
            ? _value.affectedRecipes
            : affectedRecipes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertItemImpl implements _AlertItem {
  const _$AlertItemImpl({
    required this.id,
    @JsonKey(name: 'alert_type') this.alertType = '',
    @JsonKey(name: 'ingredient_name') this.ingredientName = '',
    this.message = '',
    @JsonKey(name: 'is_read') this.isRead = false,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'affected_recipes') this.affectedRecipes = 0,
  });

  factory _$AlertItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'alert_type')
  final String alertType;
  @override
  @JsonKey(name: 'ingredient_name')
  final String ingredientName;
  @override
  @JsonKey()
  final String message;
  @override
  @JsonKey(name: 'is_read')
  final bool isRead;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'affected_recipes')
  final int affectedRecipes;

  @override
  String toString() {
    return 'AlertItem(id: $id, alertType: $alertType, ingredientName: $ingredientName, message: $message, isRead: $isRead, createdAt: $createdAt, affectedRecipes: $affectedRecipes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.alertType, alertType) ||
                other.alertType == alertType) &&
            (identical(other.ingredientName, ingredientName) ||
                other.ingredientName == ingredientName) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.affectedRecipes, affectedRecipes) ||
                other.affectedRecipes == affectedRecipes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    alertType,
    ingredientName,
    message,
    isRead,
    createdAt,
    affectedRecipes,
  );

  /// Create a copy of AlertItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertItemImplCopyWith<_$AlertItemImpl> get copyWith =>
      __$$AlertItemImplCopyWithImpl<_$AlertItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertItemImplToJson(this);
  }
}

abstract class _AlertItem implements AlertItem {
  const factory _AlertItem({
    required final String id,
    @JsonKey(name: 'alert_type') final String alertType,
    @JsonKey(name: 'ingredient_name') final String ingredientName,
    final String message,
    @JsonKey(name: 'is_read') final bool isRead,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'affected_recipes') final int affectedRecipes,
  }) = _$AlertItemImpl;

  factory _AlertItem.fromJson(Map<String, dynamic> json) =
      _$AlertItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'alert_type')
  String get alertType;
  @override
  @JsonKey(name: 'ingredient_name')
  String get ingredientName;
  @override
  String get message;
  @override
  @JsonKey(name: 'is_read')
  bool get isRead;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'affected_recipes')
  int get affectedRecipes;

  /// Create a copy of AlertItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertItemImplCopyWith<_$AlertItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
