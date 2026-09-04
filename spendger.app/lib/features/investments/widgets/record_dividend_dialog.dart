import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';

class RecordDividendDialog extends ConsumerStatefulWidget {
  final ChittyInstallment installment;
  const RecordDividendDialog({super.key, required this.installment});

  @override
  ConsumerState<RecordDividendDialog> createState() => _RecordDividendDialogState();
}

class _RecordDividendDialogState extends ConsumerState<RecordDividendDialog> {
  final _dividendController = TextEditingController();
  final _prizeAmountController = TextEditingController();
  bool _isPrizedMonth = false;
  double _netPayable = 0.0;

  @override
  void initState() {
    super.initState();
    _dividendController.text = widget.installment.dividendEarned.toString();
    _isPrizedMonth = widget.installment.isPrizedMonth;
    _prizeAmountController.text = widget.installment.prizeAmountReceived.toString();
    _recalculateNet();
  }

  @override
  void dispose() {
    _dividendController.dispose();
    _prizeAmountController.dispose();
    super.dispose();
  }

  void _recalculateNet() {
    final div = double.tryParse(_dividendController.text.trim()) ?? 0.0;
    setState(() {
      _netPayable = FinancialMath.calculateChittyNetPayable(
        grossInstallment: widget.installment.grossInstallment,
        dividendEarned: div,
      );
    });
  }

  Future<void> _updateInstallment() async {
    final div = double.tryParse(_dividendController.text.trim()) ?? 0.0;
    final prize = _isPrizedMonth ? (double.tryParse(_prizeAmountController.text.trim()) ?? 0.0) : 0.0;

    final db = ref.read(databaseProvider);

    await (db.update(db.chittyInstallments)..where((c) => c.id.equals(widget.installment.id))).write(
      ChittyInstallmentsCompanion(
        dividendEarned: drift.Value(div),
        netAmountPaid: drift.Value(_netPayable),
        isPaid: const drift.Value(true),
        paymentDate: drift.Value(DateTime.now()),
        isPrizedMonth: drift.Value(_isPrizedMonth),
        prizeAmountReceived: drift.Value(prize),
      ),
    );

    // Update investment valuation
    final allInstallments = await (db.select(db.chittyInstallments)
          ..where((c) => c.investmentId.equals(widget.installment.investmentId)))
        .get();

    final totalPaidSoFar = allInstallments.where((c) => c.isPaid).fold(0.0, (sum, c) => sum + c.netAmountPaid);

    await (db.update(db.investments)..where((i) => i.id.equals(widget.installment.investmentId))).write(
      InvestmentsCompanion(currentValuation: drift.Value(totalPaidSoFar)),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chitty payment and dividend updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text('Month ${widget.installment.installmentNumber} Payment', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gross Installment: ${CurrencyFormatter.format(widget.installment.grossInstallment)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Gap(12),
            TextField(
              controller: _dividendController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _recalculateNet(),
              decoration: const InputDecoration(
                labelText: 'Auction Dividend Declared (₹)',
                hintText: 'e.g. 2500',
                prefixIcon: Icon(Icons.percent),
              ),
            ),
            const Gap(10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.chitty.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.chitty.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Net Amount Payable:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    CurrencyFormatter.format(_netPayable),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.chitty),
                  ),
                ],
              ),
            ),
            const Gap(10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prized Month (Auction Won)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: const Text('Did you win the auction this month?', style: TextStyle(fontSize: 11)),
              value: _isPrizedMonth,
              activeThumbColor: AppColors.chitty,
              onChanged: (val) => setState(() => _isPrizedMonth = val),
            ),
            if (_isPrizedMonth) ...[
              const Gap(6),
              TextField(
                controller: _prizeAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Net Prize Money Received (₹)',
                  hintText: 'e.g. 380000',
                  prefixIcon: Icon(Icons.emoji_events_outlined),
                ),
              ),
            ],
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
          onPressed: _updateInstallment,
          child: const Text('Confirm & Mark Paid'),
        ),
      ],
    );
  }
}
