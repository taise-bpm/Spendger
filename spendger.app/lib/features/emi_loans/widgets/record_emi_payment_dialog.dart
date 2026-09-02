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

  String? _selectedCategoryId;
  String? _selectedAccountId;
  bool _logToExpenseLedger = true;

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

    if (_isAlreadyPaid) {
      _loadLinkedTransaction();
    }
  }

  Future<void> _loadLinkedTransaction() async {
    final db = ref.read(databaseProvider);
    final tx = await db.getTransactionForEmiPayment(widget.loan.id, widget.scheduledItem.monthNumber);
    if (mounted) {
      setState(() {
        if (tx != null) {
          _selectedCategoryId = tx.categoryId;
          _selectedAccountId = tx.accountId;
          _logToExpenseLedger = true;
        }
      });
    }
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

  Future<void> _submitPayment() async {
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

    final db = ref.read(databaseProvider);
    await db.recordOrUpdateEmiPayment(
      loanId: widget.loan.id,
      installmentNumber: widget.scheduledItem.monthNumber,
      paymentDate: _paymentDate,
      principalPaid: principal,
      interestPaid: interest,
      gstPaid: gst,
      totalAmountPaid: total,
      categoryId: _logToExpenseLedger ? _selectedCategoryId : null,
      accountId: _logToExpenseLedger ? _selectedAccountId : null,
    );

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isAlreadyPaid
                ? 'Month #${widget.scheduledItem.monthNumber} payment & expense updated!'
                : 'Month #${widget.scheduledItem.monthNumber} payment recorded in Expense Ledger!',
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
        title: const Text('Unmark Payment?'),
        content: Text('Remove payment record and corresponding expense ledger entry for Month #${widget.scheduledItem.monthNumber}?'),
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

    if (_selectedCategoryId == null && expenseCategories.isNotEmpty) {
      // Find a category related to EMI/Loans or default to first
      final emiCat = expenseCategories.firstWhere(
        (c) => c.name.toLowerCase().contains('loan') || c.name.toLowerCase().contains('emi'),
        orElse: () => expenseCategories.first,
      );
      _selectedCategoryId = emiCat.id;
    }

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return AlertDialog(
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

            // Expense Ledger Integration Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.primaryLight),
                          Gap(6),
                          Text('Log in Expense Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Switch(
                        value: _logToExpenseLedger,
                        activeThumbColor: AppColors.primaryLight,
                        onChanged: (val) => setState(() => _logToExpenseLedger = val),
                      ),
                    ],
                  ),
                  if (_logToExpenseLedger) ...[
                    const Gap(8),
                    // Expense Header Tag Dropdown
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Expense Header / Category',
                        prefixIcon: Icon(Icons.category_outlined, size: 18),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategoryId,
                          isExpanded: true,
                          items: expenseCategories.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Color(c.colorValue),
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                        ),
                      ),
                    ),
                    const Gap(10),
                    // Paid from Account
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Deduct From Account',
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAccountId,
                          isExpanded: true,
                          items: accounts.map((a) {
                            return DropdownMenuItem(
                              value: a.id,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(a.name, overflow: TextOverflow.ellipsis),
                                  Text(
                                    CurrencyFormatter.format(a.currentBalance),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedAccountId = val),
                        ),
                      ),
                    ),
                  ],
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
          onPressed: _submitPayment,
          child: Text(_isAlreadyPaid ? 'Update Payment' : 'Save Payment'),
        ),
      ],
    );
  }
}
