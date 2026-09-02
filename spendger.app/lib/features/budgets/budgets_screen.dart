import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/icon_helper.dart';
import 'widgets/add_budget_dialog.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(monthlyBudgetsProvider((year: _currentMonth.year, month: _currentMonth.month)));
    final transactionsAsync = ref.watch(monthlyTransactionsProvider((year: _currentMonth.year, month: _currentMonth.month)));
    final categoriesAsync = ref.watch(categoriesStreamProvider('expense'));

    final budgets = budgetsAsync.value ?? [];
    final transactions = transactionsAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];

    final catMap = {for (var c in categories) c.id: c};

    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (final b in budgets) {
      totalBudget += b.allocatedAmount;
      final spent = transactions
          .where((t) => t.categoryId == b.categoryId && t.type == 'expense')
          .fold(0.0, (sum, t) => sum + t.amount);
      totalSpent += spent;
    }

    final double overallRatio = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLight, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddBudgetDialog(
                  year: _currentMonth.year,
                  month: _currentMonth.month,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),
          // Total Monthly Overview Card
          if (budgets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Budget Pool', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              CurrencyFormatter.format(totalBudget),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Spent', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              CurrencyFormatter.format(totalSpent),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: totalSpent > totalBudget ? AppColors.expenseLight : AppColors.incomeLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: overallRatio.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          overallRatio >= 1.0
                              ? AppColors.budgetBreached
                              : (overallRatio >= 0.75 ? AppColors.budgetWarning : AppColors.budgetSafe),
                        ),
                      ),
                    ),
                    const Gap(6),
                    Text(
                      '${(overallRatio * 100).toStringAsFixed(1)}% utilized • ${CurrencyFormatter.format(totalBudget - totalSpent)} remaining',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          const Gap(8),
          // Budgets List
          Expanded(
            child: budgets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline, size: 54, color: Colors.grey.withValues(alpha: 0.4)),
                        const Gap(12),
                        const Text(
                          'No budgets set for this month',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const Gap(8),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AddBudgetDialog(
                                year: _currentMonth.year,
                                month: _currentMonth.month,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Set Budget Limit'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final b = budgets[index];
                      final cat = catMap[b.categoryId];
                      final spent = transactions
                          .where((t) => t.categoryId == b.categoryId && t.type == 'expense')
                          .fold(0.0, (sum, t) => sum + t.amount);

                      final ratio = b.allocatedAmount > 0 ? (spent / b.allocatedAmount) : 0.0;
                      Color statusColor = AppColors.budgetSafe;
                      String statusText = 'On Track';
                      if (ratio >= 1.0) {
                        statusColor = AppColors.budgetBreached;
                        statusText = 'Over Budget!';
                      } else if (ratio >= 0.75) {
                        statusColor = AppColors.budgetWarning;
                        statusText = 'Warning Zone';
                      }

                      return Dismissible(
                        key: Key(b.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.expense,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref.read(databaseProvider).delete(ref.read(databaseProvider).budgets).delete(b);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Budget removed')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddBudgetDialog(
                                  year: _currentMonth.year,
                                  month: _currentMonth.month,
                                  budgetToEdit: b,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (cat != null)
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Color(cat.colorValue).withValues(alpha: 0.15),
                                          child: Icon(
                                            IconHelper.getIcon(cat.iconCode),
                                            size: 18,
                                            color: Color(cat.colorValue),
                                          ),
                                        ),
                                      const Gap(12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cat?.name ?? 'Category',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            Text(
                                              statusText,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: statusColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${CurrencyFormatter.format(spent)} / ${CurrencyFormatter.format(b.allocatedAmount)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Text(
                                            '${(ratio * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Gap(12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: ratio.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: statusColor.withValues(alpha: 0.15),
                                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_budgets',
        backgroundColor: AppColors.primary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddBudgetDialog(
              year: _currentMonth.year,
              month: _currentMonth.month,
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
