import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/bill_provider.dart';

class BillManualEntryScreen extends ConsumerStatefulWidget {
  const BillManualEntryScreen({super.key});

  @override
  ConsumerState<BillManualEntryScreen> createState() =>
      _BillManualEntryScreenState();
}

class _BillManualEntryScreenState
    extends ConsumerState<BillManualEntryScreen> {
  final _billNumberCtrl = TextEditingController();
  final _billDateCtrl = TextEditingController();
  final List<_LineItem> _items = [_LineItem()];
  bool _loading = false;

  @override
  void dispose() {
    _billNumberCtrl.dispose();
    _billDateCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() => _items.add(_LineItem()));
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  Future<void> _submit() async {
    final validItems = _items
        .where((i) => i.nameCtrl.text.trim().isNotEmpty)
        .toList();

    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final bill = await ref.read(billRepositoryProvider).createManual({
        'bill_number': _billNumberCtrl.text.trim(),
        'bill_date': _billDateCtrl.text.trim(),
        'items': validItems
            .map((i) => {
                  'name': i.nameCtrl.text.trim(),
                  'quantity': double.tryParse(i.qtyCtrl.text),
                  'unit': i.unitCtrl.text.trim(),
                  'unit_price': double.tryParse(i.priceCtrl.text),
                })
            .toList(),
      });

      if (mounted) {
        ref.invalidate(billListProvider);
        context.go('/bills/${bill.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Bill Entry')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _billNumberCtrl,
            decoration:
                const InputDecoration(labelText: 'Bill Number (optional)'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _billDateCtrl,
            decoration: const InputDecoration(
                labelText: 'Bill Date (optional)', hintText: 'YYYY-MM-DD'),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate:
                    DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                _billDateCtrl.text =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Line Items',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: item.nameCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Item Name *', isDense: true),
                          ),
                        ),
                        if (_items.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _removeItem(i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: item.qtyCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Qty', isDense: true),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: item.unitCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Unit', isDense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: item.priceCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Unit Price', isDense: true),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create Bill'),
          ),
        ],
      ),
    );
  }
}

class _LineItem {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    unitCtrl.dispose();
    priceCtrl.dispose();
  }
}
