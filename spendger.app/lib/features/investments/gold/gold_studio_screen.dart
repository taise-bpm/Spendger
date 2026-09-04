import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../widgets/add_gold_dialog.dart';
import '../widgets/close_or_mature_dialog.dart';

class GoldStudioScreen extends ConsumerStatefulWidget {
  final Investment investment;

  const GoldStudioScreen({super.key, required this.investment});

  @override
  ConsumerState<GoldStudioScreen> createState() => _GoldStudioScreenState();
}

class _GoldStudioScreenState extends ConsumerState<GoldStudioScreen> {
  late Investment _investment;

  @override
  void initState() {
    super.initState();
    _investment = widget.investment;
  }

  void _refreshInvestment(List<Investment> allInvestments) {
    final updated = allInvestments.where((inv) => inv.id == _investment.id).firstOrNull;
    if (updated != null && mounted) {
      setState(() {
        _investment = updated;
      });
    }
  }

  void _openUpdateLiveRateDialog() {
    final currentRate = (_investment.quantity != null && _investment.quantity! > 0)
        ? (_investment.currentValuation / _investment.quantity!)
        : (_investment.purchasePrice ?? 0.0);

    final rateController = TextEditingController(text: currentRate.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.trending_up, color: AppColors.gold),
            Gap(8),
            Text('Update Market Rate'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update the current 22K/24K market gold price per gram for "${_investment.name}".'),
            const Gap(14),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Live Rate per Gram (₹)',
                prefixText: '₹ ',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black87),
            onPressed: () async {
              final newRate = double.tryParse(rateController.text.trim());
              if (newRate != null && newRate > 0) {
                final grams = _investment.quantity ?? 0.0;
                final newValuation = grams * newRate;
                final db = ref.read(databaseProvider);
                await db.updateInvestment(
                  _investment.id,
                  InvestmentsCompanion(
                    currentValuation: drift.Value(newValuation),
                  ),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Valuation updated to ₹${NumberFormat('#,##,###').format(newValuation)} (@ ₹$newRate/g)'),
                      backgroundColor: AppColors.gold,
                    ),
                  );
                }
              }
            },
            child: const Text('Update Valuation', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final db = ref.watch(databaseProvider);

    return StreamBuilder<List<Investment>>(
      stream: db.watchInvestments(type: 'gold'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _refreshInvestment(snapshot.data!);
        }

        final grams = _investment.quantity ?? 0.0;
        final buyRate = _investment.purchasePrice ?? 0.0;
        final invested = _investment.totalCommittedAmount ?? (grams * buyRate);
        final currentValuation = _investment.currentValuation;
        final pnl = currentValuation - invested;
        final pnlPercent = invested > 0 ? (pnl / invested) * 100 : 0.0;
        final isProfit = pnl >= 0;
        final currentRatePerGram = grams > 0 ? currentValuation / grams : buyRate;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_investment.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text('Gold Vault & Holdings Studio', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Holding',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddGoldDialog(investmentToEdit: _investment),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'update_rate') {
                    _openUpdateLiveRateDialog();
                  } else if (val == 'liquidate') {
                    showDialog(
                      context: context,
                      builder: (_) => CloseOrMatureDialog(investment: _investment),
                    );
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'update_rate',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: AppColors.gold),
                        Gap(8),
                        Text('Update Live Rate (₹/g)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'liquidate',
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, color: Colors.amber),
                        Gap(8),
                        Text('Sell / Liquidate to Bank'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Gold Valuation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C2411), Color(0xFF1E190B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.stars, color: AppColors.gold, size: 24),
                              ),
                              const Gap(10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CURRENT VALUATION', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                  Text(
                                    currency.format(currentValuation),
                                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.gold,
                              side: const BorderSide(color: AppColors.gold),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            icon: const Icon(Icons.sync, size: 16),
                            label: const Text('Update Rate', style: TextStyle(fontSize: 12)),
                            onPressed: _openUpdateLiveRateDialog,
                          ),
                        ],
                      ),
                      const Gap(16),
                      const Divider(color: Colors.white12),
                      const Gap(12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('Total Weight', '${grams.toStringAsFixed(2)} g', '${(grams / 8.0).toStringAsFixed(2)} Sov.'),
                          _buildStatItem('Invested Cost', currency.format(invested), '@ ₹${buyRate.toStringAsFixed(0)}/g'),
                          _buildStatItem(
                            'Unrealized P&L',
                            '${isProfit ? '+' : ''}${currency.format(pnl)}',
                            '${isProfit ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
                            valueColor: isProfit ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // Metrics / Rates details
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Holding Details & Rates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const Gap(14),
                        _buildDetailRow('Holding Type / Karat', _investment.name),
                        _buildDetailRow('Physical Quantity', '$grams grams (${(grams / 8.0).toStringAsFixed(2)} Sovereigns / Pavans)'),
                        _buildDetailRow('Purchase Rate per Gram', '₹${buyRate.toStringAsFixed(2)} / g'),
                        _buildDetailRow('Current Market Valuation Rate', '₹${currentRatePerGram.toStringAsFixed(2)} / g'),
                        _buildDetailRow('Holding Since', DateFormat('dd MMM yyyy').format(_investment.startDate)),
                        _buildDetailRow('Status', _investment.status.toUpperCase(), highlight: _investment.status == 'active'),
                      ],
                    ),
                  ),
                ),
                const Gap(20),

                // Sovereign Quick Conversion Guide
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                          Gap(8),
                          Text('Gold Vault Insights', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        '• 1 Sovereign (Pavan) = 8.0 Grams\n'
                        '• Total holding equivalent: ${(grams / 8.0).toStringAsFixed(3)} Sovereigns.\n'
                        '• When selling or exchanging gold, use the "Sell / Liquidate to Bank" option to credit the proceeds into your bank account and close this holding.',
                        style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Gap(24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.amber),
                          foregroundColor: Colors.amber,
                        ),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: const Text('Liquidate / Sell to Bank'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => CloseOrMatureDialog(investment: _investment),
                          );
                        },
                      ),
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

  Widget _buildStatItem(String label, String value, String subtext, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const Gap(4),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const Gap(2),
        Text(subtext, style: TextStyle(color: valueColor?.withValues(alpha: 0.8) ?? Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: highlight ? Colors.greenAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
