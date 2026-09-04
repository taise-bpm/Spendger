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
      expect(categories.any((c) => c.name == 'Loan Disbursement' && c.type == 'income'), isTrue);
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

    test('recordCreditCardBillPayment settles credit card balance from bank account', () async {
      final accounts = await db.getAllAccounts();
      final bankAcc = accounts.firstWhere((a) => a.accountType == 'bank');
      final cardAcc = accounts.firstWhere((a) => a.accountType == 'card' || a.accountType == 'credit_card');
      
      final initialBankBalance = bankAcc.currentBalance;
      final initialCardBalance = cardAcc.currentBalance; // e.g. -5000 or whatever seeded

      await db.recordCreditCardBillPayment(
        fromAccountId: bankAcc.id,
        creditCardAccountId: cardAcc.id,
        amount: 2500.0,
        date: DateTime.now(),
        note: 'HDFC Credit Card Bill Payment',
      );

      final updatedAccounts = await db.getAllAccounts();
      final updatedBank = updatedAccounts.firstWhere((a) => a.id == bankAcc.id);
      final updatedCard = updatedAccounts.firstWhere((a) => a.id == cardAcc.id);

      // Bank debited, Card credited (debt reduced)
      expect(updatedBank.currentBalance, equals(initialBankBalance - 2500.0));
      expect(updatedCard.currentBalance, equals(initialCardBalance + 2500.0));

      final recentTx = await db.watchRecentTransactions(limit: 1).first;
      expect(recentTx.first.type, equals('transfer'));
      expect(recentTx.first.notes, contains('Credit Card Bill Payment'));
    });

    test('Credit Card with defaultPayFromAccountId supports automatic pay-from source link', () async {
      final accounts = await db.getAllAccounts();
      final bankAcc = accounts.firstWhere((a) => a.accountType == 'bank');

      const uuid = Uuid();
      final cardId = uuid.v4();

      // Create new credit card with bankAcc as default pay from account
      await db.upsertAccount(
        AccountsCompanion(
          id: drift.Value(cardId),
          name: const drift.Value('Amazon ICICI Credit Card'),
          accountType: const drift.Value('credit_card'),
          currentBalance: const drift.Value(-8500.0),
          creditLimit: const drift.Value(200000.0),
          defaultPayFromAccountId: drift.Value(bankAcc.id),
          isActive: const drift.Value(true),
          iconCode: const drift.Value(0xe19f),
          colorValue: const drift.Value(0xFFF43F5E),
        ),
      );

      final fetchedCard = (await db.getAllAccounts()).firstWhere((a) => a.id == cardId);
      expect(fetchedCard.defaultPayFromAccountId, equals(bankAcc.id));
      expect(fetchedCard.creditLimit, equals(200000.0));
      expect(fetchedCard.currentBalance, equals(-8500.0));

      // Perform quick pay full due using the default pay from account
      final initialBankBal = (await db.getAllAccounts()).firstWhere((a) => a.id == bankAcc.id).currentBalance;
      await db.recordCreditCardBillPayment(
        fromAccountId: fetchedCard.defaultPayFromAccountId!,
        creditCardAccountId: fetchedCard.id,
        amount: fetchedCard.currentBalance.abs(),
        date: DateTime.now(),
        note: '${fetchedCard.name} Quick Bill Payment',
      );

      final afterPayAccounts = await db.getAllAccounts();
      final paidCard = afterPayAccounts.firstWhere((a) => a.id == cardId);
      final debitedBank = afterPayAccounts.firstWhere((a) => a.id == bankAcc.id);

      expect(paidCard.currentBalance, equals(0.0));
      expect(debitedBank.currentBalance, equals(initialBankBal - 8500.0));
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

    test('createLoanWithDisbursal inserts loan, credits bank account with net funds, and rollbacks on delete', () async {
      final accounts = await db.getAllAccounts();
      final bankAcc = accounts.firstWhere((a) => a.accountType == 'bank');
      final initialBankBalance = bankAcc.currentBalance;

      const uuid = Uuid();
      final loanId = uuid.v4();

      // Principal: 200,000, Processing fee: 1.5% (+18% GST -> 3540 fee) -> Net: 196,460
      final loanCompanion = EmiLoansCompanion.insert(
        id: loanId,
        productName: 'HDFC Personal Loan',
        principalAmount: 200000.0,
        annualInterestRate: 11.5,
        tenureMonths: 24,
        monthlyEmi: 9368.0,
        startDate: DateTime.now(),
        loanCategory: const drift.Value('personal_bank'),
        disbursedAccountId: drift.Value(bankAcc.id),
        processingFee: const drift.Value(1.5),
        isProcessingFeePercentage: const drift.Value(true),
        netDisbursedAmount: const drift.Value(196460.0),
        createdAt: DateTime.now(),
      );

      await db.createLoanWithDisbursal(
        loan: loanCompanion,
        disburseToAccount: true,
        destinationAccountId: bankAcc.id,
        netDisbursalAmount: 196460.0,
      );

      // Verify Loan created
      final loans = await db.watchLoans(status: 'active').first;
      expect(loans.any((l) => l.id == loanId), isTrue);

      // Verify Bank Account credited with net funds
      final updatedAccounts = await db.getAllAccounts();
      final updatedBank = updatedAccounts.firstWhere((a) => a.id == bankAcc.id);
      expect(updatedBank.currentBalance, equals(initialBankBalance + 196460.0));

      // Verify Disbursal Transaction created with 'Loan Disbursement' category
      final recentTx = await db.watchRecentTransactions(limit: 1).first;
      expect(recentTx.first.tag, equals('LOAN_DISBURSE:$loanId'));
      expect(recentTx.first.type, equals('income'));
      expect(recentTx.first.amount, equals(196460.0));
      final allCats = await db.getAllCategories();
      final disbursalCat = allCats.firstWhere((c) => c.name == 'Loan Disbursement');
      expect(recentTx.first.categoryId, equals(disbursalCat.id));

      // Delete loan and verify bank balance reverted
      await db.deleteLoan(loanId);
      final revertedAccounts = await db.getAllAccounts();
      final revertedBank = revertedAccounts.firstWhere((a) => a.id == bankAcc.id);
      expect(revertedBank.currentBalance, equals(initialBankBalance));
    });

    test('LoanComparisons CRUD operations work seamlessly', () async {
      const uuid = Uuid();
      final comp1 = LoanComparisonsCompanion.insert(
        id: uuid.v4(),
        groupName: const drift.Value('Test Group'),
        lenderName: 'Axis Bank Personal',
        loanCategory: const drift.Value('personal_bank'),
        principalAmount: 300000.0,
        annualInterestRate: 10.25,
        tenureMonths: 36,
        processingFee: const drift.Value(1.0),
        isProcessingFeePercentage: const drift.Value(true),
        gstRateOnFees: const drift.Value(18.0),
        createdAt: DateTime.now(),
      );

      final comp2 = LoanComparisonsCompanion.insert(
        id: uuid.v4(),
        groupName: const drift.Value('Test Group'),
        lenderName: 'Friend Interest-Free Loan',
        loanCategory: const drift.Value('friend_family'),
        principalAmount: 150000.0,
        annualInterestRate: 0.0,
        tenureMonths: 15,
        processingFee: const drift.Value(0.0),
        isProcessingFeePercentage: const drift.Value(false),
        gstRateOnFees: const drift.Value(18.0),
        createdAt: DateTime.now(),
      );

      // Upsert
      await db.upsertLoanComparison(comp1);
      await db.upsertLoanComparison(comp2);

      var list = await db.getAllLoanComparisons();
      expect(list.length, equals(2));

      // Delete single
      await db.deleteLoanComparison(comp1.id.value);
      list = await db.getAllLoanComparisons();
      expect(list.length, equals(1));
      expect(list.first.id, equals(comp2.id.value));

      // Clear all
      await db.clearLoanComparisons();
      list = await db.getAllLoanComparisons();
      expect(list.isEmpty, isTrue);
    });

    test('watchTransactionsForYear and watchAllTransactions query transactions properly', () async {
      final accounts = await db.getAllAccounts();
      final categories = await db.getAllCategories(type: 'expense');
      final acc = accounts.first;
      final cat = categories.first;
      const uuid = Uuid();

      final tx2025 = TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: cat.id,
        accountId: drift.Value(acc.id),
        amount: 500.0,
        type: 'expense',
        transactionDate: DateTime(2025, 6, 15),
        createdAt: DateTime(2025, 6, 15),
      );

      final tx2026 = TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: cat.id,
        accountId: drift.Value(acc.id),
        amount: 800.0,
        type: 'expense',
        transactionDate: DateTime(2026, 3, 20),
        createdAt: DateTime(2026, 3, 20),
      );

      await db.addTransactionWithAccountUpdate(tx2025);
      await db.addTransactionWithAccountUpdate(tx2026);

      final allTx = await db.watchAllTransactions().first;
      expect(allTx.length, greaterThanOrEqualTo(2));

      final txYear2025 = await db.watchTransactionsForYear(2025).first;
      expect(txYear2025.any((t) => t.id == tx2025.id.value), isTrue);
      expect(txYear2025.any((t) => t.id == tx2026.id.value), isFalse);

      final txYear2026 = await db.watchTransactionsForYear(2026).first;
      expect(txYear2026.any((t) => t.id == tx2026.id.value), isTrue);
      expect(txYear2026.any((t) => t.id == tx2025.id.value), isFalse);
    });

    test('Budget recreate and unspent carryover works correctly', () async {
      final categories = await db.getAllCategories(type: 'expense');
      final cat1 = categories[0];
      final cat2 = categories[1];
      final accounts = await db.getAllAccounts();
      final acc = accounts.first;
      const uuid = Uuid();

      // Set budgets for July 2026 (Month 7)
      await db.setOrUpdateBudget(
        categoryId: cat1.id,
        year: 2026,
        month: 7,
        allocatedAmount: 10000.0,
        rolloverEnabled: true,
      );
      await db.setOrUpdateBudget(
        categoryId: cat2.id,
        year: 2026,
        month: 7,
        allocatedAmount: 5000.0,
        rolloverEnabled: false,
      );

      // Spend 6000 in cat1 (leaving 4000 unspent) and 5500 in cat2 (overspent by 500)
      final tx1 = TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: cat1.id,
        accountId: drift.Value(acc.id),
        amount: 6000.0,
        type: 'expense',
        transactionDate: DateTime(2026, 7, 10),
        createdAt: DateTime(2026, 7, 10),
      );
      final tx2 = TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: cat2.id,
        accountId: drift.Value(acc.id),
        amount: 5500.0,
        type: 'expense',
        transactionDate: DateTime(2026, 7, 15),
        createdAt: DateTime(2026, 7, 15),
      );
      await db.addTransactionWithAccountUpdate(tx1);
      await db.addTransactionWithAccountUpdate(tx2);

      // Test searching for previous budgeted month when on Sept 2026 (Month 9, August has no budgets)
      final prior = await db.getLatestBudgetedMonthBefore(2026, 9);
      expect(prior, isNotNull);
      expect(prior!.year, equals(2026));
      expect(prior.month, equals(7));
      expect(prior.budgets.length, equals(2));

      // Recreate to August 2026 with carry unspent surplus
      await db.copyOrRecreateBudgets(
        fromYear: 7 == 12 ? 2025 : 2026,
        fromMonth: 7,
        toYear: 2026,
        toMonth: 8,
        carryUnspentSurplus: true,
      );

      final augBudgets = await db.watchBudgetsForMonth(2026, 8).first;
      expect(augBudgets.length, equals(2));

      final augCat1 = augBudgets.firstWhere((b) => b.categoryId == cat1.id);
      // 10000 base + 4000 unspent = 14000
      expect(augCat1.allocatedAmount, equals(14000.0));

      final augCat2 = augBudgets.firstWhere((b) => b.categoryId == cat2.id);
      // 5000 base + 0 (overspent, no surplus) = 5000
      expect(augCat2.allocatedAmount, equals(5000.0));
    });

    test('setOrUpdateBudgetsBatch inserts and updates multiple category budgets', () async {
      final categories = await db.getAllCategories(type: 'expense');
      final cat1 = categories[0];
      final cat2 = categories[1];

      await db.setOrUpdateBudgetsBatch([
        (categoryId: cat1.id, year: 2026, month: 10, allocatedAmount: 7500.0, rolloverEnabled: false),
        (categoryId: cat2.id, year: 2026, month: 10, allocatedAmount: 3200.0, rolloverEnabled: true),
      ]);

      final octBudgets = await db.watchBudgetsForMonth(2026, 10).first;
      expect(octBudgets.length, equals(2));
      expect(octBudgets.firstWhere((b) => b.categoryId == cat1.id).allocatedAmount, equals(7500.0));
      expect(octBudgets.firstWhere((b) => b.categoryId == cat2.id).allocatedAmount, equals(3200.0));
    });

    test('Financial report category breakdown and descending ranking aggregation', () async {
      final categories = await db.getAllCategories(type: 'expense');
      final catA = categories[0];
      final catB = categories[1];
      final catC = categories.length > 2 ? categories[2] : categories[0];
      final accounts = await db.getAllAccounts();
      final acc = accounts.first;
      const uuid = Uuid();

      // Insert 3 transactions for November 2026: catA = 12000, catB = 25000, catC = 5000
      await db.addTransactionWithAccountUpdate(TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: catA.id,
        accountId: drift.Value(acc.id),
        amount: 12000.0,
        type: 'expense',
        transactionDate: DateTime(2026, 11, 5),
        createdAt: DateTime(2026, 11, 5),
      ));

      await db.addTransactionWithAccountUpdate(TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: catB.id,
        accountId: drift.Value(acc.id),
        amount: 25000.0,
        type: 'expense',
        transactionDate: DateTime(2026, 11, 12),
        createdAt: DateTime(2026, 11, 12),
      ));

      await db.addTransactionWithAccountUpdate(TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: catC.id,
        accountId: drift.Value(acc.id),
        amount: 5000.0,
        type: 'expense',
        transactionDate: DateTime(2026, 11, 20),
        createdAt: DateTime(2026, 11, 20),
      ));

      final novTx = await db.watchTransactionsForMonth(2026, 11).first;
      final expenseTx = novTx.where((t) => t.type == 'expense').toList();

      final Map<String, double> categorySums = {};
      for (final tx in expenseTx) {
        categorySums[tx.categoryId] = (categorySums[tx.categoryId] ?? 0.0) + tx.amount;
      }

      final sortedEntries = categorySums.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Highest should be catB (25000), followed by catA (12000), then catC (5000)
      expect(sortedEntries.first.key, equals(catB.id));
      expect(sortedEntries.first.value, equals(25000.0));
      expect(sortedEntries[1].key, equals(catA.id));
      expect(sortedEntries[1].value, equals(12000.0));
    });
  });
}




