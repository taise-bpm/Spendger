import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;
  final Category? category;
  final Account? account;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? AppColors.incomeLight : AppColors.expenseLight;
    final prefix = isIncome ? '+' : '-';

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.expense,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(databaseProvider).deleteTransactionWithAccountUpdate(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: category != null
                  ? Color(category!.colorValue).withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.15),
              child: Icon(
                category != null
                    ? IconHelper.getIcon(category!.iconCode)
                    : Icons.attach_money,
                size: 20,
                color: category != null ? Color(category!.colorValue) : Colors.grey,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Uncategorized',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const Gap(2),
                  Row(
                    children: [
                      if (account != null) ...[
                        Text(
                          account!.name,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Text(' • ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                      Text(
                        DateFormat('hh:mm a').format(transaction.transactionDate),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                        const Text(' • ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Expanded(
                          child: Text(
                            transaction.notes!,
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '$prefix ${CurrencyFormatter.format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
