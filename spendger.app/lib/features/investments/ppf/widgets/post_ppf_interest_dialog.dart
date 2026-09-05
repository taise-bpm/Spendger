import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/financial_math.dart';

class PostPpfInterestDialog extends ConsumerStatefulWidget {
  final Investment ppfInvestment;
  final int initialFinancialYearStart;
  final List<Transaction>? allTransactions;
  final Transaction? existingTransaction;

  // Legacy constructor arguments for compatibility
  final int? financialYearStart;
  final double? calculatedInterest;
  final double? openingBalance;
  final double? totalDepositedThisFy;

  const PostPpfInterestDialog({
    super.key,
    required this.ppfInvestment,
    this.initialFinancialYearStart = 0,
    this.allTransactions,
    this.existingTransaction,
    this.financialYearStart,
    this.calculatedInterest,
    this.openingBalance,
    this.totalDepositedThisFy,
  });

  @override
  ConsumerState<PostPpfInterestDialog> createState() => _PostPpfInterestDialogState();
}

class _PostPpfInterestDialogState extends ConsumerState<PostPpfInterestDialog> {
  final _interestController = TextEditingController();
  final _notesController = TextEditingController();

  late int _selectedFyStart;
  late List<int> _availableYears;
  late DateTime _interestDate;

  double _currentCalculatedInterest = 0.0;
  double _currentOpeningBalance = 0.0;
  double _currentTotalDepositedThisFy = 0.0;

  List<Transaction> _allTx = [];

  @override
  void initState() {
    super.initState();
    _allTx = widget.allTransactions ?? [];

    final now = DateTime.now();
    final currentFyStart = now.month >= 4 ? now.year : now.year - 1;
    final inceptionFyStart = widget.ppfInvestment.startDate.month >= 4
        ? widget.ppfInvestment.startDate.year
        : widget.ppfInvestment.startDate.year - 1;

    final startYear = inceptionFyStart < currentFyStart ? inceptionFyStart : currentFyStart;
    final List<int> years = [];
    for (int y = startYear; y <= currentFyStart; y++) {
      years.add(y);
    }
    _availableYears = years.reversed.toList();

    // Determine initial FY
    if (widget.existingTransaction != null) {
      final txDate = widget.existingTransaction!.transactionDate;
      _selectedFyStart = txDate.month >= 4 ? txDate.year : txDate.year - 1;
    } else if (widget.financialYearStart != null && widget.financialYearStart! > 0) {
      _selectedFyStart = widget.financialYearStart!;
    } else if (widget.initialFinancialYearStart > 0) {
      _selectedFyStart = widget.initialFinancialYearStart;
    } else {
      _selectedFyStart = _availableYears.isNotEmpty ? _availableYears.first : currentFyStart;
    }

    if (!_availableYears.contains(_selectedFyStart)) {
      _availableYears.insert(0, _selectedFyStart);
    }

    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _interestController.text = tx.amount.toStringAsFixed(0);
      _notesController.text = tx.notes ?? '';
      _interestDate = tx.transactionDate;
      _computeFyMetrics(_selectedFyStart, updateTextFields: false);
    } else {
      _interestDate = DateTime(_selectedFyStart + 1, 3, 31);
      _computeFyMetrics(_selectedFyStart, updateTextFields: true);
    }
  }

  @override
  void dispose() {
    _interestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _computeFyMetrics(int fy, {bool updateTextFields = false}) {
    final fyStartDate = DateTime(fy, 4, 1);
    final fyEndDate = DateTime(fy + 1, 3, 31, 23, 59, 59);

    final fyDepositsTx = _allTx.where((t) {
      return t.type == 'expense' &&
          t.transactionDate.isAfter(fyStartDate.subtract(const Duration(seconds: 1))) &&
          t.transactionDate.isBefore(fyEndDate.add(const Duration(seconds: 1)));
    }).toList();

    final List<PpfDepositEntry> depositEntries = fyDepositsTx.map((t) {
      return PpfDepositEntry(date: t.transactionDate, amount: t.amount, note: t.notes ?? '');
    }).toList();

    Map<String, dynamic> notesData = {};
    if (widget.ppfInvestment.notes != null) {
      try {
        notesData = jsonDecode(widget.ppfInvestment.notes!);
      } catch (_) {}
    }
    final double storedOpeningBalance = double.tryParse(notesData['openingBalance']?.toString() ?? '') ?? 0.0;

    final pastDepositsTx = _allTx.where((t) {
      return t.type == 'expense' && t.transactionDate.isBefore(fyStartDate);
    }).toList();
    final double totalPastDeposits = pastDepositsTx.fold(0.0, (sum, d) => sum + d.amount);

    final pastInterestTx = _allTx.where((t) {
      return t.type == 'income' && t.transactionDate.isBefore(fyStartDate);
    }).toList();
    final double totalPastInterest = pastInterestTx.fold(0.0, (sum, d) => sum + d.amount);

    final double totalDepositedThisFy = depositEntries.fold(0.0, (sum, d) => sum + d.amount);
    final double openingBalanceForFy = storedOpeningBalance + totalPastDeposits + totalPastInterest;

    final fyResult = FinancialMath.calculatePpfFinancialYear(
      financialYearStart: fy,
      openingBalance: openingBalanceForFy,
      deposits: depositEntries,
    );

    setState(() {
      _selectedFyStart = fy;
      _currentCalculatedInterest = fyResult.totalInterestEarnedInFY;
      _currentOpeningBalance = openingBalanceForFy;
      _currentTotalDepositedThisFy = totalDepositedThisFy;
      _interestDate = DateTime(fy + 1, 3, 31);

      if (updateTextFields) {
        _interestController.text = _currentCalculatedInterest.toStringAsFixed(0);
        _notesController.text =
            '${widget.ppfInvestment.name} - Statement Interest Credited for FY $fy-${(fy + 1) % 100}';
      }
    });
  }

  Future<void> _postInterest() async {
    final interest = double.tryParse(_interestController.text.trim());

    if (interest == null || interest < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid interest amount')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final isEditing = widget.existingTransaction != null;

    if (isEditing) {
      final oldInterest = widget.existingTransaction!.amount;
      final delta = interest - oldInterest;

      final categories = await db.getAllCategories(type: 'income');
      final invCategory = categories.firstWhere(
        (c) => c.name.toLowerCase().contains('investment'),
        orElse: () => categories.first,
      );

      // Update existing transaction
      await db.updateTransactionWithAccountUpdate(
        widget.existingTransaction!,
        TransactionsCompanion(
          id: drift.Value(widget.existingTransaction!.id),
          categoryId: drift.Value(invCategory.id),
          amount: drift.Value(interest),
          type: const drift.Value('income'),
          transactionDate: drift.Value(_interestDate),
          notes: drift.Value(_notesController.text.trim()),
          tag: drift.Value('INV:${widget.ppfInvestment.id}:ppf_interest:fy$_selectedFyStart'),
        ),
      );

      // Update PPF valuation by delta
      await (db.update(db.investments)..where((i) => i.id.equals(widget.ppfInvestment.id))).write(
        InvestmentsCompanion(
          currentValuation: drift.Value(widget.ppfInvestment.currentValuation + delta),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passbook interest entry updated!'),
            backgroundColor: AppColors.incomeLight,
          ),
        );
      }
    } else {
      final updatedClosingBalance = _currentOpeningBalance + _currentTotalDepositedThisFy + interest;

      await db.postPpfAnnualInterest(
        investmentId: widget.ppfInvestment.id,
        financialYearStart: _selectedFyStart,
        interestAmount: interest,
        updatedClosingBalance: updatedClosingBalance,
        transactionDate: _interestDate,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statement interest posted and PPF balance updated!'),
            backgroundColor: AppColors.incomeLight,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existingTransaction != null;
    final now = DateTime.now();
    final currentFyStart = now.month >= 4 ? now.year : now.year - 1;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.income.withValues(alpha: 0.2) : Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: isDark ? AppColors.incomeLight : Colors.green.shade800,
              size: 22,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              isEditing ? 'Edit Passbook Interest' : 'Post Passbook Interest',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Financial Year Switcher
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_note, size: 18, color: AppColors.ppf),
                        const Gap(8),
                        Text(
                          'Financial Year:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedFyStart,
                        dropdownColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.ppf),
                        items: _availableYears.map((year) {
                          final label = 'FY $year-${(year + 1) % 100}';
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              year == currentFyStart ? '$label (Active)' : label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: year == currentFyStart
                                    ? (isDark ? AppColors.incomeLight : Colors.green.shade800)
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (year) {
                          if (year != null && year != _selectedFyStart) {
                            _computeFyMetrics(year, updateTextFields: true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),

              // 2. Summary Info Box for Selected FY
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.ppf.withValues(alpha: 0.1) : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.ppf.withValues(alpha: 0.25) : Colors.indigo.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calculated 5th-Day Interest:',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
                        Text(
                          CurrencyFormatter.format(_currentCalculatedInterest),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? AppColors.incomeLight : Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Opening + FY Deposits:',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
                        Text(
                          CurrencyFormatter.format(_currentOpeningBalance + _currentTotalDepositedThisFy),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(12),

              Text(
                'Enter the actual interest credited in your bank/post office passbook statement (credited on March 31):',
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              ),
              const Gap(10),

              // Interest Amount
              TextField(
                controller: _interestController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Credited Interest Amount (₹)',
                  hintText: 'e.g. 10500',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const Gap(10),

              // Date Picker Field
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _interestDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _interestDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: AppColors.ppf),
                          const Gap(8),
                          Text(
                            'Statement Date: ${DateFormat('dd MMM yyyy').format(_interestDate)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Icon(Icons.edit_calendar, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const Gap(10),

              // Note Field
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Passbook Note / Reference',
                  hintText: 'e.g. Annual Interest Credited',
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
            backgroundColor: isDark ? AppColors.incomeLight : AppColors.ppf,
            foregroundColor: isDark ? Colors.black87 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _postInterest,
          child: Text(
            isEditing ? 'Save Changes' : 'Post to Passbook',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
