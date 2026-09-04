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

  Future<void> _executeTransfer(String? effectiveFromId, String? effectiveToId) async {
    final amount = double.tryParse(_amountController.text.trim());
    final fromId = _fromAccountId ?? effectiveFromId;
    final toId = _toAccountId ?? effectiveToId;

    if (fromId == null || toId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both Source and Destination accounts')),
      );
      return;
    }

    if (fromId == toId) {
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

    try {
      final db = ref.read(databaseProvider);

      await db.recordIntraTransfer(
        fromAccountId: fromId,
        toAccountId: toId,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording transfer: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(activeAccountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    final effectiveFromId = (_fromAccountId != null && accounts.any((a) => a.id == _fromAccountId))
        ? _fromAccountId
        : (accounts.isNotEmpty ? accounts.first.id : null);

    final effectiveToId = (_toAccountId != null && accounts.any((a) => a.id == _toAccountId))
        ? _toAccountId
        : (accounts.length > 1
            ? (accounts.firstWhere((a) => a.id != effectiveFromId, orElse: () => accounts[1])).id
            : null);

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
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(8),
              if (accounts.length < 2) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 20),
                      Gap(8),
                      Expanded(
                        child: Text(
                          'You need at least 2 active accounts to make a self transfer.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
              ],
              // Source Account (From)
              DropdownButtonFormField<String>(
                initialValue: effectiveFromId,
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
                initialValue: effectiveToId,
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

              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Text(DateFormat('MMM dd, yyyy').format(_date)),
                ),
              ),
              const Gap(10),

              // Optional Note
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'e.g. Moved cash to bank',
                  prefixIcon: Icon(Icons.edit_note, size: 20),
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
        ElevatedButton.icon(
          icon: const Icon(Icons.swap_horiz, size: 18),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: accounts.length < 2 ? null : () => _executeTransfer(effectiveFromId, effectiveToId),
          label: const Text('TRANSFER NOW', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
