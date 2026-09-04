import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class RecordPpfDepositDialog extends ConsumerStatefulWidget {
  final Investment ppfInvestment;
  final double currentFyDepositedTotal;

  const RecordPpfDepositDialog({
    super.key,
    required this.ppfInvestment,
    this.currentFyDepositedTotal = 0.0,
  });

  @override
  ConsumerState<RecordPpfDepositDialog> createState() => _RecordPpfDepositDialogState();
}

class _RecordPpfDepositDialogState extends ConsumerState<RecordPpfDepositDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _depositDate = DateTime.now();
  String? _selectedAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isBefore5th => _depositDate.day <= 5;
  double get _remainingFyRoom => (150000.0 - widget.currentFyDepositedTotal).clamp(0.0, 150000.0);

  Future<void> _saveDeposit() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid deposit amount')),
      );
      return;
    }

    if (amount % 50 != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PPF deposit amount must be in multiples of ₹50')),
      );
      return;
    }

    if (widget.currentFyDepositedTotal + amount > 150000.0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: const Text('Exceeds ₹1.5L Annual Limit'),
          content: Text('Total deposits for this Financial Year will reach ${CurrencyFormatter.format(widget.currentFyDepositedTotal + amount)}, exceeding the ₹1.5 Lakh limit. Deposits beyond ₹1.5L do not earn interest in PPF. Do you still want to proceed?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Proceed Anyway')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final db = ref.read(databaseProvider);
    final categories = await db.getAllCategories(type: 'expense');
    final invCategory = categories.firstWhere(
      (c) => c.name.toLowerCase().contains('investment'),
      orElse: () => categories.first,
    );

    const uuid = Uuid();
    final tag = 'INV:${widget.ppfInvestment.id}:ppf_deposit:${uuid.v4().substring(0, 8)}';
    final note = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : 'PPF Deposit (${_isBefore5th ? "Earns ${DateFormat('MMM').format(_depositDate)} Interest" : "Interest starts next month"})';

    // 1. Record transaction (expense debit from account)
    await db.addTransactionWithAccountUpdate(
      TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: invCategory.id,
        accountId: drift.Value(_selectedAccountId),
        amount: amount,
        type: 'expense',
        transactionDate: _depositDate,
        notes: drift.Value(note),
        tag: drift.Value(tag),
        createdAt: DateTime.now(),
      ),
    );

    // 2. Update PPF investment current valuation
    await (db.update(db.investments)..where((i) => i.id.equals(widget.ppfInvestment.id))).write(
      InvestmentsCompanion(
        currentValuation: drift.Value(widget.ppfInvestment.currentValuation + amount),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PPF deposit recorded in ledger & account updated!'),
          backgroundColor: AppColors.ppf,
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
          Icon(Icons.shield_outlined, color: AppColors.ppf, size: 24),
          Gap(8),
          Text('Deposit into PPF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 5th-Day Rule Insight Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isBefore5th
                      ? AppColors.income.withValues(alpha: 0.15)
                      : AppColors.loan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isBefore5th
                        ? AppColors.income.withValues(alpha: 0.3)
                        : AppColors.loan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isBefore5th ? Icons.check_circle_outline : Icons.info_outline,
                      color: _isBefore5th ? AppColors.incomeLight : AppColors.loanLight,
                      size: 22,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isBefore5th ? '5th-Day Rule: Interest Earned!' : '5th-Day Rule Notice',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _isBefore5th ? AppColors.incomeLight : AppColors.loanLight,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            _isBefore5th
                                ? 'Depositing on/before the 5th earns full interest for ${DateFormat('MMMM').format(_depositDate)}!'
                                : 'Deposited after the 5th. Interest will start accruing from the 1st of next month.',
                            style: const TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),

              // Deposit Amount
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Deposit Amount (₹)',
                  hintText: 'e.g. 50000 (Multiples of ₹50)',
                  helperText: 'Remaining limit this FY: ${CurrencyFormatter.format(_remainingFyRoom)}',
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
              ),
              const Gap(10),

              // Account Selector
              if (accounts.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Debited from Account',
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

              // Deposit Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _depositDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _depositDate = picked;
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
                          Text('Deposit Date: ${DateFormat('dd MMM yyyy').format(_depositDate)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const Text('Change', style: TextStyle(fontSize: 12, color: AppColors.ppf, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const Gap(10),

              // Note
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Optional Note / Reference',
                  hintText: 'e.g. Q1 lumpsum, Cheque deposit',
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.ppf, foregroundColor: Colors.white),
          onPressed: _saveDeposit,
          child: const Text('Confirm Deposit'),
        ),
      ],
    );
  }
}
