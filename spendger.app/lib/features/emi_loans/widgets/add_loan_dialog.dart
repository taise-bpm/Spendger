import 'dart:math' as math;
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';

class AddLoanDialog extends ConsumerStatefulWidget {
  final EmiLoan? loanToEdit;
  final LoanComparisonOffer? initialComparisonOffer;

  const AddLoanDialog({
    super.key,
    this.loanToEdit,
    this.initialComparisonOffer,
  });

  @override
  ConsumerState<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends ConsumerState<AddLoanDialog> {
  final _productNameController = TextEditingController();
  final _lenderNameController = TextEditingController();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _gstController = TextEditingController(text: '0.0');
  final _feeController = TextEditingController(text: '0.0');

  String _loanCategory = 'personal_bank'; // 'personal_bank', 'asset_vehicle', 'friend_family', 'other'
  bool _isProcessingFeePercentage = false;
  bool _includeFeeGst = true;
  bool _disburseToAccount = false;
  String? _selectedDisbursedAccountId;

  DateTime _startDate = DateTime.now();
  String? _selectedExpenseCategoryId;
  String? _selectedDefaultAccountId;
  bool _autoLogExpense = true;

  double _calculatedEmi = 0.0;
  bool get _isEditing => widget.loanToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final loan = widget.loanToEdit!;
      _productNameController.text = loan.productName;
      _lenderNameController.text = loan.lenderName ?? '';
      _loanCategory = loan.loanCategory;
      _principalController.text = loan.principalAmount.truncateToDouble() == loan.principalAmount
          ? loan.principalAmount.toInt().toString()
          : loan.principalAmount.toString();
      _rateController.text = loan.annualInterestRate.toString();
      _tenureController.text = loan.tenureMonths.toString();
      _gstController.text = loan.gstRateOnInterest.toString();
      _feeController.text = loan.processingFee.toString();
      _isProcessingFeePercentage = loan.isProcessingFeePercentage;
      _selectedDisbursedAccountId = loan.disbursedAccountId;
      _startDate = loan.startDate;
      _calculatedEmi = loan.monthlyEmi;
      _selectedExpenseCategoryId = loan.expenseCategoryId;
      _selectedDefaultAccountId = loan.defaultAccountId;
      _autoLogExpense = loan.autoLogExpense;
    } else if (widget.initialComparisonOffer != null) {
      final offer = widget.initialComparisonOffer!;
      _productNameController.text = '${offer.lenderName} Loan';
      _lenderNameController.text = offer.lenderName;
      _loanCategory = offer.loanCategory;
      _principalController.text = offer.principalAmount.truncateToDouble() == offer.principalAmount
          ? offer.principalAmount.toInt().toString()
          : offer.principalAmount.toString();
      _rateController.text = offer.annualInterestRate.toString();
      _tenureController.text = offer.tenureMonths.toString();
      _feeController.text = offer.processingFee.toString();
      _isProcessingFeePercentage = offer.isProcessingFeePercentage;
      _includeFeeGst = offer.gstRateOnFees > 0;
      _disburseToAccount = offer.loanCategory == 'personal_bank' || offer.loanCategory == 'friend_family';
      _recalculateEmi();
    } else {
      _disburseToAccount = _loanCategory == 'personal_bank';
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _lenderNameController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _gstController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _recalculateEmi() {
    final principal = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final tenure = int.tryParse(_tenureController.text.trim()) ?? 0;

    setState(() {
      _calculatedEmi = FinancialMath.calculateEmi(
        principal: principal,
        annualInterestRate: rate,
        tenureMonths: tenure,
      );
    });
  }

  double _getCalculatedUpfrontFee(double principal) {
    if (_loanCategory == 'friend_family') return 0.0;
    final feeVal = double.tryParse(_feeController.text.trim()) ?? 0.0;
    return FinancialMath.calculateTotalProcessingFee(
      principal: principal,
      processingFeeValue: feeVal,
      isPercentage: _isProcessingFeePercentage,
      gstRate: _includeFeeGst ? 18.0 : 0.0,
    );
  }

  Future<void> _saveLoan() async {
    final productName = _productNameController.text.trim();
    final principal = double.tryParse(_principalController.text.trim());
    final rate = double.tryParse(_rateController.text.trim());
    final tenure = int.tryParse(_tenureController.text.trim());
    final gstRate = double.tryParse(_gstController.text.trim()) ?? 0.0;
    final feeVal = double.tryParse(_feeController.text.trim()) ?? 0.0;

    if (productName.isEmpty || principal == null || rate == null || tenure == null || principal <= 0 || tenure <= 0 || rate < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all loan fields accurately')),
      );
      return;
    }

    if (_disburseToAccount && _selectedDisbursedAccountId == null && !_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account to receive loan disbursal')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final emi = FinancialMath.calculateEmi(
      principal: principal,
      annualInterestRate: rate,
      tenureMonths: tenure,
    );

    final upfrontFee = _getCalculatedUpfrontFee(principal);
    final netDisbursal = math.max(0.0, principal - upfrontFee);

    if (_isEditing) {
      final updatedCompanion = EmiLoansCompanion(
        id: drift.Value(widget.loanToEdit!.id),
        productName: drift.Value(productName),
        lenderName: drift.Value(_lenderNameController.text.trim().isEmpty ? null : _lenderNameController.text.trim()),
        loanCategory: drift.Value(_loanCategory),
        principalAmount: drift.Value(principal),
        annualInterestRate: drift.Value(rate),
        tenureMonths: drift.Value(tenure),
        monthlyEmi: drift.Value(emi),
        startDate: drift.Value(_startDate),
        gstRateOnInterest: drift.Value(gstRate),
        expenseCategoryId: drift.Value(_selectedExpenseCategoryId),
        defaultAccountId: drift.Value(_selectedDefaultAccountId),
        disbursedAccountId: drift.Value(_selectedDisbursedAccountId),
        processingFee: drift.Value(feeVal),
        isProcessingFeePercentage: drift.Value(_isProcessingFeePercentage),
        netDisbursedAmount: drift.Value(netDisbursal),
        autoLogExpense: drift.Value(_autoLogExpense),
        status: drift.Value(widget.loanToEdit!.status),
        createdAt: drift.Value(widget.loanToEdit!.createdAt),
      );

      await db.updateLoan(widget.loanToEdit!.id, updatedCompanion);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EMI Loan & Ledger settings updated!'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    } else {
      const uuid = Uuid();
      final loanId = uuid.v4();
      final now = DateTime.now();

      final newLoan = EmiLoansCompanion.insert(
        id: loanId,
        productName: productName,
        lenderName: drift.Value(_lenderNameController.text.trim().isEmpty ? null : _lenderNameController.text.trim()),
        loanCategory: drift.Value(_loanCategory),
        principalAmount: principal,
        annualInterestRate: rate,
        tenureMonths: tenure,
        monthlyEmi: emi,
        startDate: _startDate,
        gstRateOnInterest: drift.Value(gstRate),
        expenseCategoryId: drift.Value(_selectedExpenseCategoryId),
        defaultAccountId: drift.Value(_selectedDefaultAccountId),
        disbursedAccountId: drift.Value(_selectedDisbursedAccountId),
        processingFee: drift.Value(feeVal),
        isProcessingFeePercentage: drift.Value(_isProcessingFeePercentage),
        netDisbursedAmount: drift.Value(netDisbursal),
        autoLogExpense: drift.Value(_autoLogExpense),
        status: const drift.Value('active'),
        createdAt: now,
      );

      await db.createLoanWithDisbursal(
        loan: newLoan,
        disburseToAccount: _disburseToAccount,
        destinationAccountId: _selectedDisbursedAccountId,
        netDisbursalAmount: netDisbursal,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_disburseToAccount
                ? 'EMI Loan created and ${CurrencyFormatter.format(netDisbursal)} credited to account!'
                : 'EMI Loan created successfully!'),
            backgroundColor: AppColors.loan,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider('expense'));
    final accountsAsync = ref.watch(activeAccountsStreamProvider);

    final expenseCategories = categoriesAsync.value ?? [];
    final accounts = accountsAsync.value ?? [];

    if (_selectedExpenseCategoryId == null && expenseCategories.isNotEmpty) {
      final emiCat = expenseCategories.firstWhere(
        (c) => c.name.toLowerCase().contains('loan') || c.name.toLowerCase().contains('emi'),
        orElse: () => expenseCategories.first,
      );
      _selectedExpenseCategoryId = emiCat.id;
    }

    if (_selectedDefaultAccountId == null && accounts.isNotEmpty) {
      _selectedDefaultAccountId = accounts.first.id;
    }

    if (_selectedDisbursedAccountId == null && accounts.isNotEmpty) {
      _selectedDisbursedAccountId = accounts.first.id;
    }

    final principal = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final upfrontFee = _getCalculatedUpfrontFee(principal);
    final netDisbursed = math.max(0.0, principal - upfrontFee);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(_isEditing ? 'Edit EMI Loan & Settings' : 'Add New EMI Loan', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            // Loan Category Selector
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Loan Category & Type',
                prefixIcon: Icon(Icons.account_balance),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _loanCategory,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'personal_bank',
                      child: Text('Personal Loan (Bank / Cash Disbursal)', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: 'asset_vehicle',
                      child: Text('Vehicle / Asset Loan (Direct to Dealer)', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: 'friend_family',
                      child: Text('Friend / Family Loan (0% Interest / P2P)', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text('Other / Custom Loan', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _loanCategory = val;
                        if (val == 'friend_family') {
                          _rateController.text = '0.0';
                          _feeController.text = '0.0';
                          _disburseToAccount = true;
                        } else if (val == 'asset_vehicle') {
                          _disburseToAccount = false;
                        } else if (val == 'personal_bank') {
                          _disburseToAccount = true;
                        }
                        _recalculateEmi();
                      });
                    }
                  },
                ),
              ),
            ),
            const Gap(12),

            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: _loanCategory == 'friend_family'
                    ? 'Loan Purpose (e.g. Borrowed from Rahul)'
                    : (_loanCategory == 'asset_vehicle' ? 'Vehicle / Asset Name (e.g. Hunter 350)' : 'Product / Loan Name'),
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const Gap(12),
            TextField(
              controller: _lenderNameController,
              decoration: InputDecoration(
                labelText: _loanCategory == 'friend_family' ? 'Friend / Relative Name' : 'Lender / Bank (e.g., HDFC, SBI)',
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const Gap(12),
            TextField(
              controller: _principalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _recalculateEmi(),
              decoration: const InputDecoration(
                labelText: 'Total Principal Amount (₹)',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _recalculateEmi(),
                    decoration: InputDecoration(
                      labelText: _loanCategory == 'friend_family' ? 'Interest Rate (0% for Friends)' : 'Annual Rate (%)',
                      prefixIcon: const Icon(Icons.percent),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: TextField(
                    controller: _tenureController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalculateEmi(),
                    decoration: const InputDecoration(
                      labelText: 'Tenure (Months)',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),

            // Processing Fee & Deductions Section (Hidden for friend/family 0% loans)
            if (_loanCategory != 'friend_family') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 16, color: Colors.blueGrey),
                        Gap(6),
                        Text('Processing Fees & Documentation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const Gap(8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _feeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: _isProcessingFeePercentage ? 'Fee Percentage (%)' : 'Fixed Fee (₹)',
                              prefixIcon: Icon(_isProcessingFeePercentage ? Icons.percent : Icons.currency_rupee, size: 16),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _isProcessingFeePercentage = true),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _isProcessingFeePercentage ? AppColors.loan : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                                      ),
                                      child: Text(
                                        '%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: _isProcessingFeePercentage ? Colors.white : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => setState(() => _isProcessingFeePercentage = false),
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: !_isProcessingFeePercentage ? AppColors.loan : Colors.transparent,
                                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                                      ),
                                      child: Text(
                                        '₹',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: !_isProcessingFeePercentage ? Colors.white : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),
                    InkWell(
                      onTap: () => setState(() => _includeFeeGst = !_includeFeeGst),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _includeFeeGst,
                            activeColor: AppColors.loan,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) => setState(() => _includeFeeGst = val ?? true),
                          ),
                          const Expanded(
                            child: Text('+ 18% GST on processing fee', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
            ],

            // Disbursal to Bank/Cash Account Section
            if (!_isEditing) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.income.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.income.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance_wallet, size: 16, color: AppColors.incomeLight),
                              const Gap(6),
                              Expanded(
                                child: Text(
                                  _loanCategory == 'friend_family'
                                      ? 'Deposit Borrowed Cash to Account'
                                      : 'Disburse Funds to Bank Account',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(8),
                        Switch(
                          value: _disburseToAccount,
                          activeThumbColor: AppColors.incomeLight,
                          onChanged: (val) => setState(() => _disburseToAccount = val),
                        ),
                      ],
                    ),
                    Text(
                      _disburseToAccount
                          ? 'Net loan amount of ${CurrencyFormatter.format(netDisbursed)} will be credited to selected account.'
                          : 'Funds paid directly to vendor/dealer. Personal account balance will not change.',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    if (_disburseToAccount) ...[
                      const Gap(8),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Deposit Destination Account',
                          prefixIcon: Icon(Icons.account_balance, size: 18),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDisbursedAccountId,
                            isExpanded: true,
                            items: accounts.map((a) {
                              return DropdownMenuItem(
                                value: a.id,
                                child: Text('${a.name} (${CurrencyFormatter.format(a.currentBalance)})', overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedDisbursedAccountId = val),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(12),
            ],

            // Loan Start Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _startDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Loan Start / Disbursal Date',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy').format(_startDate),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const Icon(Icons.edit_calendar, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const Gap(12),

            // Expense Ledger Default Settings Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryLight),
                            Gap(6),
                            Expanded(
                              child: Text(
                                'Expense Ledger Automation',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Switch(
                        value: _autoLogExpense,
                        activeThumbColor: AppColors.primaryLight,
                        onChanged: (val) => setState(() => _autoLogExpense = val),
                      ),
                    ],
                  ),
                  const Text(
                    'Automatically pre-tags this category & account on future EMI payments',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  if (_autoLogExpense) ...[
                    const Gap(8),
                    // Default Expense Category
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Default Expense Header / Category',
                        prefixIcon: Icon(Icons.category_outlined, size: 18),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedExpenseCategoryId,
                          isExpanded: true,
                          items: expenseCategories.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: Color(c.colorValue),
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedExpenseCategoryId = val),
                        ),
                      ),
                    ),
                    const Gap(10),
                    // Default Payment Account
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Default Payment Account',
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDefaultAccountId,
                          isExpanded: true,
                          items: accounts.map((a) {
                            return DropdownMenuItem(
                              value: a.id,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      a.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    CurrencyFormatter.format(a.currentBalance),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedDefaultAccountId = val),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Gap(14),

            // Live Calculated EMI preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.loan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.loan.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Estimated Monthly EMI:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        CurrencyFormatter.format(_calculatedEmi),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.loanLight),
                      ),
                    ],
                  ),
                  if (upfrontFee > 0) ...[
                    const Gap(6),
                    const Divider(height: 1),
                    const Gap(6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Upfront Processing Fee:',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          CurrencyFormatter.format(upfrontFee),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Net Disbursed Amount:',
                            style: TextStyle(fontSize: 11, color: AppColors.incomeLight, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          CurrencyFormatter.format(netDisbursed),
                          style: const TextStyle(fontSize: 12, color: AppColors.incomeLight, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.loan, foregroundColor: Colors.white),
          onPressed: _saveLoan,
          child: Text(_isEditing ? 'Save Changes' : 'Create EMI Schedule'),
        ),
      ],
    );
  }
}
