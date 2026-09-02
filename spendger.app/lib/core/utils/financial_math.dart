import 'dart:math' as math;

class AmortizationInstallment {
  final int monthNumber;
  final DateTime dueDate;
  final double openingBalance;
  final double emi;
  final double principal;
  final double interest;
  final double gstOnInterest;
  final double totalPayment;
  final double closingBalance;

  AmortizationInstallment({
    required this.monthNumber,
    required this.dueDate,
    required this.openingBalance,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.gstOnInterest,
    required this.totalPayment,
    required this.closingBalance,
  });
}

class EarlyPayoffSimulationResult {
  final double baselineTotalInterest;
  final double baselineTotalPayment;
  final int baselineTenureMonths;
  final double revisedTotalInterest;
  final double revisedTotalPayment;
  final int revisedTenureMonths;
  final double interestSaved;
  final int monthsSaved;
  final List<AmortizationInstallment> revisedSchedule;

  EarlyPayoffSimulationResult({
    required this.baselineTotalInterest,
    required this.baselineTotalPayment,
    required this.baselineTenureMonths,
    required this.revisedTotalInterest,
    required this.revisedTotalPayment,
    required this.revisedTenureMonths,
    required this.interestSaved,
    required this.monthsSaved,
    required this.revisedSchedule,
  });
}

class FinancialMath {
  /// Calculate Reducing Balance Monthly EMI
  static double calculateEmi({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return 0.0;
    if (annualInterestRate <= 0) return principal / tenureMonths;

    final double monthlyRate = (annualInterestRate / 12) / 100;
    final double factor = math.pow(1 + monthlyRate, tenureMonths).toDouble();
    final double emi = (principal * monthlyRate * factor) / (factor - 1);
    return emi.isNaN || emi.isInfinite ? 0.0 : emi;
  }

  /// Generate complete month-by-month amortization schedule
  static List<AmortizationInstallment> generateAmortizationSchedule({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
    double gstRateOnInterest = 0.0,
    DateTime? startDate,
  }) {
    if (principal <= 0 || tenureMonths <= 0) return [];

    final schedule = <AmortizationInstallment>[];
    final double monthlyRate = (annualInterestRate / 12) / 100;
    final double emi = calculateEmi(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
    );

    double currentBalance = principal;
    final start = startDate ?? DateTime.now();

    for (int month = 1; month <= tenureMonths && currentBalance > 0.01; month++) {
      final double interest = currentBalance * monthlyRate;
      final double gst = interest * (gstRateOnInterest / 100);
      double principalPart = emi - interest;

      if (principalPart > currentBalance || month == tenureMonths) {
        principalPart = currentBalance;
      }

      final double actualEmi = principalPart + interest;
      final double totalPayment = actualEmi + gst;
      final double closingBalance = math.max(0.0, currentBalance - principalPart);
      final dueDate = DateTime(start.year, start.month + (month - 1), start.day);

      schedule.add(
        AmortizationInstallment(
          monthNumber: month,
          dueDate: dueDate,
          openingBalance: currentBalance,
          emi: actualEmi,
          principal: principalPart,
          interest: interest,
          gstOnInterest: gst,
          totalPayment: totalPayment,
          closingBalance: closingBalance,
        ),
      );

      currentBalance = closingBalance;
    }

    return schedule;
  }

  /// Simulate Prepayment / Early Closure
  static EarlyPayoffSimulationResult simulateEarlyPayoff({
    required double principal,
    required double annualInterestRate,
    required int tenureMonths,
    required double lumpSumPrepayment,
    required int prepaymentMonth,
    double extraMonthlyPayment = 0.0,
    double gstRateOnInterest = 0.0,
    DateTime? startDate,
  }) {
    final baselineSchedule = generateAmortizationSchedule(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
      gstRateOnInterest: gstRateOnInterest,
      startDate: startDate,
    );

    double baselineInterest = 0.0;
    double baselinePayment = 0.0;
    for (final inst in baselineSchedule) {
      baselineInterest += inst.interest;
      baselinePayment += inst.totalPayment;
    }

    final double monthlyRate = (annualInterestRate / 12) / 100;
    final double standardEmi = calculateEmi(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenureMonths: tenureMonths,
    );

    final revisedSchedule = <AmortizationInstallment>[];
    double currentBalance = principal;
    final start = startDate ?? DateTime.now();

    int month = 1;
    while (currentBalance > 0.01 && month <= tenureMonths * 2) {
      final double interest = currentBalance * monthlyRate;
      final double gst = interest * (gstRateOnInterest / 100);

      double targetPayment = standardEmi + extraMonthlyPayment;
      if (month == prepaymentMonth) {
        targetPayment += lumpSumPrepayment;
      }

      double principalPart = targetPayment - interest;
      if (principalPart > currentBalance) {
        principalPart = currentBalance;
      }

      final double actualEmi = principalPart + interest;
      final double totalPayment = actualEmi + gst;
      final double closingBalance = math.max(0.0, currentBalance - principalPart);
      final dueDate = DateTime(start.year, start.month + (month - 1), start.day);

      revisedSchedule.add(
        AmortizationInstallment(
          monthNumber: month,
          dueDate: dueDate,
          openingBalance: currentBalance,
          emi: actualEmi,
          principal: principalPart,
          interest: interest,
          gstOnInterest: gst,
          totalPayment: totalPayment,
          closingBalance: closingBalance,
        ),
      );

      currentBalance = closingBalance;
      month++;
    }

    double revisedInterest = 0.0;
    double revisedPayment = 0.0;
    for (final inst in revisedSchedule) {
      revisedInterest += inst.interest;
      revisedPayment += inst.totalPayment;
    }

    final double interestSaved = math.max(0.0, baselineInterest - revisedInterest);
    final int monthsSaved = math.max(0, baselineSchedule.length - revisedSchedule.length);

    return EarlyPayoffSimulationResult(
      baselineTotalInterest: baselineInterest,
      baselineTotalPayment: baselinePayment,
      baselineTenureMonths: baselineSchedule.length,
      revisedTotalInterest: revisedInterest,
      revisedTotalPayment: revisedPayment,
      revisedTenureMonths: revisedSchedule.length,
      interestSaved: interestSaved,
      monthsSaved: monthsSaved,
      revisedSchedule: revisedSchedule,
    );
  }

  /// Chit Fund (Chitty) calculation helpers
  static double calculateChittyNetPayable({
    required double grossInstallment,
    required double dividendEarned,
  }) {
    return math.max(0.0, grossInstallment - dividendEarned);
  }

  /// Gold valuation & profit/loss
  static Map<String, double> calculateGoldValuation({
    required double weightGrams,
    required double currentPricePerGram,
    required double totalCost,
  }) {
    final currentValuation = weightGrams * currentPricePerGram;
    final pnl = currentValuation - totalCost;
    final roiPercent = totalCost > 0 ? (pnl / totalCost) * 100 : 0.0;

    return {
      'currentValuation': currentValuation,
      'pnl': pnl,
      'roiPercent': roiPercent,
    };
  }
}
