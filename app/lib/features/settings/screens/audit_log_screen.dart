import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/audit_provider.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  String? _entityType;
  String? _action;
  int _page = 1;

  AuditFilter get _filter =>
      AuditFilter(entityType: _entityType, action: _action, page: _page);

  @override
  Widget build(BuildContext context) {
    final auditAsync = ref.watch(auditLogProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _filterChip(
                    label: _entityType ?? 'All Types',
                    options: const [
                      null,
                      'ingredient',
                      'vendor',
                      'bill',
                      'recipe',
                      'sale_entry',
                      'wastage',
                      'user'
                    ],
                    labels: const [
                      'All Types',
                      'Ingredient',
                      'Vendor',
                      'Bill',
                      'Recipe',
                      'Sale',
                      'Wastage',
                      'User'
                    ],
                    onSelected: (v) =>
                        setState(() { _entityType = v; _page = 1; }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _filterChip(
                    label: _action ?? 'All Actions',
                    options: const [null, 'create', 'update', 'delete'],
                    labels: const [
                      'All Actions',
                      'Create',
                      'Update',
                      'Delete'
                    ],
                    onSelected: (v) =>
                        setState(() { _action = v; _page = 1; }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(auditLogProvider(_filter).future),
        child: auditAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('$e', style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () => ref.invalidate(auditLogProvider(_filter)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (response) {
            if (response.entries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No audit entries',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: response.entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final e = response.entries[index];
                      return Card(
                        child: ListTile(
                          dense: true,
                          leading: _actionIcon(e.action),
                          title: Text(
                            '${e.userName} ${_actionLabel(e.action)} ${e.entityType}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            _formatDate(e.createdAt),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                          trailing: Text(
                            e.entityId.substring(0, 8),
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (response.totalPages > 1)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Page $_page of ${response.totalPages}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                        Row(
                          children: [
                            if (_page > 1)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _page--),
                                child: const Text('Prev'),
                              ),
                            if (_page < response.totalPages)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _page++),
                                child: const Text('Next'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required List<String?> options,
    required List<String> labels,
    required void Function(String?) onSelected,
  }) {
    return PopupMenuButton<String?>(
      onSelected: onSelected,
      itemBuilder: (_) => List.generate(
        options.length,
        (i) => PopupMenuItem(value: options[i], child: Text(labels[i])),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(label,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(String action) {
    switch (action) {
      case 'create':
        return CircleAvatar(
          radius: 16,
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.add, size: 16, color: Colors.green.shade700),
        );
      case 'update':
        return CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.edit, size: 16, color: Colors.blue.shade700),
        );
      case 'delete':
        return CircleAvatar(
          radius: 16,
          backgroundColor: Colors.red.shade100,
          child: Icon(Icons.delete, size: 16, color: Colors.red.shade700),
        );
      default:
        return const CircleAvatar(radius: 16, child: Icon(Icons.info, size: 16));
    }
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'create':
        return 'created';
      case 'update':
        return 'updated';
      case 'delete':
        return 'deleted';
      default:
        return action;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
