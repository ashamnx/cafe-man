import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/vendor.dart';

class VendorRepository {
  final ApiClient _client;

  VendorRepository(this._client);

  Future<List<Vendor>> list({String? search, String? sort}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.vendors,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
        },
      );
      return (response.data as List).map((e) => Vendor.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load vendors',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Vendor> getById(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.vendor(id));
      return Vendor.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load vendor',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Vendor> create(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.post(ApiEndpoints.vendors, data: data);
      return Vendor.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to create vendor',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Vendor> update(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _client.dio.put(ApiEndpoints.vendor(id), data: data);
      return Vendor.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to update vendor',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.dio.delete(ApiEndpoints.vendor(id));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to delete vendor',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
