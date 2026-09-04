import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';

class RecordEmiPaymentDialog extends ConsumerStatefulWidget {
  final EmiLoan loan;
  final AmortizationInstallment scheduledItem;
  final EmiPayment? existingPayment;

  const RecordEmiPaymentDialog({
    super.key,
    required this.loan,
    required this.scheduledItem,
    this.existingPayment,
  });

  @override
  ConsumerState<RecordEmiPaymentDialog> createState() => _RecordEmiPaymentDialogState();
}

class _RecordEmiPaymentDialogState extends ConsumerState<RecordEmiPaymentDialog> {
  late TextEditingController _totalEmiController;
  late TextEditingController _interestController;
  late TextEditingController _gstController;
  late DateTime _paymentDate;

  bool get _isAlreadyPaid => widget.existingPayment != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPayment;
    final item = widget.scheduledItem;

    final initialTotal = p != null ? p.totalAmountPaid : item.totalPayment;
    final initialInterest = p != null ? p.interestPaid : item.interest;
    final initialGst = p != null ? p.gstPaid : item.gstOnInterest;

    _totalEmiController = TextEditingController(
      text: initialTotal.truncateToDouble() == initialTotal
          ? initialTotal.toInt().toString()
          : initialTotal.toStringAsFixed(2),
    );

    _interestController = TextEditingController(
      text: initialInterest.truncateToDouble() == initialInterest
          ? initialInterest.toInt().toString()
          : initialInterest.toStringAsFixed(2),
    );

    _gstController = TextEditingController(
      text: initialGst.truncateToDouble() == initialGst
          ? initialGst.toInt().toString()
          : initialGst.toStringAsFixed(2),
    );

    _paymentDate = p?.paymentDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _totalEmiController.dispose();
    _interestController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  double get _calculatedPrincipal {
    final total = double.tryParse(_totalEmiController.text.trim()) ?? 0.0;
    final interest = double.tryParse(_interestController.text.trim()) ?? 0.0;
    final gst = double.tryParse(_gstController.text.trim()) ?? 0.0;
    final principal = total - interest - gst;
    return principal > 0 ? principal : 0.0;
  }

  Future<void> _submitPayment(String? defaultCatId, String? defaultAccId) async {
    final total = double.tryParse(_totalEmiController.text.trim());
    final interest = double.tryParse(_interestController.text.trim());
    final gst = double.tryParse(_gstController.text.trim()) ?? 0.0;

    if (total == null || total <= 0 || interest == null || interest < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid payment numbers')),
      );
      return;
    }

    final principal = (total - interest - gst);
    if (principal < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interest + GST cannot exceed total EMI amount')),
      );
      return;
    }

    final catIdToUse = widget.loan.autoLogExpense
        ? (widget.loan.expenseCategoryId ?? defaultCatId)
        : null;
    final accIdToUse = widget.loan.autoLogExpense
        ? (widget.loan.defaultAccountId ?? defaultAccId)
        : null;

    final db = ref.read(databaseProvider);
    await db.recordOrUpdateEmiPayment(
      loanId: widget.loan.id,
      installmentNumber: widget.scheduledItem.monthNumber,
      paymentDate: _paymentDate,
      principalPaid: principal,
      interestPaid: interest,
      gstPaid: gst,
      totalAmountPaid: total,
      categoryId: catIdToUse,
      accountId: accIdToUse,
    );

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isAlreadyPaid
                ? 'Month #${widget.scheduledItem.monthNumber} payment updated!'
                : (widget.loan.autoLogExpense
                    ? 'Month #${widget.scheduledItem.monthNumber} payment recorded in Expense Ledger!'
                    : 'Month #${widget.scheduledItem.monthNumber} payment recorded!'),
          ),
          backgroundColor: AppColors.income,
        ),
      );
    }
  }

  Future<void> _deletePayment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Unmark Payment?'),
        content: Text('Remove payment record and corresponding expense entry for Month #${widget.scheduledItem.monthNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Unmark'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await db.deleteEmiPayment(widget.loan.id, widget.scheduledItem.monthNumber);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment and ledger entry removed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final principal = _calculatedPrincipal;
    final interest = double.tryParse(_interestController.text.trim()) ?? 0.0;
    final gst = double.tryParse(_gstController.text.trim()) ?? 0.0;

    final categoriesAsync = ref.watch(categoriesStreamProvider('expense'));
    final accountsAsync = ref.watch(accountsStreamProvider);

    final expenseCategories = categoriesAsync.value ?? [];
    final accounts = accountsAsync.value ?? [];

    Category? configuredCat;
    if (widget.loan.expenseCategoryId != null) {
      for (final c in expenseCategories) {
        if (c.id == widget.loan.expenseCategoryId) {
          configuredCat = c;
          break;
        }
      }
    }
    configuredCat ??= expenseCategories.firstWhere(
      (c) => c.name.toLowerCase().contains('loan') || c.name.toLowerCase().contains('emi'),
      orElse: () => expenseCategories.isNotEmpty ? expenseCategories.first : Category(id: '', name: 'General Expense', type: 'expense', iconCode: 0, colorValue: 0xFF10B981, isCustom: false, createdAt: DateTime.now()),
    );

    Account? configuredAccount;
    if (widget.loan.defaultAccountId != null) {
      for (final a in accounts) {
        if (a.id == widget.loan.defaultAccountId) {
          configuredAccount = a;
          break;
        }
      }
    }
    configuredAccount ??= accounts.isNotEmpty ? accounts.first : null;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.loan.withValues(alpha: 0.2),
            child: Text(
              '${widget.scheduledItem.monthNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.loanLight),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAlreadyPaid ? 'Edit Recorded Payment' : 'Record EMI Payment',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.loan.productName} • ${DateFormat('MMM yyyy').format(widget.scheduledItem.dueDate)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total EMI field
            TextField(
              controller: _totalEmiController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Total EMI Paid (₹)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const Gap(12),
            // Actual Interest field
            TextField(
              controller: _interestController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Actual Interest Paid (₹)',
                prefixIcon: const Icon(Icons.percent, color: AppColors.expenseLight),
                helperText: 'Scheduled was: ${CurrencyFormatter.format(widget.scheduledItem.interest)}',
              ),
            ),
            const Gap(12),
            // GST on Interest field
            if (widget.loan.gstRateOnInterest > 0 || gst > 0) ...[
              TextField(
                controller: _gstController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'GST on Interest (₹) - Optional',
                  prefixIcon: Icon(Icons.receipt_outlined),
                ),
              ),
              const Gap(12),
            ],
            // Payment Date
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _paymentDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Payment Date',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(_paymentDate),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const Icon(Icons.edit_calendar, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const Gap(14),

            // Clean Information Note on Expense Ledger Posting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.loan.autoLogExpense
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.loan.autoLogExpense
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    widget.loan.autoLogExpense ? Icons.receipt_long_outlined : Icons.info_outline,
                    size: 18,
                    color: widget.loan.autoLogExpense ? AppColors.primaryLight : Colors.grey,
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.loan.autoLogExpense
                              ? 'Posts to Expense Ledger'
                              : 'Expense Ledger Sync Disabled',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.loan.autoLogExpense ? AppColors.primaryLight : Colors.grey,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          widget.loan.autoLogExpense
                              ? 'Tagged under "${configuredCat.name}"${configuredAccount != null ? ' from "${configuredAccount.name}"' : ''}.'
                              : 'This payment will only update loan amortization without creating an expense entry.',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const Gap(2),
                        const Text(
                          'Change default header & account in EMI Settings (⋮).',
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(14),

            // Live Breakdown Result Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.income.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.income.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CALCULATED BREAKDOWN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey)),
                  const Gap(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Principal Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        CurrencyFormatter.format(principal),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.incomeLight),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Interest Paid:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(CurrencyFormatter.format(interest), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  if (gst > 0) ...[
                    const Gap(2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST Paid:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(CurrencyFormatter.format(gst), style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_isAlreadyPaid)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseLight),
            onPressed: _deletePayment,
            child: const Text('Unmark Paid'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.loan, foregroundColor: Colors.white),
          onPressed: () => _submitPayment(configuredCat?.id, configuredAccount?.id),
          child: Text(_isAlreadyPaid ? 'Update Payment' : 'Save Payment'),
        ),
      ],
    );
  }
}
