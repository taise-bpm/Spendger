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

class DepositMaturityResult {
  final double principalInvested;
  final double maturityAmount;
  final double totalInterestEarned;
  final double effectiveYieldAnnual;

  DepositMaturityResult({
    required this.principalInvested,
    required this.maturityAmount,
    required this.totalInterestEarned,
    required this.effectiveYieldAnnual,
  });
}

class InvestmentScheduleItem {
  final int periodNumber;
  final String periodLabel; // e.g. "Month 1", "FY 2026-27 (Year 1)"
  final DateTime dueDate;
  final double scheduledAmount;
  final double cumulativeInvested;
  final double projectedBalance;
  final double interestAccrued;
  final String note;

  InvestmentScheduleItem({
    required this.periodNumber,
    required this.periodLabel,
    required this.dueDate,
    required this.scheduledAmount,
    required this.cumulativeInvested,
    required this.projectedBalance,
    required this.interestAccrued,
    this.note = '',
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

  /// Fixed Deposit Maturity Calculation (Simple & Compound)
  /// compoundingFrequency: 0 = Simple Interest, 1 = Annually, 2 = Half-Yearly, 4 = Quarterly, 12 = Monthly
  static DepositMaturityResult calculateFdMaturity({
    required double principal,
    required double annualInterestRate,
    required double tenureYears,
    int compoundingFrequency = 4, // Default Indian Bank FD: Quarterly
  }) {
    if (principal <= 0 || tenureYears <= 0) {
      return DepositMaturityResult(
        principalInvested: principal,
        maturityAmount: principal,
        totalInterestEarned: 0.0,
        effectiveYieldAnnual: 0.0,
      );
    }

    if (annualInterestRate <= 0) {
      return DepositMaturityResult(
        principalInvested: principal,
        maturityAmount: principal,
        totalInterestEarned: 0.0,
        effectiveYieldAnnual: 0.0,
      );
    }

    double maturityAmount;
    if (compoundingFrequency == 0) {
      // Simple Interest: A = P * (1 + r * t)
      maturityAmount = principal * (1 + (annualInterestRate / 100) * tenureYears);
    } else {
      // Compound Interest: A = P * (1 + r/n)^(n * t)
      final n = compoundingFrequency;
      final ratePerPeriod = (annualInterestRate / 100) / n;
      final totalPeriods = n * tenureYears;
      maturityAmount = principal * math.pow(1 + ratePerPeriod, totalPeriods).toDouble();
    }

    final interestEarned = math.max(0.0, maturityAmount - principal);
    final effectiveYield = (interestEarned / principal / tenureYears) * 100;

    return DepositMaturityResult(
      principalInvested: principal,
      maturityAmount: maturityAmount,
      totalInterestEarned: interestEarned,
      effectiveYieldAnnual: effectiveYield,
    );
  }

  /// Recurring Deposit Maturity Calculation (Quarterly Compounding standard in Indian Banks)
  /// monthlyDeposit: Monthly installment amount (P)
  /// annualInterestRate: Interest rate per annum (r)
  /// tenureMonths: Total tenure in months (t)
  static DepositMaturityResult calculateRdMaturity({
    required double monthlyDeposit,
    required double annualInterestRate,
    required int tenureMonths,
  }) {
    final totalInvested = monthlyDeposit * tenureMonths;
    if (monthlyDeposit <= 0 || tenureMonths <= 0) {
      return DepositMaturityResult(
        principalInvested: 0.0,
        maturityAmount: 0.0,
        totalInterestEarned: 0.0,
        effectiveYieldAnnual: 0.0,
      );
    }

    if (annualInterestRate <= 0) {
      return DepositMaturityResult(
        principalInvested: totalInvested,
        maturityAmount: totalInvested,
        totalInterestEarned: 0.0,
        effectiveYieldAnnual: 0.0,
      );
    }

    // Standard Indian Banking formula for RD with quarterly compounding:
    // i = (r / 100) / 4 = r / 400
    // M = P * ((1 + i)^(t/3) - 1) / (1 - (1 + i)^(-1/3))
    final i = (annualInterestRate / 100) / 4;
    final quarters = tenureMonths / 3.0;
    final numerator = math.pow(1 + i, quarters) - 1;
    final denominator = 1 - math.pow(1 + i, -1.0 / 3.0);
    final maturityAmount = monthlyDeposit * (numerator / denominator);
    final interestEarned = math.max(0.0, maturityAmount - totalInvested);
    final tenureYears = tenureMonths / 12.0;
    final effectiveYield = tenureYears > 0 ? (interestEarned / totalInvested / tenureYears) * 100 : 0.0;

    return DepositMaturityResult(
      principalInvested: totalInvested,
      maturityAmount: maturityAmount,
      totalInterestEarned: interestEarned,
      effectiveYieldAnnual: effectiveYield,
    );
  }

  /// Public Provident Fund (PPF) Maturity Calculation
  /// yearlyDeposit: Amount deposited per financial year (max 1.5L)
  /// annualInterestRate: Rate per annum (default 7.1%)
  /// tenureYears: Tenure in years (default 15)
  static DepositMaturityResult calculatePpfMaturity({
    required double yearlyDeposit,
    double annualInterestRate = 7.1,
    int tenureYears = 15,
  }) {
    final totalInvested = yearlyDeposit * tenureYears;
    if (yearlyDeposit <= 0 || tenureYears <= 0) {
      return DepositMaturityResult(
        principalInvested: 0.0,
        maturityAmount: 0.0,
        totalInterestEarned: 0.0,
        effectiveYieldAnnual: 0.0,
      );
    }

    // PPF formula (compounded annually, deposit at beginning of each year):
    // F = P * [((1 + i)^n - 1) / i] * (1 + i)
    final i = annualInterestRate / 100;
    final maturityAmount = yearlyDeposit * ((math.pow(1 + i, tenureYears) - 1) / i) * (1 + i);
    final interestEarned = math.max(0.0, maturityAmount - totalInvested);
    final effectiveYield = (interestEarned / totalInvested / tenureYears) * 100;

    return DepositMaturityResult(
      principalInvested: totalInvested,
      maturityAmount: maturityAmount,
      totalInterestEarned: interestEarned,
      effectiveYieldAnnual: effectiveYield,
    );
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

  /// Generate month-by-month Recurring Deposit schedule
  static List<InvestmentScheduleItem> generateRdSchedule({
    required double monthlyDeposit,
    required double annualInterestRate,
    required int tenureMonths,
    DateTime? startDate,
  }) {
    if (monthlyDeposit <= 0 || tenureMonths <= 0) return [];

    final start = startDate ?? DateTime.now();
    final schedule = <InvestmentScheduleItem>[];
    final i = (annualInterestRate / 100) / 4;

    for (int month = 1; month <= tenureMonths; month++) {
      final dueDate = DateTime(start.year, start.month + (month - 1), start.day);
      final cumulativeInvested = monthlyDeposit * month;

      // Projected cumulative maturity value at month 'month' with quarterly compounding
      double projectedBalance = cumulativeInvested;
      if (annualInterestRate > 0 && month >= 1) {
        final quarters = month / 3.0;
        final num = math.pow(1 + i, quarters) - 1;
        final den = 1 - math.pow(1 + i, -1.0 / 3.0);
        projectedBalance = monthlyDeposit * (num / den);
      }

      final interestAccrued = math.max(0.0, projectedBalance - cumulativeInvested);

      schedule.add(
        InvestmentScheduleItem(
          periodNumber: month,
          periodLabel: 'Month $month',
          dueDate: dueDate,
          scheduledAmount: monthlyDeposit,
          cumulativeInvested: cumulativeInvested,
          projectedBalance: projectedBalance,
          interestAccrued: interestAccrued,
        ),
      );
    }

    return schedule;
  }

  /// Generate 15-year annual PPF schedule
  static List<InvestmentScheduleItem> generatePpfSchedule({
    required double yearlyDeposit,
    double annualInterestRate = 7.1,
    int tenureYears = 15,
    DateTime? startDate,
  }) {
    if (yearlyDeposit <= 0 || tenureYears <= 0) return [];

    final start = startDate ?? DateTime.now();
    final schedule = <InvestmentScheduleItem>[];
    final i = annualInterestRate / 100;

    for (int year = 1; year <= tenureYears; year++) {
      final dueDate = DateTime(start.year + (year - 1), start.month, start.day);
      final fyStart = start.year + (year - 1);
      final fyEnd = (fyStart + 1) % 100;
      final periodLabel = 'FY $fyStart-${fyEnd.toString().padLeft(2, '0')} (Yr $year)';

      final cumulativeInvested = yearlyDeposit * year;
      final projectedBalance = yearlyDeposit * ((math.pow(1 + i, year) - 1) / i) * (1 + i);
      final interestAccrued = math.max(0.0, projectedBalance - cumulativeInvested);

      schedule.add(
        InvestmentScheduleItem(
          periodNumber: year,
          periodLabel: periodLabel,
          dueDate: dueDate,
          scheduledAmount: yearlyDeposit,
          cumulativeInvested: cumulativeInvested,
          projectedBalance: projectedBalance,
          interestAccrued: interestAccrued,
          note: '100% Tax-Free (EEE)',
        ),
      );
    }

    return schedule;
  }

  /// Generate Monthly SIP schedule (Rolling 12 or 24 months)
  static List<InvestmentScheduleItem> generateSipSchedule({
    required double monthlyAmount,
    DateTime? startDate,
    int monthsCount = 12,
  }) {
    if (monthlyAmount <= 0 || monthsCount <= 0) return [];

    final start = startDate ?? DateTime.now();
    final schedule = <InvestmentScheduleItem>[];

    for (int month = 1; month <= monthsCount; month++) {
      final dueDate = DateTime(start.year, start.month + (month - 1), start.day);
      final cumulativeInvested = monthlyAmount * month;

      schedule.add(
        InvestmentScheduleItem(
          periodNumber: month,
          periodLabel: 'Month $month',
          dueDate: dueDate,
          scheduledAmount: monthlyAmount,
          cumulativeInvested: cumulativeInvested,
          projectedBalance: cumulativeInvested,
          interestAccrued: 0.0,
        ),
      );
    }

    return schedule;
  }

  /// Generate FD Accrual & Maturity Milestones
  static List<InvestmentScheduleItem> generateFdSchedule({
    required double principal,
    required double annualInterestRate,
    required double tenureYears,
    int compoundingFrequency = 4,
    DateTime? startDate,
  }) {
    if (principal <= 0 || tenureYears <= 0) return [];

    final start = startDate ?? DateTime.now();
    final schedule = <InvestmentScheduleItem>[];
    
    // Milestone 1: Initial Deposit
    schedule.add(
      InvestmentScheduleItem(
        periodNumber: 1,
        periodLabel: 'Initial Deposit (Principal)',
        dueDate: start,
        scheduledAmount: principal,
        cumulativeInvested: principal,
        projectedBalance: principal,
        interestAccrued: 0.0,
        note: 'Deposit active',
      ),
    );

    // Milestone 2: Final Maturity
    final maturityResult = calculateFdMaturity(
      principal: principal,
      annualInterestRate: annualInterestRate,
      tenureYears: tenureYears,
      compoundingFrequency: compoundingFrequency,
    );

    final totalDays = (tenureYears * 365).round();
    final maturityDate = start.add(Duration(days: totalDays));

    schedule.add(
      InvestmentScheduleItem(
        periodNumber: 2,
        periodLabel: 'Maturity & Payout',
        dueDate: maturityDate,
        scheduledAmount: maturityResult.maturityAmount,
        cumulativeInvested: principal,
        projectedBalance: maturityResult.maturityAmount,
        interestAccrued: maturityResult.totalInterestEarned,
        note: 'Maturity payout with interest',
      ),
    );

    return schedule;
  }

  /// Official PPF 5th-Day Rule Month Breakdown & Annual Compounding Calculation
  static PpfFinancialYearResult calculatePpfFinancialYear({
    required int financialYearStart, // e.g. 2026 for FY 2026-27
    required double openingBalance,
    required List<PpfDepositEntry> deposits,
    double annualInterestRate = 7.1,
  }) {
    final months = <PpfMonthlyBreakdown>[];
    final monthlyRate = (annualInterestRate / 100) / 12;

    double runningBalance = openingBalance;
    double totalAnnualInterest = 0.0;
    double totalDepositedThisYear = 0.0;

    // Months of the Financial Year: Month 4 (Apr) to Month 12 (Dec) of fyStart, then Month 1 (Jan) to Month 3 (Mar) of fyStart + 1
    final fyMonths = [
      (year: financialYearStart, month: 4, name: 'April'),
      (year: financialYearStart, month: 5, name: 'May'),
      (year: financialYearStart, month: 6, name: 'June'),
      (year: financialYearStart, month: 7, name: 'July'),
      (year: financialYearStart, month: 8, name: 'August'),
      (year: financialYearStart, month: 9, name: 'September'),
      (year: financialYearStart, month: 10, name: 'October'),
      (year: financialYearStart, month: 11, name: 'November'),
      (year: financialYearStart, month: 12, name: 'December'),
      (year: financialYearStart + 1, month: 1, name: 'January'),
      (year: financialYearStart + 1, month: 2, name: 'February'),
      (year: financialYearStart + 1, month: 3, name: 'March'),
    ];

    for (int i = 0; i < fyMonths.length; i++) {
      final m = fyMonths[i];
      final monthDeposits = deposits.where((d) => d.date.year == m.year && d.date.month == m.month).toList();

      double onOrBefore5thDeposits = 0.0;
      double after5thDeposits = 0.0;

      for (final d in monthDeposits) {
        if (d.date.day <= 5) {
          onOrBefore5thDeposits += d.amount;
        } else {
          after5thDeposits += d.amount;
        }
        totalDepositedThisYear += d.amount;
      }

      // Eligible lowest balance for month's interest is running balance + deposits on or before 5th
      final eligibleBalance = runningBalance + onOrBefore5thDeposits;
      final monthInterest = eligibleBalance * monthlyRate;
      totalAnnualInterest += monthInterest;

      // New running balance at end of this month includes all deposits made in this month
      runningBalance = runningBalance + onOrBefore5thDeposits + after5thDeposits;

      months.add(
        PpfMonthlyBreakdown(
          monthName: m.name,
          calendarYear: m.year,
          calendarMonth: m.month,
          openingBalance: runningBalance - onOrBefore5thDeposits - after5thDeposits,
          depositsOnOrBefore5th: onOrBefore5thDeposits,
          depositsAfter5th: after5thDeposits,
          eligibleLowestBalance: eligibleBalance,
          monthlyInterestEarned: monthInterest,
          closingBalanceEndOfMonth: runningBalance,
        ),
      );
    }

    final closingBalanceOnMarch31 = runningBalance + totalAnnualInterest;

    return PpfFinancialYearResult(
      financialYearStart: financialYearStart,
      financialYearLabel: 'FY $financialYearStart-${(financialYearStart + 1) % 100}',
      openingBalanceApril1: openingBalance,
      totalDepositedInFY: totalDepositedThisYear,
      totalInterestEarnedInFY: totalAnnualInterest,
      closingBalanceMarch31: closingBalanceOnMarch31,
      monthlyBreakdowns: months,
    );
  }
}

class PpfDepositEntry {
  final DateTime date;
  final double amount;
  final String note;

  PpfDepositEntry({
    required this.date,
    required this.amount,
    this.note = '',
  });
}

class PpfMonthlyBreakdown {
  final String monthName;
  final int calendarYear;
  final int calendarMonth;
  final double openingBalance;
  final double depositsOnOrBefore5th;
  final double depositsAfter5th;
  final double eligibleLowestBalance;
  final double monthlyInterestEarned;
  final double closingBalanceEndOfMonth;

  PpfMonthlyBreakdown({
    required this.monthName,
    required this.calendarYear,
    required this.calendarMonth,
    required this.openingBalance,
    required this.depositsOnOrBefore5th,
    required this.depositsAfter5th,
    required this.eligibleLowestBalance,
    required this.monthlyInterestEarned,
    required this.closingBalanceEndOfMonth,
  });
}

class PpfFinancialYearResult {
  final int financialYearStart;
  final String financialYearLabel;
  final double openingBalanceApril1;
  final double totalDepositedInFY;
  final double totalInterestEarnedInFY;
  final double closingBalanceMarch31;
  final List<PpfMonthlyBreakdown> monthlyBreakdowns;

  PpfFinancialYearResult({
    required this.financialYearStart,
    required this.financialYearLabel,
    required this.openingBalanceApril1,
    required this.totalDepositedInFY,
    required this.totalInterestEarnedInFY,
    required this.closingBalanceMarch31,
    required this.monthlyBreakdowns,
  });
}
