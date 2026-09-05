import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class RecordDividendDialog extends ConsumerStatefulWidget {
  final ChittyInstallment installment;
  const RecordDividendDialog({super.key, required this.installment});

  @override
  ConsumerState<RecordDividendDialog> createState() => _RecordDividendDialogState();
}

class _RecordDividendDialogState extends ConsumerState<RecordDividendDialog> {
  final _dividendController = TextEditingController();
  final _prizeAmountController = TextEditingController();
  final _fdInterestController = TextEditingController();
  final _monthFdInterestController = TextEditingController();

  bool _isPrizedMonth = false;
  bool _depositAsChittyFd = false;
  bool _prizeAlreadyCredited = false; // By default, prize money processing takes days
  String? _selectedAccountId;
  double _netPayable = 0.0;
  double _defaultChittyFdMonthlyInterest = 0.0;
  bool _hasActiveChittyFd = false;

  bool _alreadyPrizedInOtherMonth = false;
  int? _otherPrizedMonthNumber;
  double? _otherPrizedAmount;

  @override
  void initState() {
    super.initState();
    _dividendController.text = widget.installment.dividendEarned > 0
        ? widget.installment.dividendEarned.toStringAsFixed(0)
        : '0';
    _isPrizedMonth = widget.installment.isPrizedMonth;
    _prizeAmountController.text = widget.installment.prizeAmountReceived > 0
        ? widget.installment.prizeAmountReceived.toStringAsFixed(0)
        : '';

    _checkExistingChittyMetadata();
    _recalculateNet();
  }

  Future<void> _checkExistingChittyMetadata() async {
    final db = ref.read(databaseProvider);
    final allInst = await (db.select(db.chittyInstallments)
          ..where((c) => c.investmentId.equals(widget.installment.investmentId)))
        .get();

    final prizedInst = allInst.where((c) => c.isPrizedMonth && c.id != widget.installment.id).toList();
    if (prizedInst.isNotEmpty) {
      final first = prizedInst.first;
      setState(() {
        _alreadyPrizedInOtherMonth = true;
        _otherPrizedMonthNumber = first.installmentNumber;
        _otherPrizedAmount = first.prizeAmountReceived;
      });
    }

    final inv = await (db.select(db.investments)
          ..where((i) => i.id.equals(widget.installment.investmentId)))
        .getSingleOrNull();

    if (inv?.notes != null) {
      try {
        final notesData = jsonDecode(inv!.notes!);
        final prizedMonthNumber = int.tryParse(notesData['prizedMonth']?.toString() ?? '') ?? 0;
        final prizeOption = notesData['prizeOption']?.toString();
        final fdMonthly = double.tryParse(notesData['fdInterestMonthly']?.toString() ?? '') ?? 0.0;
        final savedPrizeAmount = double.tryParse(notesData['prizeAmount']?.toString() ?? '') ?? 0.0;
        final prizeDisbursed = notesData['prizeDisbursed'] == true;

        // If this installment IS the prized month, restore its exact saved prize options and values
        if (widget.installment.isPrizedMonth || widget.installment.installmentNumber == prizedMonthNumber) {
          setState(() {
            _isPrizedMonth = true;
            _depositAsChittyFd = (prizeOption == 'chitty_fd');
            _prizeAlreadyCredited = prizeDisbursed;
            if (_prizeAmountController.text.isEmpty && savedPrizeAmount > 0) {
              _prizeAmountController.text = savedPrizeAmount.toStringAsFixed(0);
            }
            if (_fdInterestController.text.isEmpty && fdMonthly > 0) {
              _fdInterestController.text = fdMonthly.toStringAsFixed(0);
            }
          });
        }

        // Chitty FD interest only offsets subsequent months after the prized month
        if (prizeOption == 'chitty_fd' && widget.installment.installmentNumber > prizedMonthNumber) {
          setState(() {
            _hasActiveChittyFd = true;
            _defaultChittyFdMonthlyInterest = fdMonthly;
            if (_monthFdInterestController.text.isEmpty) {
              _monthFdInterestController.text = fdMonthly.toStringAsFixed(0);
            }
          });
        }
        _recalculateNet();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _dividendController.dispose();
    _prizeAmountController.dispose();
    _fdInterestController.dispose();
    _monthFdInterestController.dispose();
    super.dispose();
  }

  void _recalculateNet() {
    final div = double.tryParse(_dividendController.text.trim()) ?? 0.0;
    final monthFdOffset = (_hasActiveChittyFd && !_isPrizedMonth)
        ? (double.tryParse(_monthFdInterestController.text.trim()) ?? _defaultChittyFdMonthlyInterest)
        : 0.0;
    final totalDeductions = div + monthFdOffset;
    setState(() {
      _netPayable = (widget.installment.grossInstallment - totalDeductions).clamp(0.0, widget.installment.grossInstallment);
    });
  }

  void _recalculateFdInterestFromRate(double prizeAmount) {
    // Standard default 7.5% annual interest on Chitty security FD -> monthly: (P * 7.5 / 100 / 12)
    final monthly = (prizeAmount * 7.5 / 100 / 12);
    _fdInterestController.text = monthly.roundToDouble().toStringAsFixed(0);
  }

  Future<void> _updateInstallment() async {
    final div = double.tryParse(_dividendController.text.trim()) ?? 0.0;
    final prize = _isPrizedMonth ? (double.tryParse(_prizeAmountController.text.trim()) ?? 0.0) : 0.0;

    if (_isPrizedMonth && !_depositAsChittyFd && _prizeAlreadyCredited && _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a receiving Bank Account for the prize money')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    // 1. Update installment record
    await (db.update(db.chittyInstallments)..where((c) => c.id.equals(widget.installment.id))).write(
      ChittyInstallmentsCompanion(
        dividendEarned: drift.Value(div),
        netAmountPaid: drift.Value(_netPayable),
        isPaid: const drift.Value(true),
        paymentDate: drift.Value(DateTime.now()),
        isPrizedMonth: drift.Value(_isPrizedMonth),
        prizeAmountReceived: drift.Value(prize),
      ),
    );

    // 2. If prize money is won this month, update investment notes and handle payout / FD
    if (_isPrizedMonth && prize > 0) {
      final inv = await (db.select(db.investments)..where((i) => i.id.equals(widget.installment.investmentId))).getSingleOrNull();
      Map<String, dynamic> notesData = {};
      if (inv?.notes != null) {
        try {
          notesData = jsonDecode(inv!.notes!);
        } catch (_) {}
      }

      final monthlyFdInterest = _depositAsChittyFd
          ? (double.tryParse(_fdInterestController.text.trim()) ?? (prize * 7.5 / 100 / 12))
          : 0.0;

      notesData['isPrized'] = true;
      notesData['prizedMonth'] = widget.installment.installmentNumber;
      notesData['prizeAmount'] = prize;
      notesData['prizeOption'] = _depositAsChittyFd ? 'chitty_fd' : 'withdrawn';
      notesData['prizeDisbursed'] = !_depositAsChittyFd && _prizeAlreadyCredited;
      notesData['fdInterestMonthly'] = monthlyFdInterest;

      await (db.update(db.investments)..where((i) => i.id.equals(widget.installment.investmentId))).write(
        InvestmentsCompanion(notes: drift.Value(jsonEncode(notesData))),
      );

      // If Option A and already credited to bank, record ledger transaction immediately
      if (!_depositAsChittyFd && _prizeAlreadyCredited && _selectedAccountId != null) {
        await db.recordChittyPrizePayout(
          investmentId: widget.installment.investmentId,
          investmentName: inv?.name ?? 'Chit Fund',
          destinationAccountId: _selectedAccountId!,
          amount: prize,
          date: DateTime.now(),
        );
      }
    } else if (widget.installment.isPrizedMonth && !_isPrizedMonth) {
      // User untoggled prize on previously prized installment - clear prize metadata
      final inv = await (db.select(db.investments)..where((i) => i.id.equals(widget.installment.investmentId))).getSingleOrNull();
      if (inv?.notes != null) {
        try {
          final notesData = jsonDecode(inv!.notes!) as Map<String, dynamic>;
          notesData.remove('isPrized');
          notesData.remove('prizedMonth');
          notesData.remove('prizeAmount');
          notesData.remove('prizeOption');
          notesData.remove('prizeDisbursed');
          notesData.remove('fdInterestMonthly');
          await (db.update(db.investments)..where((i) => i.id.equals(widget.installment.investmentId))).write(
            InvestmentsCompanion(notes: drift.Value(jsonEncode(notesData))),
          );
        } catch (_) {}
      }
      final prizeTx = await (db.select(db.transactions)..where((t) => t.tag.equals('INV:${widget.installment.investmentId}:prize_payout'))).getSingleOrNull();
      if (prizeTx != null) {
        await db.deleteTransactionWithAccountUpdate(prizeTx.id);
      }
    }

    // 3. Update total paid valuation on investment
    final allInstallments = await (db.select(db.chittyInstallments)
          ..where((c) => c.investmentId.equals(widget.installment.investmentId)))
        .get();

    final totalPaidSoFar = allInstallments.where((c) => c.isPaid).fold(0.0, (sum, c) => sum + c.netAmountPaid);

    await (db.update(db.investments)..where((i) => i.id.equals(widget.installment.investmentId))).write(
      InvestmentsCompanion(currentValuation: drift.Value(totalPaidSoFar)),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isPrizedMonth
              ? (_depositAsChittyFd
                  ? 'Prize money deposited as Chitty FD! Monthly interest will offset future installments.'
                  : (_prizeAlreadyCredited
                      ? 'Prize money credited to your bank account!'
                      : 'Prize recorded! Reminder active in Studio to mark when funds hit your bank.'))
              : 'Chitty payment and dividend updated!'),
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

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          const Icon(Icons.groups_outlined, color: AppColors.chitty, size: 24),
          const Gap(8),
          Expanded(
            child: Text(
              'Month ${widget.installment.installmentNumber} Payment',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
              // 1. Gross Installment Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBorder.withValues(alpha: 0.3) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gross Subscription Due:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      CurrencyFormatter.format(widget.installment.grossInstallment),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Gap(14),

              // 2. Dividend Input
              Text('Auction Dividend Declared (₹)', style: theme.textTheme.labelMedium),
              const Gap(6),
              TextField(
                controller: _dividendController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _recalculateNet(),
                decoration: const InputDecoration(
                  hintText: 'e.g. 2500',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),

              // 3. Chitty FD Offset (Editable for this particular month - applies after prized month)
              if (_hasActiveChittyFd && !_isPrizedMonth) ...[
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.income.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.income.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance, size: 16, color: AppColors.incomeLight),
                              Gap(6),
                              Text('Chitty FD Interest Offset (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            'Default: ${CurrencyFormatter.format(_defaultChittyFdMonthlyInterest)}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Gap(6),
                      TextField(
                        controller: _monthFdInterestController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _recalculateNet(),
                        decoration: const InputDecoration(
                          prefixText: '₹ ',
                          hintText: 'e.g. 2375',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          helperText: 'Editable for this month if interest adjusted or customized',
                          helperStyle: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Gap(12),

              // 4. Net Payable Highlight
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.chitty.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.chitty.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Amount Payable:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      CurrencyFormatter.format(_netPayable),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.chitty),
                    ),
                  ],
                ),
              ),
              const Gap(14),

              // 5. Prized Month Section (Enforcing Single Auction Win)
              if (_alreadyPrizedInOtherMonth) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, size: 18, color: isDark ? Colors.amber.shade300 : Colors.amber.shade800),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Prize money already claimed in Month $_otherPrizedMonthNumber (${CurrencyFormatter.format(_otherPrizedAmount ?? 0)}). A single ticket can only be prized once.',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.amber.shade200 : Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Prized Month (Auction Won)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Did you win the auction this month?', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  value: _isPrizedMonth,
                  activeThumbColor: AppColors.chitty,
                  onChanged: (val) {
                    setState(() {
                      _isPrizedMonth = val;
                      if (val && _prizeAmountController.text.isEmpty) {
                        final suggested = widget.installment.grossInstallment * 35;
                        _prizeAmountController.text = suggested.toStringAsFixed(0);
                        _recalculateFdInterestFromRate(suggested);
                      }
                    });
                  },
                ),

                if (_isPrizedMonth) ...[
                  const Gap(6),
                  Text('Net Prize Money Received (₹)', style: theme.textTheme.labelMedium),
                  const Gap(4),
                  TextField(
                    controller: _prizeAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) {
                      final parsed = double.tryParse(val.trim()) ?? 0.0;
                      _recalculateFdInterestFromRate(parsed);
                    },
                    decoration: const InputDecoration(
                      prefixText: '₹ ',
                      hintText: 'e.g. 380000',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const Gap(12),

                  // Option A vs Option B
                  Text('Prize Money Handling Option', style: theme.textTheme.labelMedium),
                  const Gap(6),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<bool>(
                          title: const Text('Withdraw / Credit to Bank', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Disbursed into your bank account (takes a few days to process)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          value: false,
                          groupValue: _depositAsChittyFd,
                          onChanged: (val) => setState(() => _depositAsChittyFd = val ?? false),
                        ),
                        const Divider(height: 1),
                        RadioListTile<bool>(
                          title: const Text('Deposit as Chitty Security FD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Earns monthly interest to offset future installments', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          value: true,
                          groupValue: _depositAsChittyFd,
                          onChanged: (val) => setState(() => _depositAsChittyFd = val ?? true),
                        ),
                      ],
                    ),
                  ),

                  if (!_depositAsChittyFd) ...[
                    const Gap(10),
                    // Check if already credited or pending disbursal
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Already Credited to Bank Account?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('If off, Spendger will remind you in Studio to mark when funds arrive', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      value: _prizeAlreadyCredited,
                      activeThumbColor: AppColors.income,
                      onChanged: (val) => setState(() => _prizeAlreadyCredited = val),
                    ),
                    if (_prizeAlreadyCredited) ...[
                      const Gap(6),
                      Text('Select Receiving Bank Account', style: theme.textTheme.labelMedium),
                      const Gap(4),
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
                  ] else ...[
                    const Gap(10),
                    Text('Monthly Interest Offsetting Next Installments (₹)', style: theme.textTheme.labelMedium),
                    const Gap(4),
                    TextField(
                      controller: _fdInterestController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        hintText: 'e.g. 2375 (Monthly interest at ~7.5% p.a.)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (widget.installment.isPaid)
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            icon: const Icon(Icons.undo, size: 16),
            label: const Text('Revert Entry'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.undo, color: AppColors.expense, size: 22),
                      Gap(8),
                      Text('Revert Installment?'),
                    ],
                  ),
                  content: Text('Revert Month ${widget.installment.installmentNumber} payment and dividend record back to unpaid status?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense, foregroundColor: Colors.white),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Revert to Unpaid'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                final db = ref.read(databaseProvider);
                await db.revertChittyInstallment(widget.installment.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Month ${widget.installment.installmentNumber} payment reverted to unpaid.'),
                      backgroundColor: AppColors.expense,
                    ),
                  );
                }
              }
            },
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.chitty, foregroundColor: Colors.white),
          onPressed: _updateInstallment,
          child: Text(widget.installment.isPaid ? 'Update Payment' : 'Confirm & Mark Paid'),
        ),
      ],
    );
  }
}
