import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../transactions/widgets/quick_add_sheet.dart';

class CategoryTransactionsSheet extends ConsumerWidget {
  final Category category;
  final List<Transaction> transactions;
  final String periodTitle;

  const CategoryTransactionsSheet({
    super.key,
    required this.category,
    required this.transactions,
    required this.periodTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? [];
    final accMap = {for (var a in accounts) a.id: a};

    final color = Color(category.colorValue);
    final totalAmount = transactions.fold<double>(0.0, (sum, t) => sum + t.amount);

    // Sort transactions newest first
    final sortedTx = [...transactions]..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      IconHelper.getIcon(category.iconCode),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$periodTitle • ${transactions.length} ${transactions.length == 1 ? "entry" : "entries"}',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(totalAmount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: category.type == 'income' ? AppColors.incomeLight : AppColors.expenseLight,
                        ),
                      ),
                      Text(
                        category.type.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Transactions List
            Expanded(
              child: sortedTx.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions for this category in $periodTitle',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: sortedTx.length,
                      itemBuilder: (context, index) {
                        final tx = sortedTx[index];
                        final account = accMap[tx.accountId];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => QuickAddSheet(transactionToEdit: tx),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM, hh:mm a').format(tx.transactionDate),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      if (account != null)
                                        Text(
                                          account.name,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Text(
                                      tx.notes != null && tx.notes!.isNotEmpty ? tx.notes! : 'No notes',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: tx.notes != null && tx.notes!.isNotEmpty
                                            ? FontStyle.normal
                                            : FontStyle.italic,
                                        color: tx.notes != null && tx.notes!.isNotEmpty ? null : Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    '${tx.type == "income" ? "+" : "-"} ${CurrencyFormatter.format(tx.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: tx.type == 'income' ? AppColors.incomeLight : AppColors.expenseLight,
                                    ),
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
      ),
    );
  }
}
