import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/financial_math.dart';
import 'widgets/early_payoff_simulator_sheet.dart';

class LoanDetailsScreen extends ConsumerWidget {
  final EmiLoan loan;
  const LoanDetailsScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(loanPaymentsStreamProvider(loan.id));
    final payments = paymentsAsync.value ?? [];

    final schedule = FinancialMath.generateAmortizationSchedule(
      principal: loan.principalAmount,
      annualInterestRate: loan.annualInterestRate,
      tenureMonths: loan.tenureMonths,
      gstRateOnInterest: loan.gstRateOnInterest,
      startDate: loan.startDate,
    );

    final paidInstallmentNums = payments.map((p) => p.installmentNumber).toSet();
    final double totalPrincipalPaid = payments.fold(0.0, (sum, p) => sum + p.principalPaid);
    final double remainingPrincipal = (loan.principalAmount - totalPrincipalPaid).clamp(0.0, loan.principalAmount);
    final double progress = loan.principalAmount > 0 ? (totalPrincipalPaid / loan.principalAmount) : 0.0;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loan.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: AppColors.loanLight),
            tooltip: 'Early Payoff Simulator',
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
                            CurrencyFormatter.format(loan.monthlyEmi),
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
                        'Paid: ${payments.length} / ${loan.tenureMonths} Months',
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
            final isPaid = paidInstallmentNums.contains(inst.monthNumber);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
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
                          Text(
                            DateFormat('MMM yyyy').format(inst.dueDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Principal: ${CurrencyFormatter.format(inst.principal)} • Interest: ${CurrencyFormatter.format(inst.interest)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(inst.totalPayment),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        InkWell(
                          onTap: () async {
                            final db = ref.read(databaseProvider);
                            if (isPaid) {
                              // Delete payment
                              await (db.delete(db.emiPayments)
                                    ..where((p) => p.loanId.equals(loan.id) & p.installmentNumber.equals(inst.monthNumber)))
                                  .go();
                            } else {
                              // Mark as paid
                              const uuid = Uuid();
                              await db.into(db.emiPayments).insert(
                                EmiPaymentsCompanion.insert(
                                  id: uuid.v4(),
                                  loanId: loan.id,
                                  installmentNumber: inst.monthNumber,
                                  paymentDate: DateTime.now(),
                                  principalPaid: inst.principal,
                                  interestPaid: inst.interest,
                                  gstPaid: drift.Value(inst.gstOnInterest),
                                  totalAmountPaid: inst.totalPayment,
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid ? AppColors.income.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPaid ? 'PAID' : 'MARK PAID',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isPaid ? AppColors.incomeLight : AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ),
                      ],
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
