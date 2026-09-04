import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

class AddChittyDialog extends ConsumerStatefulWidget {
  final Investment? investmentToEdit;

  const AddChittyDialog({super.key, this.investmentToEdit});

  @override
  ConsumerState<AddChittyDialog> createState() => _AddChittyDialogState();
}

class _AddChittyDialogState extends ConsumerState<AddChittyDialog> {
  final _nameController = TextEditingController();
  final _totalChitAmountController = TextEditingController();
  final _totalMonthsController = TextEditingController(text: '40');
  final _grossInstallmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.investmentToEdit != null) {
      final inv = widget.investmentToEdit!;
      _nameController.text = inv.name;
      _totalChitAmountController.text = (inv.totalCommittedAmount ?? 0.0).toStringAsFixed(0);
      if (inv.maturityDate != null) {
        final days = inv.maturityDate!.difference(inv.startDate).inDays;
        final months = (days / 30).round();
        if (months > 0) _totalMonthsController.text = months.toString();
      }
      _onAmountChanged();
    }
  }

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

    if (widget.investmentToEdit != null) {
      final inv = widget.investmentToEdit!;
      await db.updateInvestment(
        inv.id,
        InvestmentsCompanion(
          name: drift.Value(name),
          totalCommittedAmount: drift.Value(totalAmount),
          maturityDate: drift.Value(DateTime(inv.startDate.year, inv.startDate.month + months, inv.startDate.day)),
        ),
      );
    } else {
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
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.investmentToEdit != null ? 'Chit Fund scheme updated!' : 'Chit Fund (Chitty) scheme added!'),
          backgroundColor: AppColors.chitty,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investmentToEdit != null;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(isEditing ? 'Edit Chit Fund (Chitty)' : 'Add Chit Fund (Chitty)', style: const TextStyle(fontWeight: FontWeight.bold)),
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
          child: Text(isEditing ? 'Update Scheme' : 'Create Scheme'),
        ),
      ],
    );
  }
}
