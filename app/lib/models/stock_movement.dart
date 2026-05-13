import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_movement.freezed.dart';
part 'stock_movement.g.dart';

@freezed
abstract class StockMovement with _$StockMovement {
  const factory StockMovement({
    required String id,
    @JsonKey(name: 'ingredient_id') required String ingredientId,
    required double quantity,
    @JsonKey(name: 'movement_type') @Default('') String movementType,
    @JsonKey(name: 'reference_type') @Default('') String referenceType,
    @Default('') String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'ingredient_name') @Default('') String ingredientName,
    @JsonKey(name: 'unit_abbr') @Default('') String unitAbbr,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);
}
