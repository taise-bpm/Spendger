import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class CheckoutFdInterestDialog extends ConsumerStatefulWidget {
  final Investment fdInvestment;
  final double suggestedInterestAmount;

  const CheckoutFdInterestDialog({
    super.key,
    required this.fdInvestment,
    this.suggestedInterestAmount = 0.0,
  });

  @override
  ConsumerState<CheckoutFdInterestDialog> createState() => _CheckoutFdInterestDialogState();
}

class _CheckoutFdInterestDialogState extends ConsumerState<CheckoutFdInterestDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _payoutDate = DateTime.now();
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedInterestAmount > 0) {
      _amountController.text = widget.suggestedInterestAmount.toStringAsFixed(0);
    }
    _notesController.text = '${widget.fdInvestment.name} - Interest Payout';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveInterestCheckout() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination Bank Account')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid interest amount')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    await db.recordFdInterestPayout(
      investmentId: widget.fdInvestment.id,
      investmentName: widget.fdInvestment.name,
      destinationAccountId: _selectedAccountId!,
      amount: amount,
      date: _payoutDate,
      note: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interest payout credited to bank account and posted to Income Ledger!'),
          backgroundColor: AppColors.incomeLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Row(
        children: [
          Icon(Icons.payments_outlined, color: AppColors.incomeLight, size: 24),
          Gap(8),
          Text('FD Interest Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
              const Text(
                'Record simple/periodic interest credited to your bank account. This will post directly to your Income Ledger.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Gap(12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Interest Amount Received (₹)',
                  hintText: 'e.g. 1800',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const Gap(10),
              if (accounts.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Credit into Bank Account',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: accounts.map((a) {
                    return DropdownMenuItem<String>(
                      value: a.id,
                      child: Text(
                        '${a.name} (${CurrencyFormatter.format(a.currentBalance)})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedAccountId = val;
                    });
                  },
                ),
                const Gap(10),
              ],
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _payoutDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _payoutDate = picked;
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
                          Text('Payout Date: ${DateFormat('dd MMM yyyy').format(_payoutDate)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.fd, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const Gap(10),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Optional Note / Reference',
                  hintText: 'e.g. Q2 Interest payout',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.income, foregroundColor: Colors.white),
          onPressed: _saveInterestCheckout,
          child: const Text('Credit Bank Account'),
        ),
      ],
    );
  }
}
