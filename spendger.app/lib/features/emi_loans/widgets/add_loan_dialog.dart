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

class AddLoanDialog extends ConsumerStatefulWidget {
  final EmiLoan? loanToEdit;

  const AddLoanDialog({super.key, this.loanToEdit});

  @override
  ConsumerState<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends ConsumerState<AddLoanDialog> {
  final _productNameController = TextEditingController();
  final _lenderNameController = TextEditingController();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _gstController = TextEditingController(text: '0.0');
  DateTime _startDate = DateTime.now();

  double _calculatedEmi = 0.0;
  bool get _isEditing => widget.loanToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final loan = widget.loanToEdit!;
      _productNameController.text = loan.productName;
      _lenderNameController.text = loan.lenderName ?? '';
      _principalController.text = loan.principalAmount.truncateToDouble() == loan.principalAmount
          ? loan.principalAmount.toInt().toString()
          : loan.principalAmount.toString();
      _rateController.text = loan.annualInterestRate.toString();
      _tenureController.text = loan.tenureMonths.toString();
      _gstController.text = loan.gstRateOnInterest.toString();
      _startDate = loan.startDate;
      _calculatedEmi = loan.monthlyEmi;
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _lenderNameController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _recalculateEmi() {
    final principal = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final tenure = int.tryParse(_tenureController.text.trim()) ?? 0;

    setState(() {
      _calculatedEmi = FinancialMath.calculateEmi(
        principal: principal,
        annualInterestRate: rate,
        tenureMonths: tenure,
      );
    });
  }

  Future<void> _saveLoan() async {
    final productName = _productNameController.text.trim();
    final principal = double.tryParse(_principalController.text.trim());
    final rate = double.tryParse(_rateController.text.trim());
    final tenure = int.tryParse(_tenureController.text.trim());
    final gstRate = double.tryParse(_gstController.text.trim()) ?? 0.0;

    if (productName.isEmpty || principal == null || rate == null || tenure == null || principal <= 0 || tenure <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all loan fields accurately')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final emi = FinancialMath.calculateEmi(
      principal: principal,
      annualInterestRate: rate,
      tenureMonths: tenure,
    );

    if (_isEditing) {
      final updatedCompanion = EmiLoansCompanion(
        id: drift.Value(widget.loanToEdit!.id),
        productName: drift.Value(productName),
        lenderName: drift.Value(_lenderNameController.text.trim().isEmpty ? null : _lenderNameController.text.trim()),
        principalAmount: drift.Value(principal),
        annualInterestRate: drift.Value(rate),
        tenureMonths: drift.Value(tenure),
        monthlyEmi: drift.Value(emi),
        startDate: drift.Value(_startDate),
        gstRateOnInterest: drift.Value(gstRate),
        status: drift.Value(widget.loanToEdit!.status),
        createdAt: drift.Value(widget.loanToEdit!.createdAt),
      );

      await db.updateLoan(widget.loanToEdit!.id, updatedCompanion);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EMI Loan updated successfully!'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    } else {
      const uuid = Uuid();
      final loanId = uuid.v4();
      final now = DateTime.now();

      await db.into(db.emiLoans).insert(
        EmiLoansCompanion.insert(
          id: loanId,
          productName: productName,
          lenderName: drift.Value(_lenderNameController.text.trim().isEmpty ? null : _lenderNameController.text.trim()),
          principalAmount: principal,
          annualInterestRate: rate,
          tenureMonths: tenure,
          monthlyEmi: emi,
          startDate: _startDate,
          gstRateOnInterest: drift.Value(gstRate),
          status: const drift.Value('active'),
          createdAt: now,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EMI Loan created successfully!'),
            backgroundColor: AppColors.loan,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit EMI Loan' : 'Add New EMI Loan', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product / Loan Name (e.g., iPhone 16)',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const Gap(12),
            TextField(
              controller: _lenderNameController,
              decoration: const InputDecoration(
                labelText: 'Lender / Bank (e.g., HDFC, Bajaj Finserv)',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
            ),
            const Gap(12),
            TextField(
              controller: _principalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _recalculateEmi(),
              decoration: const InputDecoration(
                labelText: 'Total Principal Amount (₹)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _recalculateEmi(),
                    decoration: const InputDecoration(
                      labelText: 'Annual Rate (%)',
                      prefixIcon: Icon(Icons.percent),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: TextField(
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalculateEmi(),
                    decoration: const InputDecoration(
                      labelText: 'Tenure (Months)',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            // Loan Start / Disbursal Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Loan Start / Disbursal Date',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(_startDate),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const Icon(Icons.edit_calendar, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const Gap(12),
            TextField(
              controller: _gstController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'GST on Interest (%) - Optional',
                prefixIcon: Icon(Icons.receipt_outlined),
                helperText: 'Standard in India is 18.0% if applicable',
              ),
            ),
            const Gap(16),
            // Live Calculated EMI preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.loan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.loan.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Monthly EMI:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    CurrencyFormatter.format(_calculatedEmi),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.loanLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.loan, foregroundColor: Colors.white),
          onPressed: _saveLoan,
          child: Text(_isEditing ? 'Update Loan Details' : 'Create EMI Schedule'),
        ),
      ],
    );
  }
}
