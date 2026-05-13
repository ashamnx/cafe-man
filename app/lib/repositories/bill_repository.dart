import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/bill.dart';

class BillRepository {
  final ApiClient _client;

  BillRepository(this._client);

  Future<List<VendorBill>> list() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.bills);
      return (response.data as List)
          .map((e) => VendorBill.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load bills',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<VendorBill> getById(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.bill(id));
      return VendorBill.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load bill',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<VendorBill> upload(FormData formData) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.billUpload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return VendorBill.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to upload bill',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<VendorBill> createManual(Map<String, dynamic> data) async {
    try {
      final response =
          await _client.dio.post(ApiEndpoints.billManual, data: data);
      return VendorBill.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to create bill',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> mapItem(
      String billId, String itemId, Map<String, dynamic> data) async {
    try {
      await _client.dio
          .post(ApiEndpoints.billMapItem(billId, itemId), data: data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to map item',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<VendorBill> apply(String id) async {
    try {
      final response =
          await _client.dio.post(ApiEndpoints.billApply(id));
      return VendorBill.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to apply bill',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
