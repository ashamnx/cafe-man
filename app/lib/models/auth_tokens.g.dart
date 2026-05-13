// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginResponseImpl _$$LoginResponseImplFromJson(Map<String, dynamic> json) =>
    _$LoginResponseImpl(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      orgs: (json['orgs'] as List<dynamic>)
          .map((e) => Organization.fromJson(e as Map<String, dynamic>))
          .toList(),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$$LoginResponseImplToJson(_$LoginResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'orgs': instance.orgs,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };

_$RegisterResponseImpl _$$RegisterResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterResponseImpl(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  org: Organization.fromJson(json['org'] as Map<String, dynamic>),
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
);

Map<String, dynamic> _$$RegisterResponseImplToJson(
  _$RegisterResponseImpl instance,
) => <String, dynamic>{
  'user': instance.user,
  'org': instance.org,
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
};

_$SelectOrgResponseImpl _$$SelectOrgResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SelectOrgResponseImpl(
  org: Organization.fromJson(json['org'] as Map<String, dynamic>),
  accessToken: json['access_token'] as String,
);

Map<String, dynamic> _$$SelectOrgResponseImplToJson(
  _$SelectOrgResponseImpl instance,
) => <String, dynamic>{
  'org': instance.org,
  'access_token': instance.accessToken,
};

_$MeResponseImpl _$$MeResponseImplFromJson(Map<String, dynamic> json) =>
    _$MeResponseImpl(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      orgs: (json['orgs'] as List<dynamic>)
          .map((e) => Organization.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedOrg: json['selected_org'] == null
          ? null
          : Organization.fromJson(json['selected_org'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MeResponseImplToJson(_$MeResponseImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'orgs': instance.orgs,
      'selected_org': instance.selectedOrg,
    };
