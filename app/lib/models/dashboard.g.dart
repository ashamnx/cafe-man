// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardDataImpl _$$DashboardDataImplFromJson(Map<String, dynamic> json) =>
    _$DashboardDataImpl(
      ingredientCount: (json['ingredient_count'] as num?)?.toInt() ?? 0,
      recipeCount: (json['recipe_count'] as num?)?.toInt() ?? 0,
      vendorCount: (json['vendor_count'] as num?)?.toInt() ?? 0,
      lowStockCount: (json['low_stock_count'] as num?)?.toInt() ?? 0,
      unreadAlerts: (json['unread_alerts'] as num?)?.toInt() ?? 0,
      lowStock:
          (json['low_stock'] as List<dynamic>?)
              ?.map((e) => LowStockItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentMovements:
          (json['recent_movements'] as List<dynamic>?)
              ?.map(
                (e) => StockMovementBrief.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DashboardDataImplToJson(_$DashboardDataImpl instance) =>
    <String, dynamic>{
      'ingredient_count': instance.ingredientCount,
      'recipe_count': instance.recipeCount,
      'vendor_count': instance.vendorCount,
      'low_stock_count': instance.lowStockCount,
      'unread_alerts': instance.unreadAlerts,
      'low_stock': instance.lowStock,
      'recent_movements': instance.recentMovements,
    };

_$LowStockItemImpl _$$LowStockItemImplFromJson(Map<String, dynamic> json) =>
    _$LowStockItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0,
      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toDouble(),
      unit: json['unit'] == null
          ? null
          : LowStockUnit.fromJson(json['unit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LowStockItemImplToJson(_$LowStockItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'current_stock': instance.currentStock,
      'low_stock_threshold': instance.lowStockThreshold,
      'unit': instance.unit,
    };

_$LowStockUnitImpl _$$LowStockUnitImplFromJson(Map<String, dynamic> json) =>
    _$LowStockUnitImpl(abbreviation: json['abbreviation'] as String);

Map<String, dynamic> _$$LowStockUnitImplToJson(_$LowStockUnitImpl instance) =>
    <String, dynamic>{'abbreviation': instance.abbreviation};

_$StockMovementBriefImpl _$$StockMovementBriefImplFromJson(
  Map<String, dynamic> json,
) => _$StockMovementBriefImpl(
  id: json['id'] as String,
  ingredientName: json['ingredient_name'] as String? ?? '',
  unitAbbr: json['unit_abbr'] as String? ?? '',
  quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
  movementType: json['movement_type'] as String? ?? '',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$StockMovementBriefImplToJson(
  _$StockMovementBriefImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'ingredient_name': instance.ingredientName,
  'unit_abbr': instance.unitAbbr,
  'quantity': instance.quantity,
  'movement_type': instance.movementType,
  'created_at': instance.createdAt?.toIso8601String(),
};
