import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/dashboard.dart';

class DashboardRepository {
  final ApiClient _client;

  DashboardRepository(this._client);

  Future<DashboardData> getDashboard() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.dashboard);
      return DashboardData.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load dashboard',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
