import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/icon_helper.dart';
import 'widgets/add_edit_account_dialog.dart';
import 'widgets/intra_transfer_dialog.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    final double totalBankAndCash = accounts
        .where((a) => a.accountType != 'card' && a.accountType != 'credit_card')
        .fold(0.0, (sum, a) => sum + a.currentBalance);

    final double totalCreditCardDebt = accounts
        .where((a) => a.accountType == 'card' || a.accountType == 'credit_card')
        .fold(0.0, (sum, a) => sum + a.currentBalance);

    final double netLiquidAssets = totalBankAndCash - totalCreditCardDebt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts & Cards', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: AppColors.primaryLight, size: 26),
            tooltip: 'Self / Intra-Transfer',
            onPressed: () {
              showDialog(context: context, builder: (_) => const IntraTransferDialog());
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLight, size: 26),
            tooltip: 'Add Account / Card',
            onPressed: () {
              showDialog(context: context, builder: (_) => const AddEditAccountDialog());
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // Net Liquid Assets Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NET LIQUID ASSETS',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const Gap(4),
                Text(
                  CurrencyFormatter.format(netLiquidAssets),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const Gap(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cash & Bank Balances', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalBankAndCash),
                          style: const TextStyle(color: AppColors.incomeLight, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Credit Card Outstandings', style: TextStyle(color: Colors.white60, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalCreditCardDebt),
                          style: const TextStyle(color: AppColors.expenseLight, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      showDialog(context: context, builder: (_) => const IntraTransferDialog());
                    },
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Make Self / Intra-Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),

          // Accounts List Section
          const Text('YOUR ACCOUNTS & WALLETS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8)),
          const Gap(8),
          if (accounts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                    const Gap(12),
                    const Text('No accounts added yet', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ...accounts.map((acc) {
              final isCard = acc.accountType == 'card' || acc.accountType == 'credit_card';
              final limit = acc.creditLimit ?? 0.0;
              final availableCredit = limit > 0 ? (limit - acc.currentBalance).clamp(0.0, limit) : 0.0;
              final cardUtil = limit > 0 ? (acc.currentBalance / limit).clamp(0.0, 1.0) : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(acc.colorValue).withValues(alpha: 0.15),
                            child: Icon(IconHelper.getIcon(acc.iconCode), size: 18, color: Color(acc.colorValue)),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                                const Gap(2),
                                Text(
                                  acc.accountType.toUpperCase().replaceAll('_', ' '),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.format(acc.currentBalance),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isCard ? AppColors.expenseLight : AppColors.incomeLight,
                                ),
                              ),
                              Text(isCard ? 'Due' : 'Balance', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                            onSelected: (action) => _handleAccountAction(context, ref, acc, action),
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'transfer_from', child: Text('Transfer From Here')),
                              const PopupMenuItem(value: 'transfer_to', child: Text('Transfer To Here')),
                              const PopupMenuItem(value: 'edit', child: Text('Edit Account')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete Account', style: TextStyle(color: AppColors.expense))),
                            ],
                          ),
                        ],
                      ),
                      if (isCard && limit > 0) ...[
                        const Gap(10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: cardUtil,
                            minHeight: 6,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cardUtil > 0.8 ? AppColors.expense : (cardUtil > 0.5 ? AppColors.loan : AppColors.incomeLight),
                            ),
                          ),
                        ),
                        const Gap(4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Available: ${CurrencyFormatter.format(availableCredit)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('Limit: ${CurrencyFormatter.format(limit)} (${(cardUtil * 100).toStringAsFixed(0)}% used)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_accounts',
        backgroundColor: AppColors.primary,
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddEditAccountDialog());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _handleAccountAction(BuildContext context, WidgetRef ref, Account acc, String action) async {
    if (action == 'transfer_from') {
      showDialog(
        context: context,
        builder: (_) => IntraTransferDialog(initialFromAccountId: acc.id),
      );
    } else if (action == 'transfer_to') {
      showDialog(
        context: context,
        builder: (_) => IntraTransferDialog(initialToAccountId: acc.id),
      );
    } else if (action == 'edit') {
      showDialog(
        context: context,
        builder: (_) => AddEditAccountDialog(accountToEdit: acc),
      );
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: const Text('Delete Account?'),
          content: Text('Are you sure you want to delete "${acc.name}"? Transactions linked to this account will remain in records with unassigned account.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense, foregroundColor: Colors.white),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await ref.read(databaseProvider).deleteAccount(acc.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "${acc.name}"')),
          );
        }
      }
    }
  }
}
