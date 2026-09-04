import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendger/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase In-Memory Tests', () {
    test('Categories and Accounts are seeded on creation', () async {
      final categories = await db.getAllCategories();
      final accounts = await db.getAllAccounts();

      expect(categories.isNotEmpty, isTrue);
      expect(accounts.isNotEmpty, isTrue);
      expect(categories.any((c) => c.name == 'Food & Dining'), isTrue);
    });

    test('addTransactionWithAccountUpdate inserts transaction and updates account balance', () async {
      final accounts = await db.getAllAccounts();
      final categories = await db.getAllCategories(type: 'expense');
      final acc = accounts.first;
      final cat = categories.first;

      const uuid = Uuid();
      final tx = TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: cat.id,
        accountId: drift.Value(acc.id),
        amount: 250.0,
        type: 'expense',
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await db.addTransactionWithAccountUpdate(tx);

      final updatedAccounts = await db.getAllAccounts();
      final updatedAcc = updatedAccounts.firstWhere((a) => a.id == acc.id);

      expect(updatedAcc.currentBalance, equals(acc.currentBalance - 250.0));
    });

    test('EMI Loan creation and payments insertion', () async {
      const uuid = Uuid();
      final loanId = uuid.v4();

      await db.into(db.emiLoans).insert(
        EmiLoansCompanion.insert(
          id: loanId,
          productName: 'Car Loan',
          principalAmount: 300000.0,
          annualInterestRate: 9.5,
          tenureMonths: 36,
          monthlyEmi: 9611.0,
          startDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      final loans = await db.watchLoans(status: 'active').first;
      expect(loans.length, equals(1));
      expect(loans.first.productName, equals('Car Loan'));
    });

    test('Investment CRUD and Investment Ledger sync with Accounts', () async {
      final accounts = await db.getAllAccounts();
      final categories = await db.getAllCategories(type: 'expense');
      final acc = accounts.first;
      final initialBalance = acc.currentBalance;

      const uuid = Uuid();
      final invId = uuid.v4();

      // 1. Create FD Investment
      await db.into(db.investments).insert(
        InvestmentsCompanion.insert(
          id: invId,
          name: 'HDFC 1-Yr FD',
          type: 'fd',
          startDate: DateTime.now(),
          purchasePrice: const drift.Value(100000.0),
          totalCommittedAmount: const drift.Value(100000.0),
          currentValuation: 107250.0,
          createdAt: DateTime.now(),
        ),
      );

      final invList = await db.getAllInvestments();
      expect(invList.any((i) => i.id == invId), isTrue);

      // 2. Record Investment Deposit in Ledger (Expense)
      await db.recordInvestmentTransaction(
        investmentId: invId,
        investmentName: 'HDFC 1-Yr FD',
        investmentType: 'FD',
        txType: 'deposit',
        amount: 100000.0,
        date: DateTime.now(),
        accountId: acc.id,
        categoryId: categories.first.id,
      );

      // Account balance should decrease by 100,000
      var updatedAcc = (await db.getAllAccounts()).firstWhere((a) => a.id == acc.id);
      expect(updatedAcc.currentBalance, equals(initialBalance - 100000.0));

      // 3. Watch Investment Transactions
      final ledger = await db.watchInvestmentTransactions(investmentId: invId).first;
      expect(ledger.length, equals(1));
      expect(ledger.first.amount, equals(100000.0));

      // 4. Record Dividend / Return (Income)
      await db.recordInvestmentTransaction(
        investmentId: invId,
        investmentName: 'HDFC 1-Yr FD',
        investmentType: 'FD',
        txType: 'dividend',
        amount: 7250.0,
        date: DateTime.now(),
        accountId: acc.id,
        categoryId: categories.first.id,
      );

      updatedAcc = (await db.getAllAccounts()).firstWhere((a) => a.id == acc.id);
      expect(updatedAcc.currentBalance, equals(initialBalance - 100000.0 + 7250.0));

      // 5. Delete Investment (should clean up linked transactions and revert balances)
      await db.deleteInvestment(invId);

      final remainingInvs = await db.getAllInvestments();
      expect(remainingInvs.any((i) => i.id == invId), isFalse);

      final remainingLedger = await db.watchInvestmentTransactions(investmentId: invId).first;
      expect(remainingLedger.isEmpty, isTrue);

      // Balance should be reverted back to initialBalance
      final finalAcc = (await db.getAllAccounts()).firstWhere((a) => a.id == acc.id);
      expect(finalAcc.currentBalance, equals(initialBalance));
    });

    test('recordIntraTransfer atomically transfers funds between accounts', () async {
      final accounts = await db.getAllAccounts();
      final fromAcc = accounts[0];
      final toAcc = accounts[1];
      final initialFromBalance = fromAcc.currentBalance;
      final initialToBalance = toAcc.currentBalance;

      await db.recordIntraTransfer(
        fromAccountId: fromAcc.id,
        toAccountId: toAcc.id,
        amount: 5000.0,
        date: DateTime.now(),
        note: 'Bank to Wallet Transfer',
      );

      final updatedAccounts = await db.getAllAccounts();
      final updatedFrom = updatedAccounts.firstWhere((a) => a.id == fromAcc.id);
      final updatedTo = updatedAccounts.firstWhere((a) => a.id == toAcc.id);

      expect(updatedFrom.currentBalance, equals(initialFromBalance - 5000.0));
      expect(updatedTo.currentBalance, equals(initialToBalance + 5000.0));

      final recentTx = await db.watchRecentTransactions(limit: 1).first;
      expect(recentTx.first.type, equals('transfer'));
      expect(recentTx.first.toAccountId, equals(toAcc.id));

      // Test delete rollback
      await db.deleteTransactionWithAccountUpdate(recentTx.first.id);
      final rolledBackAccounts = await db.getAllAccounts();
      expect(rolledBackAccounts.firstWhere((a) => a.id == fromAcc.id).currentBalance, equals(initialFromBalance));
      expect(rolledBackAccounts.firstWhere((a) => a.id == toAcc.id).currentBalance, equals(initialToBalance));
    });

    test('postPpfAnnualInterest updates PPF valuation and logs annual statement interest', () async {
      const uuid = Uuid();
      final ppfId = uuid.v4();

      await db.into(db.investments).insert(
        InvestmentsCompanion.insert(
          id: ppfId,
          name: 'SBI Public Provident Fund',
          type: 'ppf',
          startDate: DateTime(2025, 4, 1),
          totalCommittedAmount: const drift.Value(150000.0),
          currentValuation: 150000.0,
          createdAt: DateTime.now(),
        ),
      );

      await db.postPpfAnnualInterest(
        investmentId: ppfId,
        financialYearStart: 2025,
        interestAmount: 10650.0,
        updatedClosingBalance: 160650.0,
      );

      final inv = (await db.getAllInvestments()).firstWhere((i) => i.id == ppfId);
      expect(inv.currentValuation, equals(160650.0));

      final ledger = await db.watchInvestmentTransactions(investmentId: ppfId).first;
      expect(ledger.length, equals(1));
      expect(ledger.first.amount, equals(10650.0));
      expect(ledger.first.type, equals('income'));
    });
  });
}
