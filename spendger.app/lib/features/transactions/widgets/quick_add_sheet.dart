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

class QuickAddSheet extends ConsumerStatefulWidget {
  final String initialType;
  const QuickAddSheet({super.key, this.initialType = 'expense'});

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

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
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

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_type == 'income' ? 'Income' : 'Expense'} recorded successfully!'),
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

    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(12),
          // Type Selector Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    label: 'Expense',
                    type: 'expense',
                    color: AppColors.expense,
                  ),
                ),
                Expanded(
                  child: _buildTypeButton(
                    label: 'Income',
                    type: 'income',
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          // Amount Display Header
          Text(
            _type.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: _type == 'income' ? AppColors.incomeLight : AppColors.expenseLight,
            ),
          ),
          const Gap(4),
          Text(
            '₹ $_amountStr',
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
              itemCount: categories.length,
              separatorBuilder: (_, __) => const Gap(8),
              itemBuilder: (context, index) {
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
                  decoration: const InputDecoration(
                    labelText: 'Account / Mode',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Row(
                        children: [
                          Icon(
                            IconHelper.getIcon(acc.iconCode),
                            size: 16,
                            color: Color(acc.colorValue),
                          ),
                          const Gap(8),
                          Text(acc.name, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    );
                  }).toList(),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 13),
                        ),
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
          const Gap(10),
          // Keypad Grid
          Expanded(
            child: _buildKeypadGrid(),
          ),
          // Save Button
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
              child: const Text('SAVE TRANSACTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({required String label, required String type, required Color color}) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = type;
          _selectedCategoryId = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
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
