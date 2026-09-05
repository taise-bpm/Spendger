import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'loan_details_screen.dart';
import 'widgets/add_loan_dialog.dart';
import 'widgets/loan_comparison_studio_tab.dart';

class EmiLoansScreen extends ConsumerStatefulWidget {
  const EmiLoansScreen({super.key});

  @override
  ConsumerState<EmiLoansScreen> createState() => _EmiLoansScreenState();
}

class _EmiLoansScreenState extends ConsumerState<EmiLoansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loansStreamProvider('active'));
    final paymentsAsync = ref.watch(allLoanPaymentsStreamProvider);
    final loans = loansAsync.value ?? [];
    final payments = paymentsAsync.value ?? [];

    final double totalOutstandingDebt = loans.fold(0.0, (sum, l) {
      final paidPrincipal = payments
          .where((p) => p.loanId == l.id)
          .fold(0.0, (pSum, p) => pSum + p.principalPaid);
      return sum + (l.principalAmount - paidPrincipal).clamp(0.0, l.principalAmount);
    });
    final double totalMonthlyEmi = loans.fold(0.0, (sum, l) => sum + l.monthlyEmi);
    final isCompareTab = _tabController.index == 1;

    // Vibrant Purple for Compare & Mock Studio, Amber for Active Loans
    const purpleAccent = Color(0xFF8B5CF6);
    const purpleLight = Color(0xFFA78BFA);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI & Loans Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isCompareTab ? purpleLight : AppColors.loanLight,
          labelColor: isCompareTab ? purpleLight : AppColors.loanLight,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance, size: 20), text: 'Active Loans'),
            Tab(icon: Icon(Icons.compare_arrows, size: 20), text: 'Compare & Mock Studio'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isCompareTab ? 'Add Comparison Offer' : 'Add EMI Loan',
            icon: Icon(
              isCompareTab ? Icons.playlist_add : Icons.add_circle_outline,
              color: isCompareTab ? purpleLight : AppColors.loanLight,
              size: 28,
            ),
            onPressed: () {
              if (isCompareTab) {
                AddEditLoanOfferDialog.show(context, ref);
              } else {
                showDialog(
                  context: context,
                  builder: (_) => const AddLoanDialog(),
                );
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Active Loans List & Summary
          _buildActiveLoansTab(context, ref, loans, payments, totalOutstandingDebt, totalMonthlyEmi),

          // Tab 2: Compare & Mock Studio
          const LoanComparisonStudioTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_loans',
        backgroundColor: isCompareTab ? purpleAccent : AppColors.loan,
        foregroundColor: Colors.white,
        onPressed: () {
          if (isCompareTab) {
            AddEditLoanOfferDialog.show(context, ref);
          } else {
            showDialog(
              context: context,
              builder: (_) => const AddLoanDialog(),
            );
          }
        },
        icon: const Icon(Icons.add, size: 22),
        label: Text(
          isCompareTab ? 'Add Offer' : 'Add Loan',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildActiveLoansTab(
    BuildContext context,
    WidgetRef ref,
    List<EmiLoan> loans,
    List<EmiPayment> payments,
    double totalOutstandingDebt,
    double totalMonthlyEmi,
  ) {
    final theme = Theme.of(context);

    return Column(
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
                          'OUTSTANDING PRINCIPAL',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const Gap(4),
                        Text(
                          CurrencyFormatter.format(totalOutstandingDebt),
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
                    final isFriendLoan = loan.loanCategory == 'friend_family' || loan.annualInterestRate == 0;
                    final loanPaidPrincipal = payments
                        .where((p) => p.loanId == loan.id)
                        .fold(0.0, (pSum, p) => pSum + p.principalPaid);
                    final outstanding = (loan.principalAmount - loanPaidPrincipal).clamp(0.0, loan.principalAmount);

                    final categoryTag = switch (loan.loanCategory) {
                      'personal_bank' => 'Personal Loan',
                      'asset_vehicle' => 'Vehicle / Asset',
                      'friend_family' => 'Friend / Family (0%)',
                      _ => 'Loan',
                    };

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
                                    backgroundColor: (isFriendLoan ? AppColors.income : AppColors.loan).withValues(alpha: 0.2),
                                    child: Icon(
                                      isFriendLoan ? Icons.people_outline : Icons.account_balance,
                                      size: 18,
                                      color: isFriendLoan ? AppColors.incomeLight : AppColors.loanLight,
                                    ),
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
                                        Row(
                                          children: [
                                            if (loan.lenderName != null) ...[
                                              Flexible(
                                                child: Text(
                                                  loan.lenderName!,
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const Text(' • ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                            ],
                                            Text(
                                              categoryTag,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isFriendLoan ? AppColors.incomeLight : AppColors.loanLight,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
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
                                  _buildInfoItem('Outstanding', CurrencyFormatter.formatCompact(outstanding)),
                                  _buildInfoItem('Principal', CurrencyFormatter.formatCompact(loan.principalAmount)),
                                  _buildInfoItem('Rate', isFriendLoan ? '0%' : '${loan.annualInterestRate}%'),
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
