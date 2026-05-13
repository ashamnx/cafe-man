// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockMovementImpl _$$StockMovementImplFromJson(Map<String, dynamic> json) =>
    _$StockMovementImpl(
      id: json['id'] as String,
      ingredientId: json['ingredient_id'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      movementType: json['movement_type'] as String? ?? '',
      referenceType: json['reference_type'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      ingredientName: json['ingredient_name'] as String? ?? '',
      unitAbbr: json['unit_abbr'] as String? ?? '',
    );

Map<String, dynamic> _$$StockMovementImplToJson(_$StockMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ingredient_id': instance.ingredientId,
      'quantity': instance.quantity,
      'movement_type': instance.movementType,
      'reference_type': instance.referenceType,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'ingredient_name': instance.ingredientName,
      'unit_abbr': instance.unitAbbr,
    };
