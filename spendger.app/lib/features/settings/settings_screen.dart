import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/preferences_service.dart';
import 'category_manager_screen.dart';
import '../accounts/accounts_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _biometricEnabled = PreferencesService.isBiometricEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final backupService = ref.watch(backupServiceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Vault', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Privacy Banner Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.income.withValues(alpha: 0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.incomeLight, size: 28),
                Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Offline & Private',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.incomeLight, fontSize: 14),
                      ),
                      Gap(2),
                      Text(
                        'All records and financial data remain exclusively on your local device SQLite storage.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),

          // Security Section
          Text('SECURITY & AUTHENTICATION', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey, letterSpacing: 1.1)),
          const Gap(8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint, color: AppColors.primaryLight),
                  title: const Text('Biometric / Device App Lock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Require authentication to open Spendger', style: TextStyle(fontSize: 11)),
                  value: _biometricEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    if (val) {
                      final authenticated = await BiometricService.authenticate();
                      if (authenticated) {
                        await PreferencesService.setBiometricEnabled(true);
                        setState(() {
                          _biometricEnabled = true;
                        });
                      }
                    } else {
                      await PreferencesService.setBiometricEnabled(false);
                      setState(() {
                        _biometricEnabled = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const Gap(20),

          // Currency & Preferences
          Text('PREFERENCES & APPEARANCE', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey, letterSpacing: 1.1)),
          const Gap(8),
          Card(
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final currentThemeMode = ref.watch(themeModeProvider);
                    return ListTile(
                      leading: Icon(
                        currentThemeMode == ThemeMode.dark
                            ? Icons.dark_mode_outlined
                            : (currentThemeMode == ThemeMode.light ? Icons.light_mode_outlined : Icons.brightness_auto_outlined),
                        color: AppColors.primaryLight,
                      ),
                      title: const Text('Theme Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        currentThemeMode == ThemeMode.dark
                            ? 'Dark Mode (OLED Deep Navy)'
                            : (currentThemeMode == ThemeMode.light ? 'Light Mode (Clean Slate)' : 'System Default'),
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: DropdownButton<ThemeMode>(
                        value: currentThemeMode,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Row(
                              children: [
                                Icon(Icons.dark_mode, size: 16),
                                Gap(8),
                                Text('Dark'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Row(
                              children: [
                                Icon(Icons.light_mode, size: 16),
                                Gap(8),
                                Text('Light'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Row(
                              children: [
                                Icon(Icons.brightness_auto, size: 16),
                                Gap(8),
                                Text('System'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (newMode) {
                          if (newMode != null) {
                            ref.read(themeModeProvider.notifier).setThemeMode(newMode);
                          }
                        },
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.incomeLight),
                  title: const Text('Bank Accounts & Credit Cards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Manage Bank Accounts, Credit Limits, Cash & perform Self-Transfers', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category_outlined, color: AppColors.primaryLight),
                  title: const Text('Manage Categories & Headers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Add, rename, customize icons & colors for Income and Expenses', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CategoryManagerScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: AppColors.loanLight),
                  title: const Text('Currency Symbol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Current: ${CurrencyFormatter.currencySymbol} (${CurrencyFormatter.currencyCode})', style: const TextStyle(fontSize: 11)),
                  trailing: DropdownButton<String>(
                    value: CurrencyFormatter.currencySymbol,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: '₹', child: Text('₹ (INR)')),
                      DropdownMenuItem(value: '\$', child: Text('\$ (USD)')),
                      DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
                      DropdownMenuItem(value: '£', child: Text('£ (GBP)')),
                      DropdownMenuItem(value: 'AED', child: Text('AED (Dirham)')),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await PreferencesService.setCurrencySymbol(val);
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),

          // Data Backup & Export
          Text('DATA BACKUP & PORTABILITY', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey, letterSpacing: 1.1)),
          const Gap(8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.primaryLight),
                  title: const Text('Export Transactions (CSV)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Download spreadsheet compatible with Excel / Sheets', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    try {
                      await backupService.exportTransactionsToCsv();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Export error: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup_outlined, color: AppColors.incomeLight),
                  title: const Text('Create JSON Database Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Complete encrypted snapshot of all tables', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    try {
                      await backupService.exportDatabaseSnapshotJson();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Backup error: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore_outlined, color: AppColors.expenseLight),
                  title: const Text('Restore Database from Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Restore records from a saved JSON backup file', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    try {
                      final success = await backupService.restoreFromJsonFile();
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Database restored successfully!'),
                            backgroundColor: AppColors.income,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Restore error: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const Gap(20),

          // About Card
          Center(
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/images/spendger.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.wallet, size: 28, color: AppColors.primaryLight),
                    ),
                  ),
                ),
                const Gap(8),
                Text(
                  'Spendger v1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Gap(2),
                Text(
                  '100% Offline • Private SQLite Storage',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Gap(20),
        ],
      ),
    );
  }
}
