import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/ingredient.dart';
import '../../../providers/ingredient_provider.dart';
import '../../../providers/wastage_provider.dart';

class WastageFormScreen extends ConsumerStatefulWidget {
  const WastageFormScreen({super.key});

  @override
  ConsumerState<WastageFormScreen> createState() => _WastageFormScreenState();
}

class _WastageFormScreenState extends ConsumerState<WastageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _ingredientId;
  final _qtyCtrl = TextEditingController();
  String _wastageType = 'expired';
  final _dateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _ingredientId == null) return;
    setState(() => _loading = true);

    try {
      await ref.read(wastageRepositoryProvider).create({
        'ingredient_id': _ingredientId,
        'quantity': double.parse(_qtyCtrl.text),
        'wastage_type': _wastageType,
        'wastage_date': _dateCtrl.text,
        'notes': _notesCtrl.text.trim(),
      });

      if (mounted) {
        ref.invalidate(wastageListProvider);
        context.go('/wastage');
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
    final ingredientsAsync = ref.watch(
        ingredientListProvider(const IngredientFilters()));

    return Scaffold(
      appBar: AppBar(title: const Text('Record Wastage')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ingredientsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading ingredients: $e'),
                data: (response) => DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Ingredient *'),
                  value: _ingredientId,
                  items: response.ingredients
                      .map((i) => DropdownMenuItem(
                          value: i.id, child: Text(i.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _ingredientId = v),
                  validator: (v) =>
                      v == null ? 'Select an ingredient' : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantity *'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Must be positive';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Wastage Type *'),
                value: _wastageType,
                items: const [
                  DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  DropdownMenuItem(
                      value: 'preparation_loss',
                      child: Text('Preparation Loss')),
                  DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                  DropdownMenuItem(
                      value: 'returned', child: Text('Returned')),
                ],
                onChanged: (v) => setState(() => _wastageType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateCtrl,
                decoration: const InputDecoration(labelText: 'Date'),
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
                    _dateCtrl.text =
                        DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Record Wastage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
