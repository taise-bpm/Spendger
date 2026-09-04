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
import 'widgets/pay_credit_card_bill_dialog.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    final activeAccounts = accounts.where((a) => a.isActive).toList();
    final inactiveAccounts = accounts.where((a) => !a.isActive).toList();

    final double totalBankAndCash = activeAccounts
        .where((a) => a.accountType != 'card' && a.accountType != 'credit_card')
        .fold(0.0, (sum, a) => sum + a.currentBalance);

    final double totalCreditCardDebt = activeAccounts
        .where((a) => a.accountType == 'card' || a.accountType == 'credit_card')
        .fold(0.0, (sum, a) => sum + a.currentBalance.abs());

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

          // Active Accounts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ACTIVE ACCOUNTS & CARDS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8)),
              Text('${activeAccounts.length} Active', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Gap(8),
          if (activeAccounts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                    const Gap(12),
                    const Text('No active accounts added yet', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ...activeAccounts.map((acc) => _buildAccountCard(context, ref, acc, accounts, isActive: true)),

          // Inactive / Archived Accounts Section
          if (inactiveAccounts.isNotEmpty) ...[
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ARCHIVED & INACTIVE ACCOUNTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8)),
                Text('${inactiveAccounts.length} Inactive', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const Gap(8),
            ...inactiveAccounts.map((acc) => _buildAccountCard(context, ref, acc, accounts, isActive: false)),
          ],
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

  Widget _buildAccountCard(BuildContext context, WidgetRef ref, Account acc, List<Account> allAccounts, {required bool isActive}) {
    final isCard = acc.accountType == 'card' || acc.accountType == 'credit_card';
    final dueAmount = acc.currentBalance.abs();
    final limit = acc.creditLimit ?? 0.0;
    
    // Robust available credit & card utilization math: handles negative/positive balance representations
    final availableCredit = limit > 0 ? (limit - dueAmount).clamp(0.0, limit) : 0.0;
    final cardUtil = limit > 0 ? (dueAmount / limit).clamp(0.0, 1.0) : 0.0;

    Account? defaultPayFromAcc;
    if (isCard && acc.defaultPayFromAccountId != null) {
      for (final a in allAccounts) {
        if (a.id == acc.defaultPayFromAccountId) {
          defaultPayFromAcc = a;
          break;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isActive ? null : Colors.grey.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(acc.colorValue).withValues(alpha: isActive ? 0.15 : 0.08),
                  child: Icon(
                    IconHelper.getIcon(acc.iconCode),
                    size: 18,
                    color: isActive ? Color(acc.colorValue) : Colors.grey,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              acc.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isActive ? null : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('INACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                        ],
                      ),
                      const Gap(2),
                      Text(
                        acc.accountType.toUpperCase().replaceAll('_', ' '),
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isCard ? CurrencyFormatter.format(dueAmount) : CurrencyFormatter.format(acc.currentBalance),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isCard
                            ? (dueAmount > 0 ? AppColors.expenseLight : Colors.white70)
                            : (acc.currentBalance >= 0 ? AppColors.incomeLight : AppColors.expenseLight),
                      ),
                    ),
                    Text(isCard ? 'Due / Outstanding' : 'Balance', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                  onSelected: (action) => _handleAccountAction(context, ref, acc, action),
                  itemBuilder: (_) => [
                    if (isActive && isCard) ...[
                      if (dueAmount > 0 && defaultPayFromAcc != null)
                        PopupMenuItem(
                          value: 'quick_pay_due',
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on, size: 18, color: AppColors.incomeLight),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  'Quick Pay (${CurrencyFormatter.format(dueAmount)})',
                                  style: const TextStyle(color: AppColors.incomeLight, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'pay_card_bill',
                        child: Row(
                          children: [
                            const Icon(Icons.payment, size: 18, color: AppColors.expenseLight),
                            const Gap(8),
                            Text('Pay Card Bill', style: TextStyle(color: dueAmount > 0 ? AppColors.expenseLight : null, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ] else if (isActive) ...[
                      const PopupMenuItem(value: 'transfer_from', child: Text('Transfer From Here')),
                      const PopupMenuItem(value: 'transfer_to', child: Text('Transfer To Here')),
                    ],
                    const PopupMenuItem(value: 'edit', child: Text('Edit Account & Details')),
                    PopupMenuItem(
                      value: isActive ? 'deactivate' : 'reactivate',
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.archive_outlined : Icons.unarchive_outlined,
                            size: 18,
                            color: isActive ? Colors.amber : AppColors.incomeLight,
                          ),
                          const Gap(8),
                          Text(
                            isActive ? 'Deactivate / Archive' : 'Reactivate Account',
                            style: TextStyle(color: isActive ? Colors.amber : AppColors.incomeLight),
                          ),
                        ],
                      ),
                    ),
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
                    cardUtil > 0.8 ? AppColors.expense : (cardUtil > 0.4 ? AppColors.loan : AppColors.incomeLight),
                  ),
                ),
              ),
              const Gap(6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available: ${CurrencyFormatter.format(availableCredit)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text('Limit: ${CurrencyFormatter.format(limit)} (${(cardUtil * 100).toStringAsFixed(0)}% used)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              if (defaultPayFromAcc != null) ...[
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Color(defaultPayFromAcc.colorValue).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Color(defaultPayFromAcc.colorValue).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: 12, color: Color(defaultPayFromAcc.colorValue)),
                      const Gap(4),
                      Flexible(
                        child: Text(
                          'Default Pay-From: ${defaultPayFromAcc.name}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(defaultPayFromAcc.colorValue)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isActive) ...[
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (dueAmount > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.expense.withValues(alpha: 0.5)),
                            foregroundColor: AppColors.expenseLight,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.payment, size: 16),
                          label: Text(
                            'Pay Bill (${CurrencyFormatter.format(dueAmount)})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => PayCreditCardBillDialog(creditCardAccount: acc),
                            );
                          },
                        ),
                      )
                    else
                      const Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: AppColors.incomeLight),
                          Gap(6),
                          Text('No outstanding dues 🎉', style: TextStyle(fontSize: 11, color: AppColors.incomeLight, fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _handleAccountAction(BuildContext context, WidgetRef ref, Account acc, String action) async {
    final db = ref.read(databaseProvider);

    if (action == 'quick_pay_due') {
      Account? defaultSource;
      if (acc.defaultPayFromAccountId != null) {
        final allAccs = await db.getAllAccounts();
        for (final a in allAccs) {
          if (a.id == acc.defaultPayFromAccountId) {
            defaultSource = a;
            break;
          }
        }
      }

      if (defaultSource == null) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => PayCreditCardBillDialog(creditCardAccount: acc),
          );
        }
        return;
      }

      final due = acc.currentBalance.abs();
      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: const Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.incomeLight, size: 24),
              Gap(8),
              Text('Quick Pay Card Bill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay ${CurrencyFormatter.format(due)} to settle ${acc.name}?',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Gap(10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.darkCardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(IconHelper.getIcon(defaultSource!.iconCode), size: 20, color: Color(defaultSource.colorValue)),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Debit From Account:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const Gap(2),
                            Text(
                              '${defaultSource.name} (${CurrencyFormatter.format(defaultSource.currentBalance)})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Pay ${CurrencyFormatter.format(due)} Now'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        try {
          await db.recordCreditCardBillPayment(
            fromAccountId: defaultSource.id,
            creditCardAccountId: acc.id,
            amount: due,
            date: DateTime.now(),
            note: '${acc.name} Quick Bill Payment',
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Settled ${CurrencyFormatter.format(due)} for ${acc.name} from ${defaultSource.name}!'),
                backgroundColor: AppColors.incomeLight,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment failed: $e'), backgroundColor: AppColors.expense),
            );
          }
        }
      }
    } else if (action == 'pay_card_bill') {
      showDialog(
        context: context,
        builder: (_) => PayCreditCardBillDialog(creditCardAccount: acc),
      );
    } else if (action == 'transfer_from') {
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
    } else if (action == 'deactivate') {
      await db.toggleAccountActive(acc.id, false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archived "${acc.name}". Existing transaction history is preserved.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    } else if (action == 'reactivate') {
      await db.toggleAccountActive(acc.id, true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reactivated "${acc.name}"!'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    }
  }
}
