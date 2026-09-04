import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../widgets/add_fd_dialog.dart';
import '../widgets/close_or_mature_dialog.dart';
import 'widgets/checkout_fd_interest_dialog.dart';

class FdStudioScreen extends ConsumerWidget {
  final Investment fdInvestment;

  const FdStudioScreen({super.key, required this.fdInvestment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allInvestmentsAsync = ref.watch(investmentsStreamProvider(null));
    final currentInv = allInvestmentsAsync.value?.firstWhere(
          (i) => i.id == fdInvestment.id,
          orElse: () => fdInvestment,
        ) ??
        fdInvestment;

    final transactionsAsync = ref.watch(investmentTransactionsStreamProvider(currentInv.id));
    final transactions = transactionsAsync.value ?? [];

    Map<String, dynamic> notesData = {};
    if (currentInv.notes != null) {
      try {
        notesData = jsonDecode(currentInv.notes!);
      } catch (_) {}
    }

    final double rate = (notesData['rate'] as num?)?.toDouble() ?? 0.0;
    final int compounding = (notesData['compounding'] as num?)?.toInt() ?? 4;
    final double principal = currentInv.purchasePrice ?? 0.0;
    final double maturityVal = currentInv.currentValuation;
    final double interestGain = maturityVal > principal ? (maturityVal - principal) : 0.0;
    final bool isSimpleInterest = compounding == 0;
    final bool isClosed = currentInv.status == 'matured' || currentInv.status == 'closed';

    // Total interest checked out so far
    final double totalInterestCheckedOut = transactions
        .where((t) => t.type == 'income' && t.tag != null && t.tag!.contains('interest_payout'))
        .fold(0.0, (sum, t) => sum + t.amount);

    final String compoundingLabel = switch (compounding) {
      0 => 'Simple Interest (Periodic Payout)',
      1 => 'Annual Compounding',
      2 => 'Half-Yearly Compounding',
      12 => 'Monthly Compounding',
      _ => 'Quarterly Compounding (Bank Std)',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentInv.name} Studio', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit FD Details',
            onPressed: () {
              showDialog(context: context, builder: (_) => AddFdDialog(investmentToEdit: currentInv));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // 1. FD Header Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.fd.withValues(alpha: 0.25),
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
                        color: AppColors.fd.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        compoundingLabel,
                        style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
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
                        const Text('Principal Deposited', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(principal),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Maturity Valuation', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(maturityVal),
                          style: const TextStyle(color: AppColors.fd, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(14),
                const Divider(color: Colors.white24, height: 1),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rate: $rate% p.a.', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    if (currentInv.maturityDate != null)
                      Text('Matures: ${DateFormat('dd MMM yyyy').format(currentInv.maturityDate!)}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),

          // 2. Action Buttons
          if (!isClosed) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.income,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      final suggestedQuarterly = (principal * (rate / 100)) / 4;
                      showDialog(
                        context: context,
                        builder: (_) => CheckoutFdInterestDialog(
                          fdInvestment: currentInv,
                          suggestedInterestAmount: isSimpleInterest ? suggestedQuarterly : interestGain,
                        ),
                      );
                    },
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Checkout Interest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                        builder: (_) => CloseOrMatureDialog(investment: currentInv),
                      );
                    },
                    icon: const Icon(Icons.account_balance, size: 18),
                    label: const Text('Mature / Close FD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
            const Gap(16),
          ],

          // 3. Simple Interest Checkout Summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkCardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Interest Credited to Bank', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const Gap(2),
                    Text(
                      CurrencyFormatter.format(totalInterestCheckedOut),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.incomeLight),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Expected Total Interest', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const Gap(2),
                    Text(
                      CurrencyFormatter.format(interestGain),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(20),

          // 4. Transaction History Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interest Payouts & Closure Log', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text('${transactions.length} Records', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Gap(8),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text('No interest payouts or closures recorded yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          else
            ...transactions.map((tx) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.income.withValues(alpha: 0.15),
                    child: const Icon(Icons.arrow_downward, color: AppColors.incomeLight, size: 16),
                  ),
                  title: Text(
                    tx.notes ?? 'FD Interest Payout',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(tx.transactionDate),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+${CurrencyFormatter.format(tx.amount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.incomeLight),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Transaction?'),
                              content: const Text('This entry will be deleted and the destination bank account balance reverted.'),
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
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
