import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

class AddEditAccountDialog extends ConsumerStatefulWidget {
  final Account? accountToEdit;

  const AddEditAccountDialog({super.key, this.accountToEdit});

  @override
  ConsumerState<AddEditAccountDialog> createState() => _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends ConsumerState<AddEditAccountDialog> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _creditLimitController = TextEditingController();

  String _accountType = 'bank'; // 'bank', 'credit_card', 'cash', 'wallet'
  int _selectedColor = 0xFF6366F1;
  int _selectedIcon = Icons.account_balance.codePoint;

  @override
  void initState() {
    super.initState();
    if (widget.accountToEdit != null) {
      final acc = widget.accountToEdit!;
      _nameController.text = acc.name;
      _balanceController.text = acc.currentBalance.toStringAsFixed(0);
      _accountType = acc.accountType;
      _selectedColor = acc.colorValue;
      _selectedIcon = acc.iconCode;
      if (acc.creditLimit != null) {
        _creditLimitController.text = acc.creditLimit!.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;
    final creditLimit = _accountType == 'card' || _accountType == 'credit_card'
        ? double.tryParse(_creditLimitController.text.trim())
        : null;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter account name')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final isEditing = widget.accountToEdit != null;

    final accId = isEditing ? widget.accountToEdit!.id : const Uuid().v4();

    await db.upsertAccount(
      AccountsCompanion(
        id: drift.Value(accId),
        name: drift.Value(name),
        accountType: drift.Value(_accountType),
        currentBalance: drift.Value(balance),
        creditLimit: drift.Value(creditLimit),
        iconCode: drift.Value(_selectedIcon),
        colorValue: drift.Value(_selectedColor),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Account updated!' : 'Account created!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.accountToEdit != null;
    final isCard = _accountType == 'card' || _accountType == 'credit_card';

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(isEditing ? 'Edit Account' : 'New Account / Card', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account / Card Name',
                  hintText: 'e.g. HDFC Salary, ICICI Amazon Pay Card',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const Gap(10),
              DropdownButtonFormField<String>(
                initialValue: _accountType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
                  DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash in Hand')),
                  DropdownMenuItem(value: 'wallet', child: Text('UPI / Digital Wallet')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _accountType = val;
                      if (val == 'bank') {
                        _selectedIcon = Icons.account_balance.codePoint;
                        _selectedColor = 0xFF6366F1;
                      } else if (val == 'credit_card') {
                        _selectedIcon = Icons.credit_card.codePoint;
                        _selectedColor = 0xFFF43F5E;
                      } else if (val == 'cash') {
                        _selectedIcon = Icons.payments.codePoint;
                        _selectedColor = 0xFF10B981;
                      } else if (val == 'wallet') {
                        _selectedIcon = Icons.qr_code_2.codePoint;
                        _selectedColor = 0xFF0EA5E9;
                      }
                    });
                  }
                },
              ),
              const Gap(10),
              TextField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: isCard ? 'Current Outstanding Balance (₹)' : 'Current Balance (₹)',
                  hintText: 'e.g. 25000',
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
              ),
              if (isCard) ...[
                const Gap(10),
                TextField(
                  controller: _creditLimitController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Total Credit Limit (₹)',
                    hintText: 'e.g. 150000',
                    prefixIcon: Icon(Icons.credit_score),
                  ),
                ),
              ],
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
          onPressed: _saveAccount,
          child: Text(isEditing ? 'Update Account' : 'Create Account'),
        ),
      ],
    );
  }
}
