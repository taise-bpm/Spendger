import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';
import '../widgets/add_ppf_dialog.dart';
import '../widgets/close_or_mature_dialog.dart';
import 'widgets/post_ppf_interest_dialog.dart';
import 'widgets/record_ppf_deposit_dialog.dart';

class PpfStudioScreen extends ConsumerStatefulWidget {
  final Investment ppfInvestment;

  const PpfStudioScreen({super.key, required this.ppfInvestment});

  @override
  ConsumerState<PpfStudioScreen> createState() => _PpfStudioScreenState();
}

class _PpfStudioScreenState extends ConsumerState<PpfStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedFyStart;

  // Mock Simulator State
  final _mockDepositController = TextEditingController(text: '150000');
  int _mockDepositDay = 4; // 4th of month (earns interest) vs 10th
  PpfFinancialYearResult? _mockFyResult;

  @override
  void initState() {
    super.initState();
    // 3 Tabs: Tab 1: Passbook & History (Default), Tab 2: 5th-Day Rule & FY Growth, Tab 3: 15-Yr Timeline & Simulator
    _tabController = TabController(length: 3, vsync: this);

    final now = DateTime.now();
    _selectedFyStart = now.month >= 4 ? now.year : now.year - 1;

    _recalculateMockSimulation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mockDepositController.dispose();
    super.dispose();
  }

  void _recalculateMockSimulation() {
    final amount = double.tryParse(_mockDepositController.text.trim()) ?? 0.0;
    final mockDeposit = PpfDepositEntry(
      date: DateTime(_selectedFyStart, 4, _mockDepositDay),
      amount: amount,
      note: 'Mock Deposit on Day $_mockDepositDay',
    );

    setState(() {
      _mockFyResult = FinancialMath.calculatePpfFinancialYear(
        financialYearStart: _selectedFyStart,
        openingBalance: widget.ppfInvestment.currentValuation,
        deposits: [mockDeposit],
      );
    });
  }

  List<int> _generateAvailableFinancialYears(DateTime startDate) {
    final now = DateTime.now();
    final currentFyStart = now.month >= 4 ? now.year : now.year - 1;
    final inceptionFyStart = startDate.month >= 4 ? startDate.year : startDate.year - 1;

    final startYear = inceptionFyStart < currentFyStart ? inceptionFyStart : currentFyStart;
    final endYear = currentFyStart;

    final List<int> years = [];
    for (int y = startYear; y <= endYear; y++) {
      years.add(y);
    }
    return years.reversed.toList(); // Newest first
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allInvestmentsAsync = ref.watch(investmentsStreamProvider(null));
    final currentInv = allInvestmentsAsync.value?.firstWhere(
          (i) => i.id == widget.ppfInvestment.id,
          orElse: () => widget.ppfInvestment,
        ) ??
        widget.ppfInvestment;

    final transactionsAsync = ref.watch(investmentTransactionsStreamProvider(currentInv.id));
    final allTx = transactionsAsync.value ?? [];

    final availableFyYears = _generateAvailableFinancialYears(currentInv.startDate);
    if (!availableFyYears.contains(_selectedFyStart) && availableFyYears.isNotEmpty) {
      _selectedFyStart = availableFyYears.first;
    }

    // Filter deposits for the selected financial year
    final fyStartDate = DateTime(_selectedFyStart, 4, 1);
    final fyEndDate = DateTime(_selectedFyStart + 1, 3, 31, 23, 59, 59);

    final fyDepositsTx = allTx.where((t) {
      return t.type == 'expense' &&
          t.transactionDate.isAfter(fyStartDate.subtract(const Duration(seconds: 1))) &&
          t.transactionDate.isBefore(fyEndDate.add(const Duration(seconds: 1)));
    }).toList();

    final List<PpfDepositEntry> depositEntries = fyDepositsTx.map((t) {
      return PpfDepositEntry(date: t.transactionDate, amount: t.amount, note: t.notes ?? '');
    }).toList();

    Map<String, dynamic> notesData = {};
    if (currentInv.notes != null) {
      try {
        notesData = jsonDecode(currentInv.notes!);
      } catch (_) {}
    }
    final double storedOpeningBalance = double.tryParse(notesData['openingBalance']?.toString() ?? '') ?? 0.0;

    // Deposits & interest before this selected FY for accurate opening balance
    final pastDepositsTx = allTx.where((t) {
      return t.type == 'expense' && t.transactionDate.isBefore(fyStartDate);
    }).toList();
    final double totalPastDeposits = pastDepositsTx.fold(0.0, (sum, d) => sum + d.amount);

    final pastInterestTx = allTx.where((t) {
      return t.type == 'income' && t.transactionDate.isBefore(fyStartDate);
    }).toList();
    final double totalPastInterest = pastInterestTx.fold(0.0, (sum, d) => sum + d.amount);

    final double totalDepositedThisFy = depositEntries.fold(0.0, (sum, d) => sum + d.amount);
    final double openingBalanceForFy = storedOpeningBalance + totalPastDeposits + totalPastInterest;

    final fyResult = FinancialMath.calculatePpfFinancialYear(
      financialYearStart: _selectedFyStart,
      openingBalance: openingBalanceForFy,
      deposits: depositEntries,
    );

    // Lifetime statistics
    final allDepositsTx = allTx.where((t) => t.type == 'expense').toList();
    final double totalLifetimeDeposits = allDepositsTx.fold(0.0, (sum, t) => sum + t.amount);
    final allInterestTx = allTx.where((t) => t.type == 'income').toList();
    final double totalInterestCredited = allInterestTx.fold(0.0, (sum, t) => sum + t.amount);

    final isMatured = currentInv.status == 'matured' || currentInv.status == 'closed';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMatured ? '${currentInv.name} Archive' : '${currentInv.name} Studio',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: isMatured
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: AppColors.ppf,
                labelColor: AppColors.ppf,
                unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.history_edu, size: 20), text: 'Passbook & History'),
                  Tab(icon: Icon(Icons.analytics_outlined, size: 20), text: '5th-Day & FY Growth'),
                  Tab(icon: Icon(Icons.timeline, size: 20), text: '15-Yr Projections'),
                ],
              ),
        actions: [
          if (!isMatured) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.ppf, size: 26),
              tooltip: 'Add Deposit',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => RecordPpfDepositDialog(
                    ppfInvestment: currentInv,
                    currentFyDepositedTotal: totalDepositedThisFy,
                  ),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'edit') {
                  showDialog(
                    context: context,
                    builder: (_) => AddPpfDialog(investmentToEdit: currentInv),
                  );
                } else if (value == 'close') {
                  showDialog(
                    context: context,
                    builder: (_) => CloseOrMatureDialog(investment: currentInv),
                  );
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: AppColors.ppf),
                      Gap(8),
                      Text('Edit PPF Parameters'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'close',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_outlined, size: 18, color: AppColors.incomeLight),
                      Gap(8),
                      Text('Close / Mature Account'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              tooltip: 'Delete Archived PPF Account',
              onPressed: () => _confirmDeleteArchivedPpf(context, currentInv),
            ),
          ],
        ],
      ),
      body: isMatured
          ? _buildPassbookHistoryTab(
              context,
              currentInv: currentInv,
              allTx: allTx,
              totalLifetimeDeposits: totalLifetimeDeposits,
              totalInterestCredited: totalInterestCredited,
              totalDepositedThisFy: totalDepositedThisFy,
              selectedFyStart: _selectedFyStart,
              fyResult: fyResult,
              openingBalanceForFy: openingBalanceForFy,
              isDark: isDark,
              isMatured: isMatured,
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1 (Default): Passbook & Statement History with Edit/Delete & Quick Actions
                _buildPassbookHistoryTab(
                  context,
                  currentInv: currentInv,
                  allTx: allTx,
                  totalLifetimeDeposits: totalLifetimeDeposits,
                  totalInterestCredited: totalInterestCredited,
                  totalDepositedThisFy: totalDepositedThisFy,
                  selectedFyStart: _selectedFyStart,
                  fyResult: fyResult,
                  openingBalanceForFy: openingBalanceForFy,
                  isDark: isDark,
                  isMatured: isMatured,
                ),

                // TAB 2: 5th-Day Rule & FY Growth Analyzer
                _buildFyStudioTab(
                  context,
                  currentInv: currentInv,
                  availableYears: availableFyYears,
                  fyResult: fyResult,
                  depositEntries: depositEntries,
                  fyDepositsTx: fyDepositsTx,
                  totalDepositedThisFy: totalDepositedThisFy,
                  openingBalanceForFy: openingBalanceForFy,
                  isDark: isDark,
                  isMatured: isMatured,
                ),

                // TAB 3: 15-Year Timeline & Simulator
                _buildTimelineAndSimulatorTab(context, currentInv, isDark: isDark),
              ],
            ),
      floatingActionButton: isMatured
          ? null
          : FloatingActionButton.extended(
              heroTag: 'fab_ppf_deposit',
              backgroundColor: AppColors.ppf,
              foregroundColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => RecordPpfDepositDialog(
                    ppfInvestment: currentInv,
                    currentFyDepositedTotal: totalDepositedThisFy,
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: Passbook & Lifetime History (Default Tab)
  // -------------------------------------------------------------
  Widget _buildPassbookHistoryTab(
    BuildContext context, {
    required Investment currentInv,
    required List<Transaction> allTx,
    required double totalLifetimeDeposits,
    required double totalInterestCredited,
    required double totalDepositedThisFy,
    required int selectedFyStart,
    required PpfFinancialYearResult fyResult,
    required double openingBalanceForFy,
    required bool isDark,
    required bool isMatured,
  }) {
    final theme = Theme.of(context);

    // Group transactions by financial year
    final Map<int, List<Transaction>> txByFy = {};
    for (final tx in allTx) {
      final txDate = tx.transactionDate;
      final fy = txDate.month >= 4 ? txDate.year : txDate.year - 1;
      txByFy.putIfAbsent(fy, () => []).add(tx);
    }

    final sortedFys = txByFy.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      children: [
        if (isMatured) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.amber.shade900.withValues(alpha: 0.25) : Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.amber.shade700 : Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, color: isDark ? Colors.amber.shade300 : Colors.amber.shade900, size: 22),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matured & Closed Account (Read-Only Archive)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'This PPF has been closed & settled into your bank account. Historical passbook records are locked to maintain tax and statement audit integrity.',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(14),
        ],

        // 1. Lifetime Passbook Summary Card (Gradient Card)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3A2E), Color(0xFF0B192C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.ppf.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isMatured ? Icons.lock_clock : Icons.account_balance_outlined, size: 12, color: Colors.white),
                          const Gap(4),
                          Flexible(
                            child: Text(
                              isMatured ? 'PPF (CLOSED ARCHIVE)' : 'PPF OFFICIAL PASSBOOK',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Started: ${DateFormat('dd MMM yyyy').format(currentInv.startDate)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              const Gap(12),
              Text(isMatured ? 'Final Settled Valuation' : 'Current Passbook Valuation', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const Gap(2),
              Text(
                CurrencyFormatter.format(isMatured && totalLifetimeDeposits > 0 ? (totalLifetimeDeposits + totalInterestCredited) : currentInv.currentValuation),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const Gap(14),
              Container(height: 1, color: Colors.white12),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Deposited', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const Gap(2),
                      Text(
                        CurrencyFormatter.format(totalLifetimeDeposits > 0 ? totalLifetimeDeposits : currentInv.currentValuation),
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Interest Credited', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const Gap(2),
                      Text(
                        '+${CurrencyFormatter.format(totalInterestCredited)}',
                        style: const TextStyle(color: AppColors.incomeLight, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Entries', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const Gap(2),
                      Text(
                        '${allTx.length} Entries',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(14),

        // 2. Quick Action Buttons (Only for active accounts)
        if (!isMatured) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ppf,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => RecordPpfDepositDialog(
                        ppfInvestment: currentInv,
                        currentFyDepositedTotal: totalDepositedThisFy,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Deposit', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const Gap(10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ppf,
                    side: const BorderSide(color: AppColors.ppf),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => PostPpfInterestDialog(
                        ppfInvestment: currentInv,
                        initialFinancialYearStart: selectedFyStart,
                        allTransactions: allTx,
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('Post Interest', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const Gap(16),
        ],

        // Passbook Edit Guidance Note
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app_outlined, size: 16, color: isDark ? AppColors.primaryLight : AppColors.primary),
              const Gap(8),
              Expanded(
                child: Text(
                  'Tap any passbook entry below to edit amount, date, or source account.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(14),

        // 3. Statement List Grouped by Financial Year
        if (allTx.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                const Gap(12),
                Text(
                  'No passbook entries recorded yet',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(4),
                Text(
                  'Record deposits or interest credits to generate your official statement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12),
                ),
                const Gap(14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.ppf, foregroundColor: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => RecordPpfDepositDialog(
                        ppfInvestment: currentInv,
                        currentFyDepositedTotal: 0.0,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Record First Deposit'),
                ),
              ],
            ),
          )
        else
          ...sortedFys.map((fy) {
            final txList = txByFy[fy]!;
            final double fyDepositsTotal = txList.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);
            final double fyInterestTotal = txList.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: AppColors.ppf),
                          const Gap(6),
                          Text(
                            'FY $fy-${(fy + 1) % 100}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (fyDepositsTotal > 0)
                            Text(
                              'Dep: ${CurrencyFormatter.format(fyDepositsTotal)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                              ),
                            ),
                          if (fyInterestTotal > 0) ...[
                            const Gap(8),
                            Text(
                              '+${CurrencyFormatter.format(fyInterestTotal)} Int',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.incomeLight : Colors.green.shade800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                ...txList.map((tx) => _buildPassbookEntryTile(context, tx, currentInv, totalDepositedThisFy, isDark, isMatured: isMatured)),
                const Gap(8),
              ],
            );
          }),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 2: 5th-Day Rule & FY Growth Analyzer
  // -------------------------------------------------------------
  Widget _buildFyStudioTab(
    BuildContext context, {
    required Investment currentInv,
    required List<int> availableYears,
    required PpfFinancialYearResult fyResult,
    required List<PpfDepositEntry> depositEntries,
    required List<Transaction> fyDepositsTx,
    required double totalDepositedThisFy,
    required double openingBalanceForFy,
    required bool isDark,
    required bool isMatured,
  }) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentFyStart = now.month >= 4 ? now.year : now.year - 1;
    final isCurrentFy = _selectedFyStart == currentFyStart;
    final isBefore5th = now.day <= 5;
    final daysTo5th = isBefore5th ? (5 - now.day) : 0;
    final double remainingFyLimit = (150000.0 - totalDepositedThisFy).clamp(0.0, 150000.0);
    final double fyProgress = (totalDepositedThisFy / 150000.0).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      children: [
        // 1. Financial Year Selector Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 22),
                tooltip: 'Previous Financial Year',
                onPressed: availableYears.isNotEmpty && _selectedFyStart > availableYears.last
                    ? () {
                        setState(() {
                          _selectedFyStart--;
                          _recalculateMockSimulation();
                        });
                      }
                    : null,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedFyStart,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.ppf),
                  dropdownColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                  items: availableYears.map((year) {
                    final label = 'FY $year-${(year + 1) % 100}';
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Row(
                        children: [
                          const Icon(Icons.event_note, size: 16, color: AppColors.ppf),
                          const Gap(6),
                          Text(
                            year == currentFyStart ? '$label (Active FY)' : label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: year == currentFyStart ? (isDark ? AppColors.incomeLight : Colors.green.shade800) : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (year) {
                    if (year != null) {
                      setState(() {
                        _selectedFyStart = year;
                        _recalculateMockSimulation();
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 22),
                tooltip: 'Next Financial Year',
                onPressed: _selectedFyStart < currentFyStart
                    ? () {
                        setState(() {
                          _selectedFyStart++;
                          _recalculateMockSimulation();
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),
        const Gap(14),

        // 2. Financial Year ₹1.5L Limit & Overview Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.ppf.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.ppf.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'FY $_selectedFyStart-${(_selectedFyStart + 1) % 100}',
                      style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: AppColors.incomeLight),
                      Gap(4),
                      Text('100% Tax-Free (EEE)', style: TextStyle(color: AppColors.incomeLight, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PPF Current Corpus', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const Gap(2),
                      Text(
                        CurrencyFormatter.format(currentInv.currentValuation),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Deposited in FY $_selectedFyStart', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      const Gap(2),
                      Text(
                        CurrencyFormatter.format(totalDepositedThisFy),
                        style: const TextStyle(color: AppColors.primaryLight, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: fyProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                ),
              ),
              const Gap(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Limit: ₹1.5L (₹${remainingFyLimit.toStringAsFixed(0)} room)', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  Text(
                    totalDepositedThisFy < 500 ? 'Min ₹500 required' : 'Active FY Compliant',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: totalDepositedThisFy < 500 ? AppColors.expenseLight : AppColors.incomeLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(14),

        // 3. Clear Visual Explainer: "How the PPF 5th-Day Rule Works"
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.ppf.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lightbulb_outline, color: AppColors.ppf, size: 20),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Understanding the 5th-Day Rule',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'How Government rules calculate monthly interest',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(12),
              _buildRuleStep(
                stepNumber: '1',
                title: 'Lowest Balance Rule',
                description: 'Interest is calculated monthly on the lowest balance between the 5th and the last day of every month.',
                isDark: isDark,
              ),
              const Gap(8),
              _buildRuleStep(
                stepNumber: '2',
                title: 'Deposit by 5th = Earns This Month',
                description: 'If you deposit on or before the 5th day, that money counts in this month\'s interest.',
                isDark: isDark,
                isHighlight: true,
              ),
              const Gap(8),
              _buildRuleStep(
                stepNumber: '3',
                title: 'Deposit after 5th = Earns Next Month',
                description: 'Deposits made after the 5th do not earn interest for the ongoing month; interest starts from the 1st of next month.',
                isDark: isDark,
              ),
              const Gap(8),
              _buildRuleStep(
                stepNumber: '4',
                title: 'Annual March 31 Compounding',
                description: 'Monthly interest accrues every month, but is officially compounded & credited on 31st March.',
                isDark: isDark,
              ),
              if (isCurrentFy) ...[
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isBefore5th
                        ? (isDark ? AppColors.income.withValues(alpha: 0.15) : Colors.green.shade50)
                        : (isDark ? AppColors.loan.withValues(alpha: 0.12) : Colors.amber.shade50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBefore5th
                          ? (isDark ? AppColors.income.withValues(alpha: 0.3) : Colors.green.shade200)
                          : (isDark ? AppColors.loan.withValues(alpha: 0.25) : Colors.amber.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isBefore5th ? Icons.alarm_on : Icons.calendar_today,
                        color: isBefore5th ? (isDark ? AppColors.incomeLight : Colors.green.shade800) : (isDark ? AppColors.loanLight : Colors.brown.shade800),
                        size: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          isBefore5th
                              ? 'Action: Deposit before 5th ${DateFormat('MMMM').format(now)} ($daysTo5th days left) to earn interest for this month!'
                              : 'Tip: For maximum return, plan your next deposit before 5th ${DateFormat('MMMM').format(DateTime(now.year, now.month + 1, 1))}.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isBefore5th
                                ? (isDark ? AppColors.incomeLight : Colors.green.shade900)
                                : (isDark ? AppColors.loanLight : Colors.brown.shade900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const Gap(16),

        // 4. Month-by-Month 5th-Day Rule Interest Table
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('FY Monthly Breakdown', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              'Total Accrued: +${CurrencyFormatter.format(fyResult.totalInterestEarnedInFY)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDark ? AppColors.incomeLight : Colors.green.shade800,
              ),
            ),
          ],
        ),
        const Gap(8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              ...fyResult.monthlyBreakdowns.map((m) {
                final hasEarly = m.depositsOnOrBefore5th > 0;
                final hasLate = m.depositsAfter5th > 0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? AppColors.darkCardBorder.withValues(alpha: 0.5) : Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('${m.monthName} ${m.calendarYear}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const Gap(6),
                                if (hasEarly)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.income.withValues(alpha: 0.2) : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '+${CurrencyFormatter.format(m.depositsOnOrBefore5th)} (≤5th)',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isDark ? AppColors.incomeLight : Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (hasLate) ...[
                                  const Gap(4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.loan.withValues(alpha: 0.2) : Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '+${CurrencyFormatter.format(m.depositsAfter5th)} (>5th)',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isDark ? AppColors.loanLight : Colors.brown.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const Gap(2),
                            Text(
                              'Qualifying Lowest Bal: ${CurrencyFormatter.format(m.eligibleLowestBalance)}',
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${CurrencyFormatter.format(m.monthlyInterestEarned)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? AppColors.incomeLight : Colors.green.shade800,
                            ),
                          ),
                          Text('Accrued', style: TextStyle(fontSize: 9, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleStep({
    required String stepNumber,
    required String title,
    required String description,
    required bool isDark,
    bool isHighlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isHighlight
              ? AppColors.ppf
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          child: Text(
            stepNumber,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isHighlight ? AppColors.ppf : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const Gap(1),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // Passbook Entry Tile (with Tap to Edit & Delete Actions)
  // -------------------------------------------------------------
  Widget _buildPassbookEntryTile(
    BuildContext context,
    Transaction tx,
    Investment currentInv,
    double totalDepositedThisFy,
    bool isDark, {
    bool isMatured = false,
  }) {
    final isInterest = tx.type == 'income';
    final isEarly = tx.transactionDate.day <= 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isMatured) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This PPF is matured & closed. Statement records are preserved in read-only mode.'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            // Open edit dialog on tap
            _openEditDialog(context, tx, currentInv, totalDepositedThisFy);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isInterest
                    ? (isDark ? AppColors.incomeLight.withValues(alpha: 0.2) : Colors.green.shade100)
                    : (isEarly
                        ? (isDark ? AppColors.income.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.12))
                        : (isDark ? AppColors.loan.withValues(alpha: 0.15) : Colors.amber.shade100)),
                child: Icon(
                  isInterest ? Icons.star : (isEarly ? Icons.check_circle_outline : Icons.schedule),
                  color: isInterest
                      ? (isDark ? AppColors.incomeLight : Colors.green.shade800)
                      : (isEarly ? (isDark ? AppColors.incomeLight : Colors.green.shade800) : (isDark ? AppColors.loanLight : Colors.brown.shade800)),
                  size: 18,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isInterest ? '+${CurrencyFormatter.format(tx.amount)} Interest' : CurrencyFormatter.format(tx.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isInterest ? (isDark ? AppColors.incomeLight : Colors.green.shade800) : null,
                          ),
                        ),
                        const Gap(6),
                        if (!isInterest)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isEarly
                                  ? (isDark ? AppColors.income.withValues(alpha: 0.2) : Colors.green.shade100)
                                  : (isDark ? AppColors.loan.withValues(alpha: 0.2) : Colors.amber.shade100),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isEarly ? '≤ 5th Eligible' : '> 5th Late',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isEarly
                                    ? (isDark ? AppColors.incomeLight : Colors.green.shade800)
                                    : (isDark ? AppColors.loanLight : Colors.brown.shade800),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(2),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(tx.transactionDate)}${tx.notes != null && tx.notes!.isNotEmpty ? " • ${tx.notes}" : ""}',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isMatured)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.ppf),
                  tooltip: 'Edit Entry',
                  onPressed: () => _openEditDialog(context, tx, currentInv, totalDepositedThisFy),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade500),
                  tooltip: 'Delete Entry',
                  onPressed: () => _confirmDeleteEntry(context, tx),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openEditDialog(BuildContext context, Transaction tx, Investment currentInv, double totalDepositedThisFy) {
    if (tx.type == 'income') {
      final fy = tx.transactionDate.month >= 4 ? tx.transactionDate.year : tx.transactionDate.year - 1;
      showDialog(
        context: context,
        builder: (_) => PostPpfInterestDialog(
          ppfInvestment: currentInv,
          initialFinancialYearStart: fy,
          allTransactions: ref.read(investmentTransactionsStreamProvider(currentInv.id)).value ?? [],
          existingTransaction: tx,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => RecordPpfDepositDialog(
          ppfInvestment: currentInv,
          currentFyDepositedTotal: totalDepositedThisFy,
          existingTransaction: tx,
        ),
      );
    }
  }

  Future<void> _confirmDeleteEntry(BuildContext context, Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Passbook Entry?'),
        content: const Text('This entry will be deleted and any linked bank account balance or PPF valuation will be reverted.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(databaseProvider).deleteTransactionWithAccountUpdate(tx.id);
    }
  }

  // -------------------------------------------------------------
  // TAB 3: 15-Year Timeline & Simulator
  // -------------------------------------------------------------
  Widget _buildTimelineAndSimulatorTab(BuildContext context, Investment currentInv, {required bool isDark}) {
    final theme = Theme.of(context);

    Map<String, dynamic> notesData = {};
    if (currentInv.notes != null) {
      try {
        notesData = jsonDecode(currentInv.notes!);
      } catch (_) {}
    }

    final double annualRate = double.tryParse(notesData['rate']?.toString() ?? '') ?? 7.1;
    final int tenureYears = int.tryParse(notesData['tenureYears']?.toString() ?? '') ?? 15;
    final double yearlyDeposit = currentInv.purchasePrice ?? 150000.0;

    final schedule = FinancialMath.generatePpfSchedule(
      yearlyDeposit: yearlyDeposit,
      annualInterestRate: annualRate > 0 ? annualRate : 7.1,
      tenureYears: tenureYears,
      startDate: currentInv.startDate,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
      children: [
        // 1. Interactive 5th-Day Rule Mock Simulator
        Text('5th-Day Rule Timing Simulator', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const Gap(4),
        Text(
          'Compare how depositing on Day 4 vs Day 10 affects your annual compounded return.',
          style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        const Gap(10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mockDepositController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculateMockSimulation(),
                      decoration: const InputDecoration(
                        labelText: 'Mock Deposit (₹)',
                        hintText: '150000',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _mockDepositDay,
                      isExpanded: true,
                      dropdownColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                      decoration: const InputDecoration(labelText: 'Deposit Timing'),
                      items: const [
                        DropdownMenuItem(value: 4, child: Text('Day 4 (≤ 5th Rule)')),
                        DropdownMenuItem(value: 10, child: Text('Day 10 (> 5th Rule)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _mockDepositDay = val;
                          });
                          _recalculateMockSimulation();
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_mockFyResult != null) ...[
                const Gap(14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Simulated Annual Interest:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                            '+${CurrencyFormatter.format(_mockFyResult!.totalInterestEarnedInFY)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.incomeLight : Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Year-End Closing Corpus:', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                          Text(
                            CurrencyFormatter.format(_mockFyResult!.closingBalanceMarch31),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ppf),
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
        const Gap(20),

        // 2. 15-Year Maturity Schedule
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15-Year PPF Growth Timeline', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('${schedule.length} Years', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          ],
        ),
        const Gap(8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              ...schedule.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? AppColors.darkCardBorder.withValues(alpha: 0.5) : Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.periodLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const Gap(2),
                          Text(
                            'Deposited: ${CurrencyFormatter.format(item.scheduledAmount)} • Total: ${CurrencyFormatter.format(item.cumulativeInvested)}',
                            style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(item.projectedBalance),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ppf),
                          ),
                          Text(
                            '+${CurrencyFormatter.format(item.interestAccrued)} Interest',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? AppColors.incomeLight : Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteArchivedPpf(BuildContext context, Investment currentInv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.expense, size: 24),
            Gap(8),
            Expanded(
              child: Text(
                'Delete Archived Account?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You will lose every data associated to "${currentInv.name}".',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'All passbook entries, statement records, and transaction history linked to this PPF account will be permanently deleted. This action cannot be undone.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.deleteInvestment(currentInv.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentInv.name} and all associated records have been deleted.'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }
}
