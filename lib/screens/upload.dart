import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:meals/models/meal.dart';
import 'package:meals/providers/user_meals_provider.dart';
import 'package:meals/data/dummy_data.dart';

class UploadRecipeScreen extends ConsumerStatefulWidget {
  const UploadRecipeScreen({super.key});

  @override
  ConsumerState<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends ConsumerState<UploadRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basics
  final _titleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '20');

  // Photo
  File? _imageFile;

  // Meta
  final Set<String> _selectedCategoryIds = {};
  Complexity _complexity = Complexity.simple;
  Affordability _affordability = Affordability.affordable;

  // Dietary
  bool _isGlutenFree = false;
  bool _isLactoseFree = false;
  bool _isVegan = false;
  bool _isVegetarian = false;

  // New: interactive lists
  final List<String> _ingredients = [];
  final List<String> _steps = [];
  final _ingredientInput = TextEditingController();
  final _stepInput = TextEditingController();

  // --- Image picking ---
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _imageFile = File(picked.path));
  }

  void _showImagePickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers: add / remove / reorder items ---
  void _addItem({
    required TextEditingController controller,
    required List<String> target,
    required String emptyError,
  }) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emptyError)));
      return;
    }
    setState(() {
      target.add(text);
      controller.clear();
    });
  }

  void _removeItem({
    required int index,
    required List<String> target,
    required String labelForUndo,
  }) {
    final removed = target[index];
    setState(() => target.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$labelForUndo removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => target.insert(index, removed)),
        ),
      ),
    );
  }

  void _reorderItems({
    required int oldIndex,
    required int newIndex,
    required List<String> target,
  }) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = target.removeAt(oldIndex);
      target.insert(newIndex, item);
    });
  }

  // --- Validation: ensure essentials are present ---
  bool _validateBeforeSave() {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return false;

    if (_imageFile == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please add a photo.')));
      return false;
    }
    if (_selectedCategoryIds.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Pick at least one category.')));
      return false;
    }
    if (_ingredients.isEmpty || _steps.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient and one step.')),
      );
      return false;
    }
    return true;
  }

  void _save() {
    if (!_validateBeforeSave()) return;

    final uuid = const Uuid().v4();
    final meal = Meal(
      id: uuid,
      categories: _selectedCategoryIds.toList(),
      title: _titleCtrl.text.trim(),
      imageUrl: _imageFile!.path, // local file path
      ingredients: List<String>.from(_ingredients),
      steps: List<String>.from(_steps),
      duration: int.tryParse(_durationCtrl.text.trim()) ?? 20,
      complexity: _complexity,
      affordability: _affordability,
      isGlutenFree: _isGlutenFree,
      isLactoseFree: _isLactoseFree,
      isVegan: _isVegan,
      isVegetarian: _isVegetarian,
    );

    ref.read(userMealsProvider.notifier).addMeal(meal);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _durationCtrl.dispose();
    _ingredientInput.dispose();
    _stepInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Recipe'),
        actions: [
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: _save,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Save Recipe'),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Basics',
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      helperText: 'A short, descriptive name',
                      filled: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _durationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Duration (min)',
                      helperText: 'Positive minutes (e.g., 20)',
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0) return 'Enter a positive number';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Photo
            _SectionCard(
              title: 'Photo',
              helper: 'Stored locally (image path on device)',
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showImagePickerSheet,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: cs.surfaceContainerHigh,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: _imageFile == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: cs.primary),
                              const SizedBox(height: 8),
                              const Text('Add a photo'),
                            ],
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton.filledTonal(
                                onPressed: _showImagePickerSheet,
                                icon: const Icon(Icons.edit),
                                tooltip: 'Change photo',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Categories
            _SectionCard(
              title: 'Categories',
              helper: 'Choose one or more',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in dummyCategories)
                    FilterChip(
                      selected: _selectedCategoryIds.contains(cat.id),
                      label: Text(cat.title),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategoryIds.add(cat.id);
                          } else {
                            _selectedCategoryIds.remove(cat.id);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Details
            _SectionCard(
              title: 'Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Complexity'),
                  const SizedBox(height: 8),
                  SegmentedButton<Complexity>(
                    segments: const [
                      ButtonSegment(value: Complexity.simple, label: Text('Simple'), icon: Icon(Icons.event_available)),
                      ButtonSegment(value: Complexity.challenging, label: Text('Challenging'), icon: Icon(Icons.directions_run)),
                      ButtonSegment(value: Complexity.hard, label: Text('Hard'), icon: Icon(Icons.fitness_center)),
                    ],
                    selected: {_complexity},
                    onSelectionChanged: (s) => setState(() => _complexity = s.first),
                  ),
                  const SizedBox(height: 16),
                  const Text('Affordability'),
                  const SizedBox(height: 8),
                  SegmentedButton<Affordability>(
                    segments: const [
                      ButtonSegment(value: Affordability.affordable, label: Text('Affordable'), icon: Icon(Icons.attach_money)),
                      ButtonSegment(value: Affordability.pricey, label: Text('Pricey'), icon: Icon(Icons.payments_outlined)),
                      ButtonSegment(value: Affordability.luxurious, label: Text('Luxurious'), icon: Icon(Icons.diamond_outlined)),
                    ],
                    selected: {_affordability},
                    onSelectionChanged: (s) => setState(() => _affordability = s.first),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Ingredients (interactive list)
            _SectionCard(
              title: 'Ingredients',
              helper: 'Add, reorder, or swipe to delete',
              child: Column(
                children: [
                  _AddRow(
                    controller: _ingredientInput,
                    hint: 'e.g., 2 eggs',
                    onAdd: () => _addItem(
                      controller: _ingredientInput,
                      target: _ingredients,
                      emptyError: 'Ingredient can’t be empty',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ListEmptyHint(
                    isEmpty: _ingredients.isEmpty,
                    text: 'No ingredients yet. Add your first one.',
                  ),
                  if (_ingredients.isNotEmpty)
                    _ReorderableDismissibleList(
                      items: _ingredients,
                      itemBuilder: (context, item, index) => ListTile(
                        key: ValueKey('ing_$index'),
                        leading: const Icon(Icons.drag_handle),
                        title: Text(item),
                        trailing: const SizedBox(width: 8),
                      ),
                      onReorder: (o, n) => _reorderItems(oldIndex: o, newIndex: n, target: _ingredients),
                      onDismissed: (i) => _removeItem(
                        index: i,
                        target: _ingredients,
                        labelForUndo: 'Ingredient',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Steps (interactive list)
            _SectionCard(
              title: 'Steps',
              helper: 'Add, reorder, or swipe to delete',
              child: Column(
                children: [
                  _AddRow(
                    controller: _stepInput,
                    hint: 'e.g., Preheat oven to 180°C',
                    onAdd: () => _addItem(
                      controller: _stepInput,
                      target: _steps,
                      emptyError: 'Step can’t be empty',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ListEmptyHint(
                    isEmpty: _steps.isEmpty,
                    text: 'No steps yet. Add your first one.',
                  ),
                  if (_steps.isNotEmpty)
                    _ReorderableDismissibleList(
                      items: _steps,
                      itemBuilder: (context, item, index) => ListTile(
                        key: ValueKey('step_$index'),
                        leading: CircleAvatar(
                          radius: 14,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(item),
                        trailing: const Icon(Icons.drag_handle),
                      ),
                      onReorder: (o, n) => _reorderItems(oldIndex: o, newIndex: n, target: _steps),
                      onDismissed: (i) => _removeItem(
                        index: i,
                        target: _steps,
                        labelForUndo: 'Step',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Dietary
            _SectionCard(
              title: 'Dietary',
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Gluten-free'),
                    subtitle: const Text('isGlutenFree'),
                    value: _isGlutenFree,
                    onChanged: (v) => setState(() => _isGlutenFree = v),
                  ),
                  SwitchListTile(
                    title: const Text('Lactose-free'),
                    subtitle: const Text('isLactoseFree'),
                    value: _isLactoseFree,
                    onChanged: (v) => setState(() => _isLactoseFree = v),
                  ),
                  SwitchListTile(
                    title: const Text('Vegan'),
                    subtitle: const Text('isVegan'),
                    value: _isVegan,
                    onChanged: (v) => setState(() => _isVegan = v),
                  ),
                  SwitchListTile(
                    title: const Text('Vegetarian'),
                    subtitle: const Text('isVegetarian'),
                    value: _isVegetarian,
                    onChanged: (v) => setState(() => _isVegetarian = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// --- UI helpers ---

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.helper,
  });

  final String title;
  final Widget child;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (helper != null) ...[
              const SizedBox(height: 4),
              Text(helper!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({
    required this.controller,
    required this.onAdd,
    required this.hint,
  });

  final TextEditingController controller;
  final VoidCallback onAdd;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              suffixIcon: IconButton(
                tooltip: 'Add',
                icon: const Icon(Icons.add),
                onPressed: onAdd,
              ),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
      ],
    );
  }
}

class _ReorderableDismissibleList extends StatelessWidget {
  const _ReorderableDismissibleList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    required this.onDismissed,
  });

  final List<String> items;
  final Widget Function(BuildContext, String, int) itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onDismissed;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      onReorder: onReorder,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final tile = itemBuilder(context, items[index], index);
        return Dismissible(
          key: ValueKey('d_$index:${items[index]}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Icon(Icons.delete_outline,
                color: Theme.of(context).colorScheme.onErrorContainer),
          ),
          onDismissed: (_) => onDismissed(index),
          child: ReorderableDragStartListener(
            index: index,
            child: tile,
          ),
        );
      },
    );
  }
}

class _ListEmptyHint extends StatelessWidget {
  const _ListEmptyHint({required this.isEmpty, required this.text});
  final bool isEmpty;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (!isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
