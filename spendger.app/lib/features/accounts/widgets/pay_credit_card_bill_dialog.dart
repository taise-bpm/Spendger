import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';

class PayCreditCardBillDialog extends ConsumerStatefulWidget {
  final Account creditCardAccount;

  const PayCreditCardBillDialog({
    super.key,
    required this.creditCardAccount,
  });

  @override
  ConsumerState<PayCreditCardBillDialog> createState() => _PayCreditCardBillDialogState();
}

class _PayCreditCardBillDialogState extends ConsumerState<PayCreditCardBillDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _fromAccountId;
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final dueAmount = widget.creditCardAccount.currentBalance.abs();
    if (dueAmount > 0) {
      _amountController.text = dueAmount.toStringAsFixed(0);
    }
    _fromAccountId = widget.creditCardAccount.defaultPayFromAccountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment(String? effectiveFromId) async {
    final amount = double.tryParse(_amountController.text.trim());
    final fromId = _fromAccountId ?? effectiveFromId;

    if (fromId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment bank or cash account')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payment amount')),
      );
      return;
    }

    try {
      final db = ref.read(databaseProvider);

      await db.recordCreditCardBillPayment(
        fromAccountId: fromId,
        creditCardAccountId: widget.creditCardAccount.id,
        amount: amount,
        date: _paymentDate,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credit card bill payment of ${CurrencyFormatter.format(amount)} recorded successfully!'),
            backgroundColor: AppColors.incomeLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording bill payment: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final allAccounts = accountsAsync.value ?? [];
    
    // Filter source accounts: Only Bank, Cash, and other liquid non-card accounts
    final sourceAccounts = allAccounts.where((a) => 
      a.isActive && 
      a.id != widget.creditCardAccount.id && 
      a.accountType != 'card' && 
      a.accountType != 'credit_card'
    ).toList();

    final defaultId = widget.creditCardAccount.defaultPayFromAccountId;
    final effectiveFromId = (_fromAccountId != null && sourceAccounts.any((a) => a.id == _fromAccountId))
        ? _fromAccountId
        : ((defaultId != null && sourceAccounts.any((a) => a.id == defaultId))
            ? defaultId
            : (sourceAccounts.isNotEmpty ? sourceAccounts.first.id : null));

    final dueAmount = widget.creditCardAccount.currentBalance.abs();
    final limit = widget.creditCardAccount.creditLimit ?? 0.0;
    final availableCredit = limit > 0 ? (limit - dueAmount).clamp(0.0, limit) : 0.0;

    final theme = Theme.of(context);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.expense.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payment, color: AppColors.expenseLight, size: 22),
          ),
          const Gap(10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pay Credit Card Bill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Settle outstanding balance', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
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
              // Card Details Header Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(widget.creditCardAccount.colorValue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(widget.creditCardAccount.colorValue).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(widget.creditCardAccount.colorValue).withValues(alpha: 0.2),
                      child: Icon(
                        IconHelper.getIcon(widget.creditCardAccount.iconCode),
                        size: 18,
                        color: Color(widget.creditCardAccount.colorValue),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.creditCardAccount.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            'Limit: ${CurrencyFormatter.format(limit)}  •  Avail: ${CurrencyFormatter.format(availableCredit)}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(dueAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: dueAmount > 0 ? AppColors.expenseLight : AppColors.incomeLight,
                          ),
                        ),
                        const Text('Total Due', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(16),

              if (sourceAccounts.isEmpty) ...[
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
                          'No active Bank or Cash accounts found to pay from. Please add or activate a bank account first.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Pay From (Bank/Cash Dropdown)
                DropdownButtonFormField<String>(
                  initialValue: effectiveFromId,
                  decoration: const InputDecoration(
                    labelText: 'Pay From (Bank / Cash Account)',
                    prefixIcon: Icon(Icons.account_balance, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  isExpanded: true,
                  items: sourceAccounts.map((acc) {
                    final isDefault = acc.id == widget.creditCardAccount.defaultPayFromAccountId;
                    return DropdownMenuItem(
                      value: acc.id,
                      child: Row(
                        children: [
                          Icon(IconHelper.getIcon(acc.iconCode), size: 16, color: Color(acc.colorValue)),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              '${acc.name} (${CurrencyFormatter.format(acc.currentBalance)})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          if (isDefault) ...[
                            const Gap(6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _fromAccountId = val),
                ),
              ],
              const Gap(12),

              // Payment Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee, size: 20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const Gap(8),

              // Quick Amount Action Chips
              if (dueAmount > 0)
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: Text(
                        'Full Due: ${CurrencyFormatter.format(dueAmount)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppColors.expense.withValues(alpha: 0.15),
                      onPressed: () {
                        setState(() {
                          _amountController.text = dueAmount.toStringAsFixed(0);
                        });
                      },
                    ),
                    if (dueAmount > 1000)
                      ActionChip(
                        label: const Text('₹1,000', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _amountController.text = '1000';
                          });
                        },
                      ),
                    if (dueAmount > 5000)
                      ActionChip(
                        label: const Text('₹5,000', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _amountController.text = '5000';
                          });
                        },
                      ),
                  ],
                ),
              const Gap(12),

              // Payment Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => _paymentDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment Date',
                    prefixIcon: Icon(Icons.calendar_today, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_paymentDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const Gap(12),

              // Optional Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notes / Reference (Optional)',
                  prefixIcon: Icon(Icons.note_alt_outlined, size: 18),
                  hintText: 'e.g. Statement payment via NetBanking',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          icon: const Icon(Icons.check_circle_outline, size: 18),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.incomeLight,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: sourceAccounts.isEmpty ? null : () => _submitPayment(effectiveFromId),
          label: const Text('CONFIRM PAYMENT', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
