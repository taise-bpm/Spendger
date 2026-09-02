# Antigravity Prompt: Spendger — Offline-First Personal Finance Manager (Flutter + Drift SQLite)

---

## 📌 Executive Summary & Objective

**Spendger** is a premium, offline-first personal finance management application for Android and iOS built with **Flutter 3.x** and **Dart**. The app is strictly local-first with zero external API dependencies or cloud tracking, ensuring 100% data privacy.

The application goes beyond basic expense logging by offering specialized modules for:
1. **Categorized Income & Expense Tracking** with hierarchical headers and payment modes.
2. **Proactive Budgeting** with real-time utilization progress and overspend warnings.
3. **Advanced EMI & Loan Amortization Engine** featuring interest/principal splits, optional GST on interest, and an interactive **Early Closure Simulator**.
4. **Specialized Multi-Asset Investment Tracker** with first-class support for **Chit Funds (Chitty)**, **Physical/Digital Gold**, **SIPs/Mutual Funds**, and **Fixed Deposits**.
5. **Local Recurring Notification & Reminder Engine** for due dates, dividends, and SIPs.
6. **Data Privacy, Local Backup & Security** featuring Biometric App Lock and offline JSON/CSV backup & restore.

---

## 🎯 Target User & Core Use Cases

- **Privacy-Conscious Individuals**: Users seeking full control over their financial records without bank scraping or cloud leaks.
- **Borrowers & Loan Payers**: Users managing multiple home/auto/personal loans who want clarity on principal vs. interest splits, GST impacts, and savings from prepayments.
- **Traditional & Modern Investors**: Users participating in Chit Funds (Chitty) with variable monthly dividends, physical/digital gold accumulators, and recurring SIP investors.
- **Disciplined Budgeters**: Users managing strict monthly category budgets with immediate visual feedback.

---

## 🏗️ Technical Stack & Architecture Blueprint

### 1. Technology Stack
- **Framework**: Flutter 3.24+ (Dart 3.5+) with sound null safety.
- **Database Engine**: SQLite powered by **Drift** (`drift` + `sqlite3_flutter_libs` + `path_provider`) for reactive, type-safe persistence and migration safety.
- **State Management**: **Riverpod 2.x** (`flutter_riverpod` / `riverpod_annotation` with code generation).
- **Notifications**: `flutter_local_notifications` with timezone support (`timezone`).
- **Data Visualization & Charts**: `fl_chart` for interactive financial charts and amortization curves.
- **Security & Utilities**: `local_auth` (Biometrics/PIN), `intl` (Currency/Date formatting), `file_picker` & `share_plus` (CSV/JSON export & import).
- **UI & Design System**: Material 3, dynamic Light & Deep OLED Dark themes, Google Fonts (`Inter` or `Plus Jakarta Sans`), glassmorphic accent cards.

### 2. Architecture: Clean Architecture + Feature-First
```
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       └── typography.dart
├── core/
│   ├── constants/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── daos/
│   │   └── tables/
│   ├── errors/
│   ├── services/
│   │   ├── backup_service.dart
│   │   ├── biometric_service.dart
│   │   └── notification_service.dart
│   └── utils/
│       ├── currency_formatter.dart
│       ├── date_utils.dart
│       └── financial_math.dart
└── features/
    ├── dashboard/
    ├── transactions/
    ├── budgets/
    ├── emi_loans/
    ├── investments/
    │   ├── chitty/
    │   ├── gold/
    │   └── sips/
    ├── reminders/
    └── settings/
```
Each feature directory contains:
- `data/` (Data sources, repositories implementation, mappers)
- `domain/` (Entities, value objects, use cases/calculators)
- `presentation/` (Riverpod providers/controllers, screens, widgets)

---

## 📊 Relational Database Schema (Drift SQLite)

```sql
-- 1. Categories & Headers
CREATE TABLE categories (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- 'income' | 'expense'
    icon_code INTEGER NOT NULL,
    color_value INTEGER NOT NULL,
    is_custom INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL
);

-- 2. Accounts / Payment Modes
CREATE TABLE accounts (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL, -- 'Cash', 'Bank Account', 'Credit Card', 'UPI'
    account_type TEXT NOT NULL,
    current_balance REAL NOT NULL DEFAULT 0.0,
    icon_code INTEGER NOT NULL,
    color_value INTEGER NOT NULL
);

-- 3. Financial Transactions
CREATE TABLE transactions (
    id TEXT PRIMARY KEY NOT NULL,
    category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    account_id TEXT REFERENCES accounts(id) ON DELETE SET NULL,
    amount REAL NOT NULL,
    type TEXT NOT NULL, -- 'income' | 'expense' | 'transfer'
    transaction_date INTEGER NOT NULL,
    notes TEXT,
    tag TEXT,
    created_at INTEGER NOT NULL
);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);

-- 4. Category Budgets
CREATE TABLE budgets (
    id TEXT PRIMARY KEY NOT NULL,
    category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    allocated_amount REAL NOT NULL,
    period_month INTEGER NOT NULL, -- 1-12
    period_year INTEGER NOT NULL,
    rollover_enabled INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    UNIQUE(category_id, period_month, period_year)
);

-- 5. EMI Loans
CREATE TABLE emi_loans (
    id TEXT PRIMARY KEY NOT NULL,
    product_name TEXT NOT NULL,
    lender_name TEXT,
    principal_amount REAL NOT NULL,
    annual_interest_rate REAL NOT NULL,
    tenure_months INTEGER NOT NULL,
    monthly_emi REAL NOT NULL,
    start_date INTEGER NOT NULL,
    gst_rate_on_interest REAL NOT NULL DEFAULT 0.0, -- e.g. 18.0%
    status TEXT NOT NULL DEFAULT 'active', -- 'active' | 'closed' | 'foreclosed'
    notes TEXT,
    created_at INTEGER NOT NULL
);

-- 6. EMI Payment Ledger
CREATE TABLE emi_payments (
    id TEXT PRIMARY KEY NOT NULL,
    loan_id TEXT NOT NULL REFERENCES emi_loans(id) ON DELETE CASCADE,
    installment_number INTEGER NOT NULL,
    payment_date INTEGER NOT NULL,
    principal_paid REAL NOT NULL,
    interest_paid REAL NOT NULL,
    gst_paid REAL NOT NULL DEFAULT 0.0,
    total_amount_paid REAL NOT NULL,
    is_prepayment INTEGER NOT NULL DEFAULT 0,
    notes TEXT
);

-- 7. Investments (Chitty, Gold, Mutual Funds/SIP, FD)
CREATE TABLE investments (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- 'chitty' | 'gold' | 'sip' | 'fd'
    start_date INTEGER NOT NULL,
    maturity_date INTEGER,
    total_committed_amount REAL, -- For Chitty / FD
    quantity REAL, -- E.g. Gold grams, MF units
    purchase_price REAL, -- Buy rate per unit or principal
    current_valuation REAL NOT NULL,
    status TEXT NOT NULL DEFAULT 'active', -- 'active' | 'matured' | 'sold'
    notes TEXT,
    created_at INTEGER NOT NULL
);

-- 8. Chit Fund (Chitty) Monthly Records
CREATE TABLE chitty_installments (
    id TEXT PRIMARY KEY NOT NULL,
    investment_id TEXT NOT NULL REFERENCES investments(id) ON DELETE CASCADE,
    installment_number INTEGER NOT NULL,
    due_date INTEGER NOT NULL,
    gross_installment REAL NOT NULL,
    dividend_earned REAL NOT NULL DEFAULT 0.0,
    net_amount_paid REAL NOT NULL,
    payment_date INTEGER,
    is_paid INTEGER NOT NULL DEFAULT 0,
    is_prized_month INTEGER NOT NULL DEFAULT 0,
    prize_amount_received REAL DEFAULT 0.0
);

-- 9. Reminders & Scheduled Alerts
CREATE TABLE reminders (
    id TEXT PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    reminder_type TEXT NOT NULL, -- 'emi' | 'sip' | 'chitty' | 'custom'
    reference_id TEXT, -- ID of related loan or investment
    due_date INTEGER NOT NULL,
    repeat_frequency TEXT NOT NULL, -- 'none' | 'monthly' | 'weekly' | 'yearly'
    amount REAL,
    is_active INTEGER NOT NULL DEFAULT 1,
    notification_id INTEGER NOT NULL
);
```

---

## 💡 Detailed Feature Specifications

### 1. Income & Expense Manager
- **CRUD Operations**: Add, edit, delete, and duplicate transactions with fast keypad input.
- **Hierarchical Taxonomy**: Pre-seeded with standard categories (Food, Housing, Utilities, Transportation, Entertainment, Health, Salary, Freelance, Investment Return) with customizable icons and color pickers.
- **Multi-Account/Wallet Support**: Track cash in hand, multiple bank accounts, and credit cards.
- **Filter & Search Engine**: Full-text search across notes/categories, filtered by date range, payment mode, and amount range.

### 2. Budgeting Engine
- **Monthly Category Budgets**: Assign target caps to specific expense categories.
- **Smart Progress Indicators**:
  - 🟢 **Safe Zone (< 75%)**: Smooth emerald progress ring.
  - 🟡 **Warning Zone (75% - 99%)**: Amber highlight indicating near exhaustion.
  - 🔴 **Overbudget (≥ 100%)**: Crimson indicator displaying exact overspent amount.
- **Historical Analysis**: View previous months' budget performance with variance analysis.

### 3. EMI & Loan Amortization Engine
- **Accurate Amortization Calculation**:
  - Standard Reducing Balance Formula:
    $$EMI = \frac{P \cdot r \cdot (1+r)^n}{(1+r)^n - 1}$$
    *(where $P$ is principal, $r$ is monthly interest rate, and $n$ is tenure in months).*
- **GST on Interest Split**: Automatically split every monthly installment into Principal Portion, Interest Portion, and GST on Interest (configurable percentage, e.g., 18%).
- **Interactive Early Closure / Prepayment Simulator**:
  - Interactive slider/input for one-time lump-sum prepayment or recurring extra payments.
  - Compares baseline vs. revised repayment schedule.
  - Real-time display of:
    - **Total Interest Saved** ($\Delta \text{Interest}$).
    - **Tenure Reduction** (Number of months saved).
    - **Revised Debt-Free Date**.
- **Payment History Ledger**: Mark installments as paid; supports custom prepayment adjustments.

### 4. Multi-Asset Investment Tracker
- **Chit Fund (Chitty) Module**:
  - Setup Chitty details: Total Chit Value, Total Months (e.g., 40 or 50 months), Monthly Gross Installment, Foreman Commission.
  - Track monthly **Auction Dividends**: Calculates Net Payable = Gross Installment − Dividend.
  - Prize Money Tracker: Record auction bid month, net prize money received, security deposit deductions, and cumulative net gain/loss.
- **Gold & Precious Metals**:
  - Track physical gold (jewelry/coins) or digital gold.
  - Fields: Purity (24K / 22K / 18K), Weight in Grams / Sovereigns (Pavan), Purchase Rate per Gram, Total Purchase Cost.
  - Manual spot price updater with unrealized Profit/Loss and ROI percentage.
- **SIP & Mutual Funds / Fixed Deposits**:
  - SIP installment tracker with recurring execution dates.
  - Fixed Deposit (FD) / Recurring Deposit (RD) maturity calculator with cumulative interest.

### 5. Smart Local Reminders & Notifications
- Uses `flutter_local_notifications` with local device alarms (no push server needed).
- **Triggers**:
  - EMI Payment Due (configurable: on due date, 1 day prior, 3 days prior).
  - Chit Fund Monthly Auction & Payment Due.
  - Mutual Fund SIP execution dates.
- **Interactive Actions**: Direct "Mark as Paid" and "Snooze (1 Day)" buttons directly from the notification shade.
- **Reboot Resilience**: Automatically reschedule pending notifications on device reboot via `RECEIVE_BOOT_COMPLETED`.

### 6. Local Backup, Export & Security
- **Biometric App Lock**: Fingerprint / Face ID / PIN protection using `local_auth` with customizable timeout (Immediate, 1 min, 5 mins).
- **Data Export**:
  - Export full transaction history to **CSV** (compatible with Excel / Google Sheets).
  - Export complete encrypted / raw database snapshot as **JSON Backup**.
- **Data Restore**: One-click restore from local JSON backup with data validation.

---

## 🎨 UX / UI Design System Requirements

- **Theme & Palette**:
  - **Dark Mode**: OLED Deep Black (`#0F172A` / `#000000`) with Slate Card surfaces (`#1E293B`) and vibrant neon accents.
  - **Light Mode**: Crisp Snow White (`#F8FAFC`) with Soft Neutral Cards (`#FFFFFF`) and high-contrast typography.
  - **Functional Accents**:
    - Income: `Emerald Green` (`#10B981`)
    - Expense: `Rose Red` (`#F43F5E`)
    - EMI / Loans: `Amber Gold` (`#F59E0B`)
    - Investments / Chitty: `Indigo Purple` (`#6366F1`)
- **Key Screens**:
  1. **Dashboard (Home)**:
     - Net Worth & Total Balance Card.
     - Monthly Income vs. Expense bar / pie chart.
     - Urgent carousel: Next 3 upcoming EMI / Chitty / SIP dues.
     - Active Budget Utilization meters.
  2. **Transactions Hub**:
     - Date-grouped transaction stream.
     - Fast Quick-Add bottom sheet with built-in calculator keypad.
  3. **EMI Studio & Simulator**:
     - Active loan cards with progress towards debt-free state.
     - Interactive Early Payoff Simulator with real-time interest savings cards.
     - Full Amortization Schedule table view.
  4. **Investment Vault**:
     - Tabbed view: Chitty Ledger, Gold Vault, SIP & Deposits.
     - Dividend breakdown table for Chit funds.
  5. **Reports & Analytics**:
     - Income vs. Expense monthly trends.
     - Category breakdown pie chart with touch tooltips.
  6. **Settings & Vault**:
     - Biometric toggle, Category Manager, Notification Preferences, JSON/CSV Backup & Restore.

---

## 📦 Dependencies Configuration (`pubspec.yaml`)

```yaml
name: spendger
description: "Offline-First Personal Finance Manager"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.5.0 <4.0.0"
  flutter: ">=3.24.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management & Dependency Injection
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Local Persistence (Drift SQLite)
  drift: ^2.20.1
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.4
  path: ^1.9.0

  # UI, Icons, Fonts & Charts
  material_symbols_icons: ^4.2750.0
  google_fonts: ^6.2.1
  fl_chart: ^0.68.0
  flutter_animate: ^4.5.0
  intl: ^0.19.0
  gap: ^3.0.1

  # Local Notifications & Schedule
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4

  # Security & Device Utilities
  local_auth: ^2.2.0
  file_picker: ^8.1.2
  share_plus: ^10.0.2
  csv: ^6.0.0
  uuid: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.12
  riverpod_generator: ^2.4.2
  drift_dev: ^2.20.1
```

---

## 🛠️ Step-by-Step Implementation Strategy

### Phase 1: Project Skeleton & Database Architecture
1. Initialize Flutter project with clean architecture folder structure.
2. Define Drift tables (`categories`, `accounts`, `transactions`, `budgets`, `emi_loans`, `emi_payments`, `investments`, `chitty_installments`, `reminders`).
3. Implement DAOs with reactive streams (`watchAllTransactions()`, `watchMonthlyBudgets()`, `watchActiveLoans()`).
4. Pre-seed default categories and accounts on database creation.

### Phase 2: Core Financial Engine & Utilities
1. Implement financial math utilities:
   - EMI calculation with Reducing Balance formula.
   - Amortization schedule generator with principal, interest, and GST splits.
   - Prepayment simulation logic (tenure reduction vs. EMI reduction).
   - Chit Fund dividend & net payment calculations.
2. Implement currency & date formatters supporting international and regional formats (e.g., INR ₹ with Lakhs/Crores, USD $ with Millions).

### Phase 3: Presentation & Transaction Engine
1. Setup Design Tokens (ThemeData, Colors, Typography, Card styles).
2. Build Dashboard screen with summary cards and monthly trend charts.
3. Build Transaction Entry Flow:
   - Quick Add Modal with integrated numeric keypad.
   - Category and Account pickers with visual badges.
4. Implement Transactions List with search, filtering, and swipe-to-delete.

### Phase 4: Budgets & Analytical Reports
1. Build Budget Creation & Edit dialogs.
2. Build Budget Card widget with animated progress bars and warning states.
3. Build Analytics screen with Category Spending Breakdown (Donut Chart) and Monthly Cashflow (Bar Chart).

### Phase 5: EMI Loans & Early Closure Studio
1. Loan creation form with auto-calculated EMI preview.
2. Loan Details Screen:
   - Remaining Principal progress ring.
   - Amortization schedule list with "Mark as Paid" actions.
3. Interactive Early Payoff Simulator screen with live slider for lump-sum prepayment and tenure savings comparison.

### Phase 6: Chitty, Gold & Investment Ledger
1. Chitty Manager:
   - Scheme setup (Total months, gross amount).
   - Monthly dividend entry sheet updating net payable amount.
   - Prized month recorder.
2. Gold Vault:
   - Holdings list with purity, weight, and profit/loss calculation against current market rate.
3. Investment Summary Screen with aggregate portfolio value.

### Phase 7: Local Notification Service & Reminders
1. Initialize `flutter_local_notifications` with timezone support.
2. Build reminder management UI to schedule, edit, and toggle notification alerts.
3. Hook automatic reminder scheduling whenever a new Loan, Chit Fund, or SIP is created.

### Phase 8: Security, Backup & Settings
1. Integrate `local_auth` for Biometric / PIN App Lock on app resume.
2. Implement JSON database export/import with validation.
3. Implement CSV transaction export.
4. Category manager screen (add/edit custom categories).

---

## 🔒 Constraints & Quality Guardrails

1. **Zero Network Traffic**: Absolutely no HTTP/REST/GraphQL calls, telemetry, or third-party analytics.
2. **Deterministic Financial Math**: Use `double` precision carefully rounded to 2 decimal places with `intl` formatting to avoid floating-point drift in monetary values.
3. **Database Integrity**: All foreign keys must enforce cascading rules (`CASCADE` or `RESTRICT`) to prevent orphaned records.
4. **Resilient UX**:
   - Zero empty-screen dead ends (provide meaningful illustrations and call-to-action buttons for empty states).
   - Instant visual feedback (haptic feedback on keypress, smooth animations using `flutter_animate`).
5. **Code Standards**: 100% sound null safety, strictly typed models, comprehensive error handling with user-friendly snackbars.

---

## 🏆 Deliverables & Acceptance Checklist

- [ ] **Fully Functional Flutter Codebase**: Complete, clean architecture implementation matching the schema and features.
- [ ] **Drift Database Layer**: Fully typed schema with migration logic and seeded data.
- [ ] **Working Amortization & Early Payoff Simulator**: Accurate mathematical calculations for reducing interest and GST.
- [ ] **Chit Fund (Chitty) Dividend Engine**: Accurate calculation of net dues based on dividend inputs.
- [ ] **Working Local Notifications**: Successfully schedules alarms for due dates without any external backend.
- [ ] **JSON & CSV Backup / Restore**: Verified export and import functionality.
- [ ] **Biometric Security**: Seamless lock/unlock flow.
