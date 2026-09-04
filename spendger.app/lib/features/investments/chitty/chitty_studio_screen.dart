import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../widgets/add_chitty_dialog.dart';
import '../widgets/record_dividend_dialog.dart';

class ChittyStudioScreen extends ConsumerWidget {
  final Investment chittyInvestment;

  const ChittyStudioScreen({super.key, required this.chittyInvestment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allInvestmentsAsync = ref.watch(investmentsStreamProvider(null));
    final currentInv = allInvestmentsAsync.value?.firstWhere(
          (i) => i.id == chittyInvestment.id,
          orElse: () => chittyInvestment,
        ) ??
        chittyInvestment;

    final installmentsAsync = ref.watch(chittyInstallmentsStreamProvider(currentInv.id));
    final installments = installmentsAsync.value ?? [];

    final paidCount = installments.where((c) => c.isPaid).length;
    final totalPaid = installments.where((c) => c.isPaid).fold(0.0, (sum, c) => sum + c.netAmountPaid);
    final totalDividend = installments.where((c) => c.isPaid).fold(0.0, (sum, c) => sum + c.dividendEarned);
    final totalChitValue = currentInv.totalCommittedAmount ?? 0.0;
    final progress = totalChitValue > 0 ? (totalPaid / totalChitValue).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentInv.name} Studio', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Scheme',
            onPressed: () {
              showDialog(context: context, builder: (_) => AddChittyDialog(investmentToEdit: currentInv));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // 1. Chitty Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF831843), Color(0xFF500724)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.chitty.withValues(alpha: 0.25),
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
                        color: AppColors.chitty.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Total Chit Value: ${CurrencyFormatter.format(totalChitValue)}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.groups_outlined, color: Colors.white, size: 20),
                  ],
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Net Paid', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalPaid),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Dividends Saved', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalDividend),
                          style: const TextStyle(color: AppColors.incomeLight, fontSize: 18, fontWeight: FontWeight.bold),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.chitty),
                  ),
                ),
                const Gap(6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$paidCount / ${installments.length} Months Completed', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                    Text('${(progress * 100).toStringAsFixed(0)}% Paid', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),

          // 2. Installments Schedule Table
          Text('Installments & Auction Dividend Schedule', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(8),
          ...installments.map((inst) {
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
                                if (inst.isPrizedMonth) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('PRIZED', style: TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const Gap(4),
                            Text(
                              'Gross: ${CurrencyFormatter.format(inst.grossInstallment)}  •  Div: ${CurrencyFormatter.format(inst.dividendEarned)}',
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: inst.isPaid ? AppColors.incomeLight : AppColors.chitty),
                          ),
                          Text(inst.isPaid ? 'Recorded' : 'Log Dividend', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
}
