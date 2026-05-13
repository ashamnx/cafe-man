// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientImpl _$$IngredientImplFromJson(
  Map<String, dynamic> json,
) => _$IngredientImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  imagePath: json['image_path'] as String? ?? '',
  unitId: json['unit_id'] as String,
  currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0,
  currentCostPerUnit: (json['current_cost_per_unit'] as num?)?.toDouble() ?? 0,
  lowStockThreshold: (json['low_stock_threshold'] as num?)?.toDouble(),
  priceAlertPercentage:
      (json['price_alert_percentage'] as num?)?.toDouble() ?? 10,
  categoryId: json['category_id'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  unit: json['unit'] == null
      ? null
      : IngredientUnit.fromJson(json['unit'] as Map<String, dynamic>),
  category: json['category'] == null
      ? null
      : IngredientCategory.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$IngredientImplToJson(_$IngredientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image_path': instance.imagePath,
      'unit_id': instance.unitId,
      'current_stock': instance.currentStock,
      'current_cost_per_unit': instance.currentCostPerUnit,
      'low_stock_threshold': instance.lowStockThreshold,
      'price_alert_percentage': instance.priceAlertPercentage,
      'category_id': instance.categoryId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'unit': instance.unit,
      'category': instance.category,
    };

_$IngredientCategoryImpl _$$IngredientCategoryImplFromJson(
  Map<String, dynamic> json,
) => _$IngredientCategoryImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$IngredientCategoryImplToJson(
  _$IngredientCategoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sort_order': instance.sortOrder,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
};

_$IngredientUnitImpl _$$IngredientUnitImplFromJson(Map<String, dynamic> json) =>
    _$IngredientUnitImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      unitType: json['unit_type'] as String,
    );

Map<String, dynamic> _$$IngredientUnitImplToJson(
  _$IngredientUnitImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'abbreviation': instance.abbreviation,
  'unit_type': instance.unitType,
};

_$PriceHistoryImpl _$$PriceHistoryImplFromJson(Map<String, dynamic> json) =>
    _$PriceHistoryImpl(
      id: json['id'] as String,
      ingredientId: json['ingredient_id'] as String,
      oldCostPerUnit: (json['old_cost_per_unit'] as num).toDouble(),
      newCostPerUnit: (json['new_cost_per_unit'] as num).toDouble(),
      changePercentage: (json['change_percentage'] as num).toDouble(),
      source: json['source'] as String,
      recordedAt: json['recorded_at'] == null
          ? null
          : DateTime.parse(json['recorded_at'] as String),
    );

Map<String, dynamic> _$$PriceHistoryImplToJson(_$PriceHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ingredient_id': instance.ingredientId,
      'old_cost_per_unit': instance.oldCostPerUnit,
      'new_cost_per_unit': instance.newCostPerUnit,
      'change_percentage': instance.changePercentage,
      'source': instance.source,
      'recorded_at': instance.recordedAt?.toIso8601String(),
    };
