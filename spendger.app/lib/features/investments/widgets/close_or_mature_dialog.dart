import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class CloseOrMatureDialog extends ConsumerStatefulWidget {
  final Investment investment;
  final bool isPrematureDefault;

  const CloseOrMatureDialog({
    super.key,
    required this.investment,
    this.isPrematureDefault = false,
  });

  @override
  ConsumerState<CloseOrMatureDialog> createState() => _CloseOrMatureDialogState();
}

class _CloseOrMatureDialogState extends ConsumerState<CloseOrMatureDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late bool _isPremature;
  DateTime _payoutDate = DateTime.now();
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _isPremature = widget.isPrematureDefault;
    final initialPayout = widget.investment.currentValuation > 0
        ? widget.investment.currentValuation
        : (widget.investment.totalCommittedAmount ?? widget.investment.purchasePrice ?? 0.0);
    _amountController.text = initialPayout.toStringAsFixed(0);
    _notesController.text = '${widget.investment.name} ${_isPremature ? "Premature Closure" : "Maturity Payout"}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _executeClosure() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination Bank Account')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payout amount')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    await db.closeOrMatureInvestmentWithTransfer(
      investmentId: widget.investment.id,
      investmentName: widget.investment.name,
      destinationAccountId: _selectedAccountId!,
      payoutAmount: amount,
      date: _payoutDate,
      isPremature: _isPremature,
      note: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.investment.name} ${_isPremature ? "closed" : "matured"} & funds transferred to account!'),
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
      title: Row(
        children: [
          Icon(_isPremature ? Icons.cancel_outlined : Icons.check_circle_outline, color: _isPremature ? AppColors.loanLight : AppColors.incomeLight, size: 24),
          const Gap(8),
          Text(_isPremature ? 'Premature Closure & Transfer' : 'Maturity Payout & Transfer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Closure Type Selector
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Regular Maturity'),
                      selected: !_isPremature,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _isPremature = false;
                            _notesController.text = '${widget.investment.name} Maturity Payout';
                          });
                        }
                      },
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Premature Closure'),
                      selected: _isPremature,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _isPremature = true;
                            _notesController.text = '${widget.investment.name} Premature Closure';
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const Gap(14),

              // Final Payout Amount
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Final Net Payout Received (₹)',
                  hintText: 'e.g. 107250',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  helperText: _isPremature ? 'Enter actual payout after penalty/tax if any' : 'Principal + total interest gain',
                ),
              ),
              const Gap(10),

              // Destination Account
              if (accounts.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Credit Payout to Bank Account',
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

              // Payout Date
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
                      const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const Gap(10),

              // Note
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ledger Note',
                  hintText: 'e.g. FD Closed into Salary Account',
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
          onPressed: _executeClosure,
          child: const Text('Transfer & Close'),
        ),
      ],
    );
  }
}
