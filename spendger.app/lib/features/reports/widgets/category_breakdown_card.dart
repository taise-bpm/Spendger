import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final int rank;
  final Category category;
  final double totalAmount;
  final double overallTotal;
  final int transactionCount;
  final VoidCallback onTap;

  const CategoryBreakdownCard({
    super.key,
    required this.rank,
    required this.category,
    required this.totalAmount,
    required this.overallTotal,
    required this.transactionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(category.colorValue);
    final percentage = overallTotal > 0 ? (totalAmount / overallTotal * 100) : 0.0;
    final ratio = overallTotal > 0 ? (totalAmount / overallTotal) : 0.0;
    final avgPerTx = transactionCount > 0 ? (totalAmount / transactionCount) : 0.0;
    final isIncome = category.type == 'income';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rank <= 3 ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rank <= 3 ? color.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: rank <= 3 ? color : Colors.grey,
                      ),
                    ),
                  ),
                  const Gap(10),

                  // Category Avatar
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      IconHelper.getIcon(category.iconCode),
                      size: 18,
                      color: color,
                    ),
                  ),
                  const Gap(10),

                  // Category Name & Counts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(2),
                        Text(
                          '$transactionCount ${transactionCount == 1 ? "tx" : "txs"} • Avg: ${CurrencyFormatter.formatCompact(avgPerTx)}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Amount & Percentage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(totalAmount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? AppColors.incomeLight : AppColors.expenseLight,
                        ),
                      ),
                      const Gap(2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
              const Gap(10),

              // Visual Percentage Contribution Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
