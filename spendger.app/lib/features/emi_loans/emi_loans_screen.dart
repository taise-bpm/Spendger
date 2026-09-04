import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'loan_details_screen.dart';
import 'widgets/add_loan_dialog.dart';

class EmiLoansScreen extends ConsumerWidget {
  const EmiLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansStreamProvider('active'));
    final loans = loansAsync.value ?? [];

    final double totalActiveDebt = loans.fold(0.0, (sum, l) => sum + l.principalAmount);
    final double totalMonthlyEmi = loans.fold(0.0, (sum, l) => sum + l.monthlyEmi);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI & Loans Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.loanLight, size: 28),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddLoanDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Summary Card
          if (loans.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF78350F), Color(0xFF451A03)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.loan.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACTIVE PRINCIPAL',
                            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const Gap(4),
                          Text(
                            CurrencyFormatter.format(totalActiveDebt),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'MONTHLY EMI',
                            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const Gap(4),
                          Text(
                            CurrencyFormatter.format(totalMonthlyEmi),
                            style: const TextStyle(color: AppColors.loanLight, fontSize: 18, fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Gap(4),
          // Loans List
          Expanded(
            child: loans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card_off_outlined, size: 54, color: Colors.grey.withValues(alpha: 0.4)),
                        const Gap(12),
                        const Text('No active loans or EMIs recorded', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        const Gap(8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.loan, foregroundColor: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const AddLoanDialog(),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add EMI Loan'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: loans.length,
                    itemBuilder: (context, index) {
                      final loan = loans[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LoanDetailsScreen(loan: loan),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppColors.loan.withValues(alpha: 0.2),
                                      child: const Icon(Icons.account_balance, size: 18, color: AppColors.loanLight),
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loan.productName,
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          if (loan.lenderName != null)
                                            Text(
                                              loan.lenderName!,
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Gap(10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(loan.monthlyEmi),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.loanLight),
                                        ),
                                        const Text('/ Month', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Gap(14),
                                const Divider(height: 1),
                                const Gap(10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildInfoItem('Principal', CurrencyFormatter.formatCompact(loan.principalAmount)),
                                    _buildInfoItem('Interest Rate', '${loan.annualInterestRate}% p.a.'),
                                    _buildInfoItem('Tenure', '${loan.tenureMonths} Mo'),
                                    const Row(
                                      children: [
                                        Text('Details', style: TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                                        Icon(Icons.chevron_right, size: 16, color: AppColors.primaryLight),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_loans',
        backgroundColor: AppColors.loan,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddLoanDialog(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const Gap(2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
