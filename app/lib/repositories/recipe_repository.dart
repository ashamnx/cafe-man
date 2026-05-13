import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/menu_item.dart';

class RecipeRepository {
  final ApiClient _client;

  RecipeRepository(this._client);

  Future<List<MenuItem>> list({
    String? search,
    String? category,
    String? status,
    String? sort,
  }) async {
    try {
      final response = await _client.dio.get(
        ApiEndpoints.recipes,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (category != null && category.isNotEmpty) 'category': category,
          if (status != null && status.isNotEmpty) 'status': status,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
        },
      );
      return (response.data as List).map((e) => MenuItem.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load recipes',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<RecipeDetailResponse> getById(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.recipe(id));
      final data = response.data as Map<String, dynamic>;
      final recipe = MenuItem.fromJson(data['recipe']);
      final alertCounts = _parseUuidIntMap(data['alert_counts']);
      return RecipeDetailResponse(recipe: recipe, alertCounts: alertCounts);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load recipe',
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

  Future<MenuItem> create(FormData formData) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.recipes,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return MenuItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to create recipe',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<MenuItem> update(String id, FormData formData) async {
    try {
      final response = await _client.dio.put(
        ApiEndpoints.recipe(id),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return MenuItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to update recipe',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> addIngredient(
      String recipeId, Map<String, dynamic> data) async {
    try {
      await _client.dio
          .post(ApiEndpoints.recipeIngredients(recipeId), data: data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to add ingredient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> removeIngredient(String recipeId, String riId) async {
    try {
      await _client.dio
          .delete(ApiEndpoints.recipeIngredient(recipeId, riId));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to remove ingredient',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> setUtilityCost(
      String recipeId, Map<String, dynamic> data) async {
    try {
      await _client.dio
          .post(ApiEndpoints.recipeUtilityCosts(recipeId), data: data);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to set utility cost',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.dio.delete(ApiEndpoints.recipe(id));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to delete recipe',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<MenuCategory>> listCategories() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.recipeCategories);
      return (response.data as List)
          .map((e) => MenuCategory.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load categories',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class RecipeDetailResponse {
  final MenuItem recipe;
  final Map<String, int> alertCounts;

  RecipeDetailResponse({required this.recipe, required this.alertCounts});
}
