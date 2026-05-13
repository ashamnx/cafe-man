import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_theme.dart';
import '../../../models/menu_item.dart';
import '../../../providers/recipe_provider.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipeListProvider(_search));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(recipeListProvider(_search).future),
        child: recipesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('$e', style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(recipeListProvider(_search)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (recipes) {
            if (recipes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_menu_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      _search.isNotEmpty
                          ? 'No recipes match your search'
                          : 'No recipes yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            // Group by category.
            final grouped = <String, List<MenuItem>>{};
            final order = <String>[];
            for (final r in recipes) {
              final cat = r.category?.name ?? 'Uncategorized';
              if (!grouped.containsKey(cat)) {
                grouped[cat] = [];
                order.add(cat);
              }
              grouped[cat]!.add(r);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final cat in order) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      children: [
                        Text(cat,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${grouped[cat]!.length}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...grouped[cat]!.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: r.imagePath.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          ApiEndpoints.imageUrl(r.imagePath),
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                          width: 48,
                                          height: 48,
                                          color: Colors.grey[200]),
                                      errorWidget: (_, __, ___) => Container(
                                          width: 48,
                                          height: 48,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                              Icons.restaurant_menu,
                                              size: 20)),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Icon(Icons.restaurant_menu,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        size: 20),
                                  ),
                            title: Text(r.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Row(
                              children: [
                                Text(
                                  'Cost: ${r.totalCost.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (r.sellingPrice > 0) ...[
                                  const Text(' | '),
                                  Text(
                                    '${r.costMargin.toStringAsFixed(0)}% margin',
                                    style: TextStyle(
                                      color: r.costMargin >= 50
                                          ? AppTheme.success
                                          : r.costMargin >= 30
                                              ? AppTheme.warning
                                              : AppTheme.danger,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: r.sellingPrice > 0
                                ? Text(
                                    r.sellingPrice.toStringAsFixed(2),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  )
                                : null,
                            onTap: () => context.push('/recipes/${r.id}'),
                          ),
                        ),
                      )),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recipes/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
