import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final orgName = authState is AuthAuthenticated
        ? authState.selectedOrg?.name ?? 'Searlo Cafe'
        : 'Searlo Cafe';

    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(orgName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/alerts'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'logout', child: Text('Sign Out')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardProvider.future),
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Failed to load dashboard',
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(dashboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats grid.
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.4,
                children: [
                  StatCard(
                    title: 'Ingredients',
                    value: '${data.ingredientCount}',
                    icon: Icons.inventory_2,
                    color: AppTheme.primary,
                    onTap: () => context.go('/ingredients'),
                  ),
                  StatCard(
                    title: 'Recipes',
                    value: '${data.recipeCount}',
                    icon: Icons.restaurant_menu,
                    color: AppTheme.success,
                    onTap: () => context.go('/recipes'),
                  ),
                  StatCard(
                    title: 'Vendors',
                    value: '${data.vendorCount}',
                    icon: Icons.people,
                    color: AppTheme.secondary,
                    onTap: () => context.go('/vendors'),
                  ),
                  StatCard(
                    title: 'Alerts',
                    value: '${data.unreadAlerts}',
                    icon: Icons.notifications,
                    color: data.unreadAlerts > 0
                        ? AppTheme.danger
                        : AppTheme.secondary,
                    onTap: () => context.go('/alerts'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Low stock alerts.
              if (data.lowStock.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Low Stock',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go('/ingredients'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...data.lowStock.take(5).map(
                      (item) => Card(
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.warning_amber,
                                color: AppTheme.warning, size: 20),
                          ),
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.currentStock.toStringAsFixed(1)} ${item.unit?.abbreviation ?? ''} remaining',
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 24),
              ],

              // Recent movements.
              if (data.recentMovements.isNotEmpty) ...[
                Text(
                  'Recent Activity',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...data.recentMovements.map(
                  (movement) => Card(
                    child: ListTile(
                      leading: Icon(
                        movement.quantity >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: movement.quantity >= 0
                            ? AppTheme.success
                            : AppTheme.danger,
                      ),
                      title: Text(movement.ingredientName),
                      subtitle: Text(movement.movementType),
                      trailing: Text(
                        '${movement.quantity >= 0 ? '+' : ''}${movement.quantity.toStringAsFixed(1)} ${movement.unitAbbr}',
                        style: TextStyle(
                          color: movement.quantity >= 0
                              ? AppTheme.success
                              : AppTheme.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
