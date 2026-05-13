// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuItemImpl _$$MenuItemImplFromJson(
  Map<String, dynamic> json,
) => _$MenuItemImpl(
  id: json['id'] as String,
  categoryId: json['category_id'] as String?,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  imagePath: json['image_path'] as String? ?? '',
  sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0,
  status: json['status'] as String? ?? 'active',
  preparationNotes: json['preparation_notes'] as String? ?? '',
  allergens:
      (json['allergens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  category: json['category'] == null
      ? null
      : MenuCategory.fromJson(json['category'] as Map<String, dynamic>),
  ingredients:
      (json['ingredients'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  utilityCosts:
      (json['utility_costs'] as List<dynamic>?)
          ?.map((e) => RecipeUtilityCost.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
  costMargin: (json['cost_margin'] as num?)?.toDouble() ?? 0,
  netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$MenuItemImplToJson(_$MenuItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'name': instance.name,
      'description': instance.description,
      'image_path': instance.imagePath,
      'selling_price': instance.sellingPrice,
      'status': instance.status,
      'preparation_notes': instance.preparationNotes,
      'allergens': instance.allergens,
      'created_at': instance.createdAt?.toIso8601String(),
      'category': instance.category,
      'ingredients': instance.ingredients,
      'utility_costs': instance.utilityCosts,
      'total_cost': instance.totalCost,
      'cost_margin': instance.costMargin,
      'net_profit': instance.netProfit,
    };

_$MenuCategoryImpl _$$MenuCategoryImplFromJson(Map<String, dynamic> json) =>
    _$MenuCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$MenuCategoryImplToJson(_$MenuCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
    };

_$RecipeIngredientImpl _$$RecipeIngredientImplFromJson(
  Map<String, dynamic> json,
) => _$RecipeIngredientImpl(
  id: json['id'] as String,
  menuItemId: json['menu_item_id'] as String,
  ingredientId: json['ingredient_id'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  ingredientType: json['ingredient_type'] as String? ?? 'primary',
  notes: json['notes'] as String? ?? '',
  lineCost: (json['line_cost'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$RecipeIngredientImplToJson(
  _$RecipeIngredientImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'menu_item_id': instance.menuItemId,
  'ingredient_id': instance.ingredientId,
  'quantity': instance.quantity,
  'ingredient_type': instance.ingredientType,
  'notes': instance.notes,
  'line_cost': instance.lineCost,
};

_$RecipeUtilityCostImpl _$$RecipeUtilityCostImplFromJson(
  Map<String, dynamic> json,
) => _$RecipeUtilityCostImpl(
  id: json['id'] as String,
  menuItemId: json['menu_item_id'] as String,
  name: json['name'] as String,
  cost: (json['cost'] as num).toDouble(),
);

Map<String, dynamic> _$$RecipeUtilityCostImplToJson(
  _$RecipeUtilityCostImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'menu_item_id': instance.menuItemId,
  'name': instance.name,
  'cost': instance.cost,
};
