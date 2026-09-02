import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';

class EarlyPayoffSimulatorSheet extends StatefulWidget {
  final EmiLoan loan;
  const EarlyPayoffSimulatorSheet({super.key, required this.loan});

  @override
  State<EarlyPayoffSimulatorSheet> createState() => _EarlyPayoffSimulatorSheetState();
}

class _EarlyPayoffSimulatorSheetState extends State<EarlyPayoffSimulatorSheet> {
  double _lumpSumPrepayment = 0.0;
  double _extraMonthlyPayment = 0.0;
  int _prepaymentMonth = 1;

  @override
  void initState() {
    super.initState();
    _lumpSumPrepayment = (widget.loan.principalAmount * 0.1).clamp(0, widget.loan.principalAmount);
    _prepaymentMonth = 6.clamp(1, widget.loan.tenureMonths);
  }

  @override
  Widget build(BuildContext context) {
    final result = FinancialMath.simulateEarlyPayoff(
      principal: widget.loan.principalAmount,
      annualInterestRate: widget.loan.annualInterestRate,
      tenureMonths: widget.loan.tenureMonths,
      lumpSumPrepayment: _lumpSumPrepayment,
      prepaymentMonth: _prepaymentMonth,
      extraMonthlyPayment: _extraMonthlyPayment,
      gstRateOnInterest: widget.loan.gstRateOnInterest,
      startDate: widget.loan.startDate,
    );

    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(14),
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.loanLight),
              const Gap(8),
              Expanded(
                child: Text(
                  'Early Payoff & Prepayment Simulator',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(
            'See how much interest and tenure you save with prepayments',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const Gap(18),
          // Savings Impact Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF065F46)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.income.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL INTEREST SAVED',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    const Gap(4),
                    Text(
                      CurrencyFormatter.format(result.interestSaved),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('Tenure Saved', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${result.monthsSaved} Months',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),
          Expanded(
            child: ListView(
              children: [
                // Lump Sum Slider
                Text(
                  'One-Time Lump Sum Prepayment: ${CurrencyFormatter.format(_lumpSumPrepayment)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Slider(
                  value: _lumpSumPrepayment,
                  min: 0,
                  max: widget.loan.principalAmount,
                  divisions: 100,
                  activeColor: AppColors.loan,
                  onChanged: (val) => setState(() => _lumpSumPrepayment = val),
                ),
                const Gap(8),
                // Prepayment Month Slider
                Text(
                  'Prepayment at Month: Month $_prepaymentMonth',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Slider(
                  value: _prepaymentMonth.toDouble(),
                  min: 1,
                  max: widget.loan.tenureMonths.toDouble(),
                  divisions: widget.loan.tenureMonths > 1 ? widget.loan.tenureMonths - 1 : 1,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _prepaymentMonth = val.toInt()),
                ),
                const Gap(8),
                // Extra Monthly Payment Slider
                Text(
                  'Recurring Extra Monthly Payment: ${CurrencyFormatter.format(_extraMonthlyPayment)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Slider(
                  value: _extraMonthlyPayment,
                  min: 0,
                  max: widget.loan.monthlyEmi * 2,
                  divisions: 50,
                  activeColor: AppColors.sip,
                  onChanged: (val) => setState(() => _extraMonthlyPayment = val),
                ),
                const Gap(16),
                // Comparison Table
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildComparisonRow('Metric', 'Original Loan', 'With Prepayment', isHeader: true),
                        const Divider(),
                        _buildComparisonRow(
                          'Total Tenure',
                          '${result.baselineTenureMonths} Months',
                          '${result.revisedTenureMonths} Months',
                        ),
                        _buildComparisonRow(
                          'Total Interest',
                          CurrencyFormatter.format(result.baselineTotalInterest),
                          CurrencyFormatter.format(result.revisedTotalInterest),
                          highlightValue: true,
                        ),
                        _buildComparisonRow(
                          'Total Payment',
                          CurrencyFormatter.format(result.baselineTotalPayment),
                          CurrencyFormatter.format(result.revisedTotalPayment),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close Simulator', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String metric, String val1, String val2, {bool isHeader = false, bool highlightValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              metric,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Colors.grey : null,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              val1,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                color: isHeader ? Colors.grey : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              val2,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.bold,
                color: highlightValue ? AppColors.incomeLight : (isHeader ? Colors.grey : null),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
