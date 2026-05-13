import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/user_provider.dart';

class MemberListScreen extends ConsumerWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(memberListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Roles',
            onPressed: () => context.push('/settings/roles'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(memberListProvider.future),
        child: membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('$e', style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () => ref.invalidate(memberListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (members) {
            if (members.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No team members',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final m = members[index];
                final roleName =
                    m.roles.isNotEmpty ? m.roles.first : 'No role';
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        m.fullName.isNotEmpty
                            ? m.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(m.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(m.email),
                    trailing: _roleBadge(context, roleName, m.isOwner),
                    onTap: m.isOwner
                        ? null
                        : () => _showMemberActions(context, ref, m),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/settings/users/invite'),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _roleBadge(BuildContext context, String role, bool isOwner) {
    Color bg;
    Color fg;
    if (isOwner || role == 'owner') {
      bg = Colors.amber.shade100;
      fg = Colors.amber.shade800;
    } else if (role == 'manager') {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade800;
    } else {
      bg = Colors.grey.shade200;
      fg = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  void _showMemberActions(
      BuildContext context, WidgetRef ref, dynamic member) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Change to Manager'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref
                    .read(userRepositoryProvider)
                    .changeRole(member.userId, 'manager');
                ref.invalidate(memberListProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Change to Staff'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref
                    .read(userRepositoryProvider)
                    .changeRole(member.userId, 'staff');
                ref.invalidate(memberListProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Reset Password'),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Reset Password'),
                    content: Text(
                        'Generate a new password for ${member.fullName}?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  try {
                    final newPassword = await ref
                        .read(userRepositoryProvider)
                        .resetPassword(member.userId);
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Password Reset'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('New password for ${member.fullName}:'),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SelectableText(
                                  newPassword,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Share this password securely.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                          actions: [
                            FilledButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text('Done')),
                          ],
                        ),
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
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Remove from Organization',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Remove User'),
                    content: Text(
                        'Remove ${member.fullName} from the organization?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Remove',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(userRepositoryProvider)
                      .remove(member.userId);
                  ref.invalidate(memberListProvider);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
