import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/user_provider.dart';

class RoleListScreen extends ConsumerWidget {
  const RoleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(roleListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Permissions')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(roleListProvider.future),
        child: rolesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('$e', style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () => ref.invalidate(roleListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (roles) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: roles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final role = roles[index];
              IconData icon;
              Color iconColor;
              if (role.name == 'owner') {
                icon = Icons.workspace_premium;
                iconColor = Colors.amber.shade700;
              } else if (role.name == 'manager') {
                icon = Icons.business_center;
                iconColor = Colors.blue.shade700;
              } else {
                icon = Icons.person;
                iconColor = Colors.grey.shade700;
              }

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withValues(alpha: 0.1),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  title: Text(
                    '${role.name[0].toUpperCase()}${role.name.substring(1)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(role.description.isNotEmpty
                      ? role.description
                      : '${role.permissions.length} permissions'),
                  trailing: Text(
                    '${role.permissions.length}',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600),
                  ),
                  onTap: () => context.push('/settings/roles/${role.id}'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
