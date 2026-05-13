import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/role.dart';
import '../../../providers/user_provider.dart';

class RoleDetailScreen extends ConsumerWidget {
  final String id;
  const RoleDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(roleDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Role Details')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          final role = Role.fromJson(data['role']);
          final permissions = (data['permissions'] as List)
              .map((e) => Permission.fromJson(e))
              .toList();

          // Group by resource.
          final grouped = <String, List<Permission>>{};
          for (final p in permissions) {
            grouped.putIfAbsent(p.resource, () => []).add(p);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${role.name[0].toUpperCase()}${role.name.substring(1)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (role.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(role.description,
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${permissions.length} permissions',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...grouped.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.value
                            .map((p) => Chip(
                                  avatar: Icon(Icons.check,
                                      size: 16,
                                      color: Colors.green.shade600),
                                  label: Text(p.action,
                                      style: const TextStyle(fontSize: 12)),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  )),
            ],
          );
        },
      ),
    );
  }
}
