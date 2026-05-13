import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/ingredient.dart';
import '../models/menu_item.dart';

class IngredientRepository {
  final ApiClient _client;

  IngredientRepository(this._client);

  Future<IngredientListResponse> list({
    String? search,
    String? categoryId,
    String? sort,
    String? stock,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.ingredients,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryId != null && categoryId.isNotEmpty) 'category_id': categoryId,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
          if (stock != null && stock.isNotEmpty) 'stock': stock,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final ingredients = (data['ingredients'] as List? ?? [])
          .map((e) => Ingredient.fromJson(e))
          .toList();
      final alertCounts = _parseUuidIntMap(data['alert_counts']);
      final recipeCounts = _parseUuidIntMap(data['recipe_counts']);
      return IngredientListResponse(
        ingredients: ingredients,
        alertCounts: alertCounts,
        recipeCounts: recipeCounts,
      );
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load ingredients',
        statusCode: e.response?.statusCode,
      );
    }
  }

  static Map<String, int> _parseUuidIntMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    }
    return {};
  }

  Future<Map<String, dynamic>> getById(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.ingredient(id));
      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load ingredient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Ingredient> create(FormData formData) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.ingredients,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return Ingredient.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to create ingredient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Ingredient> update(String id, FormData formData) async {
    try {
      final response = await _client.dio.put(
        ApiEndpoints.ingredient(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return Ingredient.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to update ingredient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.dio.delete(ApiEndpoints.ingredient(id));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to delete ingredient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<MenuItem>> getRecipesForIngredient(String id) async {
    try {
      final response =
          await _client.dio.get(ApiEndpoints.ingredientRecipes(id));
      return (response.data as List)
          .map((e) => MenuItem.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load recipes',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<PriceHistory>> getHistory(String id) async {
    try {
      final response =
          await _client.dio.get(ApiEndpoints.ingredientHistory(id));
      return (response.data as List)
          .map((e) => PriceHistory.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load price history',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<IngredientCategory>> getCategories() async {
    try {
      final response =
          await _client.dio.get(ApiEndpoints.ingredientCategories);
      return (response.data as List)
          .map((e) => IngredientCategory.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load categories',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<IngredientCategory> createCategory(String name, {int sortOrder = 0}) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.ingredientCategories,
        data: {'name': name, 'sort_order': sortOrder},
      );
      return IngredientCategory.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to create category',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<IngredientUnit>> getUnits() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.units);
      return (response.data as List)
          .map((e) => IngredientUnit.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load units',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class IngredientListResponse {
  final List<Ingredient> ingredients;
  final Map<String, int> alertCounts;
  final Map<String, int> recipeCounts;

  IngredientListResponse({
    required this.ingredients,
    required this.alertCounts,
    required this.recipeCounts,
  });
}
