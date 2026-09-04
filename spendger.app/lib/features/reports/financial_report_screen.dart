import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'widgets/category_breakdown_card.dart';
import 'widgets/category_transactions_sheet.dart';

class FinancialReportScreen extends ConsumerStatefulWidget {
  final bool initialIsYearly;
  final DateTime? initialDate;
  final int? initialYear;

  const FinancialReportScreen({
    super.key,
    this.initialIsYearly = false,
    this.initialDate,
    this.initialYear,
  });

  @override
  ConsumerState<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends ConsumerState<FinancialReportScreen> {
  late bool _isYearly;
  late DateTime _selectedDate;
  late int _selectedYear;
  String _reportType = 'expense'; // 'expense', 'income', 'overview'
  String _sortOrder = 'amount_desc'; // 'amount_desc', 'amount_asc', 'count_desc', 'name_asc'
  int? _touchedPieIndex;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _isYearly = widget.initialIsYearly;
    _selectedDate = widget.initialDate ?? DateTime(now.year, now.month);
    _selectedYear = widget.initialYear ?? now.year;
  }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final iconColor = theme.colorScheme.onSurface;

    final now = DateTime.now();
    final isCurrentPeriod = _isYearly
        ? _selectedYear == now.year
        : (_selectedDate.year == now.year && _selectedDate.month == now.month);

    final categoriesAsync = ref.watch(categoriesStreamProvider(null));
    final categories = categoriesAsync.value ?? [];
    final catMap = {for (var c in categories) c.id: c};

    final List<Transaction> transactions;
    if (_isYearly) {
      final yearlyTxAsync = ref.watch(yearlyTransactionsProvider(_selectedYear));
      transactions = yearlyTxAsync.value ?? [];
    } else {
      final monthlyTxAsync = ref.watch(
        monthlyTransactionsProvider((year: _selectedDate.year, month: _selectedDate.month)),
      );
      transactions = monthlyTxAsync.value ?? [];
    }

    final periodTitle = _isYearly
        ? 'Year $_selectedYear'
        : DateFormat('MMMM yyyy').format(_selectedDate);

    // Totals calculations
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

    final double totalOutflow = totalLivingExpense + totalInvested;
    final double netSavings = totalIncome - totalOutflow;
    final double savingsRate = totalIncome > 0 ? (netSavings / totalIncome * 100) : 0.0;

    // Days in period for averages
    final int daysInPeriod = _isYearly ? 365 : DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final double dailyAvgSpend = totalOutflow / daysInPeriod;

    // Filter and group by category
    final targetType = _reportType == 'income' ? 'income' : 'expense';
    final targetTransactions = transactions.where((t) => t.type == targetType).toList();

    final Map<String, List<Transaction>> categoryTxMap = {};
    for (final tx in targetTransactions) {
      categoryTxMap.putIfAbsent(tx.categoryId, () => []).add(tx);
    }

    // Category breakdown models
    final breakdownList = <({Category category, double total, int count, List<Transaction> txs})>[];
    for (final entry in categoryTxMap.entries) {
      final cat = catMap[entry.key];
      if (cat != null) {
        final sum = entry.value.fold<double>(0.0, (acc, t) => acc + t.amount);
        breakdownList.add((
          category: cat,
          total: sum,
          count: entry.value.length,
          txs: entry.value,
        ));
      }
    }

    // Sort according to _sortOrder (Descending by default)
    breakdownList.sort((a, b) {
      switch (_sortOrder) {
        case 'amount_desc':
          return b.total.compareTo(a.total);
        case 'amount_asc':
          return a.total.compareTo(b.total);
        case 'count_desc':
          return b.count.compareTo(a.count);
        case 'name_asc':
          return a.category.name.compareTo(b.category.name);
        default:
          return b.total.compareTo(a.total);
      }
    });

    final currentTotalForType = targetType == 'income' ? totalIncome : totalLivingExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GestureDetector(
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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Period Navigator & Switcher Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Monthly / Yearly Switcher
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPeriodSegment('Monthly', !_isYearly, () {
                              if (_isYearly) setState(() => _isYearly = false);
                            }, isDark),
                            _buildPeriodSegment('Yearly', _isYearly, () {
                              if (!_isYearly) setState(() => _isYearly = true);
                            }, isDark),
                          ],
                        ),
                      ),
                      // Restore Button
                      if (!isCurrentPeriod)
                        InkWell(
                          onTap: _resetToCurrent,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(10),

                  // Period Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _previousPeriod,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: surfaceColor,
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(Icons.chevron_left, size: 20, color: iconColor),
                        ),
                      ),
                      Text(
                        periodTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: _nextPeriod,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: surfaceColor,
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(Icons.chevron_right, size: 20, color: iconColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(14),

            // KPI Flow Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cash Flow Summary', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (netSavings >= 0 ? AppColors.income : AppColors.expense).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Savings: ${savingsRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: netSavings >= 0 ? AppColors.incomeLight : AppColors.expenseLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Income',
                          amount: totalIncome,
                          color: AppColors.income,
                          icon: Icons.arrow_downward,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Expenses',
                          amount: totalLivingExpense,
                          color: AppColors.expense,
                          icon: Icons.arrow_upward,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Invested',
                          amount: totalInvested,
                          color: AppColors.investment,
                          icon: Icons.trending_up,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _buildMetricItem(
                          label: 'Net Savings',
                          amount: netSavings,
                          color: netSavings >= 0 ? AppColors.incomeLight : AppColors.expenseLight,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isYearly ? 'Monthly Avg Spend:' : 'Daily Avg Spend:',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        CurrencyFormatter.format(_isYearly ? totalOutflow / 12 : dailyAvgSpend),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(14),

            // Tab Selector: Expenses vs Income vs Overview
            Row(
              children: [
                Expanded(
                  child: _buildTypeSegment(
                    label: 'Expenses',
                    count: targetType == 'expense' ? breakdownList.length : null,
                    isSelected: _reportType == 'expense',
                    color: AppColors.expense,
                    onTap: () => setState(() => _reportType = 'expense'),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildTypeSegment(
                    label: 'Income',
                    count: targetType == 'income' ? breakdownList.length : null,
                    isSelected: _reportType == 'income',
                    color: AppColors.income,
                    onTap: () => setState(() => _reportType = 'income'),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: _buildTypeSegment(
                    label: 'Overview',
                    isSelected: _reportType == 'overview',
                    color: AppColors.primary,
                    onTap: () => setState(() => _reportType = 'overview'),
                  ),
                ),
              ],
            ),
            const Gap(14),

            // Section Content
            if (_reportType == 'overview') ...[
              _buildOverviewCard(theme, totalIncome, totalLivingExpense, totalInvested, netSavings),
            ] else ...[
              // Pie / Donut Chart Card (if has data)
              if (breakdownList.isNotEmpty)
                _buildDonutChartCard(theme, breakdownList, currentTotalForType, targetType),
              const Gap(12),

              // Sorting and Analytics Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Header Breakdown (${breakdownList.length})',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Sort Breakdown',
                    initialValue: _sortOrder,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) => setState(() => _sortOrder = val),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'amount_desc',
                        child: Row(
                          children: [
                            Icon(Icons.trending_down, size: 18),
                            Gap(8),
                            Text('Highest Amount (Desc)'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'amount_asc',
                        child: Row(
                          children: [
                            Icon(Icons.trending_up, size: 18),
                            Gap(8),
                            Text('Lowest Amount (Asc)'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'count_desc',
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long, size: 18),
                            Gap(8),
                            Text('Most Active (Count)'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'name_asc',
                        child: Row(
                          children: [
                            Icon(Icons.sort_by_alpha, size: 18),
                            Gap(8),
                            Text('Category Name (A-Z)'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort, size: 14, color: iconColor),
                          const Gap(4),
                          Text(
                            _getSortLabel(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: iconColor),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),

              // Category Breakdown List
              if (breakdownList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                      const Gap(12),
                      Text(
                        'No $targetType records for $periodTitle',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...breakdownList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return CategoryBreakdownCard(
                    rank: index + 1,
                    category: item.category,
                    totalAmount: item.total,
                    overallTotal: currentTotalForType,
                    transactionCount: item.count,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CategoryTransactionsSheet(
                          category: item.category,
                          transactions: item.txs,
                          periodTitle: periodTitle,
                        ),
                      );
                    },
                  );
                }),
            ],
            const Gap(24),
          ],
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortOrder) {
      case 'amount_desc':
        return 'Highest Spend';
      case 'amount_asc':
        return 'Lowest Spend';
      case 'count_desc':
        return 'Most Active';
      case 'name_asc':
        return 'Name (A-Z)';
      default:
        return 'Sorted';
    }
  }

  Widget _buildPeriodSegment(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.grey : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSegment({
    required String label,
    int? count,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.18) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : null,
              ),
            ),
            if (count != null) ...[
              const Gap(2),
              Text(
                '$count headers',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? color.withValues(alpha: 0.8) : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const Gap(4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Gap(4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(
    ThemeData theme,
    List<({Category category, double total, int count, List<Transaction> txs})> list,
    double overallTotal,
    String targetType,
  ) {
    final topList = list.take(6).toList();
    final otherTotal = list.skip(6).fold<double>(0.0, (acc, item) => acc + item.total);

    final List<PieChartSectionData> sections = [];
    for (int i = 0; i < topList.length; i++) {
      final item = topList[i];
      final isTouched = _touchedPieIndex == i;
      final radius = isTouched ? 48.0 : 40.0;
      final color = Color(item.category.colorValue);

      sections.add(
        PieChartSectionData(
          color: color,
          value: item.total,
          title: '${(item.total / overallTotal * 100).toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    if (otherTotal > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: otherTotal,
          title: '${(otherTotal / overallTotal * 100).toStringAsFixed(0)}%',
          radius: 40.0,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${targetType == "expense" ? "Expense" : "Income"} Distribution',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  CurrencyFormatter.format(overallTotal),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: targetType == 'income' ? AppColors.incomeLight : AppColors.expenseLight,
                  ),
                ),
              ],
            ),
            const Gap(16),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedPieIndex = null;
                                return;
                              }
                              _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: sections,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...topList.map((item) {
                          final color = Color(item.category.colorValue);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const Gap(6),
                                Expanded(
                                  child: Text(
                                    item.category.name,
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(item.total / overallTotal * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (otherTotal > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                                ),
                                const Gap(6),
                                const Expanded(
                                  child: Text(
                                    'Other Categories',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(otherTotal / overallTotal * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                      ],
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

  Widget _buildOverviewCard(
    ThemeData theme,
    double income,
    double livingExpense,
    double invested,
    double netSavings,
  ) {
    final double totalOutflow = livingExpense + invested;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overall Financial Structure', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Gap(16),
            _buildFlowComparisonBar('Income', income, income, AppColors.income),
            const Gap(12),
            _buildFlowComparisonBar('Living Expenses', livingExpense, income > 0 ? income : livingExpense, AppColors.expense),
            const Gap(12),
            _buildFlowComparisonBar('Invested Capital', invested, income > 0 ? income : invested, AppColors.investment),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Outflows (Spend + Invest):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  CurrencyFormatter.format(totalOutflow),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Cash Surplus / Deficit:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  CurrencyFormatter.format(netSavings),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: netSavings >= 0 ? AppColors.incomeLight : AppColors.expenseLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowComparisonBar(String label, double value, double maxReference, Color color) {
    final ratio = maxReference > 0 ? (value / maxReference) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(CurrencyFormatter.format(value), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const Gap(6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
