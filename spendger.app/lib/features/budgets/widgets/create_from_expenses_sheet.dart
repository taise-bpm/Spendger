import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';

class CreateFromExpensesSheet extends ConsumerStatefulWidget {
  final int targetYear;
  final int targetMonth;

  const CreateFromExpensesSheet({
    super.key,
    required this.targetYear,
    required this.targetMonth,
  });

  @override
  ConsumerState<CreateFromExpensesSheet> createState() => _CreateFromExpensesSheetState();
}

class _CreateFromExpensesSheetState extends ConsumerState<CreateFromExpensesSheet> {
  late int _sourceYear;
  late int _sourceMonth;
  final Set<String> _selectedCategoryIds = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, double> _baseSpentMap = {};
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Default source month to the month immediately preceding targetMonth
    if (widget.targetMonth == 1) {
      _sourceYear = widget.targetYear - 1;
      _sourceMonth = 12;
    } else {
      _sourceYear = widget.targetYear;
      _sourceMonth = widget.targetMonth - 1;
    }
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _applyBuffer(double multiplier, {bool roundTo500 = false}) {
    setState(() {
      for (final catId in _selectedCategoryIds) {
        final spent = _baseSpentMap[catId] ?? 0.0;
        double newAmt = spent * multiplier;
        if (roundTo500) {
          newAmt = (newAmt / 500).ceil() * 500.0;
          if (newAmt == 0 && spent > 0) newAmt = 500.0;
        }
        final formatted = newAmt.truncateToDouble() == newAmt ? newAmt.toInt().toString() : newAmt.toStringAsFixed(0);
        _controllers[catId]?.text = formatted;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider('expense'));
    final sourceTransactionsAsync = ref.watch(
      monthlyTransactionsProvider((year: _sourceYear, month: _sourceMonth)),
    );

    final categories = categoriesAsync.value ?? [];
    final sourceTransactions = sourceTransactionsAsync.value ?? [];

    // Compute spent per category in source month
    for (final cat in categories) {
      final spent = sourceTransactions
          .where((t) => t.categoryId == cat.id && t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      _baseSpentMap[cat.id] = spent;

      if (!_controllers.containsKey(cat.id)) {
        final formatted = spent > 0
            ? (spent.truncateToDouble() == spent ? spent.toInt().toString() : spent.toStringAsFixed(0))
            : '0';
        _controllers[cat.id] = TextEditingController(text: formatted);
      }
    }

    // Auto-select categories that had expenses on initial load
    if (!_initialized && categories.isNotEmpty) {
      for (final cat in categories) {
        final spent = _baseSpentMap[cat.id] ?? 0.0;
        if (spent > 0) {
          _selectedCategoryIds.add(cat.id);
        }
      }
      // If none had expenses, select all by default
      if (_selectedCategoryIds.isEmpty) {
        _selectedCategoryIds.addAll(categories.map((c) => c.id));
      }
      _initialized = true;
    }

    final sourceMonthName = DateFormat('MMMM yyyy').format(DateTime(_sourceYear, _sourceMonth));
    final targetMonthName = DateFormat('MMMM yyyy').format(DateTime(widget.targetYear, widget.targetMonth));

    // Sort categories: categories with expenses first
    final sortedCategories = [...categories]..sort((a, b) {
        final spentA = _baseSpentMap[a.id] ?? 0.0;
        final spentB = _baseSpentMap[b.id] ?? 0.0;
        return spentB.compareTo(spentA);
      });

    // Calculate total pool for selected items
    double totalCalculatedPool = 0.0;
    for (final catId in _selectedCategoryIds) {
      final amt = double.tryParse(_controllers[catId]?.text.trim() ?? '') ?? 0.0;
      totalCalculatedPool += amt;
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with Source Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calculate_outlined, color: AppColors.secondary, size: 22),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-Budget from Expenses',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Based on $sourceMonthName → $targetMonthName',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Quick Preset Adjustments Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.cardColor.withValues(alpha: 0.4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Buffer: ', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const Gap(6),
                    _buildBufferChip('100% (Exact)', () => _applyBuffer(1.0)),
                    const Gap(6),
                    _buildBufferChip('+5%', () => _applyBuffer(1.05)),
                    const Gap(6),
                    _buildBufferChip('+10%', () => _applyBuffer(1.10)),
                    const Gap(6),
                    _buildBufferChip('+20%', () => _applyBuffer(1.20)),
                    const Gap(6),
                    _buildBufferChip('Round 500', () => _applyBuffer(1.0, roundTo500: true)),
                  ],
                ),
              ),
            ),

            // Selection controls & Summary Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _selectedCategoryIds.length == categories.length && categories.isNotEmpty,
                        tristate: _selectedCategoryIds.isNotEmpty && _selectedCategoryIds.length < categories.length,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            if (_selectedCategoryIds.length == categories.length) {
                              _selectedCategoryIds.clear();
                            } else {
                              _selectedCategoryIds.addAll(categories.map((c) => c.id));
                            }
                          });
                        },
                      ),
                      Text(
                        '${_selectedCategoryIds.length} of ${categories.length} Headers Selected',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    'Pool: ${CurrencyFormatter.format(totalCalculatedPool)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),

            // Category Selection List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: sortedCategories.length,
                itemBuilder: (context, index) {
                  final cat = sortedCategories[index];
                  final isSelected = _selectedCategoryIds.contains(cat.id);
                  final spent = _baseSpentMap[cat.id] ?? 0.0;
                  final color = Color(cat.colorValue);
                  final ctrl = _controllers[cat.id]!;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? theme.cardColor : theme.cardColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedCategoryIds.add(cat.id);
                                } else {
                                  _selectedCategoryIds.remove(cat.id);
                                }
                              });
                            },
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: color.withValues(alpha: 0.15),
                            child: Icon(
                              IconHelper.getIcon(cat.iconCode),
                              size: 16,
                              color: color,
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected ? null : Colors.grey,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  'Last Month Spent: ${CurrencyFormatter.format(spent)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: spent > 0 ? AppColors.expenseLight : Colors.grey,
                                    fontWeight: spent > 0 ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(8),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: ctrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              enabled: isSelected,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? null : Colors.grey,
                              ),
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                prefixStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _selectedCategoryIds.isEmpty || _isSaving
                          ? null
                          : () async {
                              setState(() => _isSaving = true);
                              try {
                                final items = <({
                                  String categoryId,
                                  int year,
                                  int month,
                                  double allocatedAmount,
                                  bool rolloverEnabled
                                })>[];

                                for (final catId in _selectedCategoryIds) {
                                  final amt = double.tryParse(_controllers[catId]?.text.trim() ?? '') ?? 0.0;
                                  if (amt > 0) {
                                    items.add((
                                      categoryId: catId,
                                      year: widget.targetYear,
                                      month: widget.targetMonth,
                                      allocatedAmount: amt,
                                      rolloverEnabled: false,
                                    ));
                                  }
                                }

                                if (items.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please specify a budget amount > 0')),
                                  );
                                  return;
                                }

                                await ref.read(databaseProvider).setOrUpdateBudgetsBatch(items);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Created ${items.length} budgets for $targetMonthName from past spending!',
                                      ),
                                      backgroundColor: AppColors.income,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to save budgets: $e'),
                                      backgroundColor: AppColors.expense,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isSaving = false);
                              }
                            },
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isSaving
                            ? 'Creating...'
                            : 'Set ${_selectedCategoryIds.length} Budgets',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBufferChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      onPressed: onTap,
    );
  }
}
