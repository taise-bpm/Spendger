import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';

class ActiveBudgetsCard extends ConsumerWidget {
  const ActiveBudgetsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final budgetsAsync = ref.watch(monthlyBudgetsProvider((year: now.year, month: now.month)));
    final transactionsAsync = ref.watch(monthlyTransactionsProvider((year: now.year, month: now.month)));
    final categoriesAsync = ref.watch(categoriesStreamProvider('expense'));

    final budgets = budgetsAsync.value ?? [];
    final transactions = transactionsAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];

    if (budgets.isEmpty) {
      return const SizedBox.shrink();
    }

    final catMap = {for (var c in categories) c.id: c};
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Monthly Budgets', style: theme.textTheme.titleLarge),
                Text(
                  '${budgets.length} set',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryLight),
                ),
              ],
            ),
            const Gap(16),
            ...budgets.take(3).map((budget) {
              final cat = catMap[budget.categoryId];
              final double spent = transactions
                  .where((t) => t.categoryId == budget.categoryId && t.type == 'expense')
                  .fold(0.0, (sum, t) => sum + t.amount);

              final double ratio = budget.allocatedAmount > 0 ? (spent / budget.allocatedAmount) : 0.0;
              Color progressColor = AppColors.budgetSafe;
              if (ratio >= 1.0) {
                progressColor = AppColors.budgetBreached;
              } else if (ratio >= 0.75) {
                progressColor = AppColors.budgetWarning;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (cat != null)
                              Icon(
                                IconHelper.getIcon(cat.iconCode),
                                size: 16,
                                color: Color(cat.colorValue),
                              ),
                            const Gap(6),
                            Text(
                              cat?.name ?? 'Category',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(budget.allocatedAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Gap(6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        backgroundColor: progressColor.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
