import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class CashFlowChart extends ConsumerWidget {
  const CashFlowChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final txAsync = ref.watch(monthlyTransactionsProvider((year: now.year, month: now.month)));
    final categoriesAsync = ref.watch(categoriesStreamProvider(null));

    final transactions = txAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];
    final catMap = {for (var c in categories) c.id: c};

    double totalIncome = 0.0;
    double totalLivingExpense = 0.0;
    double totalInvested = 0.0;

    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        final isInvestmentTag = tx.tag != null && tx.tag!.startsWith('INV:');
        final catName = catMap[tx.categoryId]?.name.toLowerCase() ?? '';
        final isInvestmentCat = catName.contains('investment') ||
            catName.contains('sip') ||
            catName.contains('gold') ||
            catName.contains('chitty') ||
            catName.contains('chit') ||
            catName.contains('fixed deposit') ||
            catName.contains('ppf') ||
            catName.contains('provident fund') ||
            catName.contains('mutual fund') ||
            catName.contains('stock') ||
            catName.contains('shares');

        if (isInvestmentTag || isInvestmentCat) {
          totalInvested += tx.amount;
        } else {
          totalLivingExpense += tx.amount;
        }
      }
    }

    final theme = Theme.of(context);
    final double totalOutflow = totalLivingExpense + totalInvested;
    final double netSavings = totalIncome - totalOutflow;

    final double maxVal = [totalIncome, totalLivingExpense, totalInvested].reduce(max);
    final double chartMaxY = maxVal > 0 ? maxVal * 1.25 : 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Cashflow',
                  style: theme.textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (netSavings >= 0 ? AppColors.income : AppColors.expense).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Net: ${CurrencyFormatter.format(netSavings)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: netSavings >= 0 ? AppColors.incomeLight : AppColors.expenseLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Three Flow Indicators: Income, Expense, Invested
            Row(
              children: [
                Expanded(
                  child: _buildFlowIndicator(
                    label: 'Income',
                    amount: totalIncome,
                    color: AppColors.income,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildFlowIndicator(
                    label: 'Expenses',
                    amount: totalLivingExpense,
                    color: AppColors.expense,
                    icon: Icons.arrow_upward,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildFlowIndicator(
                    label: 'Invested',
                    amount: totalInvested,
                    color: AppColors.investment,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            const Gap(20),

            // 3-Bar Chart
            SizedBox(
              height: 130,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = switch (group.x) {
                          0 => 'Income',
                          1 => 'Living Expenses',
                          2 => 'Invested',
                          _ => 'Amount',
                        };
                        return BarTooltipItem(
                          '$label\n${CurrencyFormatter.format(rod.toY)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final text = switch (value.toInt()) {
                            0 => 'Income',
                            1 => 'Expense',
                            2 => 'Invested',
                            _ => '',
                          };
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              text,
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalIncome,
                          color: AppColors.income,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalLivingExpense,
                          color: AppColors.expense,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: totalInvested,
                          color: AppColors.investment,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowIndicator({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, size: 12, color: color),
          ),
          const Gap(6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
