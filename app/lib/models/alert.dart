import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

@freezed
abstract class AlertItem with _$AlertItem {
  const factory AlertItem({
    required String id,
    @JsonKey(name: 'alert_type') @Default('') String alertType,
    @JsonKey(name: 'ingredient_name') @Default('') String ingredientName,
    @Default('') String message,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'affected_recipes') @Default(0) int affectedRecipes,
  }) = _AlertItem;

  factory AlertItem.fromJson(Map<String, dynamic> json) =>
      _$AlertItemFromJson(json);
}
