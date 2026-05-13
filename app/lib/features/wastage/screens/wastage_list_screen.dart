import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/wastage_provider.dart';

class WastageListScreen extends ConsumerWidget {
  const WastageListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wastageAsync = ref.watch(wastageListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wastage')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(wastageListProvider.future),
        child: wastageAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (records) {
            if (records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No wastage recorded',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final r = records[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline,
                        color: Colors.orange),
                    title: Text(r.ingredientName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${r.quantity.toStringAsFixed(1)} ${r.unitAbbr} | ${r.wastageType.replaceAll('_', ' ')}',
                    ),
                    trailing: r.notes.isNotEmpty
                        ? const Icon(Icons.notes, size: 16)
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/wastage/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
