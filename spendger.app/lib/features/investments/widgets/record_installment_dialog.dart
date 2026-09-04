import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';

class RecordInstallmentDialog extends ConsumerStatefulWidget {
  final Investment investment;
  final InvestmentScheduleItem scheduleItem;
  final Transaction? existingTransaction;

  const RecordInstallmentDialog({
    super.key,
    required this.investment,
    required this.scheduleItem,
    this.existingTransaction,
  });

  @override
  ConsumerState<RecordInstallmentDialog> createState() => _RecordInstallmentDialogState();
}

class _RecordInstallmentDialogState extends ConsumerState<RecordInstallmentDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _paymentDate = tx.transactionDate;
      _selectedAccountId = tx.accountId;
      _notesController.text = tx.notes ?? '';
    } else {
      _amountController.text = widget.scheduleItem.scheduledAmount.toStringAsFixed(0);
      _notesController.text = '${widget.investment.name} - ${widget.scheduleItem.periodLabel}';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveInstallment() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final isPayout = widget.scheduleItem.periodLabel.toLowerCase().contains('payout') ||
        widget.scheduleItem.periodLabel.toLowerCase().contains('maturity');
    final txType = isPayout ? 'income' : 'expense';
    final tag = 'INV:${widget.investment.id}:period:${widget.scheduleItem.periodNumber}';

    final categories = await db.getAllCategories(type: txType);
    final cat = categories.firstWhere(
      (c) => c.name.toLowerCase().contains('investment'),
      orElse: () => categories.first,
    );

    if (widget.existingTransaction != null) {
      // Update existing transaction
      await db.updateTransactionWithAccountUpdate(
        widget.existingTransaction!,
        TransactionsCompanion(
          id: drift.Value(widget.existingTransaction!.id),
          categoryId: drift.Value(cat.id),
          accountId: drift.Value(_selectedAccountId),
          amount: drift.Value(amount),
          type: drift.Value(txType),
          transactionDate: drift.Value(_paymentDate),
          notes: drift.Value(_notesController.text.trim()),
          tag: drift.Value(tag),
        ),
      );
    } else {
      // Create new transaction
      const uuid = Uuid();
      await db.addTransactionWithAccountUpdate(
        TransactionsCompanion.insert(
          id: uuid.v4(),
          categoryId: cat.id,
          accountId: drift.Value(_selectedAccountId),
          amount: amount,
          type: txType,
          transactionDate: _paymentDate,
          notes: drift.Value(_notesController.text.trim()),
          tag: drift.Value(tag),
          createdAt: DateTime.now(),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingTransaction != null ? 'Payment updated!' : 'Payment marked & logged in ledger!'),
          backgroundColor: AppColors.incomeLight,
        ),
      );
    }
  }

  Future<void> _deletePayment() async {
    if (widget.existingTransaction != null) {
      final db = ref.read(databaseProvider);
      await db.deleteTransactionWithAccountUpdate(widget.existingTransaction!.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment reverted and deleted from ledger')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final isPaid = widget.existingTransaction != null;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isPaid ? AppColors.income.withValues(alpha: 0.2) : AppColors.investment.withValues(alpha: 0.2),
            child: Icon(isPaid ? Icons.check : Icons.payments_outlined, size: 18, color: isPaid ? AppColors.incomeLight : AppColors.investment),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPaid ? 'Edit Logged Payment' : 'Mark Installment Paid',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.investment.name} • ${widget.scheduleItem.periodLabel}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scheduled Info Pill
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.darkCardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Scheduled Due Date', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const Gap(2),
                        Text(
                          DateFormat('dd MMM yyyy').format(widget.scheduleItem.dueDate),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Scheduled Amount', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(widget.scheduleItem.scheduledAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.investment),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(12),

              // Actual Amount Paid
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Actual Amount Paid (₹)',
                  hintText: 'e.g. 5000',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const Gap(10),

              // Account Selector
              if (accounts.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Debited from Account',
                    prefixIcon: Icon(Icons.account_balance),
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
                      _selectedAccountId = val;
                    });
                  },
                ),
                const Gap(10),
              ],

              // Payment Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _paymentDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade600.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                          const Gap(8),
                          Text('Paid On: ${DateFormat('dd MMM yyyy').format(_paymentDate)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const Gap(10),

              // Note
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ledger Note',
                  hintText: 'e.g. Monthly RD Auto-debit',
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isPaid)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseLight),
            onPressed: _deletePayment,
            child: const Text('Revert / Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.income, foregroundColor: Colors.white),
          onPressed: _saveInstallment,
          child: Text(isPaid ? 'Update Payment' : 'Confirm & Mark Paid'),
        ),
      ],
    );
  }
}
