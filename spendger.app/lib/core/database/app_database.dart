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
  Investments,
  ChittyInstallments,
  Reminders,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaultData();
    },
  );

  Future<void> _seedDefaultData() async {
    const uuid = Uuid();
    final now = DateTime.now();

    // Default Categories (Income & Expense)
    final defaultCategories = [
      // Expense Categories
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Food & Dining',
        type: 'expense',
        iconCode: Icons.restaurant.codePoint,
        colorValue: 0xFFF97316, // Orange
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Groceries',
        type: 'expense',
        iconCode: Icons.shopping_cart.codePoint,
        colorValue: 0xFF10B981, // Green
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Housing & Rent',
        type: 'expense',
        iconCode: Icons.home.codePoint,
        colorValue: 0xFF6366F1, // Indigo
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Utilities & Bills',
        type: 'expense',
        iconCode: Icons.bolt.codePoint,
        colorValue: 0xFFEAB308, // Yellow
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Transportation & Fuel',
        type: 'expense',
        iconCode: Icons.directions_car.codePoint,
        colorValue: 0xFF0EA5E9, // Sky
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Entertainment & Leisure',
        type: 'expense',
        iconCode: Icons.movie.codePoint,
        colorValue: 0xFFEC4899, // Pink
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Healthcare & Medical',
        type: 'expense',
        iconCode: Icons.local_hospital.codePoint,
        colorValue: 0xFFEF4444, // Red
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Shopping & Apparel',
        type: 'expense',
        iconCode: Icons.checkroom.codePoint,
        colorValue: 0xFF8B5CF6, // Purple
        createdAt: now,
      ),
      // Income Categories
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Salary & Wages',
        type: 'income',
        iconCode: Icons.work.codePoint,
        colorValue: 0xFF10B981, // Emerald
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Freelance & Business',
        type: 'income',
        iconCode: Icons.laptop_mac.codePoint,
        colorValue: 0xFF06B6D4, // Cyan
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Investments & Returns',
        type: 'income',
        iconCode: Icons.trending_up.codePoint,
        colorValue: 0xFF8B5CF6, // Purple
        createdAt: now,
      ),
      CategoriesCompanion.insert(
        id: uuid.v4(),
        name: 'Gifts & Allowance',
        type: 'income',
        iconCode: Icons.card_giftcard.codePoint,
        colorValue: 0xFFF59E0B, // Amber
        createdAt: now,
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
  Stream<List<Account>> watchAccounts() {
    return (select(accounts)..orderBy([(a) => OrderingTerm(expression: a.name)])).watch();
  }

  Future<List<Account>> getAllAccounts() {
    return select(accounts).get();
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

  Future<void> addTransactionWithAccountUpdate(TransactionsCompanion tx) async {
    await transaction(() async {
      await into(transactions).insert(tx);

      if (tx.accountId.value != null) {
        final account = await (select(accounts)..where((a) => a.id.equals(tx.accountId.value!))).getSingleOrNull();
        if (account != null) {
          double newBalance = account.currentBalance;
          if (tx.type.value == 'income') {
            newBalance += tx.amount.value;
          } else if (tx.type.value == 'expense') {
            newBalance -= tx.amount.value;
          }
          await (update(accounts)..where((a) => a.id.equals(account.id)))
              .write(AccountsCompanion(currentBalance: Value(newBalance)));
        }
      }
    });
  }

  Future<void> deleteTransactionWithAccountUpdate(String id) async {
    await transaction(() async {
      final tx = await (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (tx != null) {
        if (tx.accountId != null) {
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
        await (delete(transactions)..where((t) => t.id.equals(id))).go();
      }
    });
  }

  // Budgets
  Stream<List<Budget>> watchBudgetsForMonth(int year, int month) {
    return (select(budgets)..where((b) => b.periodYear.equals(year) & b.periodMonth.equals(month))).watch();
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

  Stream<List<EmiPayment>> watchPaymentsForLoan(String loanId) {
    return (select(emiPayments)
          ..where((p) => p.loanId.equals(loanId))
          ..orderBy([(p) => OrderingTerm(expression: p.installmentNumber)]))
        .watch();
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
