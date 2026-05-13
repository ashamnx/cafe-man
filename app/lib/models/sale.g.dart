// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaleEntryImpl _$$SaleEntryImplFromJson(Map<String, dynamic> json) =>
    _$SaleEntryImpl(
      id: json['id'] as String,
      saleDate: json['sale_date'] == null
          ? null
          : DateTime.parse(json['sale_date'] as String),
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => SaleEntryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$SaleEntryImplToJson(_$SaleEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sale_date': instance.saleDate?.toIso8601String(),
      'notes': instance.notes,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'items': instance.items,
      'total_items': instance.totalItems,
      'total_value': instance.totalValue,
    };

_$SaleEntryItemImpl _$$SaleEntryItemImplFromJson(Map<String, dynamic> json) =>
    _$SaleEntryItemImpl(
      id: json['id'] as String,
      saleEntryId: json['sale_entry_id'] as String,
      menuItemId: json['menu_item_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0,
      menuItemName: json['menu_item_name'] as String? ?? '',
    );

Map<String, dynamic> _$$SaleEntryItemImplToJson(_$SaleEntryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sale_entry_id': instance.saleEntryId,
      'menu_item_id': instance.menuItemId,
      'quantity': instance.quantity,
      'selling_price': instance.sellingPrice,
      'menu_item_name': instance.menuItemName,
    };
