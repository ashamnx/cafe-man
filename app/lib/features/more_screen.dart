import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          _tile(context, Icons.point_of_sale, 'Sales', '/sales'),
          _tile(context, Icons.delete_outline, 'Wastage', '/wastage'),
          _tile(context, Icons.people_outlined, 'Vendors', '/vendors'),
          _tile(context, Icons.swap_vert, 'Stock Movements', '/stock-movements'),
          _tile(context, Icons.notifications_outlined, 'Alerts', '/alerts'),
          const Divider(),
          _tile(context, Icons.group, 'Team Members', '/settings/users'),
          _tile(context, Icons.shield_outlined, 'Roles & Permissions', '/settings/roles'),
          _tile(context, Icons.history, 'Audit Log', '/settings/audit-log'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(route),
    );
  }
}
