import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/sale.dart';

class SaleRepository {
  final ApiClient _client;

  SaleRepository(this._client);

  Future<List<SaleEntry>> list() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.sales);
      return (response.data as List)
          .map((e) => SaleEntry.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(e.response?.data?['error'] ?? 'Failed to load sales',
          statusCode: e.response?.statusCode);
    }
  }

  Future<SaleEntry> create(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.post(ApiEndpoints.sales, data: data);
      return SaleEntry.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['error'] ?? 'Failed to create sale',
          statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> getById(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.sale(id));
      return response.data;
    } on DioException catch (e) {
      throw ApiException(e.response?.data?['error'] ?? 'Failed to load sale',
          statusCode: e.response?.statusCode);
    }
  }

  Future<void> addItem(String saleId, Map<String, dynamic> data) async {
    try {
      await _client.dio.post(ApiEndpoints.saleItems(saleId), data: data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data?['error'] ?? 'Failed to add item',
          statusCode: e.response?.statusCode);
    }
  }

  Future<void> removeItem(String saleId, String itemId) async {
    try {
      await _client.dio.delete(ApiEndpoints.saleItem(saleId, itemId));
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['error'] ?? 'Failed to remove item',
          statusCode: e.response?.statusCode);
    }
  }

  Future<SaleEntry> apply(String id) async {
    try {
      final response = await _client.dio.post(ApiEndpoints.saleApply(id));
      return SaleEntry.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data?['error'] ?? 'Failed to apply sale',
          statusCode: e.response?.statusCode);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.dio.delete(ApiEndpoints.sale(id));
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['error'] ?? 'Failed to delete sale',
          statusCode: e.response?.statusCode);
    }
  }
}
