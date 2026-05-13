import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/vendor_provider.dart';

class VendorDetailScreen extends ConsumerWidget {
  final String id;

  const VendorDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/vendors/$id/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Vendor'),
                  content: const Text(
                      'Are you sure you want to delete this vendor?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref
                    .read(vendorRepositoryProvider)
                    .delete(id);
                if (context.mounted) context.go('/vendors');
              }
            },
          ),
        ],
      ),
      body: vendorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (vendor) => RefreshIndicator(
          onRefresh: () => ref.refresh(vendorDetailProvider(id).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (vendor.contactName.isNotEmpty)
                        _row(Icons.person_outlined, 'Contact',
                            vendor.contactName),
                      if (vendor.phone.isNotEmpty)
                        _row(Icons.phone_outlined, 'Phone', vendor.phone),
                      if (vendor.email.isNotEmpty)
                        _row(Icons.email_outlined, 'Email', vendor.email),
                      if (vendor.address.isNotEmpty)
                        _row(Icons.location_on_outlined, 'Address',
                            vendor.address),
                      if (vendor.notes.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text('Notes',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(vendor.notes),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
