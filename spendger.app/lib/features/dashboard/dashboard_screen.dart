import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../transactions/widgets/quick_add_sheet.dart';
import '../transactions/widgets/transaction_tile.dart';
import 'widgets/active_budgets_card.dart';
import 'widgets/cash_flow_chart.dart';
import 'widgets/net_worth_card.dart';
import 'widgets/upcoming_dues_card.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToTransactions;

  const DashboardScreen({super.key, required this.onNavigateToTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTxAsync = ref.watch(recentTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider(null));
    final accountsAsync = ref.watch(accountsStreamProvider);

    final recentTransactions = recentTxAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];
    final accounts = accountsAsync.value ?? [];

    final catMap = {for (var c in categories) c.id: c};
    final accMap = {for (var a in accounts) a.id: a};

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wallet, color: AppColors.primaryLight, size: 22),
            ),
            const Gap(10),
            const Text(
              'Spendger',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const QuickAddSheet(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(recentTransactionsProvider),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Net Worth Card
            const NetWorthCard(),
            const Gap(16),

            // Cashflow Monthly Chart
            const CashFlowChart(),
            const Gap(16),

            // Upcoming Dues / Loans Card
            const UpcomingDuesCard(),
            const Gap(16),

            // Active Monthly Budgets
            const ActiveBudgetsCard(),
            const Gap(16),

            // Recent Transactions Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: theme.textTheme.titleLarge),
                TextButton(
                  onPressed: onNavigateToTransactions,
                  child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                ),
              ],
            ),
            const Gap(8),

            // Recent Transactions List (top 5)
            if (recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No transactions yet. Tap + to record income or expense!',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ),
              )
            else
              ...recentTransactions.take(5).map(
                    (tx) => TransactionTile(
                      transaction: tx,
                      category: catMap[tx.categoryId],
                      account: accMap[tx.accountId],
                    ),
                  ),
            const Gap(30),
          ],
        ),
      ),
    );
  }
}
