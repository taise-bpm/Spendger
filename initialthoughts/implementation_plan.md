# Implementation Plan: Spendger — Offline-First Personal Finance Manager

Spendger is a premium, offline-first personal finance application for Android and iOS built with Flutter 3.x and Drift (SQLite). All financial data is persisted locally with zero external network dependencies, featuring specialized engines for EMI Amortization with Early Payoff Simulation, Chit Fund (Chitty) Dividend tracking, Multi-Asset Gold & SIP Portfolios, Proactive Budgeting, and Local Biometric/PIN security.

## User Review Required

> [!IMPORTANT]
> The Flutter project will be initialized inside `d:/Projects/spendger/spendger.app` with the package name `spendger`.
> The app is strictly local-first with zero internet permissions, guaranteeing 100% data privacy.

---

## Proposed Changes

### Project Foundation & Infrastructure

#### [NEW] `pubspec.yaml`
- Configure modern dependencies: `flutter_riverpod`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `fl_chart`, `material_symbols_icons`, `google_fonts`, `flutter_animate`, `intl`, `local_auth`, `csv`, `file_picker`, `share_plus`, `uuid`.
- Configure dev dependencies: `drift_dev`, `build_runner`, `flutter_test`, `flutter_lints`.

#### [NEW] `lib/app/theme/`
- `app_colors.dart`: Define curated dark & light palette (Emerald Green for Income, Rose Red for Expense, Amber Gold for Loans, Indigo Purple for Investments).
- `app_theme.dart`: Material 3 ThemeData with deep OLED dark mode and clean light mode.
- `typography.dart`: Google Fonts `Plus Jakarta Sans` / `Inter` typography hierarchy.

---

### Core & Database Layer (Drift SQLite)

#### [NEW] `lib/core/database/tables/`
- `categories.dart`: `Categories` table (id, name, type, icon_code, color_value, is_custom, created_at).
- `accounts.dart`: `Accounts` table (id, name, account_type, current_balance, icon_code, color_value).
- `transactions.dart`: `Transactions` table (id, category_id, account_id, amount, type, transaction_date, notes, tag, created_at) with indexed date.
- `budgets.dart`: `Budgets` table (id, category_id, allocated_amount, period_month, period_year, rollover_enabled, created_at).
- `emi_loans.dart`: `EmiLoans` table (id, product_name, lender_name, principal_amount, annual_interest_rate, tenure_months, monthly_emi, start_date, gst_rate_on_interest, status, notes, created_at).
- `emi_payments.dart`: `EmiPayments` table (id, loan_id, installment_number, payment_date, principal_paid, interest_paid, gst_paid, total_amount_paid, is_prepayment, notes).
- `investments.dart`: `Investments` table (id, name, type, start_date, maturity_date, total_committed_amount, quantity, purchase_price, current_valuation, status, notes, created_at).
- `chitty_installments.dart`: `ChittyInstallments` table (id, investment_id, installment_number, due_date, gross_installment, dividend_earned, net_amount_paid, payment_date, is_paid, is_prized_month, prize_amount_received).
- `reminders.dart`: `Reminders` table (id, title, reminder_type, reference_id, due_date, repeat_frequency, amount, is_active, notification_id).

#### [NEW] `lib/core/database/app_database.dart`
- Drift SQLite Database class with schema migrations and pre-seeding of standard categories & initial accounts on database creation.

---

### Domain & Financial Calculation Engines

#### [NEW] `lib/core/utils/financial_math.dart`
- Standard Reducing Balance EMI calculation: $EMI = \frac{P \cdot r \cdot (1+r)^n}{(1+r)^n - 1}$.
- Full month-by-month Amortization Schedule generation with principal/interest split and optional GST on interest.
- **Early Closure & Prepayment Simulator**: Calculate total interest savings and tenure reduction for one-time lump-sum or recurring prepayments.
- **Chit Fund (Chitty) Engine**: Net installment calculation ($Net = Gross - Dividend$), dividend yield, prize money gain/loss.
- **Gold & Asset Valuation Engine**: Purity weight adjustments, current valuation, unrealized profit/loss, ROI.

#### [NEW] `lib/core/services/`
- `backup_service.dart`: Offline JSON database export/import and CSV transaction exporter.
- `biometric_service.dart`: Local biometric & device PIN authentication via `local_auth`.
- `currency_service.dart`: Multi-currency and regional formatting (e.g. ₹ Lakhs/Crores, $ Millions, €).

---

### Features & UI Presentation Layer

#### [NEW] `lib/features/dashboard/`
- **DashboardScreen**: Net worth summary card, monthly cash flow breakdown (Income vs. Expense bar chart), interactive active budget utilization meters, and upcoming dues carousel.

#### [NEW] `lib/features/transactions/`
- **TransactionsScreen**: Date-grouped transaction stream, category/account filters, search bar.
- **QuickAddTransactionSheet**: Bottom sheet with integrated fast numeric keypad, category badges, and payment mode selector.

#### [NEW] `lib/features/budgets/`
- **BudgetsScreen**: Monthly budget overview with visual gauge meters (Safe <75%, Warning 75-99%, Overbudget ≥100%) and budget creation/edit dialogs.

#### [NEW] `lib/features/emi_loans/`
- **EmiLoansScreen**: Active and closed loan cards with payoff progress rings.
- **LoanDetailsScreen**: Full amortization schedule with "Mark Installment Paid".
- **EarlyPayoffSimulatorScreen**: Interactive slider & lump sum input to test prepayment scenarios and view interest saved.

#### [NEW] `lib/features/investments/`
- **InvestmentsScreen**: Multi-asset segmented view:
  - **Chitty Tab**: Scheme details, monthly dividend logger, prized month recorder.
  - **Gold Tab**: Purity (22K/24K), weight in grams, cost vs. current value, PnL.
  - **SIP / Deposits Tab**: Recurring SIP & FD maturity tracker.

#### [NEW] `lib/features/reminders/`
- **RemindersScreen**: Scheduled payment dues list, toggle active state, snooze/mark paid.

#### [NEW] `lib/features/settings/`
- **SettingsScreen**: Biometric lock toggle, Category management, Currency symbol preference, JSON/CSV Backup & Restore triggers.

---

## Verification Plan

### Automated Tests
1. **Financial Mathematics Unit Tests**:
   - `test/unit/emi_calculator_test.dart`: Validate EMI formula, amortization schedule totals, and early prepayment interest savings against known mathematical benchmarks.
   - `test/unit/chitty_math_test.dart`: Validate net payment and dividend distribution formulas.
   - `test/unit/budget_calculator_test.dart`: Validate utilization percentages, warning thresholds, and variance calculations.
2. **Database Integration Tests**:
   - `test/database/app_database_test.dart`: Verify Drift in-memory database CRUD, cascade deletes, and reactive DAO streams.
3. **Static Analysis**:
   - Run `flutter analyze` in `spendger.app` to verify 0 errors, 0 warnings, and 100% sound null safety.

### Manual Verification
- Launch the application and test:
  1. Adding income/expense transactions and seeing dashboard balances update reactively.
  2. Setting up a monthly budget and viewing progress indicators change colors as spending increases.
  3. Creating an EMI loan, opening the Early Closure Simulator, adjusting the prepayment slider, and observing interest savings.
  4. Adding a Chit Fund (Chitty) entry, recording a monthly dividend, and checking net payable calculation.
  5. Adding gold holding and adjusting current market price to test real-time PnL.
  6. Exporting and importing a JSON database snapshot.
