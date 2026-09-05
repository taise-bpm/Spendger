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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    final double rate = _parseDouble(notesData['rate'], 0.0);
    final int compounding = _parseInt(notesData['compounding'], 4);
    final double principal = currentInv.purchasePrice ?? 0.0;
    final double maturityVal = currentInv.currentValuation;
    final double interestGain = maturityVal > principal ? (maturityVal - principal) : 0.0;
    final bool isSimpleInterest = compounding == 0;
    final bool isClosed = currentInv.status == 'matured' || currentInv.status == 'closed';

    // Total interest checked out / credited so far
    final double totalInterestCheckedOut = transactions
        .where((t) => t.type == 'income' && t.tag != null && (t.tag!.contains('interest_payout') || t.tag!.contains('fd_interest')))
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
        title: Text(
          isClosed ? '${currentInv.name} Archive' : '${currentInv.name} Studio',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isClosed) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit FD Details',
              onPressed: () {
                showDialog(context: context, builder: (_) => AddFdDialog(investmentToEdit: currentInv));
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              tooltip: 'Delete Archived FD Account',
              onPressed: () => _confirmDeleteArchivedFd(context, ref, currentInv),
            ),
          ],
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
                const Gap(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isClosed ? 'Final Settled Principal' : 'Principal Deposited',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(principal),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Target Maturity Value', style: TextStyle(color: Colors.white70, fontSize: 11)),
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
                Container(height: 1, color: Colors.white12),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Interest Rate', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        const Gap(2),
                        Text('$rate% p.a.', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Interest Received', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        const Gap(2),
                        Text(
                          '+${CurrencyFormatter.format(totalInterestCheckedOut)}',
                          style: const TextStyle(color: AppColors.incomeLight, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Maturity Date', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        const Gap(2),
                        Text(
                          currentInv.maturityDate != null
                              ? DateFormat('dd MMM yyyy').format(currentInv.maturityDate!)
                              : 'Not Set',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(16),

          // 2. Action Controls
          if (!isClosed) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.income,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CheckoutFdInterestDialog(
                          fdInvestment: currentInv,
                          suggestedInterestAmount: isSimpleInterest ? (principal * rate / 100 / 4) : interestGain,
                        ),
                      );
                    },
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Checkout Interest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                    label: const Text('Mature / Close FD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const Gap(16),
          ],

          // 3. Statement / Interest Transactions
          Text('Interest Payouts & Transaction History', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(8),
          if (transactions.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 36, color: Colors.grey.shade400),
                  const Gap(8),
                  const Text('No interest payouts or ledger transactions recorded yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ] else ...[
            ...transactions.map((tx) {
              final isIncome = tx.type == 'income';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isIncome
                            ? AppColors.income.withValues(alpha: 0.15)
                            : AppColors.expense.withValues(alpha: 0.15),
                        child: Icon(
                          isIncome ? Icons.payments_outlined : Icons.call_made,
                          size: 16,
                          color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.notes ?? (isIncome ? 'Interest Payout' : 'Principal Deposit'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy • hh:mm a').format(tx.transactionDate),
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'} ${CurrencyFormatter.format(tx.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteArchivedFd(BuildContext context, WidgetRef ref, Investment currentInv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.expense, size: 24),
            Gap(8),
            Expanded(
              child: Text(
                'Delete Archived FD Account?',
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
              'All transactions, interest payouts, and statement records linked to this Fixed Deposit account will be permanently deleted. This action cannot be undone.',
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
