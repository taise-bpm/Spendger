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
    final transactions = txAsync.value ?? [];

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
      }
    }

    final theme = Theme.of(context);
    final double netSavings = totalIncome - totalExpense;

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
                const Gap(12),
                Expanded(
                  child: _buildFlowIndicator(
                    label: 'Expenses',
                    amount: totalExpense,
                    color: AppColors.expense,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const Gap(20),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.25 == 0
                      ? 100
                      : (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.25,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = rodIndex == 0 ? 'Income' : 'Expense';
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
                          return Text(
                            value.toInt() == 0 ? 'In' : 'Out',
                            style: theme.textTheme.bodySmall,
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
                          width: 32,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: totalExpense,
                          color: AppColors.expense,
                          width: 32,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, size: 14, color: color),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
