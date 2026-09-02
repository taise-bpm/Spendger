import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class UpcomingDuesCard extends ConsumerWidget {
  const UpcomingDuesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersStreamProvider);
    final loansAsync = ref.watch(loansStreamProvider('active'));

    final reminders = remindersAsync.value ?? [];
    final loans = loansAsync.value ?? [];

    final theme = Theme.of(context);

    if (reminders.isEmpty && loans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.loanLight),
                    const Gap(8),
                    Text('Upcoming Dues & Reminders', style: theme.textTheme.titleLarge),
                  ],
                ),
              ],
            ),
            const Gap(14),
            if (loans.isNotEmpty)
              ...loans.take(2).map((loan) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.loan.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.loan.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.loan.withValues(alpha: 0.2),
                        child: const Icon(Icons.credit_card, size: 16, color: AppColors.loanLight),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.productName,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Monthly EMI Due',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(loan.monthlyEmi),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.loanLight),
                          ),
                          Text(
                            loan.lenderName ?? 'Active Loan',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            if (reminders.isNotEmpty)
              ...reminders.take(2).map((rem) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: const Icon(Icons.alarm, size: 16, color: AppColors.primaryLight),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rem.title,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Due: ${DateFormat('MMM dd, yyyy').format(rem.dueDate)}',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (rem.amount != null)
                        Text(
                          CurrencyFormatter.format(rem.amount!),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
