import 'package:freezed_annotation/freezed_annotation.dart';

part 'wastage.freezed.dart';
part 'wastage.g.dart';

@freezed
abstract class WastageRecord with _$WastageRecord {
  const factory WastageRecord({
    required String id,
    @JsonKey(name: 'ingredient_id') required String ingredientId,
    required double quantity,
    @JsonKey(name: 'wastage_type') @Default('') String wastageType,
    @JsonKey(name: 'wastage_date') DateTime? wastageDate,
    @Default('') String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'ingredient_name') @Default('') String ingredientName,
    @JsonKey(name: 'unit_abbr') @Default('') String unitAbbr,
  }) = _WastageRecord;

  factory WastageRecord.fromJson(Map<String, dynamic> json) =>
      _$WastageRecordFromJson(json);
}
