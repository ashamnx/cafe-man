import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_theme.dart';
import '../../../providers/ingredient_provider.dart';
import '../../../providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String id;

  const RecipeDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(recipeDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/recipes/$id/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Recipe'),
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
                await ref.read(recipeRepositoryProvider).delete(id);
                ref.invalidate(recipeListProvider);
                if (context.mounted) context.go('/recipes');
              }
            },
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (response) {
          final recipe = response.recipe;
          final alertCounts = response.alertCounts;

          // Resolve ingredient names.
          final ingListAsync =
              ref.watch(ingredientListProvider(const IngredientFilters()));
          final ingMap = <String, String>{};
          final ingUnitMap = <String, String>{};
          ingListAsync.whenData((resp) {
            for (final i in resp.ingredients) {
              ingMap[i.id] = i.name;
              ingUnitMap[i.id] = i.unit?.abbreviation ?? '';
            }
          });

          return RefreshIndicator(
            onRefresh: () => ref.refresh(recipeDetailProvider(id).future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (recipe.imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: ApiEndpoints.imageUrl(recipe.imagePath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                              child: CircularProgressIndicator())),
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                if (recipe.imagePath.isNotEmpty) const SizedBox(height: 16),

                // Info card.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(recipe.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold)),
                            ),
                            _statusChip(recipe.status),
                          ],
                        ),
                        if (recipe.category != null) ...[
                          const SizedBox(height: 4),
                          Text(recipe.category!.name,
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                        if (recipe.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(recipe.description),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cost analysis.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cost Analysis',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _costRow('Ingredient Cost',
                            recipe.totalCost.toStringAsFixed(2)),
                        _costRow('Selling Price',
                            recipe.sellingPrice.toStringAsFixed(2)),
                        const Divider(),
                        _costRow('Net Profit',
                            recipe.netProfit.toStringAsFixed(2),
                            color: recipe.netProfit >= 0
                                ? AppTheme.success
                                : AppTheme.danger),
                        _costRow(
                            'Margin',
                            '${recipe.costMargin.toStringAsFixed(1)}%',
                            color: recipe.costMargin >= 50
                                ? AppTheme.success
                                : recipe.costMargin >= 30
                                    ? AppTheme.warning
                                    : AppTheme.danger),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ingredients with alerts.
                if (recipe.ingredients.isNotEmpty) ...[
                  Text('Ingredients (${recipe.ingredients.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((ri) {
                    final name = ingMap[ri.ingredientId] ?? 'Ingredient';
                    final unit = ingUnitMap[ri.ingredientId] ?? '';
                    final alerts = alertCounts[ri.ingredientId] ?? 0;

                    return Card(
                      color: alerts > 0
                          ? AppTheme.warning.withValues(alpha: 0.05)
                          : null,
                      child: ListTile(
                        dense: true,
                        leading: alerts > 0
                            ? const Icon(Icons.warning_amber,
                                color: AppTheme.warning, size: 20)
                            : null,
                        title: Text(name),
                        subtitle: Text(
                            '${ri.quantity} $unit | ${ri.ingredientType}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (alerts > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$alerts alert${alerts > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.warning,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            Text(ri.lineCost.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 16),

                // Utility costs.
                if (recipe.utilityCosts.isNotEmpty) ...[
                  Text('Utility Costs',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...recipe.utilityCosts.map((uc) => Card(
                        child: ListTile(
                          dense: true,
                          title: Text(uc.name),
                          trailing: Text(uc.cost.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'active'
            ? AppTheme.success.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status,
          style: TextStyle(
              fontSize: 12,
              color: status == 'active' ? AppTheme.success : Colors.grey,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _costRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
