// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_tokens.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _LoginResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginResponse {
  User get user => throw _privateConstructorUsedError;
  List<Organization> get orgs => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh_token')
  String get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseCopyWith<LoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseCopyWith<$Res> {
  factory $LoginResponseCopyWith(
    LoginResponse value,
    $Res Function(LoginResponse) then,
  ) = _$LoginResponseCopyWithImpl<$Res, LoginResponse>;
  @useResult
  $Res call({
    User user,
    List<Organization> orgs,
    @JsonKey(name: 'access_token') String accessToken,
    @JsonKey(name: 'refresh_token') String refreshToken,
  });

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$LoginResponseCopyWithImpl<$Res, $Val extends LoginResponse>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? orgs = null,
    Object? accessToken = null,
    Object? refreshToken = null,
  }) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User,
            orgs: null == orgs
                ? _value.orgs
                : orgs // ignore: cast_nullable_to_non_nullable
                      as List<Organization>,
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginResponseImplCopyWith<$Res>
    implements $LoginResponseCopyWith<$Res> {
  factory _$$LoginResponseImplCopyWith(
    _$LoginResponseImpl value,
    $Res Function(_$LoginResponseImpl) then,
  ) = __$$LoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    User user,
    List<Organization> orgs,
    @JsonKey(name: 'access_token') String accessToken,
    @JsonKey(name: 'refresh_token') String refreshToken,
  });

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$LoginResponseImplCopyWithImpl<$Res>
    extends _$LoginResponseCopyWithImpl<$Res, _$LoginResponseImpl>
    implements _$$LoginResponseImplCopyWith<$Res> {
  __$$LoginResponseImplCopyWithImpl(
    _$LoginResponseImpl _value,
    $Res Function(_$LoginResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? orgs = null,
    Object? accessToken = null,
    Object? refreshToken = null,
  }) {
    return _then(
      _$LoginResponseImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        orgs: null == orgs
            ? _value._orgs
            : orgs // ignore: cast_nullable_to_non_nullable
                  as List<Organization>,
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseImpl implements _LoginResponse {
  const _$LoginResponseImpl({
    required this.user,
    required final List<Organization> orgs,
    @JsonKey(name: 'access_token') required this.accessToken,
    @JsonKey(name: 'refresh_token') required this.refreshToken,
  }) : _orgs = orgs;

  factory _$LoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseImplFromJson(json);

  @override
  final User user;
  final List<Organization> _orgs;
  @override
  List<Organization> get orgs {
    if (_orgs is EqualUnmodifiableListView) return _orgs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orgs);
  }

  @override
  @JsonKey(name: 'access_token')
  final String accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @override
  String toString() {
    return 'LoginResponse(user: $user, orgs: $orgs, accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._orgs, _orgs) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    const DeepCollectionEquality().hash(_orgs),
    accessToken,
    refreshToken,
  );

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      __$$LoginResponseImplCopyWithImpl<_$LoginResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseImplToJson(this);
  }
}

abstract class _LoginResponse implements LoginResponse {
  const factory _LoginResponse({
    required final User user,
    required final List<Organization> orgs,
    @JsonKey(name: 'access_token') required final String accessToken,
    @JsonKey(name: 'refresh_token') required final String refreshToken,
  }) = _$LoginResponseImpl;

  factory _LoginResponse.fromJson(Map<String, dynamic> json) =
      _$LoginResponseImpl.fromJson;

  @override
  User get user;
  @override
  List<Organization> get orgs;
  @override
  @JsonKey(name: 'access_token')
  String get accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  String get refreshToken;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) {
  return _RegisterResponse.fromJson(json);
}

/// @nodoc
mixin _$RegisterResponse {
  User get user => throw _privateConstructorUsedError;
  Organization get org => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'refresh_token')
  String get refreshToken => throw _privateConstructorUsedError;

  /// Serializes this RegisterResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterResponseCopyWith<RegisterResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterResponseCopyWith<$Res> {
  factory $RegisterResponseCopyWith(
    RegisterResponse value,
    $Res Function(RegisterResponse) then,
  ) = _$RegisterResponseCopyWithImpl<$Res, RegisterResponse>;
  @useResult
  $Res call({
    User user,
    Organization org,
    @JsonKey(name: 'access_token') String accessToken,
    @JsonKey(name: 'refresh_token') String refreshToken,
  });

  $UserCopyWith<$Res> get user;
  $OrganizationCopyWith<$Res> get org;
}

/// @nodoc
class _$RegisterResponseCopyWithImpl<$Res, $Val extends RegisterResponse>
    implements $RegisterResponseCopyWith<$Res> {
  _$RegisterResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? org = null,
    Object? accessToken = null,
    Object? refreshToken = null,
  }) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User,
            org: null == org
                ? _value.org
                : org // ignore: cast_nullable_to_non_nullable
                      as Organization,
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of RegisterResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of RegisterResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationCopyWith<$Res> get org {
    return $OrganizationCopyWith<$Res>(_value.org, (value) {
      return _then(_value.copyWith(org: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RegisterResponseImplCopyWith<$Res>
    implements $RegisterResponseCopyWith<$Res> {
  factory _$$RegisterResponseImplCopyWith(
    _$RegisterResponseImpl value,
    $Res Function(_$RegisterResponseImpl) then,
  ) = __$$RegisterResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    User user,
    Organization org,
    @JsonKey(name: 'access_token') String accessToken,
    @JsonKey(name: 'refresh_token') String refreshToken,
  });

  @override
  $UserCopyWith<$Res> get user;
  @override
  $OrganizationCopyWith<$Res> get org;
}

/// @nodoc
class __$$RegisterResponseImplCopyWithImpl<$Res>
    extends _$RegisterResponseCopyWithImpl<$Res, _$RegisterResponseImpl>
    implements _$$RegisterResponseImplCopyWith<$Res> {
  __$$RegisterResponseImplCopyWithImpl(
    _$RegisterResponseImpl _value,
    $Res Function(_$RegisterResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? org = null,
    Object? accessToken = null,
    Object? refreshToken = null,
  }) {
    return _then(
      _$RegisterResponseImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        org: null == org
            ? _value.org
            : org // ignore: cast_nullable_to_non_nullable
                  as Organization,
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterResponseImpl implements _RegisterResponse {
  const _$RegisterResponseImpl({
    required this.user,
    required this.org,
    @JsonKey(name: 'access_token') required this.accessToken,
    @JsonKey(name: 'refresh_token') required this.refreshToken,
  });

  factory _$RegisterResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterResponseImplFromJson(json);

  @override
  final User user;
  @override
  final Organization org;
  @override
  @JsonKey(name: 'access_token')
  final String accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @override
  String toString() {
    return 'RegisterResponse(user: $user, org: $org, accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.org, org) || other.org == org) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, user, org, accessToken, refreshToken);

  /// Create a copy of RegisterResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterResponseImplCopyWith<_$RegisterResponseImpl> get copyWith =>
      __$$RegisterResponseImplCopyWithImpl<_$RegisterResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterResponseImplToJson(this);
  }
}

abstract class _RegisterResponse implements RegisterResponse {
  const factory _RegisterResponse({
    required final User user,
    required final Organization org,
    @JsonKey(name: 'access_token') required final String accessToken,
    @JsonKey(name: 'refresh_token') required final String refreshToken,
  }) = _$RegisterResponseImpl;

  factory _RegisterResponse.fromJson(Map<String, dynamic> json) =
      _$RegisterResponseImpl.fromJson;

  @override
  User get user;
  @override
  Organization get org;
  @override
  @JsonKey(name: 'access_token')
  String get accessToken;
  @override
  @JsonKey(name: 'refresh_token')
  String get refreshToken;

  /// Create a copy of RegisterResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterResponseImplCopyWith<_$RegisterResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SelectOrgResponse _$SelectOrgResponseFromJson(Map<String, dynamic> json) {
  return _SelectOrgResponse.fromJson(json);
}

/// @nodoc
mixin _$SelectOrgResponse {
  Organization get org => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_token')
  String get accessToken => throw _privateConstructorUsedError;

  /// Serializes this SelectOrgResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SelectOrgResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SelectOrgResponseCopyWith<SelectOrgResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SelectOrgResponseCopyWith<$Res> {
  factory $SelectOrgResponseCopyWith(
    SelectOrgResponse value,
    $Res Function(SelectOrgResponse) then,
  ) = _$SelectOrgResponseCopyWithImpl<$Res, SelectOrgResponse>;
  @useResult
  $Res call({
    Organization org,
    @JsonKey(name: 'access_token') String accessToken,
  });

  $OrganizationCopyWith<$Res> get org;
}

/// @nodoc
class _$SelectOrgResponseCopyWithImpl<$Res, $Val extends SelectOrgResponse>
    implements $SelectOrgResponseCopyWith<$Res> {
  _$SelectOrgResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SelectOrgResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? org = null, Object? accessToken = null}) {
    return _then(
      _value.copyWith(
            org: null == org
                ? _value.org
                : org // ignore: cast_nullable_to_non_nullable
                      as Organization,
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of SelectOrgResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationCopyWith<$Res> get org {
    return $OrganizationCopyWith<$Res>(_value.org, (value) {
      return _then(_value.copyWith(org: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SelectOrgResponseImplCopyWith<$Res>
    implements $SelectOrgResponseCopyWith<$Res> {
  factory _$$SelectOrgResponseImplCopyWith(
    _$SelectOrgResponseImpl value,
    $Res Function(_$SelectOrgResponseImpl) then,
  ) = __$$SelectOrgResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Organization org,
    @JsonKey(name: 'access_token') String accessToken,
  });

  @override
  $OrganizationCopyWith<$Res> get org;
}

/// @nodoc
class __$$SelectOrgResponseImplCopyWithImpl<$Res>
    extends _$SelectOrgResponseCopyWithImpl<$Res, _$SelectOrgResponseImpl>
    implements _$$SelectOrgResponseImplCopyWith<$Res> {
  __$$SelectOrgResponseImplCopyWithImpl(
    _$SelectOrgResponseImpl _value,
    $Res Function(_$SelectOrgResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SelectOrgResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? org = null, Object? accessToken = null}) {
    return _then(
      _$SelectOrgResponseImpl(
        org: null == org
            ? _value.org
            : org // ignore: cast_nullable_to_non_nullable
                  as Organization,
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SelectOrgResponseImpl implements _SelectOrgResponse {
  const _$SelectOrgResponseImpl({
    required this.org,
    @JsonKey(name: 'access_token') required this.accessToken,
  });

  factory _$SelectOrgResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SelectOrgResponseImplFromJson(json);

  @override
  final Organization org;
  @override
  @JsonKey(name: 'access_token')
  final String accessToken;

  @override
  String toString() {
    return 'SelectOrgResponse(org: $org, accessToken: $accessToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectOrgResponseImpl &&
            (identical(other.org, org) || other.org == org) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, org, accessToken);

  /// Create a copy of SelectOrgResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectOrgResponseImplCopyWith<_$SelectOrgResponseImpl> get copyWith =>
      __$$SelectOrgResponseImplCopyWithImpl<_$SelectOrgResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SelectOrgResponseImplToJson(this);
  }
}

abstract class _SelectOrgResponse implements SelectOrgResponse {
  const factory _SelectOrgResponse({
    required final Organization org,
    @JsonKey(name: 'access_token') required final String accessToken,
  }) = _$SelectOrgResponseImpl;

  factory _SelectOrgResponse.fromJson(Map<String, dynamic> json) =
      _$SelectOrgResponseImpl.fromJson;

  @override
  Organization get org;
  @override
  @JsonKey(name: 'access_token')
  String get accessToken;

  /// Create a copy of SelectOrgResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectOrgResponseImplCopyWith<_$SelectOrgResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MeResponse _$MeResponseFromJson(Map<String, dynamic> json) {
  return _MeResponse.fromJson(json);
}

/// @nodoc
mixin _$MeResponse {
  User get user => throw _privateConstructorUsedError;
  List<Organization> get orgs => throw _privateConstructorUsedError;
  @JsonKey(name: 'selected_org')
  Organization? get selectedOrg => throw _privateConstructorUsedError;

  /// Serializes this MeResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeResponseCopyWith<MeResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeResponseCopyWith<$Res> {
  factory $MeResponseCopyWith(
    MeResponse value,
    $Res Function(MeResponse) then,
  ) = _$MeResponseCopyWithImpl<$Res, MeResponse>;
  @useResult
  $Res call({
    User user,
    List<Organization> orgs,
    @JsonKey(name: 'selected_org') Organization? selectedOrg,
  });

  $UserCopyWith<$Res> get user;
  $OrganizationCopyWith<$Res>? get selectedOrg;
}

/// @nodoc
class _$MeResponseCopyWithImpl<$Res, $Val extends MeResponse>
    implements $MeResponseCopyWith<$Res> {
  _$MeResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? orgs = null,
    Object? selectedOrg = freezed,
  }) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User,
            orgs: null == orgs
                ? _value.orgs
                : orgs // ignore: cast_nullable_to_non_nullable
                      as List<Organization>,
            selectedOrg: freezed == selectedOrg
                ? _value.selectedOrg
                : selectedOrg // ignore: cast_nullable_to_non_nullable
                      as Organization?,
          )
          as $Val,
    );
  }

  /// Create a copy of MeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of MeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationCopyWith<$Res>? get selectedOrg {
    if (_value.selectedOrg == null) {
      return null;
    }

    return $OrganizationCopyWith<$Res>(_value.selectedOrg!, (value) {
      return _then(_value.copyWith(selectedOrg: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MeResponseImplCopyWith<$Res>
    implements $MeResponseCopyWith<$Res> {
  factory _$$MeResponseImplCopyWith(
    _$MeResponseImpl value,
    $Res Function(_$MeResponseImpl) then,
  ) = __$$MeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    User user,
    List<Organization> orgs,
    @JsonKey(name: 'selected_org') Organization? selectedOrg,
  });

  @override
  $UserCopyWith<$Res> get user;
  @override
  $OrganizationCopyWith<$Res>? get selectedOrg;
}

/// @nodoc
class __$$MeResponseImplCopyWithImpl<$Res>
    extends _$MeResponseCopyWithImpl<$Res, _$MeResponseImpl>
    implements _$$MeResponseImplCopyWith<$Res> {
  __$$MeResponseImplCopyWithImpl(
    _$MeResponseImpl _value,
    $Res Function(_$MeResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? orgs = null,
    Object? selectedOrg = freezed,
  }) {
    return _then(
      _$MeResponseImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User,
        orgs: null == orgs
            ? _value._orgs
            : orgs // ignore: cast_nullable_to_non_nullable
                  as List<Organization>,
        selectedOrg: freezed == selectedOrg
            ? _value.selectedOrg
            : selectedOrg // ignore: cast_nullable_to_non_nullable
                  as Organization?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MeResponseImpl implements _MeResponse {
  const _$MeResponseImpl({
    required this.user,
    required final List<Organization> orgs,
    @JsonKey(name: 'selected_org') this.selectedOrg,
  }) : _orgs = orgs;

  factory _$MeResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeResponseImplFromJson(json);

  @override
  final User user;
  final List<Organization> _orgs;
  @override
  List<Organization> get orgs {
    if (_orgs is EqualUnmodifiableListView) return _orgs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orgs);
  }

  @override
  @JsonKey(name: 'selected_org')
  final Organization? selectedOrg;

  @override
  String toString() {
    return 'MeResponse(user: $user, orgs: $orgs, selectedOrg: $selectedOrg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._orgs, _orgs) &&
            (identical(other.selectedOrg, selectedOrg) ||
                other.selectedOrg == selectedOrg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    const DeepCollectionEquality().hash(_orgs),
    selectedOrg,
  );

  /// Create a copy of MeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeResponseImplCopyWith<_$MeResponseImpl> get copyWith =>
      __$$MeResponseImplCopyWithImpl<_$MeResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeResponseImplToJson(this);
  }
}

abstract class _MeResponse implements MeResponse {
  const factory _MeResponse({
    required final User user,
    required final List<Organization> orgs,
    @JsonKey(name: 'selected_org') final Organization? selectedOrg,
  }) = _$MeResponseImpl;

  factory _MeResponse.fromJson(Map<String, dynamic> json) =
      _$MeResponseImpl.fromJson;

  @override
  User get user;
  @override
  List<Organization> get orgs;
  @override
  @JsonKey(name: 'selected_org')
  Organization? get selectedOrg;

  /// Create a copy of MeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeResponseImplCopyWith<_$MeResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
