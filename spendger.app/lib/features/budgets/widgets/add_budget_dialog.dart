import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/icon_helper.dart';

class AddBudgetDialog extends ConsumerStatefulWidget {
  final int year;
  final int month;

  const AddBudgetDialog({super.key, required this.year, required this.month});

  @override
  ConsumerState<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends ConsumerState<AddBudgetDialog> {
  String? _selectedCategoryId;
  final TextEditingController _amountController = TextEditingController();
  bool _rolloverEnabled = false;

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
    const uuid = Uuid();

    try {
      await db.into(db.budgets).insert(
        BudgetsCompanion.insert(
          id: uuid.v4(),
          categoryId: _selectedCategoryId!,
          allocatedAmount: amount,
          periodMonth: widget.month,
          periodYear: widget.year,
          rolloverEnabled: drift.Value(_rolloverEnabled),
          createdAt: DateTime.now(),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A budget for this category already exists this month.')),
        );
      }
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
      title: const Text('Set Category Budget', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Category', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Gap(6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
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
                      Text(cat.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
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
          child: const Text('Save Budget'),
        ),
      ],
    );
  }
}
