import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';
import 'widgets/post_ppf_interest_dialog.dart';
import 'widgets/record_ppf_deposit_dialog.dart';

class PpfStudioScreen extends ConsumerStatefulWidget {
  final Investment ppfInvestment;

  const PpfStudioScreen({super.key, required this.ppfInvestment});

  @override
  ConsumerState<PpfStudioScreen> createState() => _PpfStudioScreenState();
}

class _PpfStudioScreenState extends ConsumerState<PpfStudioScreen> {
  final int _selectedFyStart = DateTime.now().month >= 4 ? DateTime.now().year : DateTime.now().year - 1;

  // Mock Simulator Controller
  final _mockDepositController = TextEditingController(text: '150000');
  int _mockDepositDay = 4; // 4th of month (earns interest) vs 10th
  PpfFinancialYearResult? _mockFyResult;

  @override
  void initState() {
    super.initState();
    _recalculateMockSimulation();
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final allInvestmentsAsync = ref.watch(investmentsStreamProvider(null));
    final currentInv = allInvestmentsAsync.value?.firstWhere(
          (i) => i.id == widget.ppfInvestment.id,
          orElse: () => widget.ppfInvestment,
        ) ??
        widget.ppfInvestment;

    final transactionsAsync = ref.watch(investmentTransactionsStreamProvider(currentInv.id));
    final allTx = transactionsAsync.value ?? [];

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

    // Opening balance at start of this FY (valuation before these deposits)
    final double totalDepositedThisFy = depositEntries.fold(0.0, (sum, d) => sum + d.amount);
    final double openingBalanceForFy = (currentInv.currentValuation - totalDepositedThisFy).clamp(0.0, double.infinity);

    final fyResult = FinancialMath.calculatePpfFinancialYear(
      financialYearStart: _selectedFyStart,
      openingBalance: openingBalanceForFy,
      deposits: depositEntries,
    );

    final now = DateTime.now();
    final isBefore5th = now.day <= 5;
    final daysTo5th = isBefore5th ? (5 - now.day) : 0;
    final double remainingFyLimit = (150000.0 - totalDepositedThisFy).clamp(0.0, 150000.0);
    final double fyProgress = (totalDepositedThisFy / 150000.0).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentInv.name} Studio', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.ppf, size: 28),
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
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // 1. Current Financial Year Overview Card
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
                        const Text('Total PPF Corpus Value', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(currentInv.currentValuation),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Deposited this FY', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalDepositedThisFy),
                          style: const TextStyle(color: AppColors.ppf, fontSize: 16, fontWeight: FontWeight.bold),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.ppf),
                  ),
                ),
                const Gap(6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Limit: ₹1.5L (₹${(remainingFyLimit).toStringAsFixed(0)} room)', style: const TextStyle(fontSize: 10, color: Colors.white60)),
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

          // 2. The 5th-Day Rule Reminder & Strategy Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isBefore5th ? AppColors.income.withValues(alpha: 0.15) : AppColors.loan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isBefore5th ? AppColors.income.withValues(alpha: 0.3) : AppColors.loan.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isBefore5th ? Icons.alarm_on : Icons.calendar_today,
                  color: isBefore5th ? AppColors.incomeLight : AppColors.loanLight,
                  size: 24,
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBefore5th
                            ? '5th-Day Rule Reminder ($daysTo5th days left this month)'
                            : '5th-Day Rule Insight',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isBefore5th ? AppColors.incomeLight : AppColors.loanLight,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        isBefore5th
                            ? 'Deposit before ${DateFormat('dd MMM').format(DateTime(now.year, now.month, 5))} to earn interest for the entire month of ${DateFormat('MMMM').format(now)}!'
                            : 'Deposits after the 5th start earning interest from the 1st of next month. Plan your next deposit before the 5th of ${DateFormat('MMMM').format(DateTime(now.year, now.month + 1, 1))}.',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ppf,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => PostPpfInterestDialog(
                        ppfInvestment: currentInv,
                        financialYearStart: _selectedFyStart,
                        calculatedInterest: fyResult.totalInterestEarnedInFY,
                        openingBalance: openingBalanceForFy,
                        totalDepositedThisFy: totalDepositedThisFy,
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('Post Passbook Interest', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const Gap(20),

          // 3. Month-by-Month 5th-Day Rule Interest Table
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly 5th-Day Interest Accrual', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                'Calculated: +${CurrencyFormatter.format(fyResult.totalInterestEarnedInFY)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.incomeLight),
              ),
            ],
          ),
          const Gap(8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkCardBorder),
            ),
            child: Column(
              children: [
                ...fyResult.monthlyBreakdowns.map((m) {
                  final hasDeposits = m.depositsOnOrBefore5th > 0 || m.depositsAfter5th > 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.darkCardBorder.withValues(alpha: 0.5))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('${m.monthName} ${m.calendarYear}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                if (hasDeposits) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.ppf.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '+${CurrencyFormatter.format(m.depositsOnOrBefore5th + m.depositsAfter5th)}',
                                      style: const TextStyle(fontSize: 9, color: AppColors.ppf, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const Gap(2),
                            Text(
                              'Eligible Lowest Bal: ${CurrencyFormatter.format(m.eligibleLowestBalance)}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${CurrencyFormatter.format(m.monthlyInterestEarned)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.incomeLight),
                            ),
                            const Text('Accrued', style: TextStyle(fontSize: 9, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const Gap(20),

          // 4. Interactive 5th-Day Rule Mock Simulator
          Text('5th-Day Rule Mock Simulator', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(4),
          const Text('Test different deposit timing (e.g. 4th Apr vs 10th Apr) to see the interest difference!', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const Gap(10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkCardBorder),
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
                          labelText: 'Mock Deposit Amount (₹)',
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
                        decoration: const InputDecoration(labelText: 'Deposit Day'),
                        items: const [
                          DropdownMenuItem(value: 4, child: Text('Day 4 (Before 5th)')),
                          DropdownMenuItem(value: 10, child: Text('Day 10 (After 5th)')),
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
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Simulated Annual Interest:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(
                        '+${CurrencyFormatter.format(_mockFyResult!.totalInterestEarnedInFY)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.incomeLight),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Year-End Closing Corpus:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        CurrencyFormatter.format(_mockFyResult!.closingBalanceMarch31),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ppf),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Gap(20),

          // 5. Logged Deposit Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Deposit History ($totalDepositedThisFy)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text('${depositEntries.length} Deposits', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Gap(8),
          if (depositEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: const Text('No deposits recorded for this FY yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          else
            ...fyDepositsTx.map((tx) {
              final isEarly = tx.transactionDate.day <= 5;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isEarly ? AppColors.income.withValues(alpha: 0.15) : AppColors.loan.withValues(alpha: 0.15),
                    child: Icon(
                      isEarly ? Icons.check : Icons.schedule,
                      color: isEarly ? AppColors.incomeLight : AppColors.loanLight,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    CurrencyFormatter.format(tx.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${DateFormat('dd MMM yyyy').format(tx.transactionDate)} • ${isEarly ? "Interest from ${DateFormat('MMM').format(tx.transactionDate)}" : "Interest from next month"}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Deposit?'),
                          content: const Text('The deposit will be deleted and the source account balance reverted.'),
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
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
