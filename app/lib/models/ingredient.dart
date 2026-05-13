import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String id,
    required String name,
    @Default('') String description,
    @JsonKey(name: 'image_path') @Default('') String imagePath,
    @JsonKey(name: 'unit_id') required String unitId,
    @JsonKey(name: 'current_stock') @Default(0) double currentStock,
    @JsonKey(name: 'current_cost_per_unit') @Default(0) double currentCostPerUnit,
    @JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,
    @JsonKey(name: 'price_alert_percentage') @Default(10) double priceAlertPercentage,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    IngredientUnit? unit,
    IngredientCategory? category,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}

@freezed
abstract class IngredientCategory with _$IngredientCategory {
  const factory IngredientCategory({
    required String id,
    required String name,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _IngredientCategory;

  factory IngredientCategory.fromJson(Map<String, dynamic> json) =>
      _$IngredientCategoryFromJson(json);
}

@freezed
abstract class IngredientUnit with _$IngredientUnit {
  const factory IngredientUnit({
    required String id,
    required String name,
    required String abbreviation,
    @JsonKey(name: 'unit_type') required String unitType,
  }) = _IngredientUnit;

  factory IngredientUnit.fromJson(Map<String, dynamic> json) =>
      _$IngredientUnitFromJson(json);
}

@freezed
abstract class PriceHistory with _$PriceHistory {
  const factory PriceHistory({
    required String id,
    @JsonKey(name: 'ingredient_id') required String ingredientId,
    @JsonKey(name: 'old_cost_per_unit') required double oldCostPerUnit,
    @JsonKey(name: 'new_cost_per_unit') required double newCostPerUnit,
    @JsonKey(name: 'change_percentage') required double changePercentage,
    required String source,
    @JsonKey(name: 'recorded_at') DateTime? recordedAt,
  }) = _PriceHistory;

  factory PriceHistory.fromJson(Map<String, dynamic> json) =>
      _$PriceHistoryFromJson(json);
}
