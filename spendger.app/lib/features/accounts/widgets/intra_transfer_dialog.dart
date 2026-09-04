import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class IntraTransferDialog extends ConsumerStatefulWidget {
  final String? initialFromAccountId;
  final String? initialToAccountId;

  const IntraTransferDialog({
    super.key,
    this.initialFromAccountId,
    this.initialToAccountId,
  });

  @override
  ConsumerState<IntraTransferDialog> createState() => _IntraTransferDialogState();
}

class _IntraTransferDialogState extends ConsumerState<IntraTransferDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _fromAccountId;
  String? _toAccountId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fromAccountId = widget.initialFromAccountId;
    _toAccountId = widget.initialToAccountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _executeTransfer() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both Source and Destination accounts')),
      );
      return;
    }

    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and Destination accounts must be different')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid transfer amount')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    await db.recordIntraTransfer(
      fromAccountId: _fromAccountId!,
      toAccountId: _toAccountId!,
      amount: amount,
      date: _date,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Self transfer completed successfully!'),
          backgroundColor: AppColors.incomeLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    if (_fromAccountId == null && accounts.isNotEmpty) {
      _fromAccountId = accounts.first.id;
    }
    if (_toAccountId == null && accounts.length > 1) {
      _toAccountId = accounts[1].id;
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Row(
        children: [
          Icon(Icons.swap_horiz, color: AppColors.primaryLight, size: 26),
          Gap(8),
          Text('Self / Intra-Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source Account (From)
              DropdownButtonFormField<String>(
                initialValue: _fromAccountId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'From Account (Debit)',
                  prefixIcon: Icon(Icons.arrow_upward, color: AppColors.expenseLight),
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
                    _fromAccountId = val;
                  });
                },
              ),
              const Gap(12),

              // Destination Account (To)
              DropdownButtonFormField<String>(
                initialValue: _toAccountId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'To Account (Credit)',
                  prefixIcon: Icon(Icons.arrow_downward, color: AppColors.incomeLight),
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
                    _toAccountId = val;
                  });
                },
              ),
              const Gap(12),

              // Transfer Amount
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Transfer Amount (₹)',
                  hintText: 'e.g. 5000',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const Gap(10),

              // Transfer Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _date = picked;
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
                          Text('Date: ${DateFormat('dd MMM yyyy').format(_date)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const Gap(10),

              // Note / Purpose
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Optional Transfer Note',
                  hintText: 'e.g. ATM Cash Withdrawal, Card Bill Payment',
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          onPressed: _executeTransfer,
          child: const Text('Transfer Now'),
        ),
      ],
    );
  }
}
