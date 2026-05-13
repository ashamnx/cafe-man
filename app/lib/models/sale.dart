import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale.freezed.dart';
part 'sale.g.dart';

@freezed
abstract class SaleEntry with _$SaleEntry {
  const factory SaleEntry({
    required String id,
    @JsonKey(name: 'sale_date') DateTime? saleDate,
    @Default('') String notes,
    @Default('draft') String status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default([]) List<SaleEntryItem> items,
    @JsonKey(name: 'total_items') @Default(0) int totalItems,
    @JsonKey(name: 'total_value') @Default(0) double totalValue,
  }) = _SaleEntry;

  factory SaleEntry.fromJson(Map<String, dynamic> json) =>
      _$SaleEntryFromJson(json);
}

@freezed
abstract class SaleEntryItem with _$SaleEntryItem {
  const factory SaleEntryItem({
    required String id,
    @JsonKey(name: 'sale_entry_id') required String saleEntryId,
    @JsonKey(name: 'menu_item_id') required String menuItemId,
    required int quantity,
    @JsonKey(name: 'selling_price') @Default(0) double sellingPrice,
    @JsonKey(name: 'menu_item_name') @Default('') String menuItemName,
  }) = _SaleEntryItem;

  factory SaleEntryItem.fromJson(Map<String, dynamic> json) =>
      _$SaleEntryItemFromJson(json);
}
