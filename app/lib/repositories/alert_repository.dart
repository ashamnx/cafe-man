import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/alert.dart';

class AlertRepository {
  final ApiClient _client;

  AlertRepository(this._client);

  Future<List<AlertItem>> list() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.alerts);
      return (response.data as List)
          .map((e) => AlertItem.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['error'] ?? 'Failed to load alerts',
          statusCode: e.response?.statusCode);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _client.dio.post(ApiEndpoints.alertRead(id));
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['error'] ?? 'Failed to mark alert as read',
          statusCode: e.response?.statusCode);
    }
  }
}
