import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_theme.dart';
import '../../../providers/sale_provider.dart';

class SaleListScreen extends ConsumerWidget {
  const SaleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(saleListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sales')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(saleListProvider.future),
        child: salesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (entries) {
            if (entries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.point_of_sale_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No sales recorded',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final e = entries[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      e.status == 'applied'
                          ? Icons.check_circle
                          : Icons.edit_note,
                      color: e.status == 'applied'
                          ? AppTheme.success
                          : AppTheme.warning,
                    ),
                    title: Text(
                      e.saleDate != null
                          ? DateFormat.yMMMd().format(e.saleDate!)
                          : 'Sale ${e.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${e.totalItems} items | ${e.totalValue.toStringAsFixed(2)} | ${e.status}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/sales/${e.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/sales/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
