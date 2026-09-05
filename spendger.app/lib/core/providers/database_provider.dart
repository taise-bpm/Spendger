import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/backup_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});

// Category Streams
final categoriesStreamProvider = StreamProvider.autoDispose.family<List<Category>, String?>((ref, type) {
  final db = ref.watch(databaseProvider);
  return db.watchCategories(type: type);
});

// Accounts Stream (All accounts)
final accountsStreamProvider = StreamProvider.autoDispose<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAccounts();
});

// Active Accounts Stream (Only active in-use accounts)
final activeAccountsStreamProvider = StreamProvider.autoDispose<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAccounts(onlyActive: true);
});

// Transactions Stream
final recentTransactionsProvider = StreamProvider.autoDispose<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentTransactions(limit: 100);
});

final allTransactionsProvider = StreamProvider.autoDispose<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions();
});

final monthlyTransactionsProvider = StreamProvider.autoDispose.family<List<Transaction>, ({int year, int month})>((ref, arg) {
  final db = ref.watch(databaseProvider);
  return db.watchTransactionsForMonth(arg.year, arg.month);
});

final yearlyTransactionsProvider = StreamProvider.autoDispose.family<List<Transaction>, int>((ref, year) {
  final db = ref.watch(databaseProvider);
  return db.watchTransactionsForYear(year);
});

// Budgets Stream
final monthlyBudgetsProvider = StreamProvider.autoDispose.family<List<Budget>, ({int year, int month})>((ref, arg) {
  final db = ref.watch(databaseProvider);
  return db.watchBudgetsForMonth(arg.year, arg.month);
});

final allBudgetsProvider = StreamProvider.autoDispose<List<Budget>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBudgets();
});

final latestPriorBudgetedMonthProvider = FutureProvider.autoDispose.family<({int year, int month, List<Budget> budgets})?, ({int year, int month})>((ref, target) {
  final db = ref.watch(databaseProvider);
  ref.watch(allBudgetsProvider); // auto-refresh when budgets change
  return db.getLatestBudgetedMonthBefore(target.year, target.month);
});

// Loans Stream
final loansStreamProvider = StreamProvider.autoDispose.family<List<EmiLoan>, String?>((ref, status) {
  final db = ref.watch(databaseProvider);
  return db.watchLoans(status: status);
});

final loanPaymentsStreamProvider = StreamProvider.autoDispose.family<List<EmiPayment>, String>((ref, loanId) {
  final db = ref.watch(databaseProvider);
  return db.watchPaymentsForLoan(loanId);
});

final allLoanPaymentsStreamProvider = StreamProvider.autoDispose<List<EmiPayment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllPayments();
});

final loanComparisonsStreamProvider = StreamProvider.autoDispose<List<LoanComparison>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchLoanComparisons();
});

// Investments Stream
final investmentsStreamProvider = StreamProvider.autoDispose.family<List<Investment>, String?>((ref, type) {
  final db = ref.watch(databaseProvider);
  return db.watchInvestments(type: type);
});

final chittyInstallmentsStreamProvider = StreamProvider.autoDispose.family<List<ChittyInstallment>, String>((ref, investmentId) {
  final db = ref.watch(databaseProvider);
  return db.watchChittyInstallments(investmentId);
});

final investmentTransactionsStreamProvider = StreamProvider.autoDispose.family<List<Transaction>, String?>((ref, investmentId) {
  final db = ref.watch(databaseProvider);
  return db.watchInvestmentTransactions(investmentId: investmentId);
});

// Reminders Stream
final remindersStreamProvider = StreamProvider.autoDispose<List<Reminder>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchReminders();
});
