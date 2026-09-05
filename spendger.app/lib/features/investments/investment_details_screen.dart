import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/financial_math.dart';
import 'widgets/add_chitty_dialog.dart';
import 'widgets/add_fd_dialog.dart';
import 'widgets/add_gold_dialog.dart';
import 'widgets/add_ppf_dialog.dart';
import 'widgets/add_rd_dialog.dart';
import 'widgets/add_sip_dialog.dart';
import 'widgets/record_dividend_dialog.dart';
import 'widgets/record_installment_dialog.dart';

class InvestmentDetailsScreen extends ConsumerWidget {
  final Investment investment;

  const InvestmentDetailsScreen({super.key, required this.investment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allInvestmentsAsync = ref.watch(investmentsStreamProvider(null));
    final currentInv = allInvestmentsAsync.value?.firstWhere((i) => i.id == investment.id, orElse: () => investment) ?? investment;

    final transactionsAsync = ref.watch(investmentTransactionsStreamProvider(currentInv.id));
    final linkedTransactions = transactionsAsync.value ?? [];

    final chittyInstallmentsAsync = currentInv.type == 'chitty'
        ? ref.watch(chittyInstallmentsStreamProvider(currentInv.id))
        : const AsyncValue.data(<ChittyInstallment>[]);
    final chittyInstallments = chittyInstallmentsAsync.value ?? [];

    Map<String, dynamic> notesData = {};
    if (currentInv.notes != null) {
      try {
        notesData = jsonDecode(currentInv.notes!);
      } catch (_) {}
    }

    final double annualRate = double.tryParse(notesData['rate']?.toString() ?? '') ?? 0.0;
    final int tenureMonths = int.tryParse(notesData['tenureMonths']?.toString() ?? '') ?? 12;
    final int tenureYears = int.tryParse(notesData['tenureYears']?.toString() ?? '') ?? 15;
    final int compounding = int.tryParse(notesData['compounding']?.toString() ?? '') ?? 4;

    // Generate schedule based on investment type
    final List<InvestmentScheduleItem> schedule = switch (currentInv.type) {
      'rd' => FinancialMath.generateRdSchedule(
          monthlyDeposit: currentInv.purchasePrice ?? 0.0,
          annualInterestRate: annualRate,
          tenureMonths: tenureMonths,
          startDate: currentInv.startDate,
        ),
      'ppf' => FinancialMath.generatePpfSchedule(
          yearlyDeposit: currentInv.purchasePrice ?? 0.0,
          annualInterestRate: annualRate > 0 ? annualRate : 7.1,
          tenureYears: tenureYears,
          startDate: currentInv.startDate,
        ),
      'sip' => FinancialMath.generateSipSchedule(
          monthlyAmount: currentInv.totalCommittedAmount ?? 0.0,
          startDate: currentInv.startDate,
          monthsCount: 12,
        ),
      'fd' => FinancialMath.generateFdSchedule(
          principal: currentInv.purchasePrice ?? 0.0,
          annualInterestRate: annualRate,
          tenureYears: double.tryParse(notesData['tenureYears']?.toString() ?? '') ?? 1.0,
          compoundingFrequency: compounding,
          startDate: currentInv.startDate,
        ),
      _ => [],
    };

    // Calculate progress and paid metrics
    int paidPeriods = 0;
    double totalPaidAmount = 0.0;

    if (currentInv.type == 'chitty') {
      paidPeriods = chittyInstallments.where((c) => c.isPaid).length;
      totalPaidAmount = chittyInstallments.where((c) => c.isPaid).fold(0.0, (sum, c) => sum + c.netAmountPaid);
    } else {
      for (final item in schedule) {
        final tx = _findTransactionForPeriod(linkedTransactions, currentInv.id, item.periodNumber);
        if (tx != null) {
          paidPeriods++;
          totalPaidAmount += tx.amount;
        }
      }
    }

    final double totalTargetAmount = currentInv.totalCommittedAmount ?? currentInv.currentValuation;
    final double progress = totalTargetAmount > 0 ? (totalPaidAmount / totalTargetAmount).clamp(0.0, 1.0) : 0.0;

    final theme = Theme.of(context);
    final themeColor = _getColorForType(currentInv.type);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentInv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) => _handleMenuAction(context, ref, currentInv, val),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    Gap(8),
                    Text('Edit Investment Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.expenseLight, size: 18),
                    Gap(8),
                    Text('Delete Investment', style: TextStyle(color: AppColors.expenseLight)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Growth & Progress Card
          Card(
            color: themeColor.withValues(alpha: 0.12),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Deposited So Far', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            CurrencyFormatter.format(totalPaidAmount > 0 ? totalPaidAmount : (currentInv.purchasePrice ?? 0.0)),
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: themeColor),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Target / Maturity Value', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            CurrencyFormatter.format(currentInv.currentValuation > 0 ? currentInv.currentValuation : totalTargetAmount),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress > 0 ? progress : (totalPaidAmount > 0 ? 1.0 : 0.0),
                      minHeight: 10,
                      backgroundColor: themeColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentInv.type == 'chitty'
                            ? '$paidPeriods / ${chittyInstallments.length} Months Completed'
                            : (schedule.isNotEmpty ? '$paidPeriods / ${schedule.length} Periods Paid' : 'Active Holding'),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% Goal Reached',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(20),

          // Schedule Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentInv.type == 'chitty'
                    ? 'Chitty Installment Schedule'
                    : (currentInv.type == 'ppf'
                        ? '15-Year PPF Growth Schedule'
                        : (currentInv.type == 'rd'
                            ? 'Recurring Deposit Schedule'
                            : (currentInv.type == 'sip' ? 'Monthly SIP Schedule' : 'Investment Milestones'))),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Gap(12),

          // Chitty Installments Table
          if (currentInv.type == 'chitty') ...[
            ...chittyInstallments.map((inst) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    showDialog(context: context, builder: (_) => RecordDividendDialog(installment: inst));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: inst.isPaid ? AppColors.income.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                          child: inst.isPaid
                              ? const Icon(Icons.check, size: 16, color: AppColors.incomeLight)
                              : Text('${inst.installmentNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    DateFormat('MMM yyyy').format(inst.dueDate),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  if (inst.isPaid) ...[
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
                                'Gross: ${CurrencyFormatter.format(inst.grossInstallment)}  |  Div: ${CurrencyFormatter.format(inst.dividendEarned)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(inst.netAmountPaid),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: inst.isPaid ? AppColors.incomeLight : themeColor),
                            ),
                            Text(inst.isPaid ? 'Net Paid' : 'Tap to Pay', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ] else ...[
            // RD, PPF, SIP, FD Schedule Items
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
                                    overflow: TextOverflow.ellipsis,
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
                        const Gap(8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(existingTx?.amount ?? item.scheduledAmount),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isPaid ? AppColors.incomeLight : themeColor),
                            ),
                            Text(isPaid ? 'Recorded' : 'Mark Paid', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
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

  Color _getColorForType(String type) {
    return switch (type.toLowerCase()) {
      'fd' => AppColors.fd,
      'rd' => AppColors.rd,
      'ppf' => AppColors.ppf,
      'sip' => AppColors.sip,
      'gold' => AppColors.gold,
      'chitty' => AppColors.chitty,
      _ => AppColors.investment,
    };
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, Investment inv, String action) async {
    if (action == 'edit') {
      switch (inv.type) {
        case 'fd':
          showDialog(context: context, builder: (_) => AddFdDialog(investmentToEdit: inv));
          break;
        case 'rd':
          showDialog(context: context, builder: (_) => AddRdDialog(investmentToEdit: inv));
          break;
        case 'ppf':
          showDialog(context: context, builder: (_) => AddPpfDialog(investmentToEdit: inv));
          break;
        case 'sip':
          showDialog(context: context, builder: (_) => AddSipDialog(investmentToEdit: inv));
          break;
        case 'gold':
          showDialog(context: context, builder: (_) => AddGoldDialog(investmentToEdit: inv));
          break;
        case 'chitty':
          showDialog(context: context, builder: (_) => AddChittyDialog(investmentToEdit: inv));
          break;
      }
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: const Text('Delete Investment?'),
          content: Text('Are you sure you want to delete "${inv.name}"? All associated schedule transactions will be deleted and account balances reverted.'),
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

      if (confirmed == true) {
        await ref.read(databaseProvider).deleteInvestment(inv.id);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "${inv.name}"')),
          );
        }
      }
    }
  }
}
