import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../providers/stock_movement_provider.dart';

class StockMovementsScreen extends ConsumerWidget {
  const StockMovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(stockMovementListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Movements')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(stockMovementListProvider.future),
        child: movementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (movements) {
            if (movements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_vert, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No stock movements yet',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: movements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final m = movements[index];
                final isPositive = m.quantity >= 0;
                return Card(
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? AppTheme.success : AppTheme.danger,
                      size: 20,
                    ),
                    title: Text(m.ingredientName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(m.movementType.replaceAll('_', ' ')),
                    trailing: Text(
                      '${isPositive ? '+' : ''}${m.quantity.toStringAsFixed(1)} ${m.unitAbbr}',
                      style: TextStyle(
                        color: isPositive ? AppTheme.success : AppTheme.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
