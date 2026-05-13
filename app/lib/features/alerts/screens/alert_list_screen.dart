import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../providers/alert_provider.dart';

class AlertListScreen extends ConsumerWidget {
  const AlertListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(alertListProvider.future),
        child: alertsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (alerts) {
            if (alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No alerts',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final a = alerts[index];
                final isPrice = a.alertType == 'price_increase';
                return Card(
                  color: a.isRead ? null : Colors.blue.shade50,
                  child: ListTile(
                    leading: Icon(
                      isPrice ? Icons.trending_up : Icons.warning_amber,
                      color: isPrice ? AppTheme.danger : AppTheme.warning,
                    ),
                    title: Text(
                      a.ingredientName,
                      style: TextStyle(
                        fontWeight:
                            a.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(a.message, maxLines: 2),
                    trailing: a.isRead
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.check, size: 20),
                            onPressed: () async {
                              await ref
                                  .read(alertRepositoryProvider)
                                  .markRead(a.id);
                              ref.invalidate(alertListProvider);
                            },
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
