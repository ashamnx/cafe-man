import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../models/ingredient.dart';
import '../../../providers/ingredient_provider.dart';
import '../../../shared/widgets/image_picker_widget.dart';
import 'ingredient_detail_screen.dart';

class IngredientFormScreen extends ConsumerStatefulWidget {
  final String? ingredientId;

  const IngredientFormScreen({super.key, this.ingredientId});

  bool get isEdit => ingredientId != null;

  @override
  ConsumerState<IngredientFormScreen> createState() =>
      _IngredientFormScreenState();
}

class _IngredientFormScreenState extends ConsumerState<IngredientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _costCtrl = TextEditingController(text: '0');
  final _thresholdCtrl = TextEditingController();
  String? _unitId;
  String? _categoryId;
  File? _image;
  String _existingImagePath = '';
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _stockCtrl.dispose();
    _costCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _prefill(Ingredient ing) {
    if (_initialized) return;
    _nameCtrl.text = ing.name;
    _descCtrl.text = ing.description;
    _stockCtrl.text = ing.currentStock.toString();
    _costCtrl.text = ing.currentCostPerUnit.toString();
    if (ing.lowStockThreshold != null) {
      _thresholdCtrl.text = ing.lowStockThreshold.toString();
    }
    _unitId = ing.unitId;
    _categoryId = ing.categoryId;
    _existingImagePath = ing.imagePath;
    _initialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _unitId == null) return;
    setState(() => _loading = true);

    try {
      final formData = FormData.fromMap({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        if (_categoryId != null) 'category_id': _categoryId,
        'unit_id': _unitId,
        'current_stock': _stockCtrl.text.trim(),
        'current_cost_per_unit': _costCtrl.text.trim(),
        if (_thresholdCtrl.text.trim().isNotEmpty)
          'low_stock_threshold': _thresholdCtrl.text.trim(),
        if (_image != null)
          'image': await MultipartFile.fromFile(
            _image!.path,
            filename: _image!.path.split('/').last,
          ),
        if (_image == null && _existingImagePath.isNotEmpty)
          'existing_image_path': _existingImagePath,
      });

      final repo = ref.read(ingredientRepositoryProvider);
      if (widget.isEdit) {
        await repo.update(widget.ingredientId!, formData);
      } else {
        await repo.create(formData);
      }

      if (mounted) {
        ref.invalidate(ingredientListProvider);
        if (widget.isEdit) {
          ref.invalidate(ingredientDetailProvider(widget.ingredientId!));
        }
        context.pop();
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

  Future<void> _promptCreateCategory() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    try {
      final created =
          await ref.read(ingredientRepositoryProvider).createCategory(name);
      ref.invalidate(ingredientCategoriesProvider);
      if (mounted) setState(() => _categoryId = created.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(ingredientUnitsProvider);
    final categoriesAsync = ref.watch(ingredientCategoriesProvider);

    // Pre-fill for edit mode.
    if (widget.isEdit && !_initialized) {
      final detailAsync =
          ref.watch(ingredientDetailProvider(widget.ingredientId!));
      detailAsync.whenData((data) {
        _prefill(Ingredient.fromJson(data['ingredient']));
      });
      if (detailAsync.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Ingredient')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Ingredient' : 'Add Ingredient')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImagePickerWidget(
                image: _image,
                onPicked: (file) => setState(() => _image = file),
                label: widget.isEdit && _existingImagePath.isNotEmpty
                    ? 'Change Photo'
                    : 'Add Photo',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) => validateRequired(v, 'Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading categories: $e'),
                data: (categories) => Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(labelText: 'Category'),
                        value: _categoryId,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('No category'),
                          ),
                          ...categories.map((c) => DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(c.name),
                              )),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Create new category',
                      icon: const Icon(Icons.add),
                      onPressed: _promptCreateCategory,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              unitsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading units: $e'),
                data: (units) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Unit *'),
                  value: _unitId,
                  items: units
                      .map((u) => DropdownMenuItem(
                          value: u.id,
                          child: Text('${u.name} (${u.abbreviation})')))
                      .toList(),
                  onChanged: (v) => setState(() => _unitId = v),
                  validator: (v) => v == null ? 'Select a unit' : null,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: InputDecoration(
                          labelText:
                              widget.isEdit ? 'Current Stock' : 'Initial Stock'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _costCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Cost per Unit'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thresholdCtrl,
                decoration: const InputDecoration(
                    labelText: 'Low Stock Threshold (optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(widget.isEdit
                        ? 'Update Ingredient'
                        : 'Create Ingredient'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
