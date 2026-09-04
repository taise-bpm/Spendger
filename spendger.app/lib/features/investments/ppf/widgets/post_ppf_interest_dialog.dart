import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class PostPpfInterestDialog extends ConsumerStatefulWidget {
  final Investment ppfInvestment;
  final int financialYearStart; // e.g. 2026
  final double calculatedInterest;
  final double openingBalance;
  final double totalDepositedThisFy;

  const PostPpfInterestDialog({
    super.key,
    required this.ppfInvestment,
    required this.financialYearStart,
    required this.calculatedInterest,
    required this.openingBalance,
    required this.totalDepositedThisFy,
  });

  @override
  ConsumerState<PostPpfInterestDialog> createState() => _PostPpfInterestDialogState();
}

class _PostPpfInterestDialogState extends ConsumerState<PostPpfInterestDialog> {
  final _interestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _interestController.text = widget.calculatedInterest.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _interestController.dispose();
    super.dispose();
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
    final updatedClosingBalance = widget.openingBalance + widget.totalDepositedThisFy + interest;

    await db.postPpfAnnualInterest(
      investmentId: widget.ppfInvestment.id,
      financialYearStart: widget.financialYearStart,
      interestAmount: interest,
      updatedClosingBalance: updatedClosingBalance,
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

  @override
  Widget build(BuildContext context) {
    final fyLabel = 'FY ${widget.financialYearStart}-${(widget.financialYearStart + 1) % 100}';

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: AppColors.incomeLight, size: 24),
          const Gap(8),
          Text('Post Real Interest ($fyLabel)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.ppf.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.ppf.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('5th-Day Rule Calc Interest:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          CurrencyFormatter.format(widget.calculatedInterest),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.incomeLight),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Deposited this FY:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          CurrencyFormatter.format(widget.totalDepositedThisFy),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(14),
              const Text(
                'Enter the exact annual interest credited on March 31 as shown in your Bank / Post Office PPF statement:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Gap(10),
              TextField(
                controller: _interestController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Statement Interest Amount (₹)',
                  hintText: 'e.g. 10650',
                  prefixIcon: Icon(Icons.currency_rupee),
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
          onPressed: _postInterest,
          child: const Text('Post to Statement'),
        ),
      ],
    );
  }
}
