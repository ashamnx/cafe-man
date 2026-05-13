import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

@freezed
abstract class VendorBill with _$VendorBill {
  const factory VendorBill({
    required String id,
    @JsonKey(name: 'vendor_id') String? vendorId,
    @JsonKey(name: 'bill_number') @Default('') String billNumber,
    @JsonKey(name: 'bill_date') String? billDate,
    @JsonKey(name: 'total_amount') double? totalAmount,
    @JsonKey(name: 'image_path') String? imagePath,
    @JsonKey(name: 'entry_type') @Default('scan') String entryType,
    @Default('pending') String status,
    @Default('') String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default([]) List<VendorBillItem> items,
  }) = _VendorBill;

  factory VendorBill.fromJson(Map<String, dynamic> json) =>
      _$VendorBillFromJson(json);
}

@freezed
abstract class VendorBillItem with _$VendorBillItem {
  const factory VendorBillItem({
    required String id,
    @JsonKey(name: 'bill_id') required String billId,
    @JsonKey(name: 'raw_item_name') @Default('') String rawItemName,
    @JsonKey(name: 'raw_quantity') double? rawQuantity,
    @JsonKey(name: 'raw_unit') @Default('') String rawUnit,
    @JsonKey(name: 'raw_unit_price') double? rawUnitPrice,
    @JsonKey(name: 'raw_total_price') double? rawTotalPrice,
    @JsonKey(name: 'ingredient_id') String? ingredientId,
    @JsonKey(name: 'mapped_quantity') double? mappedQuantity,
    @JsonKey(name: 'mapped_unit_price') double? mappedUnitPrice,
    @JsonKey(name: 'mapping_status') @Default('unmapped') String mappingStatus,
  }) = _VendorBillItem;

  factory VendorBillItem.fromJson(Map<String, dynamic> json) =>
      _$VendorBillItemFromJson(json);
}
