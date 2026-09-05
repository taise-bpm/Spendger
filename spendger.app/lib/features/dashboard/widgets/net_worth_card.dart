import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';

class NetWorthCard extends ConsumerStatefulWidget {
  const NetWorthCard({super.key});

  @override
  ConsumerState<NetWorthCard> createState() => _NetWorthCardState();
}

class _NetWorthCardState extends ConsumerState<NetWorthCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final investmentsAsync = ref.watch(investmentsStreamProvider(null));
    final loansAsync = ref.watch(loansStreamProvider('active'));
    final paymentsAsync = ref.watch(allLoanPaymentsStreamProvider);

    final accounts = accountsAsync.value ?? [];
    final investments = investmentsAsync.value ?? [];
    final loans = loansAsync.value ?? [];
    final payments = paymentsAsync.value ?? [];

    // --- 1. Net Worth Calculations ---
    final double totalCash = accounts
        .where((a) => a.accountType != 'card' && a.accountType != 'credit_card')
        .fold(0.0, (sum, a) => sum + a.currentBalance);
    final double totalCardDebt = accounts
        .where((a) => a.accountType == 'card' || a.accountType == 'credit_card')
        .fold(0.0, (sum, a) => sum + a.currentBalance.abs());
    final double totalInvestments = investments.fold(0.0, (sum, i) => sum + i.currentValuation);

    // Calculate outstanding loan debt by subtracting paid EMI principal for each active loan
    final double totalOutstandingLoanDebt = loans.fold(0.0, (sum, l) {
      final paidPrincipal = payments
          .where((p) => p.loanId == l.id)
          .fold(0.0, (pSum, p) => pSum + p.principalPaid);
      final remaining = (l.principalAmount - paidPrincipal).clamp(0.0, l.principalAmount);
      return sum + remaining;
    });

    final double totalDebt = totalOutstandingLoanDebt + totalCardDebt;
    final double netWorth = (totalCash + totalInvestments) - totalDebt;

    // --- 2. Expected Corpus & Projected Maturity Calculations ---
    double totalInvestedCapital = 0.0;
    double totalProjectedCorpus = 0.0;

    for (final inv in investments) {
      Map<String, dynamic> notesData = {};
      if (inv.notes != null) {
        try {
          notesData = jsonDecode(inv.notes!);
        } catch (_) {}
      }

      final double rate = _parseDouble(notesData['rate'], 0.0);
      final int tenureMonths = _parseInt(notesData['tenureMonths'], 12);
      final int tenureYears = _parseInt(notesData['tenureYears'], 15);

      switch (inv.type.toLowerCase()) {
        case 'rd':
          final monthly = inv.purchasePrice ?? 0.0;
          final committed = inv.totalCommittedAmount ?? (monthly * tenureMonths);
          totalInvestedCapital += committed;
          final maturity = inv.currentValuation > 0
              ? inv.currentValuation
              : FinancialMath.calculateRdMaturity(
                  monthlyDeposit: monthly,
                  annualInterestRate: rate > 0 ? rate : 7.0,
                  tenureMonths: tenureMonths,
                ).maturityAmount;
          totalProjectedCorpus += maturity;
          break;

        case 'ppf':
          final yearly = inv.purchasePrice ?? 150000.0;
          final committed = yearly * tenureYears;
          totalInvestedCapital += committed;
          final maturity = FinancialMath.calculatePpfMaturity(
            yearlyDeposit: yearly,
            annualInterestRate: rate > 0 ? rate : 7.1,
            tenureYears: tenureYears,
          ).maturityAmount;
          totalProjectedCorpus += (maturity > 0 ? maturity : inv.currentValuation);
          break;

        case 'fd':
          final principal = inv.purchasePrice ?? (inv.totalCommittedAmount ?? inv.currentValuation);
          totalInvestedCapital += principal;
          totalProjectedCorpus += inv.currentValuation > 0 ? inv.currentValuation : principal;
          break;

        case 'chitty':
          final committed = inv.totalCommittedAmount ?? inv.currentValuation;
          totalInvestedCapital += committed;
          totalProjectedCorpus += committed;
          break;

        case 'sip':
        case 'gold':
        default:
          final invested = inv.purchasePrice ?? (inv.totalCommittedAmount ?? inv.currentValuation);
          totalInvestedCapital += invested;
          totalProjectedCorpus += inv.currentValuation;
          break;
      }
    }

    final double totalExpectedGains = (totalProjectedCorpus - totalInvestedCapital).clamp(0.0, double.infinity);

    return SizedBox(
      height: 220,
      child: PageView(
        controller: _pageController,
        onPageChanged: (idx) {
          setState(() {
            _currentPage = idx;
          });
        },
        children: [
          // Slide 1: Estimated Net Worth
          _buildNetWorthSlide(
            context,
            netWorth: netWorth,
            totalCash: totalCash,
            totalInvestments: totalInvestments,
            totalDebt: totalDebt,
          ),

          // Slide 2: Expected Future Corpus & Maturity Wealth
          _buildCorpusSlide(
            context,
            totalProjectedCorpus: totalProjectedCorpus,
            totalInvestedCapital: totalInvestedCapital,
            totalExpectedGains: totalExpectedGains,
            activePortfoliosCount: investments.length,
          ),
        ],
      ),
    );
  }

  Widget _buildNetWorthSlide(
    BuildContext context, {
    required double netWorth,
    required double totalCash,
    required double totalInvestments,
    required double totalDebt,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF1E1B4B)], // Deep Indigo gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ESTIMATED NET WORTH',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Gap(6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      netWorth >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: netWorth >= 0 ? AppColors.incomeLight : AppColors.expenseLight,
                    ),
                    const Gap(4),
                    Text(
                      netWorth >= 0 ? 'Positive' : 'Debt',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              _buildPageIndicator(0),
            ],
          ),
          const Gap(8),
          Text(
            CurrencyFormatter.format(netWorth),
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const Divider(color: Colors.white12, height: 1),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  context,
                  label: 'Cash & Bank',
                  amount: CurrencyFormatter.formatCompact(totalCash),
                  color: AppColors.incomeLight,
                  icon: Icons.account_balance_wallet,
                ),
              ),
              const Gap(6),
              Expanded(
                child: _buildMiniMetric(
                  context,
                  label: 'Investments',
                  amount: CurrencyFormatter.formatCompact(totalInvestments),
                  color: AppColors.investment,
                  icon: Icons.auto_graph,
                ),
              ),
              const Gap(6),
              Expanded(
                child: _buildMiniMetric(
                  context,
                  label: 'Active Debt',
                  amount: CurrencyFormatter.formatCompact(totalDebt),
                  color: AppColors.loanLight,
                  icon: Icons.credit_score,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorpusSlide(
    BuildContext context, {
    required double totalProjectedCorpus,
    required double totalInvestedCapital,
    required double totalExpectedGains,
    required int activePortfoliosCount,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF022C22)], // Deep Emerald Forest gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.income.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 13, color: AppColors.incomeLight),
                    const Gap(5),
                    Flexible(
                      child: Text(
                        'EXPECTED CORPUS',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.incomeLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.incomeLight.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Future Wealth',
                      style: TextStyle(
                        color: AppColors.incomeLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              _buildPageIndicator(1),
            ],
          ),
          const Gap(8),
          Text(
            CurrencyFormatter.format(totalProjectedCorpus),
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          const Divider(color: Colors.white12, height: 1),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  context,
                  label: 'Committed',
                  amount: CurrencyFormatter.formatCompact(totalInvestedCapital),
                  color: Colors.lightBlueAccent,
                  icon: Icons.savings_outlined,
                ),
              ),
              const Gap(6),
              Expanded(
                child: _buildMiniMetric(
                  context,
                  label: 'Expected Gain',
                  amount: '+${CurrencyFormatter.formatCompact(totalExpectedGains)}',
                  color: AppColors.incomeLight,
                  icon: Icons.trending_up,
                ),
              ),
              const Gap(6),
              Expanded(
                child: _buildMiniMetric(
                  context,
                  label: 'Holdings',
                  amount: '$activePortfoliosCount Assets',
                  color: AppColors.ppf,
                  icon: Icons.pie_chart_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: _currentPage == 0 ? 14 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: _currentPage == 0 ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const Gap(4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: _currentPage == 1 ? 14 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: _currentPage == 1 ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMetric(
    BuildContext context, {
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const Gap(4),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60, fontSize: 11),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const Gap(2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
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
