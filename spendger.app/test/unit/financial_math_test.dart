import 'package:flutter_test/flutter_test.dart';
import 'package:spendger/core/utils/financial_math.dart';

void main() {
  group('FinancialMath - EMI & Amortization Calculations', () {
    test('calculateEmi calculates standard reducing balance EMI correctly', () {
      // Principal: 100,000, Rate: 12% p.a., Tenure: 12 months
      // Expected Monthly EMI is approx 8884.88
      final emi = FinancialMath.calculateEmi(
        principal: 100000,
        annualInterestRate: 12.0,
        tenureMonths: 12,
      );

      expect(emi, closeTo(8884.88, 0.5));
    });

    test('generateAmortizationSchedule generates valid schedule with zero closing balance', () {
      final schedule = FinancialMath.generateAmortizationSchedule(
        principal: 50000,
        annualInterestRate: 10.0,
        tenureMonths: 6,
        gstRateOnInterest: 18.0,
      );

      expect(schedule.length, equals(6));
      expect(schedule.last.closingBalance, closeTo(0.0, 0.05));
      expect(schedule.first.monthNumber, equals(1));
      expect(schedule.first.gstOnInterest, greaterThan(0.0));
    });

    test('simulateEarlyPayoff calculates interest savings and tenure reduction accurately', () {
      final result = FinancialMath.simulateEarlyPayoff(
        principal: 1000000, // 10 Lakhs
        annualInterestRate: 8.5,
        tenureMonths: 120, // 10 Years (120 months)
        lumpSumPrepayment: 200000, // 2 Lakh lump sum
        prepaymentMonth: 12, // at Month 12
      );

      expect(result.interestSaved, greaterThan(0.0));
      expect(result.monthsSaved, greaterThan(0));
      expect(result.revisedTenureMonths, lessThan(result.baselineTenureMonths));
    });
  });

  group('FinancialMath - Chit Fund (Chitty) & Gold Valuation', () {
    test('calculateChittyNetPayable deducts declared auction dividend from gross installment', () {
      final net = FinancialMath.calculateChittyNetPayable(
        grossInstallment: 10000,
        dividendEarned: 2200,
      );

      expect(net, equals(7800.0));
    });

    test('calculateGoldValuation computes profit/loss and ROI accurately', () {
      final res = FinancialMath.calculateGoldValuation(
        weightGrams: 8.0, // 1 Sovereign
        currentPricePerGram: 7200,
        totalCost: 50000,
      );

      expect(res['currentValuation'], equals(57600.0));
      expect(res['pnl'], equals(7600.0));
      expect(res['roiPercent'], closeTo(15.2, 0.1));
    });
  });

  group('FinancialMath - FD, RD, and PPF Calculations', () {
    test('calculateFdMaturity computes Simple and Compound Interest FD accurately', () {
      // Simple Interest: 1,00,000 at 7.0% for 1 year -> 1,07,000 (Interest 7000)
      final simpleRes = FinancialMath.calculateFdMaturity(
        principal: 100000,
        annualInterestRate: 7.0,
        tenureYears: 1.0,
        compoundingFrequency: 0,
      );
      expect(simpleRes.maturityAmount, equals(107000.0));
      expect(simpleRes.totalInterestEarned, equals(7000.0));

      // Quarterly Compounding: 1,00,000 at 7.0% for 1 year -> ~107,185.90
      final compoundRes = FinancialMath.calculateFdMaturity(
        principal: 100000,
        annualInterestRate: 7.0,
        tenureYears: 1.0,
        compoundingFrequency: 4,
      );
      expect(compoundRes.maturityAmount, closeTo(107185.90, 1.0));
      expect(compoundRes.totalInterestEarned, closeTo(7185.90, 1.0));
    });

    test('calculateRdMaturity computes standard quarterly compounded RD maturity', () {
      // 5000/month for 12 months at 7% p.a.
      // Total deposited: 60,000. Maturity: ~62,314.50
      final rdRes = FinancialMath.calculateRdMaturity(
        monthlyDeposit: 5000,
        annualInterestRate: 7.0,
        tenureMonths: 12,
      );

      expect(rdRes.principalInvested, equals(60000.0));
      expect(rdRes.maturityAmount, closeTo(62314.50, 10.0));
      expect(rdRes.totalInterestEarned, greaterThan(2200.0));
    });

    test('calculatePpfMaturity computes 15-year annual compounded PPF maturity', () {
      // 1,50,000 / year at 7.1% for 15 years
      // Total Invested: 22,50,000. Maturity: 40,68,209.22
      final ppfRes = FinancialMath.calculatePpfMaturity(
        yearlyDeposit: 150000,
        annualInterestRate: 7.1,
        tenureYears: 15,
      );

      expect(ppfRes.principalInvested, equals(2250000.0));
      expect(ppfRes.maturityAmount, closeTo(4068209.0, 50.0));
      expect(ppfRes.totalInterestEarned, greaterThan(1800000.0));
    });

    test('calculatePpfFinancialYear accurately enforces the 5th-Day rule', () {
      const rate = 7.1; // 7.1% p.a.

      // Case 1: ₹1,50,000 deposited on April 4 (on or before 5th)
      // April lowest balance: 1,50,000. Earns interest for all 12 months.
      // Monthly interest: 150000 * 7.1 / 1200 = 887.50 / mo.
      // Annual interest on March 31: 887.50 * 12 = 10,650.
      final resultEarly = FinancialMath.calculatePpfFinancialYear(
        financialYearStart: 2025,
        openingBalance: 0.0,
        annualInterestRate: rate,
        deposits: [
          PpfDepositEntry(date: DateTime(2025, 4, 4), amount: 150000),
        ],
      );

      expect(resultEarly.totalDepositedInFY, equals(150000.0));
      expect(resultEarly.totalInterestEarnedInFY, closeTo(10650.0, 1.0));
      expect(resultEarly.closingBalanceMarch31, closeTo(160650.0, 1.0));
      expect(resultEarly.monthlyBreakdowns[0].monthlyInterestEarned, closeTo(887.50, 0.1));

      // Case 2: ₹1,50,000 deposited on April 10 (after 5th)
      // April lowest balance: 0. Earns 0 interest in April.
      // May to March (11 months): 887.50 * 11 = 9,762.50.
      final resultLate = FinancialMath.calculatePpfFinancialYear(
        financialYearStart: 2025,
        openingBalance: 0.0,
        annualInterestRate: rate,
        deposits: [
          PpfDepositEntry(date: DateTime(2025, 4, 10), amount: 150000),
        ],
      );

      expect(resultLate.monthlyBreakdowns[0].monthlyInterestEarned, equals(0.0)); // April = 0
      expect(resultLate.monthlyBreakdowns[1].monthlyInterestEarned, closeTo(887.50, 0.1)); // May = 887.50
      expect(resultLate.totalInterestEarnedInFY, closeTo(9762.50, 1.0));
      expect(resultLate.closingBalanceMarch31, closeTo(159762.50, 1.0));

      // The early deposit earned exactly (10650 - 9762.50) = 887.50 more interest!
      expect(resultEarly.totalInterestEarnedInFY - resultLate.totalInterestEarnedInFY, closeTo(887.50, 0.1));
    });

    test('generatePpfSchedule generates realistic 15-year PPF timeline', () {
      final schedule = FinancialMath.generatePpfSchedule(
        yearlyDeposit: 100000,
        annualInterestRate: 7.1,
        startDate: DateTime(2025, 4, 1),
        tenureYears: 15,
      );

      expect(schedule.length, equals(15));
      expect(schedule.first.periodLabel, contains('FY 2025-26'));
      expect(schedule.last.periodLabel, contains('FY 2039-40'));
      expect(schedule.last.projectedBalance, greaterThan(2700000.0));
    });
  });
}

