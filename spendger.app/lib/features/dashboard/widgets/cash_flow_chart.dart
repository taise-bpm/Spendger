import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class CashFlowChart extends ConsumerStatefulWidget {
  const CashFlowChart({super.key});

  @override
  ConsumerState<CashFlowChart> createState() => _CashFlowChartState();
}

class _CashFlowChartState extends ConsumerState<CashFlowChart> {
  bool _isYearly = false;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedYear = DateTime.now().year;

  void _previousPeriod() {
    setState(() {
      if (_isYearly) {
        _selectedYear--;
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_isYearly) {
        _selectedYear++;
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      }
    });
  }

  void _resetToCurrent() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month);
      _selectedYear = now.year;
    });
  }

  bool _isInvestmentTransaction(Transaction tx, Map<String, Category> catMap) {
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
    return isInvestmentTag || isInvestmentCat;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentPeriod = _isYearly
        ? _selectedYear == now.year
        : (_selectedDate.year == now.year && _selectedDate.month == now.month);

    final categoriesAsync = ref.watch(categoriesStreamProvider(null));
    final categories = categoriesAsync.value ?? [];
    final catMap = {for (var c in categories) c.id: c};

    final theme = Theme.of(context);

    if (_isYearly) {
      final yearlyTxAsync = ref.watch(yearlyTransactionsProvider(_selectedYear));
      final transactions = yearlyTxAsync.value ?? [];
      return _buildYearlyCard(context, theme, transactions, catMap, isCurrentPeriod);
    } else {
      final monthlyTxAsync = ref.watch(
        monthlyTransactionsProvider((year: _selectedDate.year, month: _selectedDate.month)),
      );
      final budgetsAsync = ref.watch(
        monthlyBudgetsProvider((year: _selectedDate.year, month: _selectedDate.month)),
      );
      final transactions = monthlyTxAsync.value ?? [];
      final budgets = budgetsAsync.value ?? [];
      return _buildMonthlyCard(context, theme, transactions, budgets, catMap, isCurrentPeriod);
    }
  }

  Widget _buildMonthlyCard(
    BuildContext context,
    ThemeData theme,
    List<Transaction> transactions,
    List<Budget> budgets,
    Map<String, Category> catMap,
    bool isCurrentPeriod,
  ) {
    double totalIncome = 0.0;
    double totalLivingExpense = 0.0;
    double totalInvested = 0.0;

    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        if (_isInvestmentTransaction(tx, catMap)) {
          totalInvested += tx.amount;
        } else {
          totalLivingExpense += tx.amount;
        }
      }
    }

    final double totalBudget = budgets.fold(0.0, (sum, b) => sum + b.allocatedAmount);
    final double totalOutflow = totalLivingExpense + totalInvested;
    final double netSavings = totalIncome - totalOutflow;

    final double maxVal = [totalBudget, totalIncome, totalLivingExpense, totalInvested].reduce(max);
    final double chartMaxY = maxVal > 0 ? maxVal * 1.25 : 100.0;

    final periodTitle = DateFormat('MMMM yyyy').format(_selectedDate);

    // Budget utilization metrics
    final double budgetRatio = totalBudget > 0 ? (totalLivingExpense / totalBudget) : 0.0;
    Color budgetStatusColor = AppColors.budgetSafe;
    if (budgetRatio >= 1.0) {
      budgetStatusColor = AppColors.budgetBreached;
    } else if (budgetRatio >= 0.75) {
      budgetStatusColor = AppColors.budgetWarning;
    }

    return Card(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 150) {
              _previousPeriod();
            } else if (details.primaryVelocity! < -150) {
              _nextPeriod();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Mode Toggle & Navigation
              _buildHeader(periodTitle, isCurrentPeriod, netSavings, theme),
              const Gap(14),

              // Four Flow Indicators: Budget, Income, Expense, Invested
              Row(
                children: [
                  Expanded(
                    child: _buildFlowIndicator(
                      label: 'Budget',
                      amount: totalBudget,
                      color: AppColors.transfer,
                      icon: Icons.track_changes,
                    ),
                  ),
                  const Gap(6),
                  Expanded(
                    child: _buildFlowIndicator(
                      label: 'Income',
                      amount: totalIncome,
                      color: AppColors.income,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const Gap(6),
                  Expanded(
                    child: _buildFlowIndicator(
                      label: 'Expense',
                      amount: totalLivingExpense,
                      color: AppColors.expense,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                  const Gap(6),
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
              const Gap(16),

              // 4-Bar Chart: Budget, Income, Expense, Invested
              SizedBox(
                height: 135,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartMaxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label = switch (group.x) {
                            0 => 'Budget Pool',
                            1 => 'Total Income',
                            2 => 'Living Expenses',
                            3 => 'Invested Capital',
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
                              0 => 'Budget',
                              1 => 'Income',
                              2 => 'Expense',
                              3 => 'Invested',
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
                            toY: totalBudget,
                            color: AppColors.transfer,
                            width: 18,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: totalIncome,
                            color: AppColors.income,
                            width: 18,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: totalLivingExpense,
                            color: AppColors.expense,
                            width: 18,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: totalInvested,
                            color: AppColors.investment,
                            width: 18,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Budget Progress Bar
              if (totalBudget > 0) ...[
                const Gap(14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: budgetStatusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: budgetStatusColor.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.track_changes, size: 14, color: budgetStatusColor),
                              const Gap(6),
                              Text(
                                '${(budgetRatio * 100).toStringAsFixed(1)}% Budget Used',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: budgetStatusColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${CurrencyFormatter.format(totalLivingExpense)} / ${CurrencyFormatter.format(totalBudget)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Gap(6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: budgetRatio.clamp(0.0, 1.0),
                          backgroundColor: budgetStatusColor.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(budgetStatusColor),
                          minHeight: 6,
                        ),
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            budgetRatio >= 1.0
                                ? 'Over budget by ${CurrencyFormatter.format(totalLivingExpense - totalBudget)}'
                                : '${CurrencyFormatter.format(totalBudget - totalLivingExpense)} remaining',
                            style: TextStyle(
                              fontSize: 10,
                              color: budgetStatusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${budgets.length} categories budgeted',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearlyCard(
    BuildContext context,
    ThemeData theme,
    List<Transaction> transactions,
    Map<String, Category> catMap,
    bool isCurrentPeriod,
  ) {
    double totalIncome = 0.0;
    double totalLivingExpense = 0.0;
    double totalInvested = 0.0;

    final Map<int, ({double income, double expense, double invested})> monthlyData = {
      for (int m = 1; m <= 12; m++) m: (income: 0.0, expense: 0.0, invested: 0.0)
    };

    for (final tx in transactions) {
      final m = tx.transactionDate.month;
      final current = monthlyData[m]!;
      if (tx.type == 'income') {
        totalIncome += tx.amount;
        monthlyData[m] = (income: current.income + tx.amount, expense: current.expense, invested: current.invested);
      } else if (tx.type == 'expense') {
        if (_isInvestmentTransaction(tx, catMap)) {
          totalInvested += tx.amount;
          monthlyData[m] = (income: current.income, expense: current.expense, invested: current.invested + tx.amount);
        } else {
          totalLivingExpense += tx.amount;
          monthlyData[m] = (income: current.income, expense: current.expense + tx.amount, invested: current.invested);
        }
      }
    }

    final double totalOutflow = totalLivingExpense + totalInvested;
    final double netSavings = totalIncome - totalOutflow;

    double maxMonthVal = 0.0;
    for (final data in monthlyData.values) {
      maxMonthVal = max(maxMonthVal, max(data.income, data.expense + data.invested));
    }
    final double chartMaxY = maxMonthVal > 0 ? maxMonthVal * 1.25 : 100.0;

    final periodTitle = 'Year $_selectedYear';

    return Card(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 150) {
              _previousPeriod();
            } else if (details.primaryVelocity! < -150) {
              _nextPeriod();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Mode Toggle & Navigation
              _buildHeader(periodTitle, isCurrentPeriod, netSavings, theme),
              const Gap(14),

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
              const Gap(16),

              // 12-Month Bar Chart
              SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: chartMaxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final monthName = DateFormat('MMM').format(DateTime(2026, group.x + 1));
                          final mData = monthlyData[group.x + 1]!;
                          final isInc = rodIndex == 0;
                          final type = isInc ? 'Income' : 'Outflow';
                          final val = isInc ? mData.income : (mData.expense + mData.invested);
                          return BarTooltipItem(
                            '$monthName $type: ${CurrencyFormatter.format(val)}\n(Exp: ${CurrencyFormatter.formatCompact(mData.expense)}, Inv: ${CurrencyFormatter.formatCompact(mData.invested)})',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            final monthIndex = value.toInt();
                            if (monthIndex < 0 || monthIndex > 11) return const SizedBox.shrink();
                            final monthLabel = DateFormat('MMM').format(DateTime(2026, monthIndex + 1));
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                monthLabel.substring(0, 1),
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
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
                    barGroups: List.generate(12, (index) {
                      final m = index + 1;
                      final data = monthlyData[m]!;
                      final outflow = data.expense + data.invested;
                      return BarChartGroupData(
                        x: index,
                        barsSpace: 2,
                        barRods: [
                          BarChartRodData(
                            toY: data.income,
                            color: AppColors.income,
                            width: 6,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                          BarChartRodData(
                            toY: outflow,
                            color: AppColors.expense,
                            width: 6,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String periodTitle, bool isCurrentPeriod, double netSavings, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode switch + Net Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Segmented Switcher (Monthly / Yearly)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSegmentButton('Monthly', !_isYearly, () {
                    if (_isYearly) setState(() => _isYearly = false);
                  }),
                  _buildSegmentButton('Yearly', _isYearly, () {
                    if (!_isYearly) setState(() => _isYearly = true);
                  }),
                ],
              ),
            ),
            // Net Savings Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (netSavings >= 0 ? AppColors.income : AppColors.expense).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (netSavings >= 0 ? AppColors.income : AppColors.expense).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Net: ${CurrencyFormatter.format(netSavings)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: netSavings >= 0 ? AppColors.incomeLight : AppColors.expenseLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const Gap(10),

        // Period Navigator ( < Month/Year > + Today button)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: _previousPeriod,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkSurfaceElevated,
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: const Icon(Icons.chevron_left, size: 18),
                  ),
                ),
                const Gap(8),
                Text(
                  periodTitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Gap(8),
                InkWell(
                  onTap: _nextPeriod,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkSurfaceElevated,
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: const Icon(Icons.chevron_right, size: 18),
                  ),
                ),
              ],
            ),
            if (!isCurrentPeriod)
              InkWell(
                onTap: _resetToCurrent,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restore, size: 12, color: AppColors.primaryLight),
                      const Gap(4),
                      Text(
                        _isYearly ? 'This Year' : 'This Month',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentButton(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey,
          ),
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

