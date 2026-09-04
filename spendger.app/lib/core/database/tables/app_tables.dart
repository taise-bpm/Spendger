import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'income', 'expense'
  IntColumn get iconCode => integer()();
  IntColumn get colorValue => integer()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // 'Cash', 'Bank Account', 'Credit Card', 'UPI'
  TextColumn get accountType => text()();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  RealColumn get creditLimit => real().nullable()(); // Credit card spending limit
  TextColumn get defaultPayFromAccountId => text().nullable().references(Accounts, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get iconCode => integer()();
  IntColumn get colorValue => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get accountId => text().nullable().references(Accounts, #id, onDelete: KeyAction.setNull)();
  TextColumn get toAccountId => text().nullable().references(Accounts, #id, onDelete: KeyAction.setNull)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'income', 'expense', 'transfer'
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get tag => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id, onDelete: KeyAction.cascade)();
  RealColumn get allocatedAmount => real()();
  IntColumn get periodMonth => integer()(); // 1-12
  IntColumn get periodYear => integer()();
  BoolColumn get rolloverEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class EmiLoans extends Table {
  TextColumn get id => text()();
  TextColumn get productName => text()();
  TextColumn get lenderName => text().nullable()();
  TextColumn get loanCategory => text().withDefault(const Constant('personal_bank'))(); // 'personal_bank', 'asset_vehicle', 'friend_family', 'other'
  RealColumn get principalAmount => real()();
  RealColumn get annualInterestRate => real()();
  IntColumn get tenureMonths => integer()();
  RealColumn get monthlyEmi => real()();
  DateTimeColumn get startDate => dateTime()();
  RealColumn get gstRateOnInterest => real().withDefault(const Constant(0.0))();
  TextColumn get expenseCategoryId => text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get defaultAccountId => text().nullable().references(Accounts, #id, onDelete: KeyAction.setNull)();
  TextColumn get disbursedAccountId => text().nullable().references(Accounts, #id, onDelete: KeyAction.setNull)();
  RealColumn get processingFee => real().withDefault(const Constant(0.0))();
  BoolColumn get isProcessingFeePercentage => boolean().withDefault(const Constant(false))();
  RealColumn get netDisbursedAmount => real().nullable()();
  BoolColumn get autoLogExpense => boolean().withDefault(const Constant(true))();
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'closed', 'foreclosed'
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class EmiPayments extends Table {
  TextColumn get id => text()();
  TextColumn get loanId => text().references(EmiLoans, #id, onDelete: KeyAction.cascade)();
  IntColumn get installmentNumber => integer()();
  DateTimeColumn get paymentDate => dateTime()();
  RealColumn get principalPaid => real()();
  RealColumn get interestPaid => real()();
  RealColumn get gstPaid => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmountPaid => real()();
  BoolColumn get isPrepayment => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LoanComparisons extends Table {
  TextColumn get id => text()();
  TextColumn get groupName => text().withDefault(const Constant('General Comparison'))();
  TextColumn get lenderName => text()();
  TextColumn get loanCategory => text().withDefault(const Constant('personal_bank'))();
  RealColumn get principalAmount => real()();
  RealColumn get annualInterestRate => real()();
  IntColumn get tenureMonths => integer()();
  RealColumn get processingFee => real().withDefault(const Constant(0.0))();
  BoolColumn get isProcessingFeePercentage => boolean().withDefault(const Constant(false))();
  RealColumn get gstRateOnFees => real().withDefault(const Constant(18.0))();
  BoolColumn get isFinalized => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Investments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'chitty', 'gold', 'sip', 'fd'
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get maturityDate => dateTime().nullable()();
  RealColumn get totalCommittedAmount => real().nullable()();
  RealColumn get quantity => real().nullable()(); // Gold grams, MF units
  RealColumn get purchasePrice => real().nullable()();
  RealColumn get currentValuation => real()();
  TextColumn get status => text().withDefault(const Constant('active'))(); // 'active', 'matured', 'sold'
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChittyInstallments extends Table {
  TextColumn get id => text()();
  TextColumn get investmentId => text().references(Investments, #id, onDelete: KeyAction.cascade)();
  IntColumn get installmentNumber => integer()();
  DateTimeColumn get dueDate => dateTime()();
  RealColumn get grossInstallment => real()();
  RealColumn get dividendEarned => real().withDefault(const Constant(0.0))();
  RealColumn get netAmountPaid => real()();
  DateTimeColumn get paymentDate => dateTime().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  BoolColumn get isPrizedMonth => boolean().withDefault(const Constant(false))();
  RealColumn get prizeAmountReceived => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get reminderType => text()(); // 'emi', 'sip', 'chitty', 'custom'
  TextColumn get referenceId => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get repeatFrequency => text().withDefault(const Constant('none'))(); // 'none', 'monthly', 'weekly', 'yearly'
  RealColumn get amount => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get notificationId => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
