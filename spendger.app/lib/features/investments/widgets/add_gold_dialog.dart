import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

class AddGoldDialog extends ConsumerStatefulWidget {
  const AddGoldDialog({super.key});

  @override
  ConsumerState<AddGoldDialog> createState() => _AddGoldDialogState();
}

class _AddGoldDialogState extends ConsumerState<AddGoldDialog> {
  final _nameController = TextEditingController(text: 'Physical Gold Holdings');
  final _gramsController = TextEditingController();
  final _buyRateController = TextEditingController();
  final _currentRateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _gramsController.dispose();
    _buyRateController.dispose();
    _currentRateController.dispose();
    super.dispose();
  }

  Future<void> _saveGold() async {
    final name = _nameController.text.trim();
    final grams = double.tryParse(_gramsController.text.trim());
    final buyRate = double.tryParse(_buyRateController.text.trim());
    final currentRate = double.tryParse(_currentRateController.text.trim()) ?? (buyRate ?? 0.0);

    if (name.isEmpty || grams == null || buyRate == null || grams <= 0 || buyRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid gold weight and purchase price')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    const uuid = Uuid();
    final now = DateTime.now();

    final totalCost = grams * buyRate;
    final currentValuation = grams * currentRate;

    await db.into(db.investments).insert(
      InvestmentsCompanion.insert(
        id: uuid.v4(),
        name: name,
        type: 'gold',
        startDate: now,
        quantity: drift.Value(grams),
        purchasePrice: drift.Value(buyRate),
        totalCommittedAmount: drift.Value(totalCost),
        currentValuation: currentValuation,
        createdAt: now,
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gold holding added to vault!'),
          backgroundColor: AppColors.gold,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Gold Holding', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Holding Description',
                hintText: 'e.g. 22K Sovereign Gold, Digital Gold',
                prefixIcon: Icon(Icons.stars),
              ),
            ),
            const Gap(10),
            TextField(
              controller: _gramsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Total Weight in Grams',
                hintText: 'e.g. 8.0 (1 Sovereign = 8g)',
                prefixIcon: Icon(Icons.scale),
              ),
            ),
            const Gap(10),
            TextField(
              controller: _buyRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Purchase Rate per Gram (₹)',
                hintText: 'e.g. 6800',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const Gap(10),
            TextField(
              controller: _currentRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Current Market Rate per Gram (₹)',
                hintText: 'e.g. 7200',
                prefixIcon: Icon(Icons.trending_up),
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black87),
          onPressed: _saveGold,
          child: const Text('Save Gold Holding', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
