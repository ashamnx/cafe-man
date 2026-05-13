import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_theme.dart';
import '../../../providers/ingredient_provider.dart';

class IngredientListScreen extends ConsumerStatefulWidget {
  const IngredientListScreen({super.key});

  @override
  ConsumerState<IngredientListScreen> createState() =>
      _IngredientListScreenState();
}

class _IngredientListScreenState extends ConsumerState<IngredientListScreen> {
  String _search = '';
  String _stockFilter = '';

  IngredientFilters get _filters => IngredientFilters(
        search: _search,
        stock: _stockFilter,
      );

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientListProvider(_filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _stockFilter = value),
            itemBuilder: (_) => [
              const PopupMenuItem(value: '', child: Text('All')),
              const PopupMenuItem(value: 'low', child: Text('Low Stock')),
              const PopupMenuItem(value: 'out', child: Text('Out of Stock')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(ingredientListProvider(_filters).future),
        child: ingredientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(error.toString(),
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(ingredientListProvider(_filters)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (response) {
            final ingredients = response.ingredients;
            final alertCounts = response.alertCounts;
            final recipeCounts = response.recipeCounts;

            if (ingredients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      _search.isNotEmpty
                          ? 'No ingredients match your search'
                          : 'No ingredients yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ingredients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ing = ingredients[index];
                final isLowStock = ing.lowStockThreshold != null &&
                    ing.currentStock <= ing.lowStockThreshold!;
                final alerts = alertCounts[ing.id] ?? 0;
                final recipes = recipeCounts[ing.id] ?? 0;

                return Card(
                  child: ListTile(
                    leading: ing.imagePath.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: ApiEndpoints.imageUrl(ing.imagePath),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[200],
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[200],
                                child: const Icon(Icons.inventory_2, size: 20),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: isLowStock
                                ? AppTheme.warning.withValues(alpha: 0.1)
                                : Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                            child: Icon(
                              isLowStock
                                  ? Icons.warning_amber
                                  : Icons.inventory_2,
                              color: isLowStock
                                  ? AppTheme.warning
                                  : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                    title: Text(
                      ing.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ing.currentStock.toStringAsFixed(1)} ${ing.unit?.abbreviation ?? ''} | ${ing.category?.name ?? 'Uncategorized'}',
                        ),
                        Row(
                          children: [
                            if (recipes > 0)
                              Text('$recipes recipe${recipes > 1 ? 's' : ''}',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                            if (alerts > 0) ...[
                              if (recipes > 0)
                                Text(' | ',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400])),
                              Icon(Icons.warning_amber,
                                  size: 12, color: AppTheme.warning),
                              const SizedBox(width: 2),
                              Text('$alerts alert${alerts > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppTheme.warning)),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/ingredients/${ing.id}');
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ingredients/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
