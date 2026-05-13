// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertItemImpl _$$AlertItemImplFromJson(Map<String, dynamic> json) =>
    _$AlertItemImpl(
      id: json['id'] as String,
      alertType: json['alert_type'] as String? ?? '',
      ingredientName: json['ingredient_name'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      affectedRecipes: (json['affected_recipes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AlertItemImplToJson(_$AlertItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alert_type': instance.alertType,
      'ingredient_name': instance.ingredientName,
      'message': instance.message,
      'is_read': instance.isRead,
      'created_at': instance.createdAt?.toIso8601String(),
      'affected_recipes': instance.affectedRecipes,
    };
