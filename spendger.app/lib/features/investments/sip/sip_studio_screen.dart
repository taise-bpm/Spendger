import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';
import '../widgets/add_sip_dialog.dart';
import '../widgets/record_installment_dialog.dart';
import '../widgets/record_investment_transaction_dialog.dart';

class SipStudioScreen extends ConsumerWidget {
  final Investment sipInvestment;

  const SipStudioScreen({super.key, required this.sipInvestment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allInvestmentsAsync = ref.watch(investmentsStreamProvider(null));
    final currentInv = allInvestmentsAsync.value?.firstWhere(
          (i) => i.id == sipInvestment.id,
          orElse: () => sipInvestment,
        ) ??
        sipInvestment;

    final transactionsAsync = ref.watch(investmentTransactionsStreamProvider(currentInv.id));
    final linkedTransactions = transactionsAsync.value ?? [];

    final monthlyAmount = currentInv.totalCommittedAmount ?? 0.0;
    final schedule = FinancialMath.generateSipSchedule(
      monthlyAmount: monthlyAmount,
      startDate: currentInv.startDate,
      monthsCount: 12,
    );

    int paidPeriods = 0;
    double totalDebitedSoFar = 0.0;

    for (final item in schedule) {
      final tx = _findTransactionForPeriod(linkedTransactions, currentInv.id, item.periodNumber);
      if (tx != null) {
        paidPeriods++;
        totalDebitedSoFar += tx.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentInv.name} Studio', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit SIP / Valuation',
            onPressed: () {
              showDialog(context: context, builder: (_) => AddSipDialog(investmentToEdit: currentInv));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // 1. SIP Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E7490), Color(0xFF164E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sip.withValues(alpha: 0.25),
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
                        color: AppColors.sip.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Monthly SIP: ${CurrencyFormatter.format(monthlyAmount)}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.trending_up, color: Colors.white, size: 20),
                  ],
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total SIPs Debited', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalDebitedSoFar),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Current Portfolio Valuation', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(currentInv.currentValuation),
                          style: const TextStyle(color: AppColors.incomeLight, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$paidPeriods / 12 Months Logged', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    InkWell(
                      onTap: () => showDialog(context: context, builder: (_) => AddSipDialog(investmentToEdit: currentInv)),
                      child: const Text('Update Valuation ✎', style: TextStyle(fontSize: 11, color: AppColors.incomeLight, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),

          // 2. Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sip,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => RecordInvestmentTransactionDialog(
                        preselectedInvestment: currentInv,
                        defaultTxType: 'sip_debit',
                      ),
                    );
                  },
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Log Monthly SIP Debit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                      builder: (_) => RecordInvestmentTransactionDialog(
                        preselectedInvestment: currentInv,
                        defaultTxType: 'dividend',
                      ),
                    );
                  },
                  icon: const Icon(Icons.card_giftcard, size: 18),
                  label: const Text('Log Dividend / Gain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          const Gap(20),

          // 3. Monthly SIP Installments Schedule
          Text('Monthly SIP Amortization Schedule', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                                    child: const Text('DEBITED', style: TextStyle(fontSize: 10, color: AppColors.incomeLight, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const Gap(4),
                            Text(
                              'Cumulative: ${CurrencyFormatter.format(item.cumulativeInvested)}',
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isPaid ? AppColors.incomeLight : AppColors.sip),
                          ),
                          Text(isPaid ? 'Recorded' : 'Tap to Debit', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
