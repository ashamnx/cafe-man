import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../../providers/bill_provider.dart';

class BillDetailScreen extends ConsumerWidget {
  final String id;

  const BillDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(billDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Detail')),
      body: billAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bill) => RefreshIndicator(
          onRefresh: () => ref.refresh(billDetailProvider(id).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bill info card.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            bill.billNumber.isNotEmpty
                                ? bill.billNumber
                                : 'Bill ${bill.id.substring(0, 8)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          _statusChip(bill.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type: ${bill.entryType}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      if (bill.billDate != null)
                        Text('Date: ${bill.billDate}',
                            style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items.
              Text(
                'Items (${bill.items.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...bill.items.map((item) => Card(
                    child: ListTile(
                      leading: Icon(
                        item.mappingStatus == 'unmapped'
                            ? Icons.help_outline
                            : item.mappingStatus == 'auto_mapped'
                                ? Icons.auto_fix_high
                                : Icons.check_circle,
                        color: item.mappingStatus == 'unmapped'
                            ? AppTheme.warning
                            : AppTheme.success,
                      ),
                      title: Text(item.rawItemName),
                      subtitle: Text(
                        [
                          if (item.rawQuantity != null)
                            '${item.rawQuantity} ${item.rawUnit}',
                          if (item.rawUnitPrice != null)
                            '@ ${item.rawUnitPrice!.toStringAsFixed(2)}',
                        ].join(' '),
                      ),
                      trailing: Text(
                        item.mappingStatus.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 11,
                          color: item.mappingStatus == 'unmapped'
                              ? AppTheme.warning
                              : AppTheme.success,
                        ),
                      ),
                    ),
                  )),

              // Apply button.
              if (bill.status != 'mapped' &&
                  bill.items.any(
                      (i) => i.mappingStatus != 'unmapped')) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(billRepositoryProvider).apply(id);
                      ref.invalidate(billDetailProvider(id));
                      ref.invalidate(billListProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Bill applied successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('$e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Apply Bill'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'mapped' => AppTheme.success,
      'partially_mapped' => AppTheme.warning,
      'failed' => AppTheme.danger,
      _ => AppTheme.secondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
            fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
