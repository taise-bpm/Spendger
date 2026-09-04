import 'dart:convert';
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

class AddRdDialog extends ConsumerStatefulWidget {
  final Investment? investmentToEdit;

  const AddRdDialog({super.key, this.investmentToEdit});

  @override
  ConsumerState<AddRdDialog> createState() => _AddRdDialogState();
}

class _AddRdDialogState extends ConsumerState<AddRdDialog> {
  final _nameController = TextEditingController();
  final _monthlyDepositController = TextEditingController();
  final _rateController = TextEditingController(text: '7.0');
  final _tenureMonthsController = TextEditingController(text: '12');

  DateTime _startDate = DateTime.now();
  DepositMaturityResult? _previewResult;

  @override
  void initState() {
    super.initState();
    if (widget.investmentToEdit != null) {
      final inv = widget.investmentToEdit!;
      _nameController.text = inv.name;
      _monthlyDepositController.text = (inv.purchasePrice ?? 0.0).toStringAsFixed(0);
      _startDate = inv.startDate;
      if (inv.notes != null) {
        try {
          final notesData = jsonDecode(inv.notes!);
          if (notesData['rate'] != null) _rateController.text = notesData['rate'].toString();
          if (notesData['tenureMonths'] != null) _tenureMonthsController.text = notesData['tenureMonths'].toString();
        } catch (_) {}
      }
    }
    _recalculatePreview();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _monthlyDepositController.dispose();
    _rateController.dispose();
    _tenureMonthsController.dispose();
    super.dispose();
  }

  void _recalculatePreview() {
    final monthly = double.tryParse(_monthlyDepositController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final months = int.tryParse(_tenureMonthsController.text.trim()) ?? 0;

    if (monthly > 0 && rate > 0 && months > 0) {
      setState(() {
        _previewResult = FinancialMath.calculateRdMaturity(
          monthlyDeposit: monthly,
          annualInterestRate: rate,
          tenureMonths: months,
        );
      });
    } else {
      setState(() {
        _previewResult = null;
      });
    }
  }

  Future<void> _saveRd() async {
    final name = _nameController.text.trim();
    final monthly = double.tryParse(_monthlyDepositController.text.trim());
    final rate = double.tryParse(_rateController.text.trim());
    final months = int.tryParse(_tenureMonthsController.text.trim());

    if (name.isEmpty || monthly == null || monthly <= 0 || rate == null || rate <= 0 || months == null || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid scheme name, monthly deposit, rate, and tenure')),
      );
      return;
    }

    final maturityResult = FinancialMath.calculateRdMaturity(
      monthlyDeposit: monthly,
      annualInterestRate: rate,
      tenureMonths: months,
    );

    final db = ref.read(databaseProvider);
    final maturityDate = DateTime(_startDate.year, _startDate.month + months, _startDate.day);

    final notesData = jsonEncode({
      'rate': rate,
      'tenureMonths': months,
      'monthlyDeposit': monthly,
      'interestEarned': maturityResult.totalInterestEarned,
      'totalInvested': maturityResult.principalInvested,
    });

    if (widget.investmentToEdit != null) {
      await db.updateInvestment(
        widget.investmentToEdit!.id,
        InvestmentsCompanion(
          name: drift.Value(name),
          startDate: drift.Value(_startDate),
          maturityDate: drift.Value(maturityDate),
          purchasePrice: drift.Value(monthly),
          totalCommittedAmount: drift.Value(maturityResult.principalInvested),
          currentValuation: drift.Value(maturityResult.maturityAmount),
          notes: drift.Value(notesData),
        ),
      );
    } else {
      const uuid = Uuid();
      final now = DateTime.now();
      await db.into(db.investments).insert(
        InvestmentsCompanion.insert(
          id: uuid.v4(),
          name: name,
          type: 'rd',
          startDate: _startDate,
          maturityDate: drift.Value(maturityDate),
          purchasePrice: drift.Value(monthly),
          totalCommittedAmount: drift.Value(maturityResult.principalInvested),
          currentValuation: maturityResult.maturityAmount,
          notes: drift.Value(notesData),
          createdAt: now,
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.investmentToEdit != null ? 'Recurring Deposit updated!' : 'Recurring Deposit created!'),
          backgroundColor: AppColors.rd,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investmentToEdit != null;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          const Icon(Icons.repeat, color: AppColors.rd),
          const Gap(8),
          Text(isEditing ? 'Edit Recurring Deposit (RD)' : 'New Recurring Deposit (RD)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Bank / Scheme Name',
                  hintText: 'e.g. Post Office 5-Yr RD, SBI Monthly RD',
                  prefixIcon: Icon(Icons.savings_outlined),
                ),
              ),
              const Gap(10),
              TextField(
                controller: _monthlyDepositController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _recalculatePreview(),
                decoration: const InputDecoration(
                  labelText: 'Monthly Installment (₹)',
                  hintText: 'e.g. 5000',
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
                      onChanged: (_) => _recalculatePreview(),
                      decoration: const InputDecoration(
                        labelText: 'Interest Rate (% p.a.)',
                        hintText: 'e.g. 7.0',
                        prefixIcon: Icon(Icons.percent),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: TextField(
                      controller: _tenureMonthsController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculatePreview(),
                      decoration: const InputDecoration(
                        labelText: 'Tenure (Months)',
                        hintText: 'e.g. 12, 24, 60',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
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
                          Text('Start Date: ${DateFormat('dd MMM yyyy').format(_startDate)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.rd, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              if (_previewResult != null) ...[
                const Gap(14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.rd.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.rd.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Maturity Value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            CurrencyFormatter.format(_previewResult!.maturityAmount),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.rd),
                          ),
                        ],
                      ),
                      const Gap(6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Invested: ${CurrencyFormatter.format(_previewResult!.principalInvested)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('Interest: +${CurrencyFormatter.format(_previewResult!.totalInterestEarned)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quarterly Compounding Applied', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text('Yield: ${_previewResult!.effectiveYieldAnnual.toStringAsFixed(2)}% p.a.', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.rd, foregroundColor: Colors.white),
          onPressed: _saveRd,
          child: Text(isEditing ? 'Update RD' : 'Create RD'),
        ),
      ],
    );
  }
}
