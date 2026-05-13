import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    @JsonKey(name: 'ingredient_count') @Default(0) int ingredientCount,
    @JsonKey(name: 'recipe_count') @Default(0) int recipeCount,
    @JsonKey(name: 'vendor_count') @Default(0) int vendorCount,
    @JsonKey(name: 'low_stock_count') @Default(0) int lowStockCount,
    @JsonKey(name: 'unread_alerts') @Default(0) int unreadAlerts,
    @JsonKey(name: 'low_stock') @Default([]) List<LowStockItem> lowStock,
    @JsonKey(name: 'recent_movements') @Default([]) List<StockMovementBrief> recentMovements,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}

@freezed
abstract class LowStockItem with _$LowStockItem {
  const factory LowStockItem({
    required String id,
    required String name,
    @JsonKey(name: 'current_stock') @Default(0) double currentStock,
    @JsonKey(name: 'low_stock_threshold') double? lowStockThreshold,
    LowStockUnit? unit,
  }) = _LowStockItem;

  factory LowStockItem.fromJson(Map<String, dynamic> json) =>
      _$LowStockItemFromJson(json);
}

@freezed
abstract class LowStockUnit with _$LowStockUnit {
  const factory LowStockUnit({
    required String abbreviation,
  }) = _LowStockUnit;

  factory LowStockUnit.fromJson(Map<String, dynamic> json) =>
      _$LowStockUnitFromJson(json);
}

@freezed
abstract class StockMovementBrief with _$StockMovementBrief {
  const factory StockMovementBrief({
    required String id,
    @JsonKey(name: 'ingredient_name') @Default('') String ingredientName,
    @JsonKey(name: 'unit_abbr') @Default('') String unitAbbr,
    @Default(0) double quantity,
    @JsonKey(name: 'movement_type') @Default('') String movementType,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _StockMovementBrief;

  factory StockMovementBrief.fromJson(Map<String, dynamic> json) =>
      _$StockMovementBriefFromJson(json);
}
