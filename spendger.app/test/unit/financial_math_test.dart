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
}
