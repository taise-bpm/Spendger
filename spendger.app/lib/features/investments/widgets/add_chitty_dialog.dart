import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

class AddChittyDialog extends ConsumerStatefulWidget {
  const AddChittyDialog({super.key});

  @override
  ConsumerState<AddChittyDialog> createState() => _AddChittyDialogState();
}

class _AddChittyDialogState extends ConsumerState<AddChittyDialog> {
  final _nameController = TextEditingController();
  final _totalChitAmountController = TextEditingController();
  final _totalMonthsController = TextEditingController(text: '40');
  final _grossInstallmentController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _totalChitAmountController.dispose();
    _totalMonthsController.dispose();
    _grossInstallmentController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final total = double.tryParse(_totalChitAmountController.text.trim()) ?? 0.0;
    final months = int.tryParse(_totalMonthsController.text.trim()) ?? 0;
    if (total > 0 && months > 0) {
      _grossInstallmentController.text = (total / months).toStringAsFixed(0);
    }
  }

  Future<void> _saveChitty() async {
    final name = _nameController.text.trim();
    final totalAmount = double.tryParse(_totalChitAmountController.text.trim());
    final months = int.tryParse(_totalMonthsController.text.trim());
    final gross = double.tryParse(_grossInstallmentController.text.trim());

    if (name.isEmpty || totalAmount == null || months == null || gross == null || totalAmount <= 0 || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all Chit fund scheme fields')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    const uuid = Uuid();
    final investmentId = uuid.v4();
    final now = DateTime.now();

    // 1. Create Investment record
    await db.into(db.investments).insert(
      InvestmentsCompanion.insert(
        id: investmentId,
        name: name,
        type: 'chitty',
        startDate: now,
        maturityDate: drift.Value(DateTime(now.year, now.month + months, now.day)),
        totalCommittedAmount: drift.Value(totalAmount),
        currentValuation: 0.0,
        createdAt: now,
      ),
    );

    // 2. Pre-populate all installment months for the Chitty
    for (int i = 1; i <= months; i++) {
      final dueDate = DateTime(now.year, now.month + (i - 1), 10);
      await db.into(db.chittyInstallments).insert(
        ChittyInstallmentsCompanion.insert(
          id: uuid.v4(),
          investmentId: investmentId,
          installmentNumber: i,
          dueDate: dueDate,
          grossInstallment: gross,
          dividendEarned: const drift.Value(0.0),
          netAmountPaid: gross,
          isPaid: const drift.Value(false),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chit Fund (Chitty) scheme added!'),
          backgroundColor: AppColors.chitty,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Chit Fund (Chitty)', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Scheme Name / Company',
                hintText: 'e.g. KSFE 5 Lakh Chitty, Gokulam Chit',
                prefixIcon: Icon(Icons.groups_outlined),
              ),
            ),
            const Gap(10),
            TextField(
              controller: _totalChitAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _onAmountChanged(),
              decoration: const InputDecoration(
                labelText: 'Total Chit Value (₹)',
                hintText: 'e.g. 500000',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _totalMonthsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onAmountChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Total Months',
                      hintText: 'e.g. 40 or 50',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: TextField(
                    controller: _grossInstallmentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Gross Installment (₹)',
                      hintText: 'e.g. 12500',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                ),
              ],
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.chitty, foregroundColor: Colors.white),
          onPressed: _saveChitty,
          child: const Text('Create Scheme'),
        ),
      ],
    );
  }
}
