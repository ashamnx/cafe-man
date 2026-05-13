import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_theme.dart';
import '../../../providers/bill_provider.dart';

class BillListScreen extends ConsumerWidget {
  const BillListScreen({super.key});

  Color _statusColor(String status) {
    return switch (status) {
      'mapped' => AppTheme.success,
      'partially_mapped' => AppTheme.warning,
      'failed' => AppTheme.danger,
      'processing' => AppTheme.primary,
      _ => AppTheme.secondary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(billListProvider.future),
        child: billsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('$e', style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () => ref.invalidate(billListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (bills) {
            if (bills.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No bills yet',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bills.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final bill = bills[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      bill.entryType == 'scan'
                          ? Icons.document_scanner
                          : Icons.edit_note,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      bill.billNumber.isNotEmpty
                          ? bill.billNumber
                          : 'Bill ${bill.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(bill.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bill.status.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 11,
                              color: _statusColor(bill.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bill.entryType,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/bills/${bill.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Scan Bill'),
              subtitle: const Text('Upload a bill image for AI extraction'),
              onTap: () {
                Navigator.pop(context);
                context.push('/bills/upload');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Manual Entry'),
              subtitle: const Text('Enter bill items manually'),
              onTap: () {
                Navigator.pop(context);
                context.push('/bills/manual');
              },
            ),
          ],
        ),
      ),
    );
  }
}
