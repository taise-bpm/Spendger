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
  });
}
