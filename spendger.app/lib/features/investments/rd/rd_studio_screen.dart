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
import '../widgets/add_rd_dialog.dart';
import '../widgets/close_or_mature_dialog.dart';
import '../widgets/record_installment_dialog.dart';

class RdStudioScreen extends ConsumerWidget {
  final Investment rdInvestment;

  const RdStudioScreen({super.key, required this.rdInvestment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allInvestmentsAsync = ref.watch(investmentsStreamProvider(null));
    final currentInv = allInvestmentsAsync.value?.firstWhere(
          (i) => i.id == rdInvestment.id,
          orElse: () => rdInvestment,
        ) ??
        rdInvestment;

    final transactionsAsync = ref.watch(investmentTransactionsStreamProvider(currentInv.id));
    final linkedTransactions = transactionsAsync.value ?? [];

    Map<String, dynamic> notesData = {};
    if (currentInv.notes != null) {
      try {
        notesData = jsonDecode(currentInv.notes!);
      } catch (_) {}
    }

    final double rate = (notesData['rate'] as num?)?.toDouble() ?? 7.0;
    final int tenureMonths = (notesData['tenureMonths'] as num?)?.toInt() ?? 12;
    final double monthlyDeposit = currentInv.purchasePrice ?? 0.0;
    final bool isClosed = currentInv.status == 'matured' || currentInv.status == 'closed';

    final schedule = FinancialMath.generateRdSchedule(
      monthlyDeposit: monthlyDeposit,
      annualInterestRate: rate,
      tenureMonths: tenureMonths,
      startDate: currentInv.startDate,
    );

    int paidPeriods = 0;
    double totalPaidAmount = 0.0;

    for (final item in schedule) {
      final tx = _findTransactionForPeriod(linkedTransactions, currentInv.id, item.periodNumber);
      if (tx != null) {
        paidPeriods++;
        totalPaidAmount += tx.amount;
      }
    }

    final double totalTargetInvested = monthlyDeposit * tenureMonths;
    final double progress = totalTargetInvested > 0 ? (totalPaidAmount / totalTargetInvested).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentInv.name} Studio', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit RD Details',
            onPressed: () {
              showDialog(context: context, builder: (_) => AddRdDialog(investmentToEdit: currentInv));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // 1. RD Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF022C22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.rd.withValues(alpha: 0.25),
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
                        color: AppColors.rd.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Quarterly Compounding RD',
                        style: TextStyle(color: AppColors.rd, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isClosed ? AppColors.loan.withValues(alpha: 0.2) : AppColors.income.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        currentInv.status.toUpperCase(),
                        style: TextStyle(
                          color: isClosed ? AppColors.loanLight : AppColors.incomeLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Deposited So Far', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalPaidAmount),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Target Maturity Value', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(currentInv.currentValuation),
                          style: const TextStyle(color: AppColors.rd, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.rd),
                  ),
                ),
                const Gap(6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$paidPeriods / $tenureMonths Months Paid', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                    Text('${(progress * 100).toStringAsFixed(0)}% Completed', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),

          // 2. Maturity / Premature Closure Button
          if (!isClosed) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CloseOrMatureDialog(investment: currentInv),
                  );
                },
                icon: const Icon(Icons.account_balance, size: 18),
                label: const Text('Mature / Premature Close RD & Transfer Funds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const Gap(16),
          ],

          // 3. Month-by-Month Amortization Schedule
          Text('Monthly Deposit Amortization Schedule', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(8),
          ...schedule.map((item) {
            final existingTx = _findTransactionForPeriod(linkedTransactions, currentInv.id, item.periodNumber);
            final isPaid = existingTx != null;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => RecordInstallmentDialog(
                      investment: currentInv,
                      scheduleItem: item,
                      existingTransaction: existingTx,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isPaid ? AppColors.income.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                        child: isPaid
                            ? const Icon(Icons.check, size: 16, color: AppColors.incomeLight)
                            : Text('${item.periodNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${item.periodLabel} (${DateFormat('MMM yyyy').format(item.dueDate)})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (isPaid) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.income.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('PAID', style: TextStyle(fontSize: 10, color: AppColors.incomeLight, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const Gap(4),
                            Text(
                              'Cum. Invested: ${CurrencyFormatter.format(item.cumulativeInvested)}  •  Bal: ${CurrencyFormatter.format(item.projectedBalance)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(existingTx?.amount ?? item.scheduledAmount),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isPaid ? AppColors.incomeLight : AppColors.rd),
                          ),
                          Text(isPaid ? 'Recorded' : 'Tap to Pay', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Transaction? _findTransactionForPeriod(List<Transaction> transactions, String investmentId, int periodNumber) {
    final periodTag = 'INV:$investmentId:period:$periodNumber';
    for (final tx in transactions) {
      if (tx.tag != null && tx.tag!.contains(periodTag)) {
        return tx;
      }
    }
    return null;
  }
}
