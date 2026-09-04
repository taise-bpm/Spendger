import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/icon_helper.dart';
import '../../settings/category_manager_screen.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  final String initialType;
  final Transaction? transactionToEdit;

  const QuickAddSheet({
    super.key,
    this.initialType = 'expense',
    this.transactionToEdit,
  });

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  late String _type;
  String _amountStr = '0';
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  bool get _isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final tx = widget.transactionToEdit!;
      _type = tx.type;
      _amountStr = tx.amount.truncateToDouble() == tx.amount
          ? tx.amount.toInt().toString()
          : tx.amount.toString();
      _selectedCategoryId = tx.categoryId;
      _selectedAccountId = tx.accountId;
      _selectedDate = tx.transactionDate;
      _notesController.text = tx.notes ?? '';
    } else {
      _type = widget.initialType;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onKeypadPress(String val) {
    setState(() {
      if (val == 'C') {
        _amountStr = '0';
      } else if (val == '⌫') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (val == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = val;
        } else {
          _amountStr += val;
        }
      }
    });
  }

  Future<void> _submitTransaction() async {
    final double? amount = double.tryParse(_amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    const uuid = Uuid();

    if (_isEditing) {
      final updatedTx = TransactionsCompanion(
        id: drift.Value(widget.transactionToEdit!.id),
        categoryId: drift.Value(_selectedCategoryId!),
        accountId: drift.Value(_selectedAccountId),
        amount: drift.Value(amount),
        type: drift.Value(_type),
        transactionDate: drift.Value(_selectedDate),
        notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
        createdAt: drift.Value(widget.transactionToEdit!.createdAt),
      );
      await db.updateTransactionWithAccountUpdate(widget.transactionToEdit!, updatedTx);
    } else {
      final tx = TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: _selectedCategoryId!,
        accountId: drift.Value(_selectedAccountId),
        amount: amount,
        type: _type,
        transactionDate: _selectedDate,
        notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
        createdAt: DateTime.now(),
      );
      await db.addTransactionWithAccountUpdate(tx);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? '${_type == 'income' ? 'Income' : 'Expense'} updated successfully!'
                : '${_type == 'income' ? 'Income' : 'Expense'} recorded successfully!',
          ),
          backgroundColor: _type == 'income' ? AppColors.income : AppColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider(_type));
    final accountsAsync = ref.watch(accountsStreamProvider);

    final categories = categoriesAsync.value ?? [];
    final accounts = accountsAsync.value ?? [];    
    final availableAccounts = accounts.where((a) => a.isActive || a.id == _selectedAccountId).toList();

    if (_selectedAccountId == null && availableAccounts.isNotEmpty) {
      _selectedAccountId = availableAccounts.firstWhere((a) => a.isActive, orElse: () => availableAccounts.first).id;
    }

    final accountDropdownItems = <DropdownMenuItem<String>>[];
    for (final acc in availableAccounts) {
      accountDropdownItems.add(
        DropdownMenuItem(
          value: acc.id,
          child: Row(
            children: [
              Icon(
                IconHelper.getIcon(acc.iconCode),
                size: 16,
                color: Color(acc.colorValue),
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  acc.isActive ? acc.name : '${acc.name} (Inactive)',
                  style: TextStyle(
                    fontSize: 12,
                    color: acc.isActive ? null : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_selectedAccountId != null && !availableAccounts.any((a) => a.id == _selectedAccountId)) {
      accountDropdownItems.add(
        DropdownMenuItem(
          value: _selectedAccountId,
          child: const Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
              Gap(6),
              Expanded(
                child: Text(
                  'Archived / Previous Account',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: bottomInset > 0 ? bottomInset + 8 : 16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Top Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(10),
          // Type Toggle (Income / Expense)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _type = 'expense';
                        _selectedCategoryId = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _type == 'expense' ? AppColors.expense : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _type == 'expense' ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _type = 'income';
                        _selectedCategoryId = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _type == 'income' ? AppColors.income : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Income',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _type == 'income' ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(14),
          // Amount Display & Note field
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    '₹$_amountStr',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: _type == 'income' ? AppColors.incomeLight : AppColors.expenseLight,
                    ),
                  ),
                  const Gap(14),
                  // Category horizontal scroll
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, __) => const Gap(8),
                      itemBuilder: (context, index) {
                        if (index == categories.length) {
                          return ActionChip(
                            avatar: const Icon(Icons.settings, size: 15, color: AppColors.primaryLight),
                            label: const Text('Manage Heads', style: TextStyle(fontSize: 12, color: AppColors.primaryLight)),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CategoryManagerScreen()),
                              );
                            },
                          );
                        }
                        final cat = categories[index];
                        final isSelected = cat.id == _selectedCategoryId;
                        return ChoiceChip(
                          avatar: Icon(
                            IconHelper.getIcon(cat.iconCode),
                            size: 16,
                            color: isSelected ? Colors.white : Color(cat.colorValue),
                          ),
                          label: Text(cat.name),
                          selected: isSelected,
                          selectedColor: Color(cat.colorValue),
                          onSelected: (val) {
                            setState(() => _selectedCategoryId = cat.id);
                          },
                        );
                      },
                    ),
                  ),
                  const Gap(10),
                  // Account & Date Selector Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedAccountId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Account / Mode',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: accountDropdownItems,
                          onChanged: (val) => setState(() => _selectedAccountId = val),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => _selectedDate = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const Gap(4),
                                const Icon(Icons.calendar_today, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  // Optional Notes
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Notes (Optional)',
                      prefixIcon: Icon(Icons.edit_note, size: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(10),
          // Keypad Grid
          Expanded(
            child: _buildKeypadGrid(),
          ),
            // Save / Update Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == 'income' ? AppColors.income : AppColors.expense,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _submitTransaction,
                child: Text(
                  _isEditing ? 'UPDATE TRANSACTION' : 'SAVE TRANSACTION',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildKeypadGrid() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Expanded(
          child: Row(
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: InkWell(
                    onTap: () => _onKeypadPress(key),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          key,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
