import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../models/ingredient.dart';
import '../../../models/menu_item.dart';
import '../../../providers/ingredient_provider.dart';
import '../../../repositories/ingredient_repository.dart';

final ingredientDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) {
    final repo = IngredientRepository(ref.read(apiClientProvider));
    return repo.getById(id);
  },
);

final ingredientRecipesProvider =
    FutureProvider.autoDispose.family<List<MenuItem>, String>(
  (ref, id) async {
    final repo = IngredientRepository(ref.read(apiClientProvider));
    final recipes = await repo.getRecipesForIngredient(id);
    return recipes;
  },
);

class IngredientDetailScreen extends ConsumerWidget {
  final String id;

  const IngredientDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(ingredientDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/ingredients/$id/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Ingredient'),
                  content: const Text('Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref.read(ingredientRepositoryProvider).delete(id);
                ref.invalidate(ingredientListProvider);
                if (context.mounted) context.go('/ingredients');
              }
            },
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (data) {
          final ing = Ingredient.fromJson(data['ingredient']);
          final history = (data['price_history'] as List?)
                  ?.map((e) => PriceHistory.fromJson(e))
                  .toList() ??
              [];

          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(ingredientDetailProvider(id).future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Image.
                if (ing.imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: ApiEndpoints.imageUrl(ing.imagePath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                if (ing.imagePath.isNotEmpty) const SizedBox(height: 16),

                // Info card.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ing.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (ing.category != null) ...[
                          const SizedBox(height: 4),
                          Chip(label: Text(ing.category!.name)),
                        ],
                        if (ing.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(ing.description,
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        _infoRow('Stock',
                            '${ing.currentStock.toStringAsFixed(2)} ${ing.unit?.abbreviation ?? ''}'),
                        _infoRow('Cost per Unit',
                            ing.currentCostPerUnit.toStringAsFixed(2)),
                        if (ing.lowStockThreshold != null)
                          _infoRow('Low Stock Threshold',
                              '${ing.lowStockThreshold!.toStringAsFixed(1)} ${ing.unit?.abbreviation ?? ''}'),
                        _infoRow('Price Alert',
                            '${ing.priceAlertPercentage.toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Price history.
                if (history.isNotEmpty) ...[
                  Text(
                    'Price History',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...history.map(
                    (h) => Card(
                      child: ListTile(
                        leading: Icon(
                          h.changePercentage >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: h.changePercentage >= 0
                              ? AppTheme.danger
                              : AppTheme.success,
                        ),
                        title: Text(
                          '${h.oldCostPerUnit.toStringAsFixed(2)} -> ${h.newCostPerUnit.toStringAsFixed(2)}',
                        ),
                        subtitle: Text(h.source),
                        trailing: Text(
                          '${h.changePercentage >= 0 ? '+' : ''}${h.changePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: h.changePercentage >= 0
                                ? AppTheme.danger
                                : AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Recipes using this ingredient.
                _buildRecipesSection(context, ref),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipesSection(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(ingredientRecipesProvider(id));

    return recipesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (recipes) {
        if (recipes.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Used in Recipes (${recipes.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipes.map(
              (r) => Card(
                child: ListTile(
                  leading: Icon(Icons.restaurant_menu,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(r.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: r.category != null
                      ? Text(r.category!.name)
                      : null,
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.push('/recipes/${r.id}'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
