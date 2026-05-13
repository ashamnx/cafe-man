import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/audit_log_entry.dart';

class AuditRepository {
  final ApiClient _client;

  AuditRepository(this._client);

  Future<AuditLogResponse> list({
    String? entityType,
    String? action,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.auditLog,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (entityType != null && entityType.isNotEmpty)
            'entity_type': entityType,
          if (action != null && action.isNotEmpty) 'action': action,
        },
      );
      return AuditLogResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load audit log',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
