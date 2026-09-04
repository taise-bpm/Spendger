import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

class RecordInvestmentTransactionDialog extends ConsumerStatefulWidget {
  final Investment? preselectedInvestment;
  final String? defaultTxType;

  const RecordInvestmentTransactionDialog({
    super.key,
    this.preselectedInvestment,
    this.defaultTxType,
  });

  @override
  ConsumerState<RecordInvestmentTransactionDialog> createState() => _RecordInvestmentTransactionDialogState();
}

class _RecordInvestmentTransactionDialogState extends ConsumerState<RecordInvestmentTransactionDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  Investment? _selectedInvestment;
  String _txType = 'deposit'; // 'deposit', 'sip_debit', 'dividend', 'maturity_payout', 'withdrawal'
  DateTime _date = DateTime.now();
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _selectedInvestment = widget.preselectedInvestment;
    if (widget.defaultTxType != null) {
      _txType = widget.defaultTxType!;
    } else if (_selectedInvestment != null) {
      if (_selectedInvestment!.type == 'sip') {
        _txType = 'sip_debit';
        _amountController.text = (_selectedInvestment!.totalCommittedAmount ?? 0.0).toStringAsFixed(0);
      } else if (_selectedInvestment!.type == 'rd') {
        _txType = 'deposit';
        _amountController.text = (_selectedInvestment!.purchasePrice ?? 0.0).toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isIncomeTx =>
      _txType == 'dividend' || _txType == 'maturity_payout' || _txType == 'withdrawal';

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (_selectedInvestment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an investment')),
      );
      return;
    }
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final targetCategoryType = _isIncomeTx ? 'income' : 'expense';
    final categories = await db.getAllCategories(type: targetCategoryType);
    
    // Find or fallback to investment category
    String categoryId = '';
    if (_isIncomeTx) {
      final invIncomeCat = categories.firstWhere(
        (c) => c.name.toLowerCase().contains('investment'),
        orElse: () => categories.first,
      );
      categoryId = invIncomeCat.id;
    } else {
      final invExpenseCat = categories.firstWhere(
        (c) => c.name.toLowerCase().contains('investment') || c.name.toLowerCase().contains('saving'),
        orElse: () => categories.first,
      );
      categoryId = invExpenseCat.id;
    }

    await db.recordInvestmentTransaction(
      investmentId: _selectedInvestment!.id,
      investmentName: _selectedInvestment!.name,
      investmentType: _selectedInvestment!.type.toUpperCase(),
      txType: _txType,
      amount: amount,
      date: _date,
      accountId: _selectedAccountId,
      categoryId: categoryId,
      note: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged ${_txType.replaceAll('_', ' ')} in Investment Ledger!'),
          backgroundColor: _isIncomeTx ? AppColors.incomeLight : AppColors.investment,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final investmentsAsync = ref.watch(investmentsStreamProvider(null));
    final allInvestments = investmentsAsync.value ?? [];
    final accountsAsync = ref.watch(accountsStreamProvider);
    final accounts = accountsAsync.value ?? [];

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final isIncome = _isIncomeTx;
    final themeColor = isIncome ? AppColors.incomeLight : AppColors.investment;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Icon(Icons.history_edu, color: themeColor),
          const Gap(8),
          const Text('Record Investment Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
              // Target Investment Picker
              if (widget.preselectedInvestment == null) ...[
                DropdownButtonFormField<Investment>(
                  initialValue: _selectedInvestment,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Investment Instrument',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  items: allInvestments.map((inv) {
                    return DropdownMenuItem<Investment>(
                      value: inv,
                      child: Text(
                        '${inv.name} [${inv.type.toUpperCase()}]',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedInvestment = val;
                      if (val != null && val.type == 'sip' && (val.totalCommittedAmount ?? 0) > 0) {
                        _amountController.text = val.totalCommittedAmount!.toStringAsFixed(0);
                      }
                    });
                  },
                ),
                const Gap(10),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.investment.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 16, color: AppColors.investment),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          '${widget.preselectedInvestment!.name} (${widget.preselectedInvestment!.type.toUpperCase()})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
              ],

              // Transaction Type Picker
              DropdownButtonFormField<String>(
                initialValue: _txType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Transaction Activity Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'deposit',
                    child: Text('Contribution / Deposit (Expense)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'sip_debit',
                    child: Text('Monthly SIP Debit (Expense)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'dividend',
                    child: Text('Dividend / Interest Received (Income)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'maturity_payout',
                    child: Text('Maturity Payout Received (Income)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'withdrawal',
                    child: Text('Redemption / Partial Withdrawal (Income)', overflow: TextOverflow.ellipsis),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _txType = val;
                    });
                  }
                },
              ),
              const Gap(10),

              // Amount
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isIncome ? 'Amount Received (₹)' : 'Amount Paid / Invested (₹)',
                  hintText: 'e.g. 5000',
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
              ),
              const Gap(10),

              // Account Selector
              if (accounts.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: isIncome ? 'Credit to Account' : 'Debit from Account',
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                  items: accounts.map((a) {
                    return DropdownMenuItem<String>(
                      value: a.id,
                      child: Text(
                        '${a.name} (₹${a.currentBalance.toStringAsFixed(0)})',
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

              // Date Picker
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
                          Text('Transaction Date: ${DateFormat('dd MMM yyyy').format(_date)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      Text('Change', style: TextStyle(fontSize: 12, color: themeColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const Gap(10),

              // Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Optional Note / Reference',
                  hintText: 'e.g. Monthly auto-debit, Q3 Dividend',
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
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: isIncome ? Colors.black87 : Colors.white,
          ),
          onPressed: _saveTransaction,
          child: const Text('Post to Ledger', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
