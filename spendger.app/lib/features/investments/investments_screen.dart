import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import 'widgets/add_chitty_dialog.dart';
import 'widgets/add_gold_dialog.dart';
import 'widgets/add_sip_dialog.dart';
import 'widgets/record_dividend_dialog.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentsAsync = ref.watch(investmentsStreamProvider(null));
    final investments = investmentsAsync.value ?? [];

    final double totalValuation = investments.fold(0.0, (sum, i) => sum + i.currentValuation);

    final chitties = investments.where((i) => i.type == 'chitty').toList();
    final goldHoldings = investments.where((i) => i.type == 'gold').toList();
    final sips = investments.where((i) => i.type == 'sip' || i.type == 'fd').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Investment Vault', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: AppColors.investment,
            tabs: [
              Tab(text: 'Chit Funds (Chitty)'),
              Tab(text: 'Gold Vault'),
              Tab(text: 'SIPs & Deposits'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.investment, size: 28),
              onSelected: (val) {
                if (val == 'chitty') {
                  showDialog(context: context, builder: (_) => const AddChittyDialog());
                } else if (val == 'gold') {
                  showDialog(context: context, builder: (_) => const AddGoldDialog());
                } else if (val == 'sip') {
                  showDialog(context: context, builder: (_) => const AddSipDialog());
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'chitty', child: Text('Add Chit Fund (Chitty)')),
                const PopupMenuItem(value: 'gold', child: Text('Add Gold Holding')),
                const PopupMenuItem(value: 'sip', child: Text('Add SIP / Mutual Fund')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Top Portfolio Header
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
                  _buildChittyTab(context, ref, chitties),
                  _buildGoldTab(context, ref, goldHoldings),
                  _buildSipTab(context, ref, sips),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      padding: const EdgeInsets.all(16),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(chitty.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.chitty.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Total: ${CurrencyFormatter.format(chitty.totalCommittedAmount ?? 0.0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.chitty),
                      ),
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
                const Text('Recent Installments Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
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
        );
      },
    );
  }

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
      padding: const EdgeInsets.all(16),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.gold,
                          child: Icon(Icons.scale, size: 16, color: Colors.black87),
                        ),
                        const Gap(10),
                        Text(gold.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    Text('${grams.toStringAsFixed(2)} g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        );
      },
    );
  }

  Widget _buildSipTab(BuildContext context, WidgetRef ref, List<Investment> sips) {
    if (sips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_outlined, size: 54, color: Colors.grey.withValues(alpha: 0.4)),
            const Gap(12),
            const Text('No SIPs or Deposits recorded', style: TextStyle(color: Colors.grey)),
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
      padding: const EdgeInsets.all(16),
      itemCount: sips.length,
      itemBuilder: (context, index) {
        final sip = sips[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sip.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Gap(4),
                    Text(
                      'Monthly SIP: ${CurrencyFormatter.format(sip.totalCommittedAmount ?? 0.0)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(sip.currentValuation),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.sip),
                    ),
                    const Text('Valuation', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
}
