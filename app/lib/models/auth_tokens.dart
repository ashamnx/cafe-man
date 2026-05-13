import 'package:freezed_annotation/freezed_annotation.dart';

import 'organization.dart';
import 'user.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required User user,
    required List<Organization> orgs,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
abstract class RegisterResponse with _$RegisterResponse {
  const factory RegisterResponse({
    required User user,
    required Organization org,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RegisterResponse;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
}

@freezed
abstract class SelectOrgResponse with _$SelectOrgResponse {
  const factory SelectOrgResponse({
    required Organization org,
    @JsonKey(name: 'access_token') required String accessToken,
  }) = _SelectOrgResponse;

  factory SelectOrgResponse.fromJson(Map<String, dynamic> json) =>
      _$SelectOrgResponseFromJson(json);
}

@freezed
abstract class MeResponse with _$MeResponse {
  const factory MeResponse({
    required User user,
    required List<Organization> orgs,
    @JsonKey(name: 'selected_org') Organization? selectedOrg,
  }) = _MeResponse;

  factory MeResponse.fromJson(Map<String, dynamic> json) =>
      _$MeResponseFromJson(json);
}
