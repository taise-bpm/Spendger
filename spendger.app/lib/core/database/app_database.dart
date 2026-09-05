import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'tables/app_tables.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'spendger.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [
  Categories,
  Accounts,
  Transactions,
  Budgets,
  EmiLoans,
  EmiPayments,
  LoanComparisons,
  Investments,
  ChittyInstallments,
  Reminders,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaultData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(emiLoans, emiLoans.expenseCategoryId).catchError((_) {});
        await m.addColumn(emiLoans, emiLoans.defaultAccountId).catchError((_) {});
        await m.addColumn(emiLoans, emiLoans.autoLogExpense).catchError((_) {});
      }
      if (from < 3) {
        await m.addColumn(accounts, accounts.creditLimit).catchError((_) {});
      }
      if (from < 4) {
        await m.addColumn(accounts, accounts.isActive).catchError((_) {});
      }
      if (from < 5) {
        await customStatement('ALTER TABLE transactions ADD COLUMN to_account_id TEXT REFERENCES accounts (id) ON DELETE SET NULL;').catchError((_) {});
      }
      if (from < 6) {
        await m.createTable(loanComparisons).catchError((_) {});
        await m.addColumn(emiLoans, emiLoans.loanCategory).catchError((_) {});
        await m.addColumn(emiLoans, emiLoans.disbursedAccountId).catchError((_) {});
        await m.addColumn(emiLoans, emiLoans.processingFee).catchError((_) {});
        await m.addColumn(emiLoans, emiLoans.isProcessingFeePercentage).catchError((_) {});
        await m.addColumn(emiLoans, emiLoans.netDisbursedAmount).catchError((_) {});
      }
      if (from < 7) {
        await m.addColumn(accounts, accounts.defaultPayFromAccountId).catchError((_) {});
      }
    },
    beforeOpen: (details) async {
      // Self-healing migration checks: guarantee all columns & tables exist even on hot-reload/upgrade
      try {
        await customStatement('ALTER TABLE transactions ADD COLUMN to_account_id TEXT REFERENCES accounts (id) ON DELETE SET NULL;');
      } catch (_) {}
      try {
        await customStatement('ALTER TABLE accounts ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;');
      } catch (_) {}
      try {
        await customStatement('ALTER TABLE accounts ADD COLUMN credit_limit REAL;');
      } catch (_) {}
      try {
        await customStatement('ALTER TABLE accounts ADD COLUMN default_pay_from_account_id TEXT REFERENCES accounts (id) ON DELETE SET NULL;');
      } catch (_) {}
      try {
        await customStatement('ALTER TABLE emi_loans ADD COLUMN loan_category TEXT NOT NULL DEFAULT \'personal_bank\';');
      } catch (_) {}
      try {
        await customStatement('ALTER TABLE emi_loans ADD COLUMN disbursed_account_id TEXT REFERENCES accounts (id) ON DELETE SET NULL;');
      } catch (_) {}
      try {
        await customStatement('ALTER TABLE emi_loans ADD COLUMN processing_fee REAL NOT NULL DEFAULT 0.0;');
      } catch (_) {}
      try {
        await customStatement('ALTER TABLE emi_loans ADD COLUMN is_processing_fee_percentage INTEGER NOT NULL DEFAULT 0;');
      } catch (_) {}
      try {
        await customStatement('ALTER TABLE emi_loans ADD COLUMN net_disbursed_amount REAL;');
      } catch (_) {}
      try {
        await customStatement('''
          CREATE TABLE IF NOT EXISTS loan_comparisons (
            id TEXT NOT NULL PRIMARY KEY,
            group_name TEXT NOT NULL DEFAULT 'General Comparison',
            lender_name TEXT NOT NULL,
            loan_category TEXT NOT NULL DEFAULT 'personal_bank',
            principal_amount REAL NOT NULL,
            annual_interest_rate REAL NOT NULL,
            tenure_months INTEGER NOT NULL,
            processing_fee REAL NOT NULL DEFAULT 0.0,
            is_processing_fee_percentage INTEGER NOT NULL DEFAULT 0,
            gst_rate_on_fees REAL NOT NULL DEFAULT 18.0,
            is_finalized INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL
          );
        ''');
      } catch (_) {}
      try {
        final existingDisbursalCat = await (select(categories)
              ..where((c) => c.name.equals('Loan Disbursement') & c.type.equals('income')))
            .getSingleOrNull();
        if (existingDisbursalCat == null) {
          const uuid = Uuid();
          await into(categories).insert(
            CategoriesCompanion.insert(
              id: uuid.v4(),
              name: 'Loan Disbursement',
              type: 'income',
              iconCode: Icons.account_balance.codePoint,
              colorValue: 0xFFF59E0B,
            ),
          );
        }
      } catch (_) {}
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  Future<void> _seedDefaultData() async {
    const uuid = Uuid();

    // Default Categories (Income & Expense)
    final defaultCategories = [
      // Expense Categories
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Food & Dining',
        type: 'expense',
        iconCode: Icons.restaurant.codePoint,
        colorValue: 0xFFF97316, // Orange
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Groceries',
        type: 'expense',
        iconCode: Icons.shopping_cart.codePoint,
        colorValue: 0xFF10B981, // Green
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Housing & Rent',
        type: 'expense',
        iconCode: Icons.home.codePoint,
        colorValue: 0xFF6366F1, // Indigo
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Utilities & Bills',
        type: 'expense',
        iconCode: Icons.bolt.codePoint,
        colorValue: 0xFFEAB308, // Yellow
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Transportation & Fuel',
        type: 'expense',
        iconCode: Icons.directions_car.codePoint,
        colorValue: 0xFF0EA5E9, // Sky
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Entertainment & Leisure',
        type: 'expense',
        iconCode: Icons.movie.codePoint,
        colorValue: 0xFFEC4899, // Pink
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Healthcare & Medical',
        type: 'expense',
        iconCode: Icons.local_hospital.codePoint,
        colorValue: 0xFFEF4444, // Red
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Shopping & Apparel',
        type: 'expense',
        iconCode: Icons.checkroom.codePoint,
        colorValue: 0xFF8B5CF6, // Purple
      ),
      // Income Categories
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Salary & Wages',
        type: 'income',
        iconCode: Icons.work.codePoint,
        colorValue: 0xFF10B981, // Emerald
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Freelance & Business',
        type: 'income',
        iconCode: Icons.laptop_mac.codePoint,
        colorValue: 0xFF06B6D4, // Cyan
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Investments & Returns',
        type: 'income',
        iconCode: Icons.trending_up.codePoint,
        colorValue: 0xFF8B5CF6, // Purple
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Gifts & Allowance',
        type: 'income',
        iconCode: Icons.card_giftcard.codePoint,
        colorValue: 0xFFF59E0B, // Amber
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Loan Disbursement',
        type: 'income',
        iconCode: Icons.account_balance.codePoint,
        colorValue: 0xFFF59E0B, // Amber / Loan Accent
      ),
    ];

    for (final cat in defaultCategories) {
      await into(categories).insert(cat);
    }

    // Default Accounts
    final defaultAccounts = [
      AccountsCompanion.insert(
        id: uuid.v4(),
        name: 'Cash in Hand',
        accountType: 'cash',
        currentBalance: const Value(0.0),
        iconCode: Icons.payments.codePoint,
        colorValue: 0xFF10B981,
      ),
      AccountsCompanion.insert(
        id: uuid.v4(),
        name: 'Primary Bank Account',
        accountType: 'bank',
        currentBalance: const Value(0.0),
        iconCode: Icons.account_balance.codePoint,
        colorValue: 0xFF6366F1,
      ),
      AccountsCompanion.insert(
        id: uuid.v4(),
        name: 'Credit Card',
        accountType: 'card',
        currentBalance: const Value(0.0),
        iconCode: Icons.credit_card.codePoint,
        colorValue: 0xFFF43F5E,
      ),
      AccountsCompanion.insert(
        id: uuid.v4(),
        name: 'UPI / Digital Wallet',
        accountType: 'wallet',
        currentBalance: const Value(0.0),
        iconCode: Icons.qr_code_2.codePoint,
        colorValue: 0xFF0EA5E9,
      ),
    ];

    for (final acc in defaultAccounts) {
      await into(accounts).insert(acc);
    }
  }

  // Reactive Streams & Queries

  // Categories
  Stream<List<Category>> watchCategories({String? type}) {
    final query = select(categories);
    if (type != null) {
      query.where((c) => c.type.equals(type));
    }
    query.orderBy([(c) => OrderingTerm(expression: c.name)]);
    return query.watch();
  }

  Future<List<Category>> getAllCategories({String? type}) {
    final query = select(categories);
    if (type != null) {
      query.where((c) => c.type.equals(type));
    }
    return query.get();
  }

  // Accounts
  Stream<List<Account>> watchAccounts({bool? onlyActive}) {
    final query = select(accounts);
    if (onlyActive == true) {
      query.where((a) => a.isActive.equals(true));
    }
    query.orderBy([(a) => OrderingTerm(expression: a.name)]);
    return query.watch();
  }

  Future<List<Account>> getAllAccounts({bool? onlyActive}) {
    final query = select(accounts);
    if (onlyActive == true) {
      query.where((a) => a.isActive.equals(true));
    }
    query.orderBy([(a) => OrderingTerm(expression: a.name)]);
    return query.get();
  }

  Future<void> toggleAccountActive(String id, bool isActive) async {
    await (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(isActive: Value(isActive)),
    );
  }

  Future<void> upsertAccount(AccountsCompanion acc) async {
    await into(accounts).insertOnConflictUpdate(acc);
  }

  Future<void> deleteAccount(String id) async {
    // Check if transactions exist for this account
    final linkedTx = await (select(transactions)..where((t) => t.accountId.equals(id) | t.toAccountId.equals(id))).get();
    if (linkedTx.isNotEmpty) {
      // Soft-deactivate instead of hard deleting to preserve transaction integrity
      await toggleAccountActive(id, false);
    } else {
      await (delete(accounts)..where((a) => a.id.equals(id))).go();
    }
  }

  // Transactions
  Stream<List<Transaction>> watchRecentTransactions({int limit = 50}) {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)])
          ..limit(limit))
        .watch();
  }

  Stream<List<Transaction>> watchTransactionsForMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return (select(transactions)
          ..where((t) => t.transactionDate.isBiggerOrEqualValue(start) & t.transactionDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<Transaction>> watchTransactionsForYear(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    return (select(transactions)
          ..where((t) => t.transactionDate.isBiggerOrEqualValue(start) & t.transactionDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.asc)]))
        .watch();
  }

  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> addTransactionWithAccountUpdate(TransactionsCompanion tx) async {
    await transaction(() async {
      await into(transactions).insert(tx);

      final type = tx.type.value;
      final amount = tx.amount.value;

      if (type == 'transfer') {
        // Source Account (Debit)
        final sourceId = tx.accountId.value;
        if (sourceId != null) {
          final srcAcc = await (select(accounts)..where((a) => a.id.equals(sourceId))).getSingleOrNull();
          if (srcAcc != null) {
            await (update(accounts)..where((a) => a.id.equals(srcAcc.id)))
                .write(AccountsCompanion(currentBalance: Value(srcAcc.currentBalance - amount)));
          }
        }
        // Destination Account (Credit)
        String? destId = tx.toAccountId.value;
        if (destId == null) {
          final tag = tx.tag.value;
          if (tag != null && tag.startsWith('TRANSFER:')) {
            final parts = tag.split(':');
            if (parts.length >= 3) {
              destId = parts[2];
            }
          }
        }
        if (destId != null) {
          final destAcc = await (select(accounts)..where((a) => a.id.equals(destId!))).getSingleOrNull();
          if (destAcc != null) {
            await (update(accounts)..where((a) => a.id.equals(destAcc.id)))
                .write(AccountsCompanion(currentBalance: Value(destAcc.currentBalance + amount)));
          }
        }
      } else if (tx.accountId.value != null) {
        final account = await (select(accounts)..where((a) => a.id.equals(tx.accountId.value!))).getSingleOrNull();
        if (account != null) {
          double newBalance = account.currentBalance;
          if (type == 'income') {
            newBalance += amount;
          } else if (type == 'expense') {
            newBalance -= amount;
          }
          await (update(accounts)..where((a) => a.id.equals(account.id)))
              .write(AccountsCompanion(currentBalance: Value(newBalance)));
        }
      }
    });
  }

  Future<void> updateTransactionWithAccountUpdate(Transaction oldTx, TransactionsCompanion newTx) async {
    await transaction(() async {
      // 1. Revert previous transaction impact on old account
      if (oldTx.type == 'transfer') {
        if (oldTx.accountId != null) {
          final src = await (select(accounts)..where((a) => a.id.equals(oldTx.accountId!))).getSingleOrNull();
          if (src != null) {
            await (update(accounts)..where((a) => a.id.equals(src.id)))
                .write(AccountsCompanion(currentBalance: Value(src.currentBalance + oldTx.amount)));
          }
        }
        final oldDestId = oldTx.toAccountId ?? (oldTx.tag != null && oldTx.tag!.startsWith('TRANSFER:') ? oldTx.tag!.split(':')[2] : null);
        if (oldDestId != null) {
          final dest = await (select(accounts)..where((a) => a.id.equals(oldDestId))).getSingleOrNull();
          if (dest != null) {
            await (update(accounts)..where((a) => a.id.equals(dest.id)))
                .write(AccountsCompanion(currentBalance: Value(dest.currentBalance - oldTx.amount)));
          }
        }
      } else if (oldTx.accountId != null) {
        final oldAccount = await (select(accounts)..where((a) => a.id.equals(oldTx.accountId!))).getSingleOrNull();
        if (oldAccount != null) {
          double revertedBalance = oldAccount.currentBalance;
          if (oldTx.type == 'income') {
            revertedBalance -= oldTx.amount;
          } else if (oldTx.type == 'expense') {
            revertedBalance += oldTx.amount;
          }
          await (update(accounts)..where((a) => a.id.equals(oldAccount.id)))
              .write(AccountsCompanion(currentBalance: Value(revertedBalance)));
        }
      }

      // 2. Apply new transaction impact
      final newType = newTx.type.value;
      final newAmount = newTx.amount.value;

      if (newType == 'transfer') {
        final srcId = newTx.accountId.value;
        if (srcId != null) {
          final src = await (select(accounts)..where((a) => a.id.equals(srcId))).getSingleOrNull();
          if (src != null) {
            await (update(accounts)..where((a) => a.id.equals(src.id)))
                .write(AccountsCompanion(currentBalance: Value(src.currentBalance - newAmount)));
          }
        }
        final newDestId = newTx.toAccountId.value ?? (newTx.tag.value != null && newTx.tag.value!.startsWith('TRANSFER:') ? newTx.tag.value!.split(':')[2] : null);
        if (newDestId != null) {
          final dest = await (select(accounts)..where((a) => a.id.equals(newDestId))).getSingleOrNull();
          if (dest != null) {
            await (update(accounts)..where((a) => a.id.equals(dest.id)))
                .write(AccountsCompanion(currentBalance: Value(dest.currentBalance + newAmount)));
          }
        }
      } else if (newTx.accountId.value != null) {
        final currentAccount = await (select(accounts)..where((a) => a.id.equals(newTx.accountId.value!))).getSingleOrNull();
        if (currentAccount != null) {
          double updatedBalance = currentAccount.currentBalance;
          if (newType == 'income') {
            updatedBalance += newAmount;
          } else if (newType == 'expense') {
            updatedBalance -= newAmount;
          }
          await (update(accounts)..where((a) => a.id.equals(currentAccount.id)))
              .write(AccountsCompanion(currentBalance: Value(updatedBalance)));
        }
      }

      // 3. Update the transaction row
      await (update(transactions)..where((t) => t.id.equals(oldTx.id))).write(newTx);
    });
  }

  Future<void> deleteTransactionWithAccountUpdate(String id) async {
    await transaction(() async {
      final tx = await (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (tx != null) {
        if (tx.type == 'transfer') {
          if (tx.accountId != null) {
            final src = await (select(accounts)..where((a) => a.id.equals(tx.accountId!))).getSingleOrNull();
            if (src != null) {
              await (update(accounts)..where((a) => a.id.equals(src.id)))
                  .write(AccountsCompanion(currentBalance: Value(src.currentBalance + tx.amount)));
            }
          }
          final destId = tx.toAccountId ?? (tx.tag != null && tx.tag!.startsWith('TRANSFER:') ? tx.tag!.split(':')[2] : null);
          if (destId != null) {
            final dest = await (select(accounts)..where((a) => a.id.equals(destId))).getSingleOrNull();
            if (dest != null) {
              await (update(accounts)..where((a) => a.id.equals(dest.id)))
                  .write(AccountsCompanion(currentBalance: Value(dest.currentBalance - tx.amount)));
            }
          }
        } else if (tx.accountId != null) {
          final account = await (select(accounts)..where((a) => a.id.equals(tx.accountId!))).getSingleOrNull();
          if (account != null) {
            double newBalance = account.currentBalance;
            if (tx.type == 'income') {
              newBalance -= tx.amount;
            } else if (tx.type == 'expense') {
              newBalance += tx.amount;
            }
            await (update(accounts)..where((a) => a.id.equals(account.id)))
                .write(AccountsCompanion(currentBalance: Value(newBalance)));
          }
        }
        if (tx.tag != null && tx.tag!.startsWith('INV:')) {
          final parts = tx.tag!.split(':');
          if (parts.length > 1) {
            final invId = parts[1];
            final inv = await (select(investments)..where((i) => i.id.equals(invId))).getSingleOrNull();
            if (inv != null) {
              await (update(investments)..where((i) => i.id.equals(inv.id))).write(
                InvestmentsCompanion(
                  currentValuation: Value((inv.currentValuation - tx.amount).clamp(0.0, double.infinity)),
                ),
              );
            }
          }
        }
        await (delete(transactions)..where((t) => t.id.equals(id))).go();
      }
    });
  }

  Future<String> _getOrCreateTransferCategory() async {
    final existing = await (select(categories)..where((c) => c.name.equals('Transfers & Payments'))).getSingleOrNull();
    if (existing != null) return existing.id;

    final anyCat = await (select(categories)..limit(1)).getSingleOrNull();
    if (anyCat != null) return anyCat.id;

    const uuid = Uuid();
    final newId = uuid.v4();
    await into(categories).insert(
      CategoriesCompanion.insert(
        id: newId,
        name: 'Transfers & Payments',
        type: 'expense',
        iconCode: Icons.swap_horiz.codePoint,
        colorValue: 0xFF6366F1,
      ),
    );
    return newId;
  }

  /// Record Self/Intra-Transfer between user accounts
  Future<void> recordIntraTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final fromAcc = await (select(accounts)..where((a) => a.id.equals(fromAccountId))).getSingleOrNull();
    final toAcc = await (select(accounts)..where((a) => a.id.equals(toAccountId))).getSingleOrNull();
    final fromName = fromAcc?.name ?? 'Account';
    final toName = toAcc?.name ?? 'Account';

    const uuid = Uuid();
    final defaultNote = 'Self Transfer: $fromName ➔ $toName';

    final catId = await _getOrCreateTransferCategory();

    await addTransactionWithAccountUpdate(
      TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: catId,
        accountId: Value(fromAccountId),
        toAccountId: Value(toAccountId),
        amount: amount,
        type: 'transfer',
        transactionDate: date,
        notes: Value(note?.isNotEmpty == true ? note! : defaultNote),
        tag: Value('TRANSFER:$fromAccountId:$toAccountId'),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Record Credit Card Bill Payment from a Bank/Cash account to settle card dues
  Future<void> recordCreditCardBillPayment({
    required String fromAccountId,
    required String creditCardAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final fromAcc = await (select(accounts)..where((a) => a.id.equals(fromAccountId))).getSingleOrNull();
    final cardAcc = await (select(accounts)..where((a) => a.id.equals(creditCardAccountId))).getSingleOrNull();
    final fromName = fromAcc?.name ?? 'Bank Account';
    final cardName = cardAcc?.name ?? 'Credit Card';

    const uuid = Uuid();
    final defaultNote = 'Credit Card Bill Payment: $cardName (from $fromName)';

    final catId = await _getOrCreateTransferCategory();

    await addTransactionWithAccountUpdate(
      TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: catId,
        accountId: Value(fromAccountId),
        toAccountId: Value(creditCardAccountId),
        amount: amount,
        type: 'transfer',
        transactionDate: date,
        notes: Value(note?.isNotEmpty == true ? note! : defaultNote),
        tag: Value('TRANSFER:$fromAccountId:$creditCardAccountId'),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Record periodic interest payout for Fixed Deposit (posts to Income Ledger and credits Bank Account)
  Future<void> recordFdInterestPayout({
    required String investmentId,
    required String investmentName,
    required String destinationAccountId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final categories = await getAllCategories(type: 'income');
    final invCategory = categories.firstWhere(
      (c) => c.name.toLowerCase().contains('investment') || c.name.toLowerCase().contains('return'),
      orElse: () => categories.first,
    );

    const uuid = Uuid();
    final defaultNote = 'FD Interest Payout: $investmentName';

    await addTransactionWithAccountUpdate(
      TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: invCategory.id,
        accountId: Value(destinationAccountId),
        amount: amount,
        type: 'income',
        transactionDate: date,
        notes: Value(note?.isNotEmpty == true ? note! : defaultNote),
        tag: Value('INV:$investmentId:interest_payout:${uuid.v4().substring(0, 8)}'),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Close or Mature an Investment and transfer payout to Bank Account
  Future<void> closeOrMatureInvestmentWithTransfer({
    required String investmentId,
    required String investmentName,
    required String destinationAccountId,
    required double payoutAmount,
    required DateTime date,
    bool isPremature = false,
    String? note,
  }) async {
    await transaction(() async {
      // 1. Update investment status
      await (update(investments)..where((i) => i.id.equals(investmentId))).write(
        InvestmentsCompanion(
          status: Value(isPremature ? 'closed' : 'matured'),
          currentValuation: const Value(0.0),
        ),
      );

      // 2. Credit destination bank account with payout amount
      final categories = await getAllCategories(type: 'income');
      final invCategory = categories.firstWhere(
        (c) => c.name.toLowerCase().contains('investment') || c.name.toLowerCase().contains('return'),
        orElse: () => categories.first,
      );

      const uuid = Uuid();
      final defaultNote = isPremature
          ? 'Premature Closure Payout: $investmentName'
          : 'Maturity Payout: $investmentName';

      await addTransactionWithAccountUpdate(
        TransactionsCompanion.insert(
          id: uuid.v4(),
          categoryId: invCategory.id,
          accountId: Value(destinationAccountId),
          amount: payoutAmount,
          type: 'income',
          transactionDate: date,
          notes: Value(note?.isNotEmpty == true ? note! : defaultNote),
          tag: Value('INV:$investmentId:${isPremature ? "premature_closure" : "maturity_payout"}'),
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  /// Post Real Annual PPF Interest from Passbook statement
  Future<void> postPpfAnnualInterest({
    required String investmentId,
    required int financialYearStart,
    required double interestAmount,
    required double updatedClosingBalance,
    DateTime? transactionDate,
    String? notes,
  }) async {
    await transaction(() async {
      final inv = await (select(investments)..where((i) => i.id.equals(investmentId))).getSingleOrNull();
      if (inv != null) {
        // Update investment valuation
        await (update(investments)..where((i) => i.id.equals(investmentId))).write(
          InvestmentsCompanion(
            currentValuation: Value(updatedClosingBalance),
          ),
        );

        // Record statement interest entry (tagged with FY)
        final categories = await getAllCategories(type: 'income');
        final invCategory = categories.firstWhere(
          (c) => c.name.toLowerCase().contains('investment'),
          orElse: () => categories.first,
        );

        const uuid = Uuid();
        final finalDate = transactionDate ?? DateTime(financialYearStart + 1, 3, 31);
        final defaultNotes = '${inv.name} - Statement Interest Credited for FY $financialYearStart-${(financialYearStart + 1) % 100}';
        await into(transactions).insert(
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: invCategory.id,
            amount: interestAmount,
            type: 'income',
            transactionDate: finalDate,
            notes: Value(notes != null && notes.isNotEmpty ? notes : defaultNotes),
            tag: Value('INV:$investmentId:ppf_interest:fy$financialYearStart'),
            createdAt: DateTime.now(),
          ),
        );
      }
    });
  }

  // Budgets
  Stream<List<Budget>> watchBudgetsForMonth(int year, int month) {
    return (select(budgets)..where((b) => b.periodYear.equals(year) & b.periodMonth.equals(month))).watch();
  }

  Stream<List<Budget>> watchAllBudgets() {
    return (select(budgets)..orderBy([
      (b) => OrderingTerm(expression: b.periodYear, mode: OrderingMode.desc),
      (b) => OrderingTerm(expression: b.periodMonth, mode: OrderingMode.desc),
    ])).watch();
  }

  Future<({int year, int month, List<Budget> budgets})?> getLatestBudgetedMonthBefore(int year, int month) async {
    final allBudgets = await (select(budgets)
          ..where((b) => b.periodYear.isSmallerThanValue(year) |
                         (b.periodYear.equals(year) & b.periodMonth.isSmallerThanValue(month)))
          ..orderBy([
            (b) => OrderingTerm(expression: b.periodYear, mode: OrderingMode.desc),
            (b) => OrderingTerm(expression: b.periodMonth, mode: OrderingMode.desc),
          ]))
        .get();

    if (allBudgets.isEmpty) return null;

    final first = allBudgets.first;
    final latestYear = first.periodYear;
    final latestMonth = first.periodMonth;

    final latestBudgets = allBudgets
        .where((b) => b.periodYear == latestYear && b.periodMonth == latestMonth)
        .toList();

    return (year: latestYear, month: latestMonth, budgets: latestBudgets);
  }

  Future<void> copyOrRecreateBudgets({
    required int fromYear,
    required int fromMonth,
    required int toYear,
    required int toMonth,
    required bool carryUnspentSurplus,
  }) async {
    final sourceBudgets = await (select(budgets)
          ..where((b) => b.periodYear.equals(fromYear) & b.periodMonth.equals(fromMonth)))
        .get();
    if (sourceBudgets.isEmpty) return;

    final fromStart = DateTime(fromYear, fromMonth, 1);
    final fromEnd = fromMonth == 12 ? DateTime(fromYear + 1, 1, 1) : DateTime(fromYear, fromMonth + 1, 1);

    final sourceTransactions = await (select(transactions)
          ..where((t) =>
              t.transactionDate.isBiggerOrEqualValue(fromStart) &
              t.transactionDate.isSmallerThanValue(fromEnd) &
              t.type.equals('expense')))
        .get();

    for (final sb in sourceBudgets) {
      double allocated = sb.allocatedAmount;
      if (carryUnspentSurplus) {
        final spent = sourceTransactions
            .where((t) => t.categoryId == sb.categoryId)
            .fold(0.0, (sum, t) => sum + t.amount);
        final unspent = sb.allocatedAmount - spent;
        if (unspent > 0) {
          allocated += unspent;
        }
      }

      await setOrUpdateBudget(
        categoryId: sb.categoryId,
        year: toYear,
        month: toMonth,
        allocatedAmount: allocated,
        rolloverEnabled: sb.rolloverEnabled,
      );
    }
  }

  Future<void> setOrUpdateBudgetsBatch(
    List<({String categoryId, int year, int month, double allocatedAmount, bool rolloverEnabled})> items,
  ) async {
    for (final item in items) {
      await setOrUpdateBudget(
        categoryId: item.categoryId,
        year: item.year,
        month: item.month,
        allocatedAmount: item.allocatedAmount,
        rolloverEnabled: item.rolloverEnabled,
      );
    }
  }

  Future<void> setOrUpdateBudget({
    required String categoryId,
    required int year,
    required int month,
    required double allocatedAmount,
    required bool rolloverEnabled,
  }) async {
    final existing = await (select(budgets)
          ..where((b) => b.categoryId.equals(categoryId) & b.periodYear.equals(year) & b.periodMonth.equals(month)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(budgets)..where((b) => b.id.equals(existing.id))).write(
        BudgetsCompanion(
          allocatedAmount: Value(allocatedAmount),
          rolloverEnabled: Value(rolloverEnabled),
        ),
      );
    } else {
      const uuid = Uuid();
      await into(budgets).insert(
        BudgetsCompanion.insert(
          id: uuid.v4(),
          categoryId: categoryId,
          allocatedAmount: allocatedAmount,
          periodMonth: month,
          periodYear: year,
          rolloverEnabled: Value(rolloverEnabled),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> upsertCategory(CategoriesCompanion cat) async {
    await into(categories).insertOnConflictUpdate(cat);
  }

  Future<void> deleteCategory(String id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }

  // EMI Loans & Payments
  Stream<List<EmiLoan>> watchLoans({String? status}) {
    final query = select(emiLoans);
    if (status != null) {
      query.where((l) => l.status.equals(status));
    }
    query.orderBy([(l) => OrderingTerm(expression: l.createdAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  /// Create a loan with optional immediate account disbursal
  Future<void> createLoanWithDisbursal({
    required EmiLoansCompanion loan,
    required bool disburseToAccount,
    String? destinationAccountId,
    double? netDisbursalAmount,
  }) async {
    await transaction(() async {
      await into(emiLoans).insert(loan);

      if (disburseToAccount && destinationAccountId != null && netDisbursalAmount != null && netDisbursalAmount > 0) {
        final loanName = loan.productName.value;
        final lender = loan.lenderName.value ?? 'Lender';

        // Find or create 'Loan Disbursement' income category (default header)
        final incomeCategories = await getAllCategories(type: 'income');
        var disbursalCategory = incomeCategories.where((c) => c.name.toLowerCase() == 'loan disbursement').firstOrNull ??
            incomeCategories.where((c) => c.name.toLowerCase().contains('loan disburs')).firstOrNull ??
            incomeCategories.where((c) => c.name.toLowerCase().contains('loan')).firstOrNull;

        if (disbursalCategory == null) {
          const uuid = Uuid();
          final newCatId = uuid.v4();
          await into(categories).insert(
            CategoriesCompanion.insert(
              id: newCatId,
              name: 'Loan Disbursement',
              type: 'income',
              iconCode: Icons.account_balance.codePoint,
              colorValue: 0xFFF59E0B, // Amber
            ),
          );
          disbursalCategory = await (select(categories)..where((c) => c.id.equals(newCatId))).getSingle();
        }

        const uuid = Uuid();
        // Credit the bank/cash account with net disbursed funds
        await addTransactionWithAccountUpdate(
          TransactionsCompanion.insert(
            id: uuid.v4(),
            categoryId: disbursalCategory.id,
            accountId: Value(destinationAccountId),
            amount: netDisbursalAmount,
            type: 'income',
            transactionDate: loan.startDate.value,
            notes: Value('Loan Disbursal: $loanName ($lender) • Net Credited'),
            tag: Value('LOAN_DISBURSE:${loan.id.value}'),
            createdAt: DateTime.now(),
          ),
        );
      }
    });
  }

  Future<void> updateLoan(String id, EmiLoansCompanion loan) async {
    await (update(emiLoans)..where((l) => l.id.equals(id))).write(loan);
  }

  Future<void> deleteLoan(String id) async {
    await transaction(() async {
      final allTx = await (select(transactions)..where((t) => t.tag.like('EMI:$id:%') | t.tag.like('LOAN_DISBURSE:$id%'))).get();
      for (final tx in allTx) {
        await deleteTransactionWithAccountUpdate(tx.id);
      }
      await (delete(emiPayments)..where((p) => p.loanId.equals(id))).go();
      await (delete(emiLoans)..where((l) => l.id.equals(id))).go();
    });
  }

  // Loan Comparisons Streams & CRUD
  Stream<List<LoanComparison>> watchLoanComparisons() {
    return (select(loanComparisons)..orderBy([(c) => OrderingTerm(expression: c.createdAt, mode: OrderingMode.desc)])).watch();
  }

  Future<List<LoanComparison>> getAllLoanComparisons() {
    return (select(loanComparisons)..orderBy([(c) => OrderingTerm(expression: c.createdAt, mode: OrderingMode.desc)])).get();
  }

  Future<void> upsertLoanComparison(LoanComparisonsCompanion comp) async {
    await into(loanComparisons).insertOnConflictUpdate(comp);
  }

  Future<void> deleteLoanComparison(String id) async {
    await (delete(loanComparisons)..where((c) => c.id.equals(id))).go();
  }

  Future<void> clearLoanComparisons() async {
    await delete(loanComparisons).go();
  }

  Stream<List<EmiPayment>> watchPaymentsForLoan(String loanId) {
    return (select(emiPayments)
          ..where((p) => p.loanId.equals(loanId))
          ..orderBy([(p) => OrderingTerm(expression: p.installmentNumber)]))
        .watch();
  }

  Stream<List<EmiPayment>> watchAllPayments() {
    return (select(emiPayments)
          ..orderBy([(p) => OrderingTerm(expression: p.paymentDate, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<EmiPayment>> getAllPayments() {
    return (select(emiPayments)
          ..orderBy([(p) => OrderingTerm(expression: p.paymentDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<Transaction?> getTransactionForEmiPayment(String loanId, int installmentNumber) async {
    final txTag = 'EMI:$loanId:$installmentNumber';
    return (select(transactions)..where((t) => t.tag.equals(txTag))).getSingleOrNull();
  }

  Future<void> recordOrUpdateEmiPayment({
    required String loanId,
    required int installmentNumber,
    required DateTime paymentDate,
    required double principalPaid,
    required double interestPaid,
    required double gstPaid,
    required double totalAmountPaid,
    String? categoryId,
    String? accountId,
  }) async {
    await transaction(() async {
      final loan = await (select(emiLoans)..where((l) => l.id.equals(loanId))).getSingleOrNull();
      final productName = loan?.productName ?? 'Loan';
      final txTag = 'EMI:$loanId:$installmentNumber';

      final existing = await (select(emiPayments)
            ..where((p) => p.loanId.equals(loanId) & p.installmentNumber.equals(installmentNumber)))
          .getSingleOrNull();

      if (existing != null) {
        await (update(emiPayments)..where((p) => p.id.equals(existing.id))).write(
          EmiPaymentsCompanion(
            paymentDate: Value(paymentDate),
            principalPaid: Value(principalPaid),
            interestPaid: Value(interestPaid),
            gstPaid: Value(gstPaid),
            totalAmountPaid: Value(totalAmountPaid),
          ),
        );
      } else {
        const uuid = Uuid();
        await into(emiPayments).insert(
          EmiPaymentsCompanion.insert(
            id: uuid.v4(),
            loanId: loanId,
            installmentNumber: installmentNumber,
            paymentDate: paymentDate,
            principalPaid: principalPaid,
            interestPaid: interestPaid,
            gstPaid: Value(gstPaid),
            totalAmountPaid: totalAmountPaid,
          ),
        );
      }

      // Sync with Expense Ledger (Transactions table)
      if (categoryId != null && categoryId.isNotEmpty) {
        final existingTx = await (select(transactions)..where((t) => t.tag.equals(txTag))).getSingleOrNull();
        if (existingTx != null) {
          // Update existing transaction & adjust account balance
          await updateTransactionWithAccountUpdate(
            existingTx,
            TransactionsCompanion(
              id: Value(existingTx.id),
              categoryId: Value(categoryId),
              accountId: Value(accountId),
              amount: Value(totalAmountPaid),
              type: const Value('expense'),
              transactionDate: Value(paymentDate),
              notes: Value('EMI Payment for $productName (Month #$installmentNumber)'),
              tag: Value(txTag),
            ),
          );
        } else {
          // Insert new transaction & update account balance
          const uuid = Uuid();
          await addTransactionWithAccountUpdate(
            TransactionsCompanion.insert(
              id: uuid.v4(),
              categoryId: categoryId,
              accountId: Value(accountId),
              amount: totalAmountPaid,
              type: 'expense',
              transactionDate: paymentDate,
              notes: Value('EMI Payment for $productName (Month #$installmentNumber)'),
              tag: Value(txTag),
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    });
  }

  Future<void> deleteEmiPayment(String loanId, int installmentNumber) async {
    await transaction(() async {
      final txTag = 'EMI:$loanId:$installmentNumber';
      final existingTx = await (select(transactions)..where((t) => t.tag.equals(txTag))).getSingleOrNull();
      if (existingTx != null) {
        await deleteTransactionWithAccountUpdate(existingTx.id);
      }
      await (delete(emiPayments)
            ..where((p) => p.loanId.equals(loanId) & p.installmentNumber.equals(installmentNumber)))
          .go();
    });
  }

  // Investments & Chitty
  Stream<List<Investment>> watchInvestments({String? type}) {
    final query = select(investments);
    if (type != null) {
      query.where((i) => i.type.equals(type));
    }
    query.orderBy([(i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<List<Investment>> getAllInvestments({String? type}) {
    final query = select(investments);
    if (type != null) {
      query.where((i) => i.type.equals(type));
    }
    return query.get();
  }

  Future<void> updateInvestment(String id, InvestmentsCompanion companion) async {
    await (update(investments)..where((i) => i.id.equals(id))).write(companion);
  }

  Future<void> deleteInvestment(String id) async {
    await transaction(() async {
      // 1. Revert and delete all linked transactions for this investment
      final linkedTx = await (select(transactions)..where((t) => t.tag.like('INV:$id%'))).get();
      for (final tx in linkedTx) {
        await deleteTransactionWithAccountUpdate(tx.id);
      }
      // 2. Delete chitty installments if any
      await (delete(chittyInstallments)..where((c) => c.investmentId.equals(id))).go();
      // 3. Delete the investment
      await (delete(investments)..where((i) => i.id.equals(id))).go();
    });
  }

  /// Watch investment transactions from the main ledger
  Stream<List<Transaction>> watchInvestmentTransactions({String? investmentId}) {
    final query = select(transactions);
    if (investmentId != null && investmentId.isNotEmpty) {
      query.where((t) => t.tag.like('INV:$investmentId%'));
    } else {
      query.where((t) => t.tag.like('INV:%'));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]);
    return query.watch();
  }

  /// Record an investment ledger transaction (Deposit, Monthly SIP, Dividend/Interest, Maturity Payout)
  Future<void> recordInvestmentTransaction({
    required String investmentId,
    required String investmentName,
    required String investmentType,
    required String txType, // 'deposit' (expense), 'sip_debit' (expense), 'dividend' (income), 'maturity_payout' (income), 'withdrawal' (income)
    required double amount,
    required DateTime date,
    required String? accountId,
    required String categoryId,
    String? note,
  }) async {
    final isIncome = txType == 'dividend' || txType == 'maturity_payout' || txType == 'withdrawal';
    final typeStr = isIncome ? 'income' : 'expense';
    const uuid = Uuid();
    final tag = 'INV:$investmentId:$txType:${uuid.v4().substring(0, 8)}';

    final defaultNote = switch (txType) {
      'deposit' => 'Deposit/Contribution to $investmentName ($investmentType)',
      'sip_debit' => 'Monthly SIP debit for $investmentName',
      'dividend' => 'Dividend/Interest received from $investmentName',
      'maturity_payout' => 'Maturity payout received from $investmentName',
      'withdrawal' => 'Withdrawal/Redemption from $investmentName',
      _ => 'Investment transaction for $investmentName',
    };

    await addTransactionWithAccountUpdate(
      TransactionsCompanion.insert(
        id: uuid.v4(),
        categoryId: categoryId,
        accountId: Value(accountId),
        amount: amount,
        type: typeStr,
        transactionDate: date,
        notes: Value(note?.isNotEmpty == true ? note! : defaultNote),
        tag: Value(tag),
        createdAt: DateTime.now(),
      ),
    );
  }

  Stream<List<ChittyInstallment>> watchChittyInstallments(String investmentId) {
    return (select(chittyInstallments)
          ..where((c) => c.investmentId.equals(investmentId))
          ..orderBy([(c) => OrderingTerm(expression: c.installmentNumber)]))
        .watch();
  }

  // Reminders
  Stream<List<Reminder>> watchReminders() {
    return (select(reminders)
          ..where((r) => r.isActive.equals(true))
          ..orderBy([(r) => OrderingTerm(expression: r.dueDate)]))
        .watch();
  }
}
