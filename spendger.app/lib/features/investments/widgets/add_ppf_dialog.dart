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

class AddPpfDialog extends ConsumerStatefulWidget {
  final Investment? investmentToEdit;

  const AddPpfDialog({super.key, this.investmentToEdit});

  @override
  ConsumerState<AddPpfDialog> createState() => _AddPpfDialogState();
}

class _AddPpfDialogState extends ConsumerState<AddPpfDialog> {
  final _nameController = TextEditingController(text: 'Public Provident Fund (PPF)');
  final _openingBalanceController = TextEditingController(text: '0');
  final _yearlyDepositController = TextEditingController(text: '150000');
  final _rateController = TextEditingController(text: '7.1');
  final _tenureYearsController = TextEditingController(text: '15');

  DateTime _startDate = DateTime.now();
  DepositMaturityResult? _previewResult;

  @override
  void initState() {
    super.initState();
    if (widget.investmentToEdit != null) {
      final inv = widget.investmentToEdit!;
      _nameController.text = inv.name;
      _yearlyDepositController.text = (inv.purchasePrice ?? 0.0).toStringAsFixed(0);
      _startDate = inv.startDate;
      if (inv.notes != null) {
        try {
          final notesData = jsonDecode(inv.notes!);
          if (notesData['rate'] != null) _rateController.text = notesData['rate'].toString();
          if (notesData['tenureYears'] != null) _tenureYearsController.text = notesData['tenureYears'].toString();
          if (notesData['openingBalance'] != null) {
            final parsedBal = double.tryParse(notesData['openingBalance'].toString()) ?? 0.0;
            _openingBalanceController.text = parsedBal.toStringAsFixed(0);
          } else {
            _openingBalanceController.text = inv.currentValuation.toStringAsFixed(0);
          }
        } catch (_) {}
      }
    }
    _recalculatePreview();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openingBalanceController.dispose();
    _yearlyDepositController.dispose();
    _rateController.dispose();
    _tenureYearsController.dispose();
    super.dispose();
  }

  void _recalculatePreview() {
    final yearly = double.tryParse(_yearlyDepositController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final years = int.tryParse(_tenureYearsController.text.trim()) ?? 0;

    if (yearly > 0 && rate > 0 && years > 0) {
      setState(() {
        _previewResult = FinancialMath.calculatePpfMaturity(
          yearlyDeposit: yearly,
          annualInterestRate: rate,
          tenureYears: years,
        );
      });
    } else {
      setState(() {
        _previewResult = null;
      });
    }
  }

  Future<void> _savePpf() async {
    final name = _nameController.text.trim();
    final openingBalance = double.tryParse(_openingBalanceController.text.trim()) ?? 0.0;
    final yearly = double.tryParse(_yearlyDepositController.text.trim());
    final rate = double.tryParse(_rateController.text.trim());
    final years = int.tryParse(_tenureYearsController.text.trim());

    if (name.isEmpty || yearly == null || yearly <= 0 || rate == null || rate <= 0 || years == null || years <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid PPF details')),
      );
      return;
    }

    final maturityResult = FinancialMath.calculatePpfMaturity(
      yearlyDeposit: yearly,
      annualInterestRate: rate,
      tenureYears: years,
    );

    final db = ref.read(databaseProvider);
    final maturityDate = DateTime(_startDate.year + years, _startDate.month, _startDate.day);

    double oldOpeningBalance = 0.0;
    if (widget.investmentToEdit?.notes != null) {
      try {
        final oldNotes = jsonDecode(widget.investmentToEdit!.notes!);
        oldOpeningBalance = double.tryParse(oldNotes['openingBalance']?.toString() ?? '') ?? 0.0;
      } catch (_) {}
    }
    final deltaOpening = openingBalance - oldOpeningBalance;
    final updatedValuation = ((widget.investmentToEdit?.currentValuation ?? 0.0) + deltaOpening).clamp(0.0, double.infinity);

    final notesData = jsonEncode({
      'rate': rate,
      'tenureYears': years,
      'yearlyDeposit': yearly,
      'openingBalance': openingBalance,
      'expectedMaturityAmount': maturityResult.maturityAmount,
      'interestEarned': maturityResult.totalInterestEarned,
      'totalInvested': maturityResult.principalInvested,
      'taxStatus': 'EEE (Exempt-Exempt-Exempt)',
    });

    if (widget.investmentToEdit != null) {
      await db.updateInvestment(
        widget.investmentToEdit!.id,
        InvestmentsCompanion(
          name: drift.Value(name),
          startDate: drift.Value(_startDate),
          maturityDate: drift.Value(maturityDate),
          purchasePrice: drift.Value(yearly),
          totalCommittedAmount: drift.Value(maturityResult.principalInvested),
          currentValuation: drift.Value(updatedValuation),
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
          type: 'ppf',
          startDate: _startDate,
          maturityDate: drift.Value(maturityDate),
          purchasePrice: drift.Value(yearly),
          totalCommittedAmount: drift.Value(maturityResult.principalInvested),
          currentValuation: openingBalance,
          notes: drift.Value(notesData),
          createdAt: now,
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.investmentToEdit != null ? 'PPF Account updated!' : 'PPF Account created!'),
          backgroundColor: AppColors.ppf,
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
          const Icon(Icons.shield_outlined, color: AppColors.ppf),
          const Gap(8),
          Text(isEditing ? 'Edit PPF Account' : 'New PPF Account', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
              const Gap(8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account / Bank Name',
                  hintText: 'e.g. Post Office PPF, SBI PPF Account',
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const Gap(10),
              TextField(
                controller: _openingBalanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Opening / Existing Balance (₹)',
                  hintText: '0 for new PPF, or existing balance if importing',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const Gap(10),
              TextField(
                controller: _yearlyDepositController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _recalculatePreview(),
                decoration: const InputDecoration(
                  labelText: 'Planned Annual Contribution (₹ / Year)',
                  hintText: 'e.g. ₹1,50,000 per financial year',
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
                        hintText: '7.1',
                        prefixIcon: Icon(Icons.percent),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: TextField(
                      controller: _tenureYearsController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculatePreview(),
                      decoration: const InputDecoration(
                        labelText: 'Tenure (Years)',
                        hintText: '15',
                        prefixIcon: Icon(Icons.lock_clock),
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
                      const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.ppf, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              if (_previewResult != null) ...[
                const Gap(14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.ppf.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.ppf.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Maturity (15 Yrs)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            CurrencyFormatter.format(_previewResult!.maturityAmount),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.ppf),
                          ),
                        ],
                      ),
                      const Gap(6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invested: ${CurrencyFormatter.format(_previewResult!.principalInvested)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('Interest: +${CurrencyFormatter.format(_previewResult!.totalInterestEarned)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax Status: 100% Tax Free (EEE)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                          Text('Yield: ${_previewResult!.effectiveYieldAnnual.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.ppf, foregroundColor: Colors.white),
          onPressed: _savePpf,
          child: Text(isEditing ? 'Update PPF' : 'Create PPF'),
        ),
      ],
    );
  }
}
