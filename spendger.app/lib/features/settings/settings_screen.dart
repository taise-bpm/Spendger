import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/utils/currency_formatter.dart';

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
    _biometricEnabled = BiometricService.isBiometricEnabled;
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
                        setState(() {
                          _biometricEnabled = true;
                          BiometricService.isBiometricEnabled = true;
                        });
                      }
                    } else {
                      setState(() {
                        _biometricEnabled = false;
                        BiometricService.isBiometricEnabled = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const Gap(20),

          // Currency & Preferences
          Text('PREFERENCES', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey, letterSpacing: 1.1)),
          const Gap(8),
          Card(
            child: Column(
              children: [
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
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          CurrencyFormatter.currencySymbol = val;
                        });
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
                Text(
                  'Spendger v1.0.0 (Offline-First)',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const Gap(2),
                Text(
                  'Built with Flutter 3.x & Drift SQLite Engine',
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
