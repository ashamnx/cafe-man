import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/ingredient.dart';
import '../repositories/ingredient_repository.dart';

final ingredientRepositoryProvider = Provider((ref) {
  return IngredientRepository(ref.read(apiClientProvider));
});

final ingredientListProvider = FutureProvider.autoDispose
    .family<IngredientListResponse, IngredientFilters>(
  (ref, filters) {
    return ref.read(ingredientRepositoryProvider).list(
          search: filters.search,
          categoryId: filters.categoryId,
          sort: filters.sort,
          stock: filters.stock,
        );
  },
);

final ingredientUnitsProvider =
    FutureProvider.autoDispose<List<IngredientUnit>>((ref) {
  return ref.read(ingredientRepositoryProvider).getUnits();
});

final ingredientCategoriesProvider =
    FutureProvider.autoDispose<List<IngredientCategory>>((ref) {
  return ref.read(ingredientRepositoryProvider).getCategories();
});

class IngredientFilters {
  final String? search;
  final String? categoryId;
  final String? sort;
  final String? stock;

  const IngredientFilters({this.search, this.categoryId, this.sort, this.stock});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientFilters &&
          search == other.search &&
          categoryId == other.categoryId &&
          sort == other.sort &&
          stock == other.stock;

  @override
  int get hashCode => Object.hash(search, categoryId, sort, stock);
}
