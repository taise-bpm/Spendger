import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class NetWorthCard extends ConsumerWidget {
  const NetWorthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final investmentsAsync = ref.watch(investmentsStreamProvider(null));
    final loansAsync = ref.watch(loansStreamProvider('active'));

    final accounts = accountsAsync.value ?? [];
    final investments = investmentsAsync.value ?? [];
    final loans = loansAsync.value ?? [];

    final double totalCash = accounts.fold(0.0, (sum, a) => sum + a.currentBalance);
    final double totalInvestments = investments.fold(0.0, (sum, i) => sum + i.currentValuation);
    final double totalDebt = loans.fold(0.0, (sum, l) => sum + l.principalAmount);
    final double netWorth = (totalCash + totalInvestments) - totalDebt;

    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESTIMATED NET WORTH',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      netWorth >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: netWorth >= 0 ? AppColors.incomeLight : AppColors.expenseLight,
                    ),
                    const Gap(4),
                    Text(
                      netWorth >= 0 ? 'Positive' : 'Debt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(10),
          Text(
            CurrencyFormatter.format(netWorth),
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(20),
          const Divider(color: Colors.white12, height: 1),
          const Gap(14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric(
                context,
                label: 'Cash & Bank',
                amount: totalCash,
                color: AppColors.incomeLight,
                icon: Icons.account_balance_wallet,
              ),
              _buildMiniMetric(
                context,
                label: 'Investments',
                amount: totalInvestments,
                color: AppColors.investment,
                icon: Icons.auto_graph,
              ),
              _buildMiniMetric(
                context,
                label: 'Active Debt',
                amount: totalDebt,
                color: AppColors.loanLight,
                icon: Icons.credit_score,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(
    BuildContext context, {
    required String label,
    required double amount,
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
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ],
        ),
        const Gap(4),
        Text(
          CurrencyFormatter.formatCompact(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
