import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../models/menu_item.dart';
import '../../../providers/ingredient_provider.dart';
import '../../../providers/recipe_provider.dart';
import '../../../shared/widgets/image_picker_widget.dart';

class RecipeFormScreen extends ConsumerStatefulWidget {
  final String? recipeId;

  const RecipeFormScreen({super.key, this.recipeId});

  bool get isEdit => recipeId != null;

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '0');
  final _prepNotesCtrl = TextEditingController();
  final _allergensCtrl = TextEditingController();
  String? _categoryId;
  String _status = 'draft';
  File? _image;
  String _existingImagePath = '';
  bool _loading = false;
  bool _initialized = false;
  List<RecipeIngredient> _recipeIngredients = [];
  List<RecipeUtilityCost> _utilityCosts = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _prepNotesCtrl.dispose();
    _allergensCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final formData = FormData.fromMap({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'selling_price': _priceCtrl.text.trim(),
        'status': _status,
        'preparation_notes': _prepNotesCtrl.text.trim(),
        'allergens': _allergensCtrl.text.trim(),
        if (_categoryId != null) 'category_id': _categoryId,
        if (_image != null)
          'image': await MultipartFile.fromFile(
            _image!.path,
            filename: _image!.path.split('/').last,
          ),
        if (_image == null && _existingImagePath.isNotEmpty)
          'existing_image_path': _existingImagePath,
      });

      final repo = ref.read(recipeRepositoryProvider);
      if (widget.isEdit) {
        await repo.update(widget.recipeId!, formData);
        if (mounted) {
          ref.invalidate(recipeListProvider);
          ref.invalidate(recipeDetailProvider(widget.recipeId!));
          context.pop();
        }
      } else {
        final recipe = await repo.create(formData);
        if (mounted) {
          ref.invalidate(recipeListProvider);
          context.pop();
          context.push('/recipes/${recipe.id}');
        }
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

  Future<void> _addIngredient() async {
    if (!widget.isEdit) return;

    final ingredientsAsync = ref.read(
        ingredientListProvider(const IngredientFilters()));

    final ingredients = ingredientsAsync.valueOrNull?.ingredients ?? [];
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No ingredients available')),
      );
      return;
    }

    String? selectedIngId;
    final qtyCtrl = TextEditingController(text: '1');
    String ingType = 'primary';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ingredient'),
                isExpanded: true,
                value: selectedIngId,
                items: ingredients
                    .map((i) => DropdownMenuItem(
                        value: i.id,
                        child: Text(i.name, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedIngId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type'),
                value: ingType,
                items: const [
                  DropdownMenuItem(value: 'primary', child: Text('Primary')),
                  DropdownMenuItem(
                      value: 'secondary', child: Text('Secondary')),
                ],
                onChanged: (v) => setDialogState(() => ingType = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedIngId == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && selectedIngId != null) {
      try {
        await ref.read(recipeRepositoryProvider).addIngredient(
          widget.recipeId!,
          {
            'ingredient_id': selectedIngId,
            'quantity': double.tryParse(qtyCtrl.text) ?? 1,
            'ingredient_type': ingType,
          },
        );
        // Reload the recipe detail to get updated ingredients.
        ref.invalidate(recipeDetailProvider(widget.recipeId!));
        _initialized = false; // Force re-fetch.
        setState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red),
          );
        }
      }
    }
    qtyCtrl.dispose();
  }

  Future<void> _removeIngredient(RecipeIngredient ri) async {
    if (!widget.isEdit) return;
    try {
      await ref
          .read(recipeRepositoryProvider)
          .removeIngredient(widget.recipeId!, ri.id);
      ref.invalidate(recipeDetailProvider(widget.recipeId!));
      _initialized = false;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addUtilityCost() async {
    if (!widget.isEdit) return;

    final nameCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Utility Cost'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Name', hintText: 'e.g. gas, electricity'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costCtrl,
              decoration: const InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      try {
        await ref.read(recipeRepositoryProvider).setUtilityCost(
          widget.recipeId!,
          {
            'name': nameCtrl.text.trim(),
            'cost': double.tryParse(costCtrl.text) ?? 0,
          },
        );
        ref.invalidate(recipeDetailProvider(widget.recipeId!));
        _initialized = false;
        setState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red),
          );
        }
      }
    }
    nameCtrl.dispose();
    costCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(recipeCategoriesProvider);

    // Pre-fill for edit mode.
    if (widget.isEdit && !_initialized) {
      final detailAsync = ref.watch(recipeDetailProvider(widget.recipeId!));
      detailAsync.whenData((response) {
        if (!_initialized) {
          final recipe = response.recipe;
          _nameCtrl.text = recipe.name;
          _descCtrl.text = recipe.description;
          _priceCtrl.text = recipe.sellingPrice.toString();
          _prepNotesCtrl.text = recipe.preparationNotes;
          _allergensCtrl.text = recipe.allergens.join(', ');
          _categoryId = recipe.categoryId;
          _status = recipe.status;
          _existingImagePath = recipe.imagePath;
          _recipeIngredients = recipe.ingredients;
          _utilityCosts = recipe.utilityCosts;
          _initialized = true;
        }
      });
      if (detailAsync.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Recipe')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
    }

    // Also pre-fetch ingredients list for the add dialog.
    if (widget.isEdit) {
      ref.watch(ingredientListProvider(const IngredientFilters()));
    }

    return Scaffold(
      appBar:
          AppBar(title: Text(widget.isEdit ? 'Edit Recipe' : 'Add Recipe')),
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
                data: (categories) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: _categoryId,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('No category')),
                    ...categories.map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Selling Price'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                ],
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prepNotesCtrl,
                decoration:
                    const InputDecoration(labelText: 'Preparation Notes'),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _allergensCtrl,
                decoration: const InputDecoration(
                  labelText: 'Allergens',
                  hintText: 'Comma-separated, e.g. dairy, nuts',
                ),
              ),

              // Recipe Ingredients section (edit mode only).
              if (widget.isEdit) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ingredients',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (_recipeIngredients.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No ingredients added yet',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                ..._recipeIngredients.map((ri) {
                  final ingResp = ref
                      .read(ingredientListProvider(const IngredientFilters()))
                      .valueOrNull;
                  final ingList = ingResp?.ingredients;
                  final ingName = ingList
                          ?.where((i) => i.id == ri.ingredientId)
                          .firstOrNull
                          ?.name ??
                      'Ingredient';
                  final ingUnit = ingList
                          ?.where((i) => i.id == ri.ingredientId)
                          .firstOrNull
                          ?.unit
                          ?.abbreviation ??
                      '';

                  return Card(
                    child: ListTile(
                      dense: true,
                      title: Text(ingName),
                      subtitle: Text(
                          '${ri.quantity} $ingUnit | ${ri.ingredientType}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red, size: 20),
                        onPressed: () => _removeIngredient(ri),
                      ),
                    ),
                  );
                }),

                // Utility Costs section.
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Utility Costs',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: _addUtilityCost,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (_utilityCosts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No utility costs added yet',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                ..._utilityCosts.map((uc) => Card(
                      child: ListTile(
                        dense: true,
                        title: Text(uc.name),
                        trailing: Text(uc.cost.toStringAsFixed(2),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    )),
              ],

              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(widget.isEdit
                        ? 'Update Recipe'
                        : 'Create Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
