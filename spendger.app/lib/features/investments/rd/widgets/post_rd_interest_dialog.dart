import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class PostRdInterestDialog extends ConsumerStatefulWidget {
  final Investment rdInvestment;
  final double currentTotalDeposited;

  const PostRdInterestDialog({
    super.key,
    required this.rdInvestment,
    required this.currentTotalDeposited,
  });

  @override
  ConsumerState<PostRdInterestDialog> createState() => _PostRdInterestDialogState();
}

class _PostRdInterestDialogState extends ConsumerState<PostRdInterestDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _interestDate = DateTime.now();
  String? _selectedAccountId;
  bool _creditToBankAccount = false;
  double _rate = 7.0;

  @override
  void initState() {
    super.initState();
    if (widget.rdInvestment.notes != null) {
      try {
        final notesData = jsonDecode(widget.rdInvestment.notes!);
        _rate = double.tryParse(notesData['rate']?.toString() ?? '') ?? 7.0;
      } catch (_) {}
    }

    // Estimate 1 quarter of interest on current deposited balance: (P * r * 0.25 / 100)
    final estimatedQuarterInterest = (widget.currentTotalDeposited * (_rate / 100) / 4);
    if (estimatedQuarterInterest > 0) {
      _amountController.text = estimatedQuarterInterest.roundToDouble().toStringAsFixed(0);
    }

    final now = DateTime.now();
    _notesController.text = '${widget.rdInvestment.name} - Interest Credited (${DateFormat('MMM yyyy').format(now)})';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveInterest() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid interest amount')),
      );
      return;
    }

    if (_creditToBankAccount && _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a receiving Bank Account')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    await db.postRdInterest(
      investmentId: widget.rdInvestment.id,
      investmentName: widget.rdInvestment.name,
      interestAmount: amount,
      date: _interestDate,
      destinationAccountId: _creditToBankAccount ? _selectedAccountId : null,
      note: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_creditToBankAccount
              ? 'Interest credited to Bank Account and recorded!'
              : 'Interest posted to RD passbook balance!'),
          backgroundColor: AppColors.incomeLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final estimatedQuarterInterest = (widget.currentTotalDeposited * (_rate / 100) / 4);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Row(
        children: [
          Icon(Icons.savings_outlined, color: AppColors.rd, size: 24),
          Gap(8),
          Expanded(
            child: Text(
              'Mark RD Interest Credited',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scheme Overview Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.rd.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.rd.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Scheme Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(widget.rdInvestment.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Interest Rate', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('$_rate% p.a. (Quarterly)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.rd)),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Deposited So Far', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(CurrencyFormatter.format(widget.currentTotalDeposited), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    if (estimatedQuarterInterest > 0) ...[
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Qtr Interest', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            '+${CurrencyFormatter.format(estimatedQuarterInterest)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.incomeLight),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(16),

              // Date Selector
              Text('Posting Date', style: theme.textTheme.labelMedium),
              const Gap(6),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _interestDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2040),
                  );
                  if (picked != null) {
                    setState(() => _interestDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMMM yyyy').format(_interestDate)),
                      const Icon(Icons.calendar_today, size: 16),
                    ],
                  ),
                ),
              ),
              const Gap(14),

              // Interest Amount Input
              Text('Interest Amount Credited (₹)', style: theme.textTheme.labelMedium),
              const Gap(6),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                  hintText: 'Enter interest amount',
                ),
              ),
              const Gap(14),

              // Destination Mode Selector
              Text('Interest Destination', style: theme.textTheme.labelMedium),
              const Gap(6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      title: const Text('Add to RD Passbook Balance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Compounded inside RD account (Default)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: false,
                      groupValue: _creditToBankAccount,
                      onChanged: (val) => setState(() => _creditToBankAccount = val ?? false),
                    ),
                    const Divider(height: 1),
                    RadioListTile<bool>(
                      title: const Text('Credit to Bank Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Paid out to your linked bank account', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: true,
                      groupValue: _creditToBankAccount,
                      onChanged: (val) => setState(() => _creditToBankAccount = val ?? true),
                    ),
                  ],
                ),
              ),

              if (_creditToBankAccount) ...[
                const Gap(12),
                Text('Select Destination Bank Account', style: theme.textTheme.labelMedium),
                const Gap(6),
                DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: accounts.map((a) {
                    return DropdownMenuItem(
                      value: a.id,
                      child: Text('${a.name} (${CurrencyFormatter.format(a.currentBalance)})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAccountId = val),
                ),
              ],
              const Gap(14),

              // Notes Input
              Text('Notes / Reference', style: theme.textTheme.labelMedium),
              const Gap(6),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Q1 Interest Credited by SBI',
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.rd,
            foregroundColor: Colors.white,
          ),
          onPressed: _saveInterest,
          child: const Text('Post Interest'),
        ),
      ],
    );
  }
}
