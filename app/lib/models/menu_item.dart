import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item.freezed.dart';
part 'menu_item.g.dart';

@freezed
abstract class MenuItem with _$MenuItem {
  const factory MenuItem({
    required String id,
    @JsonKey(name: 'category_id') String? categoryId,
    required String name,
    @Default('') String description,
    @JsonKey(name: 'image_path') @Default('') String imagePath,
    @JsonKey(name: 'selling_price') @Default(0) double sellingPrice,
    @Default('active') String status,
    @JsonKey(name: 'preparation_notes') @Default('') String preparationNotes,
    @Default([]) List<String> allergens,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    MenuCategory? category,
    @Default([]) List<RecipeIngredient> ingredients,
    @JsonKey(name: 'utility_costs') @Default([]) List<RecipeUtilityCost> utilityCosts,
    @JsonKey(name: 'total_cost') @Default(0) double totalCost,
    @JsonKey(name: 'cost_margin') @Default(0) double costMargin,
    @JsonKey(name: 'net_profit') @Default(0) double netProfit,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
}

@freezed
abstract class MenuCategory with _$MenuCategory {
  const factory MenuCategory({
    required String id,
    required String name,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _MenuCategory;

  factory MenuCategory.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryFromJson(json);
}

@freezed
abstract class RecipeIngredient with _$RecipeIngredient {
  const factory RecipeIngredient({
    required String id,
    @JsonKey(name: 'menu_item_id') required String menuItemId,
    @JsonKey(name: 'ingredient_id') required String ingredientId,
    required double quantity,
    @JsonKey(name: 'ingredient_type') @Default('primary') String ingredientType,
    @Default('') String notes,
    @JsonKey(name: 'line_cost') @Default(0) double lineCost,
  }) = _RecipeIngredient;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientFromJson(json);
}

@freezed
abstract class RecipeUtilityCost with _$RecipeUtilityCost {
  const factory RecipeUtilityCost({
    required String id,
    @JsonKey(name: 'menu_item_id') required String menuItemId,
    required String name,
    required double cost,
  }) = _RecipeUtilityCost;

  factory RecipeUtilityCost.fromJson(Map<String, dynamic> json) =>
      _$RecipeUtilityCostFromJson(json);
}
