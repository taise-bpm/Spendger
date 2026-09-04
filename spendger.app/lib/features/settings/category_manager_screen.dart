import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/icon_helper.dart';

class CategoryManagerScreen extends ConsumerStatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  ConsumerState<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends ConsumerState<CategoryManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddOrEditCategoryDialog({Category? categoryToEdit, required String type}) {
    showDialog(
      context: context,
      builder: (_) => _AddOrEditCategoryDialog(
        categoryToEdit: categoryToEdit,
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories & Headers'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primaryLight,
          tabs: const [
            Tab(icon: Icon(Icons.arrow_upward, size: 18), text: 'Expenses'),
            Tab(icon: Icon(Icons.arrow_downward, size: 18), text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList('expense', theme),
          _buildCategoryList('income', theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_category_manager',
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          final currentType = _tabController.index == 0 ? 'expense' : 'income';
          _showAddOrEditCategoryDialog(type: currentType);
        },
      ),
    );
  }

  Widget _buildCategoryList(String type, ThemeData theme) {
    final categoriesAsync = ref.watch(categoriesStreamProvider(type));

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                const Gap(12),
                Text('No $type categories found.', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Gap(8),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final color = Color(cat.colorValue);

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(IconHelper.getIcon(cat.iconCode), color: color, size: 20),
                ),
                title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  cat.isCustom ? 'Custom Category' : 'Default Category',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: AppColors.primaryLight),
                      tooltip: 'Edit Header',
                      onPressed: () => _showAddOrEditCategoryDialog(categoryToEdit: cat, type: type),
                    ),
                    if (cat.isCustom)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.expenseLight),
                        tooltip: 'Delete Category',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Category?'),
                              content: Text('Are you sure you want to delete "${cat.name}"? Existing transactions will retain their logs.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(databaseProvider).deleteCategory(cat.id);
                          }
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AddOrEditCategoryDialog extends ConsumerStatefulWidget {
  final Category? categoryToEdit;
  final String type;

  const _AddOrEditCategoryDialog({
    this.categoryToEdit,
    required this.type,
  });

  @override
  ConsumerState<_AddOrEditCategoryDialog> createState() => _AddOrEditCategoryDialogState();
}

class _AddOrEditCategoryDialogState extends ConsumerState<_AddOrEditCategoryDialog> {
  late TextEditingController _nameController;
  late int _selectedColorValue;
  late int _selectedIconCode;

  final List<Color> _availableColors = const [
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFF6366F1),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
    Color(0xFF64748B),
  ];

  final List<IconData> _availableIcons = const [
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.directions_car,
    Icons.receipt_long,
    Icons.movie,
    Icons.medical_services,
    Icons.school,
    Icons.flight,
    Icons.card_giftcard,
    Icons.home,
    Icons.work,
    Icons.account_balance,
    Icons.trending_up,
    Icons.laptop,
    Icons.savings,
    Icons.attach_money,
    Icons.coffee,
    Icons.fitness_center,
  ];

  bool get _isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.categoryToEdit!;
      _nameController = TextEditingController(text: c.name);
      _selectedColorValue = c.colorValue;
      _selectedIconCode = c.iconCode;
    } else {
      _nameController = TextEditingController();
      _selectedColorValue = _availableColors.first.toARGB32();
      _selectedIconCode = _availableIcons.first.codePoint;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    try {
      final db = ref.read(databaseProvider);
      const uuid = Uuid();
      final now = DateTime.now();

      final catCompanion = CategoriesCompanion(
        id: drift.Value(_isEditing ? widget.categoryToEdit!.id : uuid.v4()),
        name: drift.Value(name),
        type: drift.Value(_isEditing ? widget.categoryToEdit!.type : widget.type),
        iconCode: drift.Value(_selectedIconCode),
        colorValue: drift.Value(_selectedColorValue),
        isCustom: drift.Value(_isEditing ? widget.categoryToEdit!.isCustom : true),
        createdAt: drift.Value(_isEditing ? widget.categoryToEdit!.createdAt : now),
      );

      await db.upsertCategory(catCompanion);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Category "$name" updated!' : 'Category "$name" created!'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save category: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(_isEditing ? 'Edit Category' : 'Add ${widget.type == 'income' ? 'Income' : 'Expense'} Category', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category / Header Name',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const Gap(16),
            const Text('Pick Icon', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((ic) {
                final isSelected = ic.codePoint == _selectedIconCode;
                return InkWell(
                  onTap: () => setState(() => _selectedIconCode = ic.codePoint),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Theme.of(context).cardTheme.color,
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(ic, size: 20, color: isSelected ? AppColors.primaryLight : Colors.white70),
                  ),
                );
              }).toList(),
            ),
            const Gap(16),
            const Text('Pick Color', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((col) {
                final isSelected = col.toARGB32() == _selectedColorValue;
                return InkWell(
                  onTap: () => setState(() => _selectedColorValue = col.toARGB32()),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Create Category'),
        ),
      ],
    );
  }
}
