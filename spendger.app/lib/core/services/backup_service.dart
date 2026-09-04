import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

class BackupService {
  final AppDatabase db;

  BackupService(this.db);

  /// Export transactions to CSV file and trigger share/save
  Future<String?> exportTransactionsToCsv() async {
    final transactions = await db.select(db.transactions).get();
    final categories = await db.getAllCategories();
    final accounts = await db.getAllAccounts();

    final catMap = {for (var c in categories) c.id: c.name};
    final accMap = {for (var a in accounts) a.id: a.name};

    final List<List<dynamic>> rows = [
      ['Transaction ID', 'Date', 'Type', 'Category', 'Account', 'Amount', 'Notes', 'Tag'],
    ];

    for (final tx in transactions) {
      rows.add([
        tx.id,
        DateFormat('yyyy-MM-dd HH:mm').format(tx.transactionDate),
        tx.type.toUpperCase(),
        catMap[tx.categoryId] ?? 'Unknown',
        accMap[tx.accountId] ?? 'None',
        tx.amount,
        tx.notes ?? '',
        tx.tag ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final tempDir = await getTemporaryDirectory();
    final fileName = 'spendger_transactions_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csvString);

    await Share.shareXFiles([XFile(file.path)], text: 'Spendger Transactions Export');
    return file.path;
  }

  /// Export entire SQLite database snapshot as structured JSON
  Future<String?> exportDatabaseSnapshotJson() async {
    final categories = await db.select(db.categories).get();
    final accounts = await db.select(db.accounts).get();
    final transactions = await db.select(db.transactions).get();
    final budgets = await db.select(db.budgets).get();
    final loans = await db.select(db.emiLoans).get();
    final payments = await db.select(db.emiPayments).get();
    final investments = await db.select(db.investments).get();
    final installments = await db.select(db.chittyInstallments).get();
    final reminders = await db.select(db.reminders).get();

    final Map<String, dynamic> snapshot = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories.map((c) => {
        'id': c.id,
        'name': c.name,
        'type': c.type,
        'iconCode': c.iconCode,
        'colorValue': c.colorValue,
        'isCustom': c.isCustom,
        'createdAt': c.createdAt.toIso8601String(),
      }).toList(),
      'accounts': accounts.map((a) => {
        'id': a.id,
        'name': a.name,
        'accountType': a.accountType,
        'currentBalance': a.currentBalance,
        'iconCode': a.iconCode,
        'colorValue': a.colorValue,
      }).toList(),
      'transactions': transactions.map((t) => {
        'id': t.id,
        'categoryId': t.categoryId,
        'accountId': t.accountId,
        'amount': t.amount,
        'type': t.type,
        'transactionDate': t.transactionDate.toIso8601String(),
        'notes': t.notes,
        'tag': t.tag,
        'createdAt': t.createdAt.toIso8601String(),
      }).toList(),
      'budgets': budgets.map((b) => {
        'id': b.id,
        'categoryId': b.categoryId,
        'allocatedAmount': b.allocatedAmount,
        'periodMonth': b.periodMonth,
        'periodYear': b.periodYear,
        'rolloverEnabled': b.rolloverEnabled,
        'createdAt': b.createdAt.toIso8601String(),
      }).toList(),
      'emiLoans': loans.map((l) => {
        'id': l.id,
        'productName': l.productName,
        'lenderName': l.lenderName,
        'principalAmount': l.principalAmount,
        'annualInterestRate': l.annualInterestRate,
        'tenureMonths': l.tenureMonths,
        'monthlyEmi': l.monthlyEmi,
        'startDate': l.startDate.toIso8601String(),
        'gstRateOnInterest': l.gstRateOnInterest,
        'status': l.status,
        'notes': l.notes,
        'createdAt': l.createdAt.toIso8601String(),
      }).toList(),
      'emiPayments': payments.map((p) => {
        'id': p.id,
        'loanId': p.loanId,
        'installmentNumber': p.installmentNumber,
        'paymentDate': p.paymentDate.toIso8601String(),
        'principalPaid': p.principalPaid,
        'interestPaid': p.interestPaid,
        'gstPaid': p.gstPaid,
        'totalAmountPaid': p.totalAmountPaid,
        'isPrepayment': p.isPrepayment,
        'notes': p.notes,
      }).toList(),
      'investments': investments.map((i) => {
        'id': i.id,
        'name': i.name,
        'type': i.type,
        'startDate': i.startDate.toIso8601String(),
        'maturityDate': i.maturityDate?.toIso8601String(),
        'totalCommittedAmount': i.totalCommittedAmount,
        'quantity': i.quantity,
        'purchasePrice': i.purchasePrice,
        'currentValuation': i.currentValuation,
        'status': i.status,
        'notes': i.notes,
        'createdAt': i.createdAt.toIso8601String(),
      }).toList(),
      'chittyInstallments': installments.map((c) => {
        'id': c.id,
        'investmentId': c.investmentId,
        'installmentNumber': c.installmentNumber,
        'dueDate': c.dueDate.toIso8601String(),
        'grossInstallment': c.grossInstallment,
        'dividendEarned': c.dividendEarned,
        'netAmountPaid': c.netAmountPaid,
        'paymentDate': c.paymentDate?.toIso8601String(),
        'isPaid': c.isPaid,
        'isPrizedMonth': c.isPrizedMonth,
        'prizeAmountReceived': c.prizeAmountReceived,
      }).toList(),
      'reminders': reminders.map((r) => {
        'id': r.id,
        'title': r.title,
        'reminderType': r.reminderType,
        'referenceId': r.referenceId,
        'dueDate': r.dueDate.toIso8601String(),
        'repeatFrequency': r.repeatFrequency,
        'amount': r.amount,
        'isActive': r.isActive,
        'notificationId': r.notificationId,
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(snapshot);
    final tempDir = await getTemporaryDirectory();
    final fileName = 'spendger_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)], text: 'Spendger JSON Backup');
    return file.path;
  }

  /// Restore database snapshot from JSON file
  Future<bool> restoreFromJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return false;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    if (!data.containsKey('transactions') || !data.containsKey('categories')) {
      throw Exception('Invalid Spendger backup file structure.');
    }

    // Restore categories and transactions within atomic transaction
    await db.transaction(() async {
      if (data['categories'] != null) {
        for (final item in data['categories']) {
          await db.into(db.categories).insertOnConflictUpdate(
            CategoriesCompanion.insert(
              id: item['id'],
              name: item['name'],
              type: item['type'],
              iconCode: item['iconCode'],
              colorValue: item['colorValue'],
              isCustom: Value(item['isCustom'] ?? false),
              createdAt: Value(DateTime.parse(item['createdAt'])),
            ),
          );
        }
      }

      if (data['accounts'] != null) {
        for (final item in data['accounts']) {
          await db.into(db.accounts).insertOnConflictUpdate(
            AccountsCompanion.insert(
              id: item['id'],
              name: item['name'],
              accountType: item['accountType'],
              currentBalance: Value((item['currentBalance'] as num).toDouble()),
              iconCode: item['iconCode'],
              colorValue: item['colorValue'],
            ),
          );
        }
      }

      if (data['transactions'] != null) {
        for (final item in data['transactions']) {
          await db.into(db.transactions).insertOnConflictUpdate(
            TransactionsCompanion.insert(
              id: item['id'],
              categoryId: item['categoryId'],
              accountId: Value(item['accountId']),
              amount: (item['amount'] as num).toDouble(),
              type: item['type'],
              transactionDate: DateTime.parse(item['transactionDate']),
              notes: Value(item['notes']),
              tag: Value(item['tag']),
              createdAt: DateTime.parse(item['createdAt']),
            ),
          );
        }
      }
    });

    return true;
  }
}
