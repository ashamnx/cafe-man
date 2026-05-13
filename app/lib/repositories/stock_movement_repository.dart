import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/stock_movement.dart';

class StockMovementRepository {
  final ApiClient _client;

  StockMovementRepository(this._client);

  Future<List<StockMovement>> list(
      {String? ingredient, String? type, int? limit}) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.stockMovements,
        queryParameters: {
          if (ingredient != null && ingredient.isNotEmpty)
            'ingredient': ingredient,
          if (type != null && type.isNotEmpty) 'type': type,
          if (limit != null) 'limit': limit,
        },
      );
      return (response.data as List)
          .map((e) => StockMovement.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
          e.response?.data?['error'] ?? 'Failed to load stock movements',
          statusCode: e.response?.statusCode);
    }
  }
}
