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
import 'widgets/post_rd_interest_dialog.dart';

class RdStudioScreen extends ConsumerWidget {
  final Investment rdInvestment;

  const RdStudioScreen({super.key, required this.rdInvestment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    final double rate = _parseDouble(notesData['rate'], 7.0);
    final int tenureMonths = _parseInt(notesData['tenureMonths'], 12);
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

    // Filter interest transactions
    final interestTransactions = linkedTransactions
        .where((t) => t.type == 'income' || (t.tag != null && t.tag!.contains('rd_interest')))
        .toList();
    final double totalInterestCredited = interestTransactions.fold(0.0, (sum, t) => sum + t.amount);

    // Current Passbook Valuation = Total Installments Paid + Total Marked Interest
    final double currentPassbookValuation = totalPaidAmount + totalInterestCredited;
    final double totalTargetInvested = monthlyDeposit * tenureMonths;
    final double progress = totalTargetInvested > 0 ? (totalPaidAmount / totalTargetInvested).clamp(0.0, 1.0) : 0.0;

    // Projected Maturity
    final targetMaturity = FinancialMath.calculateRdMaturity(
      monthlyDeposit: monthlyDeposit,
      annualInterestRate: rate,
      tenureMonths: tenureMonths,
    ).maturityAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isClosed ? '${currentInv.name} Archive' : '${currentInv.name} Studio',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isClosed) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit RD Details',
              onPressed: () {
                showDialog(context: context, builder: (_) => AddRdDialog(investmentToEdit: currentInv));
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              tooltip: 'Delete Archived RD Account',
              onPressed: () => _confirmDeleteArchivedRd(context, ref, currentInv),
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // 1. RD Overview Header Card
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
                      child: Text(
                        'Quarterly Compounding ($rate% p.a.)',
                        style: const TextStyle(color: AppColors.rd, fontSize: 11, fontWeight: FontWeight.bold),
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
                const Gap(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isClosed ? 'Final Settled Value' : 'Current Passbook Valuation',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(currentPassbookValuation),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Target Maturity Value', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(targetMaturity),
                          style: const TextStyle(color: AppColors.rd, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(12),
                Container(height: 1, color: Colors.white12),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Principal Deposited', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalPaidAmount),
                          style: const TextStyle(color: AppColors.primaryLight, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Interest Credited', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        const Gap(2),
                        Text(
                          '+${CurrencyFormatter.format(totalInterestCredited)}',
                          style: const TextStyle(color: AppColors.incomeLight, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Monthly Deposit', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(monthlyDeposit),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
                    Text('$paidPeriods / $tenureMonths Months Deposited', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                    Text('${(progress * 100).toStringAsFixed(0)}% Completed', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),

          // 2. Action Buttons (Post Interest & Mature RD)
          if (!isClosed) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rd,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => PostRdInterestDialog(
                          rdInvestment: currentInv,
                          currentTotalDeposited: totalPaidAmount,
                        ),
                      );
                    },
                    icon: const Icon(Icons.savings_outlined, size: 18),
                    label: const Text('Post Interest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CloseOrMatureDialog(investment: currentInv),
                      );
                    },
                    icon: const Icon(Icons.account_balance, size: 18),
                    label: const Text('Mature / Close RD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const Gap(16),
          ],

          // 3. Interest Credits History (if any)
          if (interestTransactions.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Posted Interest Credits', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('+${CurrencyFormatter.format(totalInterestCredited)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.incomeLight, fontSize: 12)),
              ],
            ),
            const Gap(8),
            ...interestTransactions.map((tx) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.income.withValues(alpha: 0.15),
                        child: const Icon(Icons.trending_up, size: 14, color: AppColors.incomeLight),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.notes ?? 'Quarterly Interest Credited',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(tx.transactionDate),
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+${CurrencyFormatter.format(tx.amount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.incomeLight),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Gap(12),
          ],

          // 4. Month-by-Month Amortization Schedule
          Text(
            isClosed ? 'Monthly Deposit History (Archived)' : 'Monthly Deposit Amortization Schedule',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          ...schedule.map((item) {
            final existingTx = _findTransactionForPeriod(linkedTransactions, currentInv.id, item.periodNumber);
            final isPaid = existingTx != null;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isPaid
                      ? AppColors.income.withValues(alpha: isDark ? 0.3 : 0.2)
                      : (isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: isClosed
                    ? null
                    : () {
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
                          Text(
                            isClosed ? (isPaid ? 'Paid' : 'Unpaid') : (isPaid ? 'Recorded' : 'Tap to Pay'),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
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

  Future<void> _confirmDeleteArchivedRd(BuildContext context, WidgetRef ref, Investment currentInv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.expense, size: 24),
            Gap(8),
            Expanded(
              child: Text(
                'Delete Archived RD Account?',
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
              'All installments, interest entries, statement records, and transaction history linked to this Recurring Deposit account will be permanently deleted. This action cannot be undone.',
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

  double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? fallback;
  }

  int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? fallback;
  }
}
