import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';
import '../../emi_loans/loan_details_screen.dart';
import '../../investments/chitty/chitty_studio_screen.dart';
import '../../investments/fd/fd_studio_screen.dart';
import '../../investments/gold/gold_studio_screen.dart';
import '../../investments/investment_details_screen.dart';
import '../../investments/ppf/ppf_studio_screen.dart';
import '../../investments/rd/rd_studio_screen.dart';
import '../../investments/sip/sip_studio_screen.dart';
import 'quick_add_sheet.dart';

class TransactionDetailsSheet extends ConsumerWidget {
  final Transaction transaction;
  final Category? category;
  final Account? account;
  final Account? toAccount;

  const TransactionDetailsSheet({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.toAccount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isTransfer = transaction.type == 'transfer';
    final isIncome = transaction.type == 'income';
    final amountColor = isTransfer
        ? Colors.lightBlueAccent
        : (isIncome ? AppColors.incomeLight : AppColors.expenseLight);
    final prefix = isTransfer ? '⇄' : (isIncome ? '+' : '-');

    final isInvestmentTx = transaction.tag?.startsWith('INV:') == true;
    final isLoanTx = transaction.tag?.startsWith('LOAN:') == true ||
        transaction.tag?.startsWith('LOAN_DISBURSE:') == true ||
        transaction.tag?.startsWith('LOAN_PAYMENT:') == true;

    final avatarIcon = isTransfer
        ? Icons.swap_horiz
        : (isInvestmentTx
            ? Icons.shield_outlined
            : (isLoanTx
                ? Icons.request_quote_outlined
                : (category != null ? IconHelper.getIcon(category!.iconCode) : Icons.attach_money)));

    final avatarColor = isTransfer
        ? Colors.lightBlueAccent
        : (isInvestmentTx
            ? AppColors.ppf
            : (isLoanTx
                ? AppColors.loan
                : (category != null ? Color(category!.colorValue) : Colors.grey)));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            const Gap(12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(8),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content List
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Amount & Primary Avatar Header Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBorder.withValues(alpha: 0.3) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: avatarColor.withValues(alpha: 0.15),
                          child: Icon(avatarIcon, size: 28, color: avatarColor),
                        ),
                        const Gap(10),
                        Text(
                          '$prefix ${CurrencyFormatter.format(transaction.amount)}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: amountColor,
                          ),
                        ),
                        const Gap(6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: avatarColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getTypeBadgeLabel(transaction),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: avatarColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),

                  // 2. Metadata Section Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBorder.withValues(alpha: 0.2) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          icon: Icons.category_outlined,
                          iconColor: avatarColor,
                          label: 'Category',
                          value: isTransfer
                              ? 'Account Transfer'
                              : (category?.name ?? 'Uncategorized'),
                          isDark: isDark,
                        ),
                        const Divider(height: 1, indent: 48),
                        _buildDetailRow(
                          context,
                          icon: isTransfer ? Icons.call_made : Icons.account_balance_wallet_outlined,
                          iconColor: Colors.blueAccent,
                          label: isTransfer ? 'Source Account' : 'Account / Mode',
                          value: account?.name ?? 'Not Specified',
                          isDark: isDark,
                        ),
                        if (isTransfer && toAccount != null) ...[
                          const Divider(height: 1, indent: 48),
                          _buildDetailRow(
                            context,
                            icon: Icons.call_received,
                            iconColor: Colors.greenAccent,
                            label: 'Destination Account',
                            value: toAccount!.name,
                            isDark: isDark,
                          ),
                        ],
                        const Divider(height: 1, indent: 48),
                        _buildDetailRow(
                          context,
                          icon: Icons.calendar_today_outlined,
                          iconColor: Colors.orangeAccent,
                          label: 'Date & Time',
                          value: DateFormat('EEEE, dd MMM yyyy • hh:mm a').format(transaction.transactionDate),
                          isDark: isDark,
                        ),
                        if (transaction.notes != null && transaction.notes!.trim().isNotEmpty) ...[
                          const Divider(height: 1, indent: 48),
                          _buildDetailRow(
                            context,
                            icon: Icons.notes_outlined,
                            iconColor: Colors.purpleAccent,
                            label: 'Notes / Remarks',
                            value: transaction.notes!,
                            isDark: isDark,
                          ),
                        ],
                        if (transaction.tag != null && transaction.tag!.isNotEmpty) ...[
                          const Divider(height: 1, indent: 48),
                          _buildDetailRow(
                            context,
                            icon: Icons.tag,
                            iconColor: Colors.tealAccent,
                            label: 'System Reference',
                            value: _formatTagDescription(transaction.tag!),
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Gap(16),

                  // 3. Special Linked Asset Deep Dive Card (Investment or Loan)
                  if (isInvestmentTx) ...[
                    _buildLinkedInvestmentCard(context, ref, transaction, isDark: isDark),
                    const Gap(16),
                  ] else if (isLoanTx) ...[
                    _buildLinkedLoanCard(context, ref, transaction, isDark: isDark),
                    const Gap(16),
                  ] else if (isTransfer) ...[
                    _buildTransferInfoCard(isDark: isDark),
                    const Gap(16),
                  ],

                  // 4. Action Buttons (Edit / Delete for Standard Transactions)
                  if (!isInvestmentTx && !isLoanTx && !isTransfer) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              foregroundColor: AppColors.expense,
                              side: const BorderSide(color: AppColors.expense),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _confirmDeleteTransaction(context, ref),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => QuickAddSheet(transactionToEdit: transaction),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedInvestmentCard(
    BuildContext context,
    WidgetRef ref,
    Transaction tx, {
    required bool isDark,
  }) {
    final invId = _extractInvestmentId(tx.tag);
    final db = ref.read(databaseProvider);

    return FutureBuilder<Investment?>(
      future: invId != null ? db.getInvestmentById(invId) : Future.value(null),
      builder: (context, snapshot) {
        final inv = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.ppf.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ppf.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.ppf, size: 20),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      inv?.name ?? 'Investment Portfolio Record',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ppf),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (inv != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.ppf.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        inv.status == 'matured' || inv.status == 'closed' ? 'Archived' : 'Active',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.ppf),
                      ),
                    ),
                ],
              ),
              const Gap(8),
              Text(
                'This transaction is locked to maintain compound interest and valuation consistency. All edits, passbook history, and interest entries are managed in its studio.',
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
              if (inv != null) ...[
                const Gap(10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ppf,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(
                      'Open ${inv.name} Studio',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToInvestmentStudio(context, inv);
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLinkedLoanCard(
    BuildContext context,
    WidgetRef ref,
    Transaction tx, {
    required bool isDark,
  }) {
    final loanId = _extractLoanId(tx.tag);
    final db = ref.read(databaseProvider);

    return FutureBuilder<EmiLoan?>(
      future: loanId != null ? db.getLoanById(loanId) : Future.value(null),
      builder: (context, snapshot) {
        final loan = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.loan.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.loan.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.request_quote_outlined, color: AppColors.loan, size: 20),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      loan?.productName ?? 'EMI Loan Account Record',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.loan),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (loan != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.loan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        loan.status.toUpperCase(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.loan),
                      ),
                    ),
                ],
              ),
              const Gap(8),
              Text(
                'This transaction is linked to an active loan. Principal repayments, remaining tenure, and amortizations are tracked in Loan Details.',
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
              if (loan != null) ...[
                const Gap(10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.loan,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(
                      'Open ${loan.productName} Details',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LoanDetailsScreen(loan: loan)),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransferInfoCard({required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.lightBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.lightBlueAccent, size: 20),
          const Gap(10),
          Expanded(
            child: Text(
              'Direct transfer between accounts. Both sending and receiving account balances are kept synchronized.',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToInvestmentStudio(BuildContext context, Investment inv) {
    switch (inv.type) {
      case 'ppf':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PpfStudioScreen(ppfInvestment: inv)),
        );
        break;
      case 'fd':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FdStudioScreen(fdInvestment: inv)),
        );
        break;
      case 'rd':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RdStudioScreen(rdInvestment: inv)),
        );
        break;
      case 'sip':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SipStudioScreen(sipInvestment: inv)),
        );
        break;
      case 'chitty':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChittyStudioScreen(chittyInvestment: inv)),
        );
        break;
      case 'gold':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GoldStudioScreen(investment: inv)),
        );
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => InvestmentDetailsScreen(investment: inv)),
        );
        break;
    }
  }

  Future<void> _confirmDeleteTransaction(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('Are you sure you want to delete this transaction from your ledger? Account balance will be reconciled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(databaseProvider).deleteTransactionWithAccountUpdate(transaction.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    }
  }

  String _getTypeBadgeLabel(Transaction tx) {
    if (tx.type == 'transfer') return 'ACCOUNT TRANSFER';
    if (tx.tag?.startsWith('INV:') == true) {
      if (tx.tag?.contains('ppf_interest') == true || tx.tag?.contains('interest_payout') == true) {
        return 'INVESTMENT INTEREST';
      }
      if (tx.tag?.contains('deposit') == true || tx.tag?.contains('installment') == true) {
        return 'INVESTMENT DEPOSIT';
      }
      return 'INVESTMENT RECORD';
    }
    if (tx.tag?.startsWith('LOAN:') == true || tx.tag?.startsWith('LOAN_PAYMENT:') == true) {
      return 'LOAN EMI PAYMENT';
    }
    if (tx.tag?.startsWith('LOAN_DISBURSE:') == true) {
      return 'LOAN DISBURSAL';
    }
    return tx.type.toUpperCase();
  }

  String _formatTagDescription(String tag) {
    if (tag.startsWith('INV:')) {
      final parts = tag.split(':');
      if (parts.length >= 3) {
        final action = parts[2].replaceAll('_', ' ').toUpperCase();
        return 'Investment • $action';
      }
      return 'Investment Record';
    }
    if (tag.startsWith('LOAN:')) {
      return 'Loan EMI Payment';
    }
    if (tag.startsWith('LOAN_DISBURSE:')) {
      return 'Loan Disbursal Credit';
    }
    if (tag.startsWith('TRANSFER:')) {
      return 'Inter-Account Transfer';
    }
    return tag;
  }

  String? _extractInvestmentId(String? tag) {
    if (tag == null || !tag.startsWith('INV:')) return null;
    final parts = tag.split(':');
    return parts.length >= 2 ? parts[1] : null;
  }

  String? _extractLoanId(String? tag) {
    if (tag == null) return null;
    if (tag.startsWith('LOAN:')) {
      final parts = tag.split(':');
      return parts.length >= 2 ? parts[1] : null;
    }
    if (tag.startsWith('LOAN_DISBURSE:')) {
      final parts = tag.split(':');
      return parts.length >= 2 ? parts[1] : null;
    }
    if (tag.startsWith('LOAN_PAYMENT:')) {
      final parts = tag.split(':');
      return parts.length >= 2 ? parts[1] : null;
    }
    return null;
  }
}
