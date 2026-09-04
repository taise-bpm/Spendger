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

class AddFdDialog extends ConsumerStatefulWidget {
  final Investment? investmentToEdit;

  const AddFdDialog({super.key, this.investmentToEdit});

  @override
  ConsumerState<AddFdDialog> createState() => _AddFdDialogState();
}

class _AddFdDialogState extends ConsumerState<AddFdDialog> {
  final _nameController = TextEditingController();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController(text: '7.25');
  final _tenureYearsController = TextEditingController(text: '1');
  final _tenureMonthsController = TextEditingController(text: '0');
  final _tenureDaysController = TextEditingController(text: '0');

  // Compounding frequency: 0 = Simple Interest, 4 = Quarterly, 12 = Monthly, 2 = Half-Yearly, 1 = Annually
  int _compoundingFrequency = 4;
  DateTime _startDate = DateTime.now();
  DepositMaturityResult? _previewResult;

  @override
  void initState() {
    super.initState();
    if (widget.investmentToEdit != null) {
      final inv = widget.investmentToEdit!;
      _nameController.text = inv.name;
      _principalController.text = (inv.purchasePrice ?? 0.0).toStringAsFixed(0);
      _startDate = inv.startDate;
      if (inv.maturityDate != null) {
        final days = inv.maturityDate!.difference(inv.startDate).inDays;
        final years = (days / 365).floor();
        final remMonths = ((days % 365) / 30).floor();
        final remDays = (days % 365) % 30;
        _tenureYearsController.text = years.toString();
        _tenureMonthsController.text = remMonths.toString();
        _tenureDaysController.text = remDays.toString();
      }
      if (inv.notes != null) {
        try {
          final notesData = jsonDecode(inv.notes!);
          if (notesData['rate'] != null) _rateController.text = notesData['rate'].toString();
          if (notesData['compounding'] != null) _compoundingFrequency = notesData['compounding'] as int;
        } catch (_) {}
      }
    }
    _recalculatePreview();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureYearsController.dispose();
    _tenureMonthsController.dispose();
    _tenureDaysController.dispose();
    super.dispose();
  }

  double get _totalTenureInYears {
    final y = double.tryParse(_tenureYearsController.text.trim()) ?? 0.0;
    final m = double.tryParse(_tenureMonthsController.text.trim()) ?? 0.0;
    final d = double.tryParse(_tenureDaysController.text.trim()) ?? 0.0;
    return y + (m / 12.0) + (d / 365.0);
  }

  DateTime get _calculatedMaturityDate {
    final y = int.tryParse(_tenureYearsController.text.trim()) ?? 0;
    final m = int.tryParse(_tenureMonthsController.text.trim()) ?? 0;
    final d = int.tryParse(_tenureDaysController.text.trim()) ?? 0;
    return DateTime(_startDate.year + y, _startDate.month + m, _startDate.day + d);
  }

  void _recalculatePreview() {
    final principal = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final tenure = _totalTenureInYears;

    if (principal > 0 && rate > 0 && tenure > 0) {
      setState(() {
        _previewResult = FinancialMath.calculateFdMaturity(
          principal: principal,
          annualInterestRate: rate,
          tenureYears: tenure,
          compoundingFrequency: _compoundingFrequency,
        );
      });
    } else {
      setState(() {
        _previewResult = null;
      });
    }
  }

  Future<void> _saveFd() async {
    final name = _nameController.text.trim();
    final principal = double.tryParse(_principalController.text.trim());
    final rate = double.tryParse(_rateController.text.trim());
    final tenure = _totalTenureInYears;

    if (name.isEmpty || principal == null || principal <= 0 || rate == null || rate <= 0 || tenure <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid FD name, principal, rate, and tenure')),
      );
      return;
    }

    final maturityResult = FinancialMath.calculateFdMaturity(
      principal: principal,
      annualInterestRate: rate,
      tenureYears: tenure,
      compoundingFrequency: _compoundingFrequency,
    );

    final db = ref.read(databaseProvider);
    final maturityDate = _calculatedMaturityDate;

    final notesData = jsonEncode({
      'rate': rate,
      'compounding': _compoundingFrequency,
      'tenureYears': _tenureYearsController.text.trim(),
      'tenureMonths': _tenureMonthsController.text.trim(),
      'tenureDays': _tenureDaysController.text.trim(),
      'interestEarned': maturityResult.totalInterestEarned,
    });

    if (widget.investmentToEdit != null) {
      // Update existing FD
      await db.updateInvestment(
        widget.investmentToEdit!.id,
        InvestmentsCompanion(
          name: drift.Value(name),
          startDate: drift.Value(_startDate),
          maturityDate: drift.Value(maturityDate),
          purchasePrice: drift.Value(principal),
          totalCommittedAmount: drift.Value(principal),
          currentValuation: drift.Value(maturityResult.maturityAmount),
          notes: drift.Value(notesData),
        ),
      );
    } else {
      // Insert new FD
      const uuid = Uuid();
      final now = DateTime.now();
      await db.into(db.investments).insert(
        InvestmentsCompanion.insert(
          id: uuid.v4(),
          name: name,
          type: 'fd',
          startDate: _startDate,
          maturityDate: drift.Value(maturityDate),
          purchasePrice: drift.Value(principal),
          totalCommittedAmount: drift.Value(principal),
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
          content: Text(widget.investmentToEdit != null ? 'Fixed Deposit updated!' : 'Fixed Deposit created!'),
          backgroundColor: AppColors.fd,
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
          const Icon(Icons.account_balance, color: AppColors.fd),
          const Gap(8),
          Text(isEditing ? 'Edit Fixed Deposit (FD)' : 'New Fixed Deposit (FD)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
                  labelText: 'Bank / Institution & FD Name',
                  hintText: 'e.g. HDFC Bank 1-Yr FD, SBI Cumulative FD',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const Gap(10),
              TextField(
                controller: _principalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _recalculatePreview(),
                decoration: const InputDecoration(
                  labelText: 'Deposit Principal Amount (₹)',
                  hintText: 'e.g. 100000',
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
                        hintText: 'e.g. 7.25',
                        prefixIcon: Icon(Icons.percent),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _compoundingFrequency,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Interest Type / Frequency',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 4,
                          child: Text('Quarterly Compound (Bank Std)', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 12,
                          child: Text('Monthly Compound', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Half-Yearly Compound', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Annual Compound', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Simple Interest', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _compoundingFrequency = val;
                          });
                          _recalculatePreview();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const Gap(10),
              const Text('Tenure Breakdown', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const Gap(6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tenureYearsController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculatePreview(),
                      decoration: const InputDecoration(
                        labelText: 'Years',
                        hintText: '1',
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: TextField(
                      controller: _tenureMonthsController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculatePreview(),
                      decoration: const InputDecoration(
                        labelText: 'Months',
                        hintText: '0',
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: TextField(
                      controller: _tenureDaysController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculatePreview(),
                      decoration: const InputDecoration(
                        labelText: 'Days',
                        hintText: '0',
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
                      const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.fd, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              if (_previewResult != null) ...[
                const Gap(14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fd.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.fd.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Maturity Value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            CurrencyFormatter.format(_previewResult!.maturityAmount),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.fd),
                          ),
                        ],
                      ),
                      const Gap(6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Interest Earned: ${CurrencyFormatter.format(_previewResult!.totalInterestEarned)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('Yield: ${_previewResult!.effectiveYieldAnnual.toStringAsFixed(2)}% p.a.', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.incomeLight)),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Maturity Date: ${DateFormat('dd MMM yyyy').format(_calculatedMaturityDate)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.fd, foregroundColor: Colors.white),
          onPressed: _saveFd,
          child: Text(isEditing ? 'Update FD' : 'Create FD'),
        ),
      ],
    );
  }
}
