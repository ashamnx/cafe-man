import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/wastage.dart';

class WastageRepository {
  final ApiClient _client;

  WastageRepository(this._client);

  Future<List<WastageRecord>> list(
      {String? ingredient, String? type}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.wastage,
        queryParameters: {
          if (ingredient != null && ingredient.isNotEmpty)
            'ingredient': ingredient,
          if (type != null && type.isNotEmpty) 'type': type,
        },
      );
      return (response.data as List)
          .map((e) => WastageRecord.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['error'] ?? 'Failed to load wastage',
          statusCode: e.response?.statusCode);
    }
  }

  Future<WastageRecord> create(Map<String, dynamic> data) async {
    try {
      final response =
          await _client.dio.post(ApiEndpoints.wastage, data: data);
      return WastageRecord.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['error'] ?? 'Failed to record wastage',
          statusCode: e.response?.statusCode);
    }
  }
}
