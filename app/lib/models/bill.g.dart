// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorBillImpl _$$VendorBillImplFromJson(Map<String, dynamic> json) =>
    _$VendorBillImpl(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String?,
      billNumber: json['bill_number'] as String? ?? '',
      billDate: json['bill_date'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      imagePath: json['image_path'] as String?,
      entryType: json['entry_type'] as String? ?? 'scan',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => VendorBillItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VendorBillImplToJson(_$VendorBillImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendor_id': instance.vendorId,
      'bill_number': instance.billNumber,
      'bill_date': instance.billDate,
      'total_amount': instance.totalAmount,
      'image_path': instance.imagePath,
      'entry_type': instance.entryType,
      'status': instance.status,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'items': instance.items,
    };

_$VendorBillItemImpl _$$VendorBillItemImplFromJson(Map<String, dynamic> json) =>
    _$VendorBillItemImpl(
      id: json['id'] as String,
      billId: json['bill_id'] as String,
      rawItemName: json['raw_item_name'] as String? ?? '',
      rawQuantity: (json['raw_quantity'] as num?)?.toDouble(),
      rawUnit: json['raw_unit'] as String? ?? '',
      rawUnitPrice: (json['raw_unit_price'] as num?)?.toDouble(),
      rawTotalPrice: (json['raw_total_price'] as num?)?.toDouble(),
      ingredientId: json['ingredient_id'] as String?,
      mappedQuantity: (json['mapped_quantity'] as num?)?.toDouble(),
      mappedUnitPrice: (json['mapped_unit_price'] as num?)?.toDouble(),
      mappingStatus: json['mapping_status'] as String? ?? 'unmapped',
    );

Map<String, dynamic> _$$VendorBillItemImplToJson(
  _$VendorBillItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'bill_id': instance.billId,
  'raw_item_name': instance.rawItemName,
  'raw_quantity': instance.rawQuantity,
  'raw_unit': instance.rawUnit,
  'raw_unit_price': instance.rawUnitPrice,
  'raw_total_price': instance.rawTotalPrice,
  'ingredient_id': instance.ingredientId,
  'mapped_quantity': instance.mappedQuantity,
  'mapped_unit_price': instance.mappedUnitPrice,
  'mapping_status': instance.mappingStatus,
};
