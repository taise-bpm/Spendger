import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../widgets/add_chitty_dialog.dart';
import '../widgets/record_dividend_dialog.dart';

class ChittyStudioScreen extends ConsumerWidget {
  final Investment chittyInvestment;

  const ChittyStudioScreen({super.key, required this.chittyInvestment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allInvestmentsAsync = ref.watch(investmentsStreamProvider(null));
    final currentInv = allInvestmentsAsync.value?.firstWhere(
          (i) => i.id == chittyInvestment.id,
          orElse: () => chittyInvestment,
        ) ??
        chittyInvestment;

    final isClosed = currentInv.status == 'matured' || currentInv.status == 'closed';

    // Parse JSON notes metadata
    Map<String, dynamic> notesData = {};
    if (currentInv.notes != null && currentInv.notes!.trim().startsWith('{')) {
      try {
        notesData = jsonDecode(currentInv.notes!) as Map<String, dynamic>;
      } catch (_) {}
    }

    final isPrized = notesData['isPrized'] == true;
    final prizedMonth = _parseInt(notesData['prizedMonth']);
    final prizeOption = notesData['prizeOption']?.toString();
    final prizeAmount = _parseDouble(notesData['prizeAmount']);
    final prizeDisbursed = notesData['prizeDisbursed'] == true;
    final fdInterestMonthly = _parseDouble(notesData['fdInterestMonthly']);

    final installmentsAsync = ref.watch(chittyInstallmentsStreamProvider(currentInv.id));
    final installments = installmentsAsync.value ?? [];

    final paidInstallments = installments.where((c) => c.isPaid).toList();
    final paidCount = paidInstallments.length;
    final lastPaidInst = paidInstallments.isNotEmpty ? paidInstallments.last : null;

    final totalPaid = paidInstallments.fold(0.0, (sum, c) => sum + c.netAmountPaid);
    final totalDividend = paidInstallments.fold(0.0, (sum, c) => sum + c.dividendEarned);
    final totalChitValue = currentInv.totalCommittedAmount ?? (installments.isNotEmpty ? installments.first.grossInstallment * installments.length : 0.0);
    final progress = totalChitValue > 0 ? (totalPaid / totalChitValue).clamp(0.0, 1.0) : 0.0;

    final isAllInstallmentsPaid = installments.isNotEmpty && paidCount == installments.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentInv.name} Studio', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Chitty Options',
            onSelected: (value) async {
              if (value == 'edit') {
                showDialog(context: context, builder: (_) => AddChittyDialog(investmentToEdit: currentInv));
              } else if (value == 'revert_last' && lastPaidInst != null) {
                _confirmRevertInstallment(context, ref, lastPaidInst);
              } else if (value == 'clear_prize') {
                _confirmClearPrizeDeclaration(context, ref, currentInv, prizedMonth, prizeAmount);
              } else if (value == 'delete') {
                _confirmDeleteChitty(context, ref, currentInv);
              }
            },
            itemBuilder: (context) => [
              if (!isClosed)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      Gap(10),
                      Text('Edit Scheme Parameters'),
                    ],
                  ),
                ),
              if (!isClosed && lastPaidInst != null)
                PopupMenuItem(
                  value: 'revert_last',
                  child: Row(
                    children: [
                      const Icon(Icons.undo, color: AppColors.expense, size: 20),
                      const Gap(10),
                      Text('Revert Month ${lastPaidInst.installmentNumber} Payment'),
                    ],
                  ),
                ),
              if (isPrized)
                const PopupMenuItem(
                  value: 'clear_prize',
                  child: Row(
                    children: [
                      Icon(Icons.restart_alt, color: AppColors.loanLight, size: 20),
                      Gap(10),
                      Text('Reset Prize Declaration'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.expense, size: 20),
                    Gap(10),
                    Text('Delete Chitty Scheme', style: TextStyle(color: AppColors.expense)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          // 1. Chitty Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF831843), Color(0xFF500724)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.chitty.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Total Chit Value: ${CurrencyFormatter.format(totalChitValue)}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isClosed ? Colors.amber.withValues(alpha: 0.25) : AppColors.income.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isClosed ? 'MATURED / CLOSED' : 'ACTIVE CHITTY',
                        style: TextStyle(
                          color: isClosed ? Colors.amber.shade200 : AppColors.incomeLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Net Paid', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalPaid),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Dividends Saved', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalDividend),
                          style: const TextStyle(color: AppColors.incomeLight, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.chitty),
                  ),
                ),
                const Gap(6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$paidCount / ${installments.length} Months Completed', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                    Text('${(progress * 100).toStringAsFixed(0)}% Paid', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                  ],
                ),

                // Prized Status Banner Inside Header
                if (isPrized) ...[
                  const Gap(14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: prizeOption == 'chitty_fd'
                          ? Colors.amber.shade900.withValues(alpha: 0.35)
                          : Colors.teal.shade900.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: prizeOption == 'chitty_fd'
                            ? Colors.amber.shade400.withValues(alpha: 0.5)
                            : Colors.tealAccent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          prizeOption == 'chitty_fd' ? Icons.account_balance : Icons.account_balance_wallet,
                          color: prizeOption == 'chitty_fd' ? Colors.amber.shade300 : Colors.tealAccent,
                          size: 20,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prizeOption == 'chitty_fd'
                                    ? 'Chitty Security FD: ${CurrencyFormatter.format(prizeAmount)}'
                                    : (prizeDisbursed
                                        ? 'Prize Money Received: ${CurrencyFormatter.format(prizeAmount)}'
                                        : 'Auction Won: ${CurrencyFormatter.format(prizeAmount)} (Pending Disbursal)'),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const Gap(2),
                              Text(
                                prizeOption == 'chitty_fd'
                                    ? 'Monthly interest of ${CurrencyFormatter.format(fdInterestMonthly)} offsets subsequent installment subscriptions.'
                                    : (prizeDisbursed
                                        ? 'Credited to your bank account for Month $prizedMonth auction win.'
                                        : 'Won in Month $prizedMonth. Awaiting bank credit confirmation.'),
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(16),

          // 2. Reminder Banner: "Did you receive prize money?" (If prize won with withdrawal option but not credited yet)
          if (isPrized && prizeOption == 'withdrawn' && !prizeDisbursed) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.amber.shade900.withValues(alpha: 0.25) : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notification_important, color: Colors.amber.shade800, size: 22),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Did you receive prize money?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  Text(
                    'You won ${CurrencyFormatter.format(prizeAmount)} in Month $prizedMonth. Once the chitty company processes your surety and deposits the payout, mark it here to credit your bank account in the ledger.',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                  ),
                  const Gap(12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.income,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.account_balance_wallet, size: 16),
                      label: const Text('Mark as Received & Credit to Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () => _showDisbursePrizeMoneyDialog(context, ref, currentInv, prizeAmount, prizedMonth, notesData),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
          ],

          // 3. Maturity Checkout Card: "Did you receive matured amount?" (Visible only when ALL installments are paid and not closed)
          if (!isClosed && isAllInstallmentsPaid) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.income.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.income.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.incomeLight, size: 22),
                      Gap(8),
                      Expanded(
                        child: Text(
                          'Did you receive matured amount?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  Text(
                    'All ${installments.length} subscription installments have been successfully paid. Receive your final settlement / Chitty FD refund into your bank account and close this chitty scheme.',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                  ),
                  const Gap(12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.income,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Mark Matured & Settle to Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _showCheckoutChittyDialog(
                        context,
                        ref,
                        currentInv,
                        totalChitValue,
                        prizeOption,
                        prizeAmount,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
          ],

          // 4. Installments Schedule Table
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Installments & Auction Dividend Schedule', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              if (isClosed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('READ ONLY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
            ],
          ),
          const Gap(8),
          ...List.generate(installments.length, (i) {
            final inst = installments[i];
            // Sequential lock rule: An entry can only be edited if the next entry is NOT paid/marked
            final bool isLockedByNext = (i + 1 < installments.length) && installments[i + 1].isPaid;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (isClosed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('This Chitty is matured and in read-only mode.')),
                    );
                    return;
                  }
                  if (isLockedByNext) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Month ${inst.installmentNumber} is locked because Month ${installments[i + 1].installmentNumber} is already marked. Revert subsequent months to edit this.'),
                        backgroundColor: Colors.amber.shade900,
                      ),
                    );
                    return;
                  }
                  showDialog(context: context, builder: (_) => RecordDividendDialog(installment: inst));
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: inst.isPaid
                            ? (isLockedByNext ? Colors.grey.withValues(alpha: 0.2) : AppColors.income.withValues(alpha: 0.2))
                            : Colors.grey.withValues(alpha: 0.1),
                        child: inst.isPaid
                            ? (isLockedByNext
                                ? const Icon(Icons.lock, size: 14, color: Colors.grey)
                                : const Icon(Icons.check, size: 16, color: AppColors.incomeLight))
                            : Text('${inst.installmentNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  DateFormat('MMM yyyy').format(inst.dueDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                if (inst.isPaid) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isLockedByNext ? Colors.grey.withValues(alpha: 0.2) : AppColors.income.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isLockedByNext ? 'SETTLED' : 'PAID',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isLockedByNext ? Colors.grey : AppColors.incomeLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                if (inst.isPrizedMonth) ...[
                                  const Gap(6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('PRIZED', style: TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const Gap(4),
                            Text(
                              'Gross: ${CurrencyFormatter.format(inst.grossInstallment)}  •  Div: ${CurrencyFormatter.format(inst.dividendEarned)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(inst.netAmountPaid),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: inst.isPaid
                                  ? (isLockedByNext ? Colors.grey : AppColors.incomeLight)
                                  : AppColors.chitty,
                            ),
                          ),
                          Text(
                            isClosed
                                ? (inst.isPaid ? 'Settled' : 'Unpaid')
                                : (inst.isPaid
                                    ? (isLockedByNext ? 'Locked' : 'Recorded')
                                    : 'Log Dividend'),
                            style: TextStyle(
                              fontSize: 10,
                              color: isLockedByNext ? Colors.grey.shade500 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDisbursePrizeMoneyDialog(
    BuildContext context,
    WidgetRef ref,
    Investment currentInv,
    double prizeAmount,
    int prizedMonth,
    Map<String, dynamic> notesData,
  ) {
    final amountController = TextEditingController(text: prizeAmount > 0 ? prizeAmount.toStringAsFixed(0) : '');
    final noteController = TextEditingController(text: '${currentInv.name} - Auction Prize Money Received (Month $prizedMonth)');
    DateTime receiptDate = DateTime.now();
    String? selectedAccountId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final accountsAsync = ref.watch(accountsStreamProvider);
            final accounts = accountsAsync.value ?? [];

            if (selectedAccountId == null && accounts.isNotEmpty) {
              selectedAccountId = accounts.first.id;
            }

            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              title: const Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: AppColors.incomeLight, size: 24),
                  Gap(8),
                  Expanded(
                    child: Text('Credit Prize Money to Bank', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Prize Amount Received (₹)',
                          prefixIcon: Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const Gap(12),
                      if (accounts.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          value: selectedAccountId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Receiving Bank Account',
                            prefixIcon: Icon(Icons.account_balance),
                            border: OutlineInputBorder(),
                          ),
                          items: accounts.map((a) {
                            return DropdownMenuItem<String>(
                              value: a.id,
                              child: Text(
                                '${a.name} (${CurrencyFormatter.format(a.currentBalance)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedAccountId = val;
                            });
                          },
                        ),
                        const Gap(12),
                      ],
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Ledger Note',
                          prefixIcon: Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.income,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (selectedAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a destination Bank Account')),
                      );
                      return;
                    }
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid received amount')),
                      );
                      return;
                    }

                    final db = ref.read(databaseProvider);

                    // 1. Record prize money income in ledger
                    await db.recordChittyPrizePayout(
                      investmentId: currentInv.id,
                      investmentName: currentInv.name,
                      destinationAccountId: selectedAccountId!,
                      amount: amount,
                      date: receiptDate,
                      note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                    );

                    // 2. Mark prizeDisbursed = true in investment notes
                    final updatedNotes = Map<String, dynamic>.from(notesData);
                    updatedNotes['prizeDisbursed'] = true;
                    updatedNotes['prizeAmount'] = amount;

                    await (db.update(db.investments)..where((i) => i.id.equals(currentInv.id))).write(
                      InvestmentsCompanion(notes: drift.Value(jsonEncode(updatedNotes))),
                    );

                    if (context.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Prize money of ${CurrencyFormatter.format(amount)} credited to your account!'),
                          backgroundColor: AppColors.incomeLight,
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm & Credit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCheckoutChittyDialog(
    BuildContext context,
    WidgetRef ref,
    Investment currentInv,
    double totalChitValue,
    String? prizeOption,
    double prizeAmount,
  ) {
    // If user deposited prize money as FD, the maturity refund is that FD amount
    // If not prized, it's the full chit value/settlement
    final defaultAmount = (prizeOption == 'chitty_fd' && prizeAmount > 0)
        ? prizeAmount
        : totalChitValue;

    final amountController = TextEditingController(text: defaultAmount > 0 ? defaultAmount.toStringAsFixed(0) : '0');
    final noteController = TextEditingController(text: '${currentInv.name} Maturity Payout');
    DateTime payoutDate = DateTime.now();
    String? selectedAccountId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final accountsAsync = ref.watch(accountsStreamProvider);
            final accounts = accountsAsync.value ?? [];

            if (selectedAccountId == null && accounts.isNotEmpty) {
              selectedAccountId = accounts.first.id;
            }

            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              title: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.incomeLight, size: 24),
                  Gap(8),
                  Expanded(
                    child: Text('Did you receive matured amount?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (prizeOption == 'chitty_fd') ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade900.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  'Chitty Security FD of ${CurrencyFormatter.format(prizeAmount)} will be refunded and credited to your chosen bank account.',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                      ],
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Final Payout Received (₹)',
                          prefixIcon: Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const Gap(12),
                      if (accounts.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          value: selectedAccountId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Credit Payout to Bank Account',
                            prefixIcon: Icon(Icons.account_balance),
                            border: OutlineInputBorder(),
                          ),
                          items: accounts.map((a) {
                            return DropdownMenuItem<String>(
                              value: a.id,
                              child: Text(
                                '${a.name} (${CurrencyFormatter.format(a.currentBalance)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedAccountId = val;
                            });
                          },
                        ),
                        const Gap(12),
                      ],
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Ledger Note',
                          prefixIcon: Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.income,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    final db = ref.read(databaseProvider);

                    await db.matureChittyWithPayout(
                      investmentId: currentInv.id,
                      investmentName: currentInv.name,
                      destinationAccountId: selectedAccountId,
                      payoutAmount: amount,
                      date: payoutDate,
                      note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                    );

                    if (context.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${currentInv.name} marked as matured and funds transferred!'),
                          backgroundColor: AppColors.incomeLight,
                        ),
                      );
                    }
                  },
                  child: const Text('Transfer & Settle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmRevertInstallment(
    BuildContext context,
    WidgetRef ref,
    ChittyInstallment inst,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.undo, color: AppColors.expense, size: 24),
            Gap(8),
            Text('Revert Installment?'),
          ],
        ),
        content: Text('Revert Month ${inst.installmentNumber} payment and dividend record back to unpaid status?'),
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
            child: const Text('Revert to Unpaid'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.revertChittyInstallment(inst.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Month ${inst.installmentNumber} installment reverted to unpaid.'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _confirmClearPrizeDeclaration(
    BuildContext context,
    WidgetRef ref,
    Investment currentInv,
    int prizedMonth,
    double prizeAmount,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restart_alt, color: AppColors.loanLight, size: 24),
            Gap(8),
            Text('Reset Prize Declaration?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will reset the prize declaration for ${CurrencyFormatter.format(prizeAmount)} (Month $prizedMonth).',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'Any Chitty FD interest offsets will be cleared, and any pending prize payouts will be reverted. You will be able to re-declare prize money on any installment.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loanLight,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset Declaration'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.clearChittyPrizeDeclaration(currentInv.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prize money declaration and FD offsets have been reset.'),
            backgroundColor: AppColors.incomeLight,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteChitty(BuildContext context, WidgetRef ref, Investment currentInv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.expense, size: 24),
            const Gap(8),
            Text('Delete ${currentInv.name}?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You will lose every data associated to "${currentInv.name}".',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            const Text(
              'All installments, auction records, dividends, prize money payouts, and transaction history will be permanently deleted. This action cannot be undone.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
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
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await db.deleteInvestment(currentInv.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentInv.name} and all associated records have been deleted.'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
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
