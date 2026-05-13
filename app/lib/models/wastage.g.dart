// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wastage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WastageRecordImpl _$$WastageRecordImplFromJson(Map<String, dynamic> json) =>
    _$WastageRecordImpl(
      id: json['id'] as String,
      ingredientId: json['ingredient_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      wastageType: json['wastage_type'] as String? ?? '',
      wastageDate: json['wastage_date'] == null
          ? null
          : DateTime.parse(json['wastage_date'] as String),
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      ingredientName: json['ingredient_name'] as String? ?? '',
      unitAbbr: json['unit_abbr'] as String? ?? '',
    );

Map<String, dynamic> _$$WastageRecordImplToJson(_$WastageRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ingredient_id': instance.ingredientId,
      'quantity': instance.quantity,
      'wastage_type': instance.wastageType,
      'wastage_date': instance.wastageDate?.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'ingredient_name': instance.ingredientName,
      'unit_abbr': instance.unitAbbr,
    };
