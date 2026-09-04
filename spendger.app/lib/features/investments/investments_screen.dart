import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'chitty/chitty_studio_screen.dart';
import 'fd/fd_studio_screen.dart';
import 'gold/gold_studio_screen.dart';
import 'investment_details_screen.dart';
import 'ppf/ppf_studio_screen.dart';
import 'rd/rd_studio_screen.dart';
import 'sip/sip_studio_screen.dart';
import 'widgets/add_chitty_dialog.dart';
import 'widgets/add_fd_dialog.dart';
import 'widgets/add_gold_dialog.dart';
import 'widgets/add_ppf_dialog.dart';
import 'widgets/add_rd_dialog.dart';
import 'widgets/add_sip_dialog.dart';
import 'widgets/record_dividend_dialog.dart';
import 'widgets/record_investment_transaction_dialog.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(investmentsStreamProvider(null));
    final investments = investmentsAsync.value ?? [];

    final double totalValuation = investments.fold(0.0, (sum, i) => sum + i.currentValuation);

    final depositsAndPpf = investments.where((i) => i.type == 'fd' || i.type == 'rd' || i.type == 'ppf').toList();
    final sips = investments.where((i) => i.type == 'sip').toList();
    final chitties = investments.where((i) => i.type == 'chitty').toList();
    final goldHoldings = investments.where((i) => i.type == 'gold').toList();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Investment Vault', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.investment,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Deposits & PPF'),
              Tab(text: 'Mutual Funds & SIP'),
              Tab(text: 'Chit Funds (Chitty)'),
              Tab(text: 'Gold Vault'),
              Tab(text: 'Schedules & Ledger'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.investment, size: 28),
              onSelected: (val) {
                switch (val) {
                  case 'fd':
                    showDialog(context: context, builder: (_) => const AddFdDialog());
                    break;
                  case 'rd':
                    showDialog(context: context, builder: (_) => const AddRdDialog());
                    break;
                  case 'ppf':
                    showDialog(context: context, builder: (_) => const AddPpfDialog());
                    break;
                  case 'sip':
                    showDialog(context: context, builder: (_) => const AddSipDialog());
                    break;
                  case 'gold':
                    showDialog(context: context, builder: (_) => const AddGoldDialog());
                    break;
                  case 'chitty':
                    showDialog(context: context, builder: (_) => const AddChittyDialog());
                    break;
                  case 'ledger':
                    showDialog(context: context, builder: (_) => const RecordInvestmentTransactionDialog());
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'fd',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, color: AppColors.fd, size: 20),
                      Gap(8),
                      Text('Fixed Deposit (FD)'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'rd',
                  child: Row(
                    children: [
                      Icon(Icons.repeat, color: AppColors.rd, size: 20),
                      Gap(8),
                      Text('Recurring Deposit (RD)'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'ppf',
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.ppf, size: 20),
                      Gap(8),
                      Text('PPF Account'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'sip',
                  child: Row(
                    children: [
                      Icon(Icons.show_chart, color: AppColors.sip, size: 20),
                      Gap(8),
                      Text('Mutual Fund / SIP'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'gold',
                  child: Row(
                    children: [
                      Icon(Icons.scale, color: AppColors.gold, size: 20),
                      Gap(8),
                      Text('Gold Holding'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'chitty',
                  child: Row(
                    children: [
                      Icon(Icons.groups_outlined, color: AppColors.chitty, size: 20),
                      Gap(8),
                      Text('Chit Fund (Chitty)'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'ledger',
                  child: Row(
                    children: [
                      Icon(Icons.history_edu, color: AppColors.investment, size: 20),
                      Gap(8),
                      Text('Record Ledger Entry'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Top Portfolio Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4C1D95), Color(0xFF2E1065)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.investment.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL INVESTMENT VALUATION',
                            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const Gap(4),
                          Text(
                            CurrencyFormatter.format(totalValuation),
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    const Icon(Icons.auto_graph, color: AppColors.investment, size: 28),
                  ],
                ),
              ),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildDepositsTab(context, ref, depositsAndPpf),
                  _buildSipTab(context, ref, sips),
                  _buildChittyTab(context, ref, chitties),
                  _buildGoldTab(context, ref, goldHoldings),
                  _buildLedgerTab(context, ref, investments),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: Deposits & PPF (FD, RD, PPF)
  Widget _buildDepositsTab(BuildContext context, WidgetRef ref, List<Investment> deposits) {
    if (deposits.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_outlined, size: 54, color: Colors.grey.withValues(alpha: 0.4)),
              const Gap(12),
              const Text('No Fixed / Recurring Deposits or PPF added yet', style: TextStyle(color: Colors.grey)),
              const Gap(16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.fd, foregroundColor: Colors.white),
                    onPressed: () => showDialog(context: context, builder: (_) => const AddFdDialog()),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Bank FD'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.rd, foregroundColor: Colors.white),
                    onPressed: () => showDialog(context: context, builder: (_) => const AddRdDialog()),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add RD'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.ppf, foregroundColor: Colors.white),
                    onPressed: () => showDialog(context: context, builder: (_) => const AddPpfDialog()),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add PPF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: deposits.length,
      itemBuilder: (context, index) {
        final inv = deposits[index];
        final type = inv.type.toLowerCase();
        
        Color badgeColor;
        String typeLabel;
        IconData typeIcon;

        switch (type) {
          case 'fd':
            badgeColor = AppColors.fd;
            typeLabel = 'FIXED DEPOSIT';
            typeIcon = Icons.account_balance;
            break;
          case 'rd':
            badgeColor = AppColors.rd;
            typeLabel = 'RECURRING DEPOSIT';
            typeIcon = Icons.repeat;
            break;
          case 'ppf':
            badgeColor = AppColors.ppf;
            typeLabel = 'PPF ACCOUNT';
            typeIcon = Icons.shield_outlined;
            break;
          default:
            badgeColor = AppColors.investment;
            typeLabel = 'DEPOSIT';
            typeIcon = Icons.savings_outlined;
        }

        Map<String, dynamic> notesData = {};
        if (inv.notes != null) {
          try {
            notesData = jsonDecode(inv.notes!);
          } catch (_) {}
        }

        final double rate = (notesData['rate'] as num?)?.toDouble() ?? 0.0;
        final double invested = inv.totalCommittedAmount ?? inv.purchasePrice ?? 0.0;
        final double maturityVal = inv.currentValuation;
        final double interestGain = maturityVal > invested ? (maturityVal - invested) : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openInvestmentStudio(context, inv),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: badgeColor.withValues(alpha: 0.15),
                              child: Icon(typeIcon, size: 16, color: badgeColor),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                                  const Gap(2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      typeLabel,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: badgeColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                        onSelected: (action) => _handleDepositAction(context, ref, inv, action),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'schedule', child: Text('View Schedule & Timeline')),
                          const PopupMenuItem(value: 'record_tx', child: Text('Record Deposit / Return')),
                          const PopupMenuItem(value: 'edit', child: Text('Edit Deposit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Deposit', style: TextStyle(color: AppColors.expense))),
                        ],
                      ),
                    ],
                  ),
                  const Gap(14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric(
                        type == 'rd' ? 'Monthly Deposit' : (type == 'ppf' ? 'Annual Deposit' : 'Principal Deposited'),
                        CurrencyFormatter.format(inv.purchasePrice ?? invested),
                      ),
                      if (rate > 0)
                        _buildMetric('Interest Rate', '${rate.toStringAsFixed(2)}% p.a.', color: AppColors.incomeLight),
                      _buildMetric('Maturity Value', CurrencyFormatter.format(maturityVal), color: badgeColor),
                    ],
                  ),
                  const Gap(10),
                  const Divider(),
                  const Gap(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        inv.maturityDate != null
                            ? 'Matures: ${DateFormat('dd MMM yyyy').format(inv.maturityDate!)}'
                            : 'Started: ${DateFormat('dd MMM yyyy').format(inv.startDate)}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      if (interestGain > 0)
                        Text(
                          '+${CurrencyFormatter.format(interestGain)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.incomeLight),
                        ),
                      Row(
                        children: [
                          Text('Schedule', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor)),
                          Icon(Icons.chevron_right, size: 14, color: badgeColor),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 2: Mutual Funds & SIPs
  Widget _buildSipTab(BuildContext context, WidgetRef ref, List<Investment> sips) {
    if (sips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_outlined, size: 54, color: Colors.grey.withValues(alpha: 0.4)),
            const Gap(12),
            const Text('No Mutual Fund or SIP portfolios recorded', style: TextStyle(color: Colors.grey)),
            const Gap(8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.sip, foregroundColor: Colors.white),
              onPressed: () => showDialog(context: context, builder: (_) => const AddSipDialog()),
              icon: const Icon(Icons.add),
              label: const Text('Add Mutual Fund / SIP'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: sips.length,
      itemBuilder: (context, index) {
        final sip = sips[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openInvestmentStudio(context, sip),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.sip.withValues(alpha: 0.15),
                              child: const Icon(Icons.show_chart, size: 16, color: AppColors.sip),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sip.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                                  const Gap(2),
                                  Text(
                                    'Monthly SIP: ${CurrencyFormatter.format(sip.totalCommittedAmount ?? 0.0)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                        onSelected: (action) => _handleSipAction(context, ref, sip, action),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'schedule', child: Text('View Monthly SIP Schedule')),
                          const PopupMenuItem(value: 'record_debit', child: Text('Record Monthly SIP Debit')),
                          const PopupMenuItem(value: 'record_tx', child: Text('Record Dividend / Return')),
                          const PopupMenuItem(value: 'edit', child: Text('Edit SIP')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete SIP', style: TextStyle(color: AppColors.expense))),
                        ],
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Current Portfolio Value', CurrencyFormatter.format(sip.currentValuation), color: AppColors.sip),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sip.withValues(alpha: 0.15),
                              foregroundColor: AppColors.sip,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => RecordInvestmentTransactionDialog(
                                  preselectedInvestment: sip,
                                  defaultTxType: 'sip_debit',
                                ),
                              );
                            },
                            icon: const Icon(Icons.payments_outlined, size: 16),
                            label: const Text('Log SIP Debit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const Gap(6),
                          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 3: Chit Funds (Chitty)
  Widget _buildChittyTab(BuildContext context, WidgetRef ref, List<Investment> chitties) {
    if (chitties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 54, color: Colors.grey.withValues(alpha: 0.4)),
            const Gap(12),
            const Text('No Chit Fund schemes added yet', style: TextStyle(color: Colors.grey)),
            const Gap(8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.chitty, foregroundColor: Colors.white),
              onPressed: () => showDialog(context: context, builder: (_) => const AddChittyDialog()),
              icon: const Icon(Icons.add),
              label: const Text('Add Chit Fund (Chitty)'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: chitties.length,
      itemBuilder: (context, index) {
        final chitty = chitties[index];
        final installmentsAsync = ref.watch(chittyInstallmentsStreamProvider(chitty.id));
        final installments = installmentsAsync.value ?? [];

        final paidCount = installments.where((c) => c.isPaid).length;
        final totalPaid = installments.where((c) => c.isPaid).fold(0.0, (sum, c) => sum + c.netAmountPaid);
        final totalDividend = installments.where((c) => c.isPaid).fold(0.0, (sum, c) => sum + c.dividendEarned);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openInvestmentStudio(context, chitty),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chitty.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                            const Gap(4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.chitty.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Chit Value: ${CurrencyFormatter.format(chitty.totalCommittedAmount ?? 0.0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.chitty),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                        onSelected: (action) => _handleChittyAction(context, ref, chitty, action),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'schedule', child: Text('View Full Amortization Schedule')),
                          const PopupMenuItem(value: 'record_tx', child: Text('Record Deposit / Return')),
                          const PopupMenuItem(value: 'edit', child: Text('Edit Scheme')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete Scheme', style: TextStyle(color: AppColors.expense))),
                        ],
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Total Paid', CurrencyFormatter.format(totalPaid)),
                      _buildMetric('Dividends Saved', CurrencyFormatter.format(totalDividend), color: AppColors.incomeLight),
                      _buildMetric('Progress', '$paidCount / ${installments.length} Mos'),
                    ],
                  ),
                  const Gap(14),
                  const Divider(),
                  const Gap(8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Installments Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                      Row(
                        children: [
                          Text('All Months', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.chitty)),
                          Icon(Icons.chevron_right, size: 14, color: AppColors.chitty),
                        ],
                      ),
                    ],
                  ),
                  const Gap(8),
                  ...installments.take(3).map((inst) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Month ${inst.installmentNumber} (${DateFormat('MMM yy').format(inst.dueDate)})', style: const TextStyle(fontSize: 12)),
                          Row(
                            children: [
                              Text(
                                'Net: ${CurrencyFormatter.format(inst.netAmountPaid)}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: inst.isPaid ? AppColors.incomeLight : Colors.grey),
                              ),
                              const Gap(8),
                              InkWell(
                                onTap: () {
                                  showDialog(context: context, builder: (_) => RecordDividendDialog(installment: inst));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: inst.isPaid ? AppColors.income.withValues(alpha: 0.15) : AppColors.chitty.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    inst.isPaid ? 'PAID' : 'LOG DIVIDEND',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: inst.isPaid ? AppColors.incomeLight : AppColors.chitty,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TAB 4: Gold Vault
  Widget _buildGoldTab(BuildContext context, WidgetRef ref, List<Investment> goldHoldings) {
    if (goldHoldings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars_outlined, size: 54, color: Colors.grey.withValues(alpha: 0.4)),
            const Gap(12),
            const Text('No Gold holdings in vault', style: TextStyle(color: Colors.grey)),
            const Gap(8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black87),
              onPressed: () => showDialog(context: context, builder: (_) => const AddGoldDialog()),
              icon: const Icon(Icons.add),
              label: const Text('Add Gold Holding', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: goldHoldings.length,
      itemBuilder: (context, index) {
        final gold = goldHoldings[index];
        final grams = gold.quantity ?? 0.0;
        final buyPrice = gold.purchasePrice ?? 0.0;
        final totalCost = gold.totalCommittedAmount ?? (grams * buyPrice);
        final currentVal = gold.currentValuation;
        final pnl = currentVal - totalCost;
        final roi = totalCost > 0 ? (pnl / totalCost) * 100 : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openInvestmentStudio(context, gold),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.gold,
                            child: Icon(Icons.scale, size: 16, color: Colors.black87),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Text(gold.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Text('${grams.toStringAsFixed(2)} g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                      onSelected: (action) => _handleGoldAction(context, ref, gold, action),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit Holding')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete Holding', style: TextStyle(color: AppColors.expense))),
                      ],
                    ),
                  ],
                ),
                const Gap(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric('Invested', CurrencyFormatter.format(totalCost)),
                    _buildMetric('Current Value', CurrencyFormatter.format(currentVal), color: AppColors.gold),
                    _buildMetric(
                      'P/L (ROI)',
                      '${pnl >= 0 ? '+' : ''}${CurrencyFormatter.format(pnl)} (${roi.toStringAsFixed(1)}%)',
                      color: pnl >= 0 ? AppColors.incomeLight : AppColors.expenseLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  // TAB 5: Schedules & Investment Ledger Hub
  Widget _buildLedgerTab(BuildContext context, WidgetRef ref, List<Investment> allInvestments) {
    final ledgerAsync = ref.watch(investmentTransactionsStreamProvider(null));
    final transactions = ledgerAsync.value ?? [];

    final double totalOutflow = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    final double totalInflow = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);

    final double netInvested = totalOutflow - totalInflow;

    // Active recurring commitments (RDs, SIPs, PPF, Chitties)
    final recurringCommitments = allInvestments.where((i) => i.type == 'rd' || i.type == 'sip' || i.type == 'ppf' || i.type == 'chitty').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkCardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetric('Total Contributions', CurrencyFormatter.format(totalOutflow), color: AppColors.expenseLight),
                  _buildMetric('Returns & Dividends', CurrencyFormatter.format(totalInflow), color: AppColors.incomeLight),
                  _buildMetric('Net Deployed', CurrencyFormatter.format(netInvested), color: AppColors.investment),
                ],
              ),
              const Gap(10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.investment,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    showDialog(context: context, builder: (_) => const RecordInvestmentTransactionDialog());
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Record Custom Investment Entry'),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),

        // Section A: Active Investment Schedules (Amortization Hub)
        if (recurringCommitments.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Investment Schedules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${recurringCommitments.length} Active', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Gap(8),
          ...recurringCommitments.map((inv) {
            final color = switch (inv.type) {
              'rd' => AppColors.rd,
              'ppf' => AppColors.ppf,
              'sip' => AppColors.sip,
              'chitty' => AppColors.chitty,
              _ => AppColors.investment,
            };

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => _openInvestmentStudio(context, inv),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(
                    inv.type == 'rd'
                        ? Icons.repeat
                        : (inv.type == 'ppf'
                            ? Icons.shield_outlined
                            : (inv.type == 'sip' ? Icons.show_chart : Icons.groups_outlined)),
                    size: 16,
                    color: color,
                  ),
                ),
                title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(
                  '${inv.type.toUpperCase()} • Target: ${CurrencyFormatter.format(inv.totalCommittedAmount ?? inv.currentValuation)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Schedule', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.primaryLight),
                  ],
                ),
              ),
            );
          }),
          const Gap(16),
        ],

        // Section B: Payment History Ledger
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Logged Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('${transactions.length} Entries', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const Gap(8),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.history_edu_outlined, size: 42, color: Colors.grey.withValues(alpha: 0.4)),
                const Gap(8),
                const Text('No investment payments logged yet', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const Gap(4),
                const Text('Mark monthly installments from schedules or log custom entries.', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          )
        else
          ...transactions.map((tx) {
            final isIncome = tx.type == 'income';
            final color = isIncome ? AppColors.incomeLight : AppColors.expenseLight;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: color,
                    size: 18,
                  ),
                ),
                title: Text(
                  tx.notes ?? (isIncome ? 'Investment Return' : 'Investment Contribution'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('dd MMM yyyy').format(tx.transactionDate),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                      onPressed: () => _confirmDeleteTransaction(context, ref, tx.id),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _openInvestmentStudio(BuildContext context, Investment inv) {
    Widget screen;
    switch (inv.type.toLowerCase()) {
      case 'ppf':
        screen = PpfStudioScreen(ppfInvestment: inv);
        break;
      case 'fd':
        screen = FdStudioScreen(fdInvestment: inv);
        break;
      case 'rd':
        screen = RdStudioScreen(rdInvestment: inv);
        break;
      case 'sip':
        screen = SipStudioScreen(sipInvestment: inv);
        break;
      case 'chitty':
        screen = ChittyStudioScreen(chittyInvestment: inv);
        break;
      case 'gold':
        screen = GoldStudioScreen(investment: inv);
        break;
      default:
        screen = InvestmentDetailsScreen(investment: inv);
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildMetric(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const Gap(2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _handleDepositAction(BuildContext context, WidgetRef ref, Investment inv, String action) {
    if (action == 'schedule') {
      _openInvestmentStudio(context, inv);
    } else if (action == 'record_tx') {
      showDialog(
        context: context,
        builder: (_) => RecordInvestmentTransactionDialog(preselectedInvestment: inv),
      );
    } else if (action == 'edit') {
      if (inv.type == 'fd') {
        showDialog(context: context, builder: (_) => AddFdDialog(investmentToEdit: inv));
      } else if (inv.type == 'rd') {
        showDialog(context: context, builder: (_) => AddRdDialog(investmentToEdit: inv));
      } else if (inv.type == 'ppf') {
        showDialog(context: context, builder: (_) => AddPpfDialog(investmentToEdit: inv));
      }
    } else if (action == 'delete') {
      _confirmDeleteInvestment(context, ref, inv);
    }
  }

  void _handleSipAction(BuildContext context, WidgetRef ref, Investment inv, String action) {
    if (action == 'schedule') {
      _openInvestmentStudio(context, inv);
    } else if (action == 'record_debit') {
      showDialog(
        context: context,
        builder: (_) => RecordInvestmentTransactionDialog(
          preselectedInvestment: inv,
          defaultTxType: 'sip_debit',
        ),
      );
    } else if (action == 'record_tx') {
      showDialog(
        context: context,
        builder: (_) => RecordInvestmentTransactionDialog(preselectedInvestment: inv),
      );
    } else if (action == 'edit') {
      showDialog(context: context, builder: (_) => AddSipDialog(investmentToEdit: inv));
    } else if (action == 'delete') {
      _confirmDeleteInvestment(context, ref, inv);
    }
  }

  void _handleChittyAction(BuildContext context, WidgetRef ref, Investment inv, String action) {
    if (action == 'schedule') {
      _openInvestmentStudio(context, inv);
    } else if (action == 'record_tx') {
      showDialog(
        context: context,
        builder: (_) => RecordInvestmentTransactionDialog(preselectedInvestment: inv),
      );
    } else if (action == 'edit') {
      showDialog(context: context, builder: (_) => AddChittyDialog(investmentToEdit: inv));
    } else if (action == 'delete') {
      _confirmDeleteInvestment(context, ref, inv);
    }
  }

  void _handleGoldAction(BuildContext context, WidgetRef ref, Investment inv, String action) {
    if (action == 'edit') {
      showDialog(context: context, builder: (_) => AddGoldDialog(investmentToEdit: inv));
    } else if (action == 'delete') {
      _confirmDeleteInvestment(context, ref, inv);
    }
  }

  Future<void> _confirmDeleteInvestment(BuildContext context, WidgetRef ref, Investment inv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Delete Investment?'),
        content: Text('Are you sure you want to delete "${inv.name}"? All associated ledger transactions and installments will be deleted and balances adjusted.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deleteInvestment(inv.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${inv.name}"')),
        );
      }
    }
  }

  Future<void> _confirmDeleteTransaction(BuildContext context, WidgetRef ref, String txId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Delete Ledger Entry?'),
        content: const Text('Are you sure you want to delete this investment transaction? The account balance will be automatically reverted.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deleteTransactionWithAccountUpdate(txId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Investment transaction deleted & balance reverted')),
        );
      }
    }
  }
}
