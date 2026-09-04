import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';

class RecreateBudgetSheet extends ConsumerStatefulWidget {
  final int sourceYear;
  final int sourceMonth;
  final List<Budget> sourceBudgets;
  final int targetYear;
  final int targetMonth;

  const RecreateBudgetSheet({
    super.key,
    required this.sourceYear,
    required this.sourceMonth,
    required this.sourceBudgets,
    required this.targetYear,
    required this.targetMonth,
  });

  @override
  ConsumerState<RecreateBudgetSheet> createState() => _RecreateBudgetSheetState();
}

class _RecreateBudgetSheetState extends ConsumerState<RecreateBudgetSheet> {
  bool _carryUnspentSurplus = true;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider('expense'));
    final sourceTransactionsAsync = ref.watch(
      monthlyTransactionsProvider((year: widget.sourceYear, month: widget.sourceMonth)),
    );

    final categories = categoriesAsync.value ?? [];
    final catMap = {for (var c in categories) c.id: c};
    final sourceTransactions = sourceTransactionsAsync.value ?? [];

    final sourceMonthName = DateFormat('MMMM yyyy').format(DateTime(widget.sourceYear, widget.sourceMonth));
    final targetMonthName = DateFormat('MMMM yyyy').format(DateTime(widget.targetYear, widget.targetMonth));

    // Calculate preview items
    double totalBaseBudget = 0.0;
    double totalCalculatedBudget = 0.0;
    double totalUnspentSurplus = 0.0;

    final previewList = widget.sourceBudgets.map((sb) {
      final cat = catMap[sb.categoryId];
      final spent = sourceTransactions
          .where((t) => t.categoryId == sb.categoryId && t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      final unspent = sb.allocatedAmount - spent;
      final surplus = unspent > 0 ? unspent : 0.0;

      final calculatedAmount = _carryUnspentSurplus ? (sb.allocatedAmount + surplus) : sb.allocatedAmount;

      totalBaseBudget += sb.allocatedAmount;
      totalCalculatedBudget += calculatedAmount;
      totalUnspentSurplus += surplus;

      return (
        budget: sb,
        category: cat,
        spent: spent,
        unspent: unspent,
        surplus: surplus,
        targetAmount: calculatedAmount,
      );
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_mode_rounded, color: AppColors.primaryLight, size: 22),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recreate Budgets',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Copy from $sourceMonthName → $targetMonthName',
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

            // Rollover Option Switch Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.savings_outlined, size: 16, color: AppColors.incomeLight),
                            const Gap(6),
                            Text(
                              'Carry Unspent Surplus',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          _carryUnspentSurplus
                              ? 'Unspent balances from $sourceMonthName (${CurrencyFormatter.format(totalUnspentSurplus)}) will be added to $targetMonthName limits.'
                              : 'Exact base budget limits from $sourceMonthName will be copied without carryover.',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _carryUnspentSurplus,
                    activeTrackColor: AppColors.incomeLight,
                    onChanged: (val) {
                      setState(() => _carryUnspentSurplus = val);
                    },
                  ),
                ],
              ),
            ),

            // Summary Totals
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${previewList.length} Categories (Base: ${CurrencyFormatter.format(totalBaseBudget)})',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Target: ${CurrencyFormatter.format(totalCalculatedBudget)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),
            const Gap(6),

            // Categories Preview List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: previewList.length,
                itemBuilder: (context, index) {
                  final item = previewList[index];
                  final cat = item.category;
                  final color = cat != null ? Color(cat.colorValue) : Colors.grey;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: color.withValues(alpha: 0.15),
                            child: Icon(
                              cat != null ? IconHelper.getIcon(cat.iconCode) : Icons.category,
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
                                  cat?.name ?? 'Category',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const Gap(2),
                                Text(
                                  'Base: ${CurrencyFormatter.format(item.budget.allocatedAmount)} • Spent: ${CurrencyFormatter.format(item.spent)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(item.targetAmount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              if (_carryUnspentSurplus && item.surplus > 0)
                                Text(
                                  '+${CurrencyFormatter.format(item.surplus)} surplus',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.incomeLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
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
                      onPressed: _isSaving
                          ? null
                          : () async {
                              setState(() => _isSaving = true);
                              try {
                                await ref.read(databaseProvider).copyOrRecreateBudgets(
                                      fromYear: widget.sourceYear,
                                      fromMonth: widget.sourceMonth,
                                      toYear: widget.targetYear,
                                      toMonth: widget.targetMonth,
                                      carryUnspentSurplus: _carryUnspentSurplus,
                                    );

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Recreated budgets for $targetMonthName successfully!',
                                      ),
                                      backgroundColor: AppColors.income,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to copy budgets: $e'),
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
                            ? 'Recreating...'
                            : 'Recreate for $targetMonthName',
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
}
