import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/icon_helper.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final int year;
  final int month;
  final Budget? budgetToEdit;

  const AddBudgetDialog({
    super.key,
    required this.year,
    required this.month,
    this.budgetToEdit,
  });

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  String? _selectedCategoryId;
  final TextEditingController _amountController = TextEditingController();
  bool _rolloverEnabled = false;

  bool get _isEditing => widget.budgetToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final b = widget.budgetToEdit!;
      _selectedCategoryId = b.categoryId;
      _amountController.text = b.allocatedAmount.truncateToDouble() == b.allocatedAmount
          ? b.allocatedAmount.toInt().toString()
          : b.allocatedAmount.toString();
      _rolloverEnabled = b.rolloverEnabled;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an expense category')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    await db.setOrUpdateBudget(
      categoryId: _selectedCategoryId!,
      year: widget.year,
      month: widget.month,
      allocatedAmount: amount,
      rolloverEnabled: _rolloverEnabled,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Budget updated successfully!' : 'Budget saved successfully!'),
          backgroundColor: AppColors.income,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider('expense'));
    final categories = categoriesAsync.value ?? [];

    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(_isEditing ? 'Edit Category Budget' : 'Set Category Budget', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Category', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Gap(6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              isExpanded: true,
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Row(
                    children: [
                      Icon(
                        IconHelper.getIcon(cat.iconCode),
                        size: 18,
                        color: Color(cat.colorValue),
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          cat.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isEditing
                  ? null // Category is locked during edit
                  : (val) => setState(() => _selectedCategoryId = val),
            ),
            const Gap(16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Allocated Monthly Limit (₹)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const Gap(12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Rollover', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Carry unspent amount to next month', style: TextStyle(fontSize: 11)),
              value: _rolloverEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => setState(() => _rolloverEnabled = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          onPressed: _saveBudget,
          child: Text(_isEditing ? 'Update Budget' : 'Save Budget'),
        ),
      ],
    );
  }
}
