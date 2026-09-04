import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

class AddSipDialog extends ConsumerStatefulWidget {
  final Investment? investmentToEdit;

  const AddSipDialog({super.key, this.investmentToEdit});

  @override
  ConsumerState<AddSipDialog> createState() => _AddSipDialogState();
}

class _AddSipDialogState extends ConsumerState<AddSipDialog> {
  final _nameController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  final _currentValuationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.investmentToEdit != null) {
      final inv = widget.investmentToEdit!;
      _nameController.text = inv.name;
      _monthlyAmountController.text = (inv.totalCommittedAmount ?? 0.0).toStringAsFixed(0);
      _currentValuationController.text = inv.currentValuation.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _monthlyAmountController.dispose();
    _currentValuationController.dispose();
    super.dispose();
  }

  Future<void> _saveSip() async {
    final name = _nameController.text.trim();
    final monthlyAmount = double.tryParse(_monthlyAmountController.text.trim());
    final currentVal = double.tryParse(_currentValuationController.text.trim()) ?? 0.0;

    if (name.isEmpty || monthlyAmount == null || monthlyAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter scheme name and SIP monthly amount')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    if (widget.investmentToEdit != null) {
      await db.updateInvestment(
        widget.investmentToEdit!.id,
        InvestmentsCompanion(
          name: drift.Value(name),
          totalCommittedAmount: drift.Value(monthlyAmount),
          currentValuation: drift.Value(currentVal),
        ),
      );
    } else {
      const uuid = Uuid();
      final now = DateTime.now();
      await db.into(db.investments).insert(
        InvestmentsCompanion.insert(
          id: uuid.v4(),
          name: name,
          type: 'sip',
          startDate: now,
          totalCommittedAmount: drift.Value(monthlyAmount),
          currentValuation: currentVal,
          createdAt: now,
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.investmentToEdit != null ? 'SIP Portfolio updated!' : 'SIP Portfolio added!'),
          backgroundColor: AppColors.sip,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investmentToEdit != null;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(isEditing ? 'Edit Mutual Fund / SIP' : 'Add Mutual Fund / SIP', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Fund / Scheme Name',
                hintText: 'e.g. Parag Parikh Flexi Cap, Nifty 50 Index',
                prefixIcon: Icon(Icons.show_chart),
              ),
            ),
            const Gap(10),
            TextField(
              controller: _monthlyAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monthly SIP Amount (₹)',
                hintText: 'e.g. 5000',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const Gap(10),
            TextField(
              controller: _currentValuationController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Current Portfolio Value (₹)',
                hintText: 'e.g. 45000',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.sip, foregroundColor: Colors.white),
          onPressed: _saveSip,
          child: Text(isEditing ? 'Update SIP' : 'Save SIP'),
        ),
      ],
    );
  }
}
