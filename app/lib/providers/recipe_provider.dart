import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../models/menu_item.dart';
import '../repositories/recipe_repository.dart';

final recipeRepositoryProvider = Provider((ref) {
  return RecipeRepository(ref.read(apiClientProvider));
});

final recipeListProvider =
    FutureProvider.autoDispose.family<List<MenuItem>, String>((ref, search) {
  return ref.read(recipeRepositoryProvider).list(search: search);
});

final recipeDetailProvider =
    FutureProvider.autoDispose.family<RecipeDetailResponse, String>((ref, id) {
  return ref.read(recipeRepositoryProvider).getById(id);
});

final recipeCategoriesProvider =
    FutureProvider.autoDispose<List<MenuCategory>>((ref) {
  return ref.read(recipeRepositoryProvider).listCategories();
});
