import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_helper.dart';

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

  bool _isActive = true;
  String _accountType = 'bank'; // 'bank', 'credit_card', 'cash', 'wallet'
  String? _defaultPayFromAccountId;
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
      _defaultPayFromAccountId = acc.defaultPayFromAccountId;
      _selectedColor = acc.colorValue;
      _selectedIcon = acc.iconCode;
      _isActive = acc.isActive;
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
    final isCard = _accountType == 'card' || _accountType == 'credit_card';
    final creditLimit = isCard
        ? double.tryParse(_creditLimitController.text.trim())
        : null;
    final defaultPayFrom = isCard ? _defaultPayFromAccountId : null;

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
        defaultPayFromAccountId: drift.Value(defaultPayFrom),
        isActive: drift.Value(_isActive),
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

    final accountsAsync = ref.watch(activeAccountsStreamProvider);
    final allAccounts = accountsAsync.value ?? [];
    final availablePayFromAccounts = allAccounts.where((a) =>
      a.id != (widget.accountToEdit?.id ?? '') &&
      a.accountType != 'card' &&
      a.accountType != 'credit_card'
    ).toList();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(isEditing ? 'Edit Account' : 'New Account / Card', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  labelText: isCard ? 'Current Outstanding Due (₹)' : 'Current Balance (₹)',
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
                const Gap(10),
                DropdownButtonFormField<String?>(
                  initialValue: availablePayFromAccounts.any((a) => a.id == _defaultPayFromAccountId)
                      ? _defaultPayFromAccountId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Default "Pay From" Account (Optional)',
                    hintText: 'Select account for quick bill pay',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None / Choose Each Time', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                    ...availablePayFromAccounts.map((a) => DropdownMenuItem<String?>(
                          value: a.id,
                          child: Row(
                            children: [
                              Icon(IconHelper.getIcon(a.iconCode), size: 16, color: Color(a.colorValue)),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  '${a.name} (${CurrencyFormatter.format(a.currentBalance)})',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (val) => setState(() => _defaultPayFromAccountId = val),
                ),
              ],
              if (isEditing) ...[
                const Gap(10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Account Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(
                    _isActive ? 'Active & In-Use' : 'Archived / Inactive (Preserved in history)',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  value: _isActive,
                  activeThumbColor: AppColors.incomeLight,
                  onChanged: (val) => setState(() => _isActive = val),
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
