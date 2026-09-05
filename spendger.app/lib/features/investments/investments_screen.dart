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
import 'ppf/ppf_hub_screen.dart';
import 'ppf/ppf_studio_screen.dart';
import 'rd/rd_studio_screen.dart';
import 'sip/sip_studio_screen.dart';
import 'widgets/add_chitty_dialog.dart';
import 'widgets/add_fd_dialog.dart';
import 'widgets/add_gold_dialog.dart';
import 'widgets/add_ppf_dialog.dart';
import 'widgets/add_rd_dialog.dart';
import 'widgets/add_sip_dialog.dart';
import 'widgets/matured_investments_screen.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final investmentsAsync = ref.watch(investmentsStreamProvider(null));
    final allInvestments = investmentsAsync.value ?? [];

    final activeInvestments = allInvestments.where((i) => i.status != 'matured' && i.status != 'closed').toList();
    final maturedInvestments = allInvestments.where((i) => i.status == 'matured' || i.status == 'closed').toList();

    // Group active investments by type
    final ppfList = activeInvestments.where((i) => i.type == 'ppf').toList();
    final fdList = activeInvestments.where((i) => i.type == 'fd').toList();
    final rdList = activeInvestments.where((i) => i.type == 'rd').toList();
    final sipList = activeInvestments.where((i) => i.type == 'sip').toList();
    final chittyList = activeInvestments.where((i) => i.type == 'chitty').toList();
    final goldList = activeInvestments.where((i) => i.type == 'gold').toList();

    final double totalActiveValuation = activeInvestments.fold(0.0, (sum, i) => sum + i.currentValuation);
    final double totalCommittedCapital = activeInvestments.fold(0.0, (sum, i) => sum + (i.totalCommittedAmount ?? i.purchasePrice ?? 0.0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Vault', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined, size: 22),
            tooltip: 'Matured & Closed Archive',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MaturedInvestmentsScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.investment, size: 26),
            tooltip: 'Add Investment',
            onSelected: (val) {
              switch (val) {
                case 'ppf':
                  showDialog(context: context, builder: (_) => const AddPpfDialog());
                  break;
                case 'fd':
                  showDialog(context: context, builder: (_) => const AddFdDialog());
                  break;
                case 'rd':
                  showDialog(context: context, builder: (_) => const AddRdDialog());
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
              }
            },
            itemBuilder: (_) => const [
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
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        children: [
          // 1. Portfolio Overview Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up, size: 12, color: AppColors.incomeLight),
                          Gap(4),
                          Text('ACTIVE PORTFOLIO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                        ],
                      ),
                    ),
                    Text(
                      '${activeInvestments.length} Active • ${maturedInvestments.length} Matured',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const Gap(12),
                const Text('Total Investment Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const Gap(2),
                Text(
                  CurrencyFormatter.format(totalActiveValuation),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const Gap(14),
                Container(height: 1, color: Colors.white12),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Committed Principal', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const Gap(2),
                        Text(
                          CurrencyFormatter.format(totalCommittedCapital),
                          style: const TextStyle(color: AppColors.primaryLight, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Active Asset Classes', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const Gap(2),
                        Text(
                          '${_countActiveClasses([ppfList, fdList, rdList, sipList, chittyList, goldList])} Categories',
                          style: const TextStyle(color: AppColors.incomeLight, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(20),

          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Investment Micro-Apps', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text('Select category to explore', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            ],
          ),
          const Gap(12),

          // 2. Micro-App Tiles Grid (2 columns)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              // 1. PPF Micro-App Tile
              _buildMicroAppTile(
                context,
                title: 'Public Provident Fund',
                shortCode: 'PPF',
                tagBadge: '100% Tax-Free',
                icon: Icons.shield_outlined,
                color: AppColors.ppf,
                activeCount: ppfList.length,
                totalValuation: ppfList.fold(0.0, (sum, i) => sum + i.currentValuation),
                isDark: isDark,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PpfHubScreen()),
                  );
                },
              ),

              // 2. Fixed Deposit (FD) Micro-App Tile
              _buildMicroAppTile(
                context,
                title: 'Fixed Deposits',
                shortCode: 'FD',
                tagBadge: 'Guaranteed',
                icon: Icons.account_balance,
                color: AppColors.fd,
                activeCount: fdList.length,
                totalValuation: fdList.fold(0.0, (sum, i) => sum + i.currentValuation),
                isDark: isDark,
                onTap: () {
                  _navigateOrAdd(context, fdList, () => const AddFdDialog(), (inv) => FdStudioScreen(fdInvestment: inv));
                },
              ),

              // 3. Recurring Deposit (RD) Micro-App Tile
              _buildMicroAppTile(
                context,
                title: 'Recurring Deposits',
                shortCode: 'RD',
                tagBadge: 'Monthly',
                icon: Icons.repeat,
                color: AppColors.rd,
                activeCount: rdList.length,
                totalValuation: rdList.fold(0.0, (sum, i) => sum + i.currentValuation),
                isDark: isDark,
                onTap: () {
                  _navigateOrAdd(context, rdList, () => const AddRdDialog(), (inv) => RdStudioScreen(rdInvestment: inv));
                },
              ),

              // 4. Mutual Funds & SIP Micro-App Tile
              _buildMicroAppTile(
                context,
                title: 'Mutual Funds / SIP',
                shortCode: 'SIP',
                tagBadge: 'Market Linked',
                icon: Icons.show_chart,
                color: AppColors.sip,
                activeCount: sipList.length,
                totalValuation: sipList.fold(0.0, (sum, i) => sum + i.currentValuation),
                isDark: isDark,
                onTap: () {
                  _navigateOrAdd(context, sipList, () => const AddSipDialog(), (inv) => SipStudioScreen(sipInvestment: inv));
                },
              ),

              // 5. Chit Funds (Chitty) Micro-App Tile
              _buildMicroAppTile(
                context,
                title: 'Chit Funds',
                shortCode: 'Chitty',
                tagBadge: 'Community',
                icon: Icons.groups_outlined,
                color: AppColors.chitty,
                activeCount: chittyList.length,
                totalValuation: chittyList.fold(0.0, (sum, i) => sum + i.currentValuation),
                isDark: isDark,
                onTap: () {
                  _navigateOrAdd(context, chittyList, () => const AddChittyDialog(), (inv) => ChittyStudioScreen(chittyInvestment: inv));
                },
              ),

              // 6. Gold Vault Micro-App Tile
              _buildMicroAppTile(
                context,
                title: 'Gold Vault',
                shortCode: 'Gold',
                tagBadge: 'Precious Metal',
                icon: Icons.scale,
                color: AppColors.gold,
                activeCount: goldList.length,
                totalValuation: goldList.fold(0.0, (sum, i) => sum + i.currentValuation),
                isDark: isDark,
                onTap: () {
                  _navigateOrAdd(context, goldList, () => const AddGoldDialog(), (inv) => GoldStudioScreen(investment: inv));
                },
              ),
            ],
          ),
          const Gap(20),

          // 3. Matured & Closed Archive Section Card
          Card(
            elevation: 0,
            color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MaturedInvestmentsScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isDark ? Colors.amber.shade900.withValues(alpha: 0.25) : Colors.amber.shade100,
                      child: Icon(Icons.archive_outlined, color: isDark ? Colors.amber.shade300 : Colors.amber.shade900, size: 22),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Matured & Closed Archive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const Gap(6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${maturedInvestments.length}',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          const Gap(2),
                          Text(
                            maturedInvestments.isEmpty
                                ? 'No closed investments. Completed assets will appear here.'
                                : 'View past statements, payouts & read-only history.',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _countActiveClasses(List<List<Investment>> lists) {
    return lists.where((l) => l.isNotEmpty).length;
  }

  Widget _buildMicroAppTile(
    BuildContext context, {
    required String title,
    required String shortCode,
    required String tagBadge,
    required IconData icon,
    required Color color,
    required int activeCount,
    required double totalValuation,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: activeCount > 0
              ? color.withValues(alpha: isDark ? 0.4 : 0.3)
              : (isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tagBadge,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ],
              ),
              const Gap(6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(1),
                  Text(
                    activeCount == 0 ? '0 Active' : '$activeCount Active',
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(totalValuation),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: activeCount > 0 ? color : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(4),
                  Icon(Icons.arrow_forward, size: 12, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateOrAdd(
    BuildContext context,
    List<Investment> list,
    Widget Function() addDialogBuilder,
    Widget Function(Investment inv) studioBuilder,
  ) {
    if (list.isEmpty) {
      showDialog(context: context, builder: (_) => addDialogBuilder());
    } else if (list.length == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => studioBuilder(list.first)),
      );
    } else {
      // If multiple accounts of this type exist, show chooser modal sheet
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.investment),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      showDialog(context: context, builder: (_) => addDialogBuilder());
                    },
                  ),
                ],
              ),
              const Divider(),
              ...list.map(
                (inv) => ListTile(
                  title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Valuation: ${CurrencyFormatter.format(inv.currentValuation)}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => studioBuilder(inv)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
