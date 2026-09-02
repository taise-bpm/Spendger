import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';

class AddLoanDialog extends ConsumerStatefulWidget {
  const AddLoanDialog({super.key});

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

  double _calculatedEmi = 0.0;

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
    const uuid = Uuid();
    final loanId = uuid.v4();
    final now = DateTime.now();

    final emi = FinancialMath.calculateEmi(
      principal: principal,
      annualInterestRate: rate,
      tenureMonths: tenure,
    );

    await db.into(db.emiLoans).insert(
      EmiLoansCompanion.insert(
        id: loanId,
        productName: productName,
        lenderName: drift.Value(_lenderNameController.text.trim().isEmpty ? null : _lenderNameController.text.trim()),
        principalAmount: principal,
        annualInterestRate: rate,
        tenureMonths: tenure,
        monthlyEmi: emi,
        startDate: now,
        gstRateOnInterest: drift.Value(gstRate),
        status: const drift.Value('active'),
        createdAt: now,
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('EMI Loan created successfully!'),
          backgroundColor: AppColors.loan,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add EMI Loan', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Loan / Product Name',
                hintText: 'e.g. Home Loan, iPhone 16 EMI',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const Gap(10),
            TextField(
              controller: _lenderNameController,
              decoration: const InputDecoration(
                labelText: 'Lender / Bank (Optional)',
                hintText: 'e.g. HDFC, Chase, SBI',
                prefixIcon: Icon(Icons.account_balance),
              ),
            ),
            const Gap(10),
            TextField(
              controller: _principalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _recalculateEmi(),
              decoration: const InputDecoration(
                labelText: 'Total Principal Amount (₹)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _recalculateEmi(),
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate (% p.a.)',
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
            const Gap(10),
            TextField(
              controller: _gstController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'GST on Interest Rate (%)',
                hintText: 'e.g. 18.0 for India, 0 for none',
                prefixIcon: Icon(Icons.receipt_outlined),
              ),
            ),
            const Gap(14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.loan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.loan.withValues(alpha: 0.25)),
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
          child: const Text('Add Loan'),
        ),
      ],
    );
  }
}
