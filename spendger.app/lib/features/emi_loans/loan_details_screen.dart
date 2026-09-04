import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/financial_math.dart';
import 'widgets/add_loan_dialog.dart';
import 'widgets/early_payoff_simulator_sheet.dart';
import 'widgets/record_emi_payment_dialog.dart';

class LoanDetailsScreen extends ConsumerWidget {
  final EmiLoan loan;
  const LoanDetailsScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLoansAsync = ref.watch(loansStreamProvider(null));
    final currentLoan = allLoansAsync.value?.firstWhere((l) => l.id == loan.id, orElse: () => loan) ?? loan;

    final paymentsAsync = ref.watch(loanPaymentsStreamProvider(currentLoan.id));
    final payments = paymentsAsync.value ?? [];

    final schedule = FinancialMath.generateAmortizationSchedule(
      principal: currentLoan.principalAmount,
      annualInterestRate: currentLoan.annualInterestRate,
      tenureMonths: currentLoan.tenureMonths,
      gstRateOnInterest: currentLoan.gstRateOnInterest,
      startDate: currentLoan.startDate,
    );

    final double totalPrincipalPaid = payments.fold(0.0, (sum, p) => sum + p.principalPaid);
    final double remainingPrincipal = (currentLoan.principalAmount - totalPrincipalPaid).clamp(0.0, currentLoan.principalAmount);
    final double progress = currentLoan.principalAmount > 0 ? (totalPrincipalPaid / currentLoan.principalAmount) : 0.0;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLoan.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: AppColors.loanLight),
            tooltip: 'Early Payoff Simulator',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => EarlyPayoffSimulatorSheet(loan: currentLoan),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) async {
              if (val == 'edit_settings') {
                showDialog(
                  context: context,
                  builder: (_) => AddLoanDialog(loanToEdit: currentLoan),
                );
              } else if (val == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Loan?'),
                    content: Text('Are you sure you want to delete "${currentLoan.productName}" and its logged payments?'),
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
                  await ref.read(databaseProvider).deleteLoan(currentLoan.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Loan deleted successfully')),
                    );
                  }
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit_settings',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    Gap(8),
                    Text('Edit Loan & Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.expenseLight, size: 18),
                    Gap(8),
                    Text('Delete Loan', style: TextStyle(color: AppColors.expenseLight)),
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
          // Loan Progress Card
          Card(
            color: AppColors.loan.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Remaining Principal', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            CurrencyFormatter.format(remainingPrincipal),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.loanLight),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Monthly EMI', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            CurrencyFormatter.format(currentLoan.monthlyEmi),
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
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: AppColors.loan.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.loanLight),
                    ),
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paid: ${payments.length} / ${currentLoan.tenureMonths} Months',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% Completed',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amortization Schedule', style: theme.textTheme.titleLarge),
              OutlinedButton.icon(
                icon: const Icon(Icons.flash_on, size: 16),
                label: const Text('Simulate Prepay'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => EarlyPayoffSimulatorSheet(loan: loan),
                  );
                },
              ),
            ],
          ),
          const Gap(12),
          // Amortization Schedule Table Cards
          ...schedule.map((inst) {
            EmiPayment? existingPayment;
            for (final p in payments) {
              if (p.installmentNumber == inst.monthNumber) {
                existingPayment = p;
                break;
              }
            }
            final isPaid = existingPayment != null;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => RecordEmiPaymentDialog(
                      loan: currentLoan,
                      scheduledItem: inst,
                      existingPayment: existingPayment,
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
                            : Text('${inst.monthNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                                if (isPaid) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.income.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('PAID', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                                  ),
                                ],
                              ],
                            ),
                            const Gap(2),
                            Text(
                              isPaid
                                  ? 'Actual: Principal ${CurrencyFormatter.format(existingPayment.principalPaid)} • Interest ${CurrencyFormatter.format(existingPayment.interestPaid)}'
                                  : 'Scheduled: Principal ${CurrencyFormatter.format(inst.principal)} • Interest ${CurrencyFormatter.format(inst.interest)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isPaid ? AppColors.incomeLight.withValues(alpha: 0.8) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(isPaid ? existingPayment.totalAmountPaid : inst.totalPayment),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPaid ? AppColors.income.withValues(alpha: 0.15) : AppColors.loan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPaid ? Icons.edit_outlined : Icons.check_circle_outline,
                                  size: 11,
                                  color: isPaid ? AppColors.incomeLight : AppColors.loanLight,
                                ),
                                const Gap(4),
                                Text(
                                  isPaid ? 'EDIT PAID' : 'RECORD EMI',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isPaid ? AppColors.incomeLight : AppColors.loanLight,
                                  ),
                                ),
                              ],
                            ),
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
}
