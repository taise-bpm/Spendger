import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../chitty/chitty_studio_screen.dart';
import '../fd/fd_studio_screen.dart';
import '../gold/gold_studio_screen.dart';
import '../investment_details_screen.dart';
import '../ppf/ppf_studio_screen.dart';
import '../rd/rd_studio_screen.dart';
import '../sip/sip_studio_screen.dart';

class MaturedInvestmentsScreen extends ConsumerStatefulWidget {
  const MaturedInvestmentsScreen({super.key});

  @override
  ConsumerState<MaturedInvestmentsScreen> createState() => _MaturedInvestmentsScreenState();
}

class _MaturedInvestmentsScreenState extends ConsumerState<MaturedInvestmentsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final investmentsAsync = ref.watch(investmentsStreamProvider(null));
    final allInvestments = investmentsAsync.value ?? [];

    final maturedList = allInvestments.where((i) {
      final isClosed = i.status == 'matured' || i.status == 'closed';
      if (!isClosed) return false;
      if (_selectedFilter == 'all') return true;
      return i.type == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matured & Closed Archive', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Types', 'all'),
                _buildFilterChip('PPF', 'ppf'),
                _buildFilterChip('Fixed Deposits', 'fd'),
                _buildFilterChip('Recurring Deposits', 'rd'),
                _buildFilterChip('Chit Funds', 'chitty'),
                _buildFilterChip('SIP / Funds', 'sip'),
                _buildFilterChip('Gold Vault', 'gold'),
              ],
            ),
          ),
          const Gap(16),

          if (maturedList.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.archive_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                  const Gap(12),
                  Text('No matured investments in archive', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Gap(4),
                  Text(
                    'When investments mature or close, they are preserved here in read-only mode for lifetime tax & audit statements.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
              ),
            )
          else
            ...maturedList.map((inv) => _buildMaturedCard(context, inv, isDark: isDark)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String typeKey) {
    final isSelected = _selectedFilter == typeKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.ppf.withValues(alpha: 0.2),
        checkmarkColor: AppColors.ppf,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.ppf : null,
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = typeKey;
          });
        },
      ),
    );
  }

  Widget _buildMaturedCard(BuildContext context, Investment inv, {required bool isDark}) {
    Color typeColor = AppColors.investment;
    IconData typeIcon = Icons.account_balance;

    switch (inv.type) {
      case 'ppf':
        typeColor = AppColors.ppf;
        typeIcon = Icons.shield_outlined;
        break;
      case 'fd':
        typeColor = AppColors.fd;
        typeIcon = Icons.account_balance;
        break;
      case 'rd':
        typeColor = AppColors.rd;
        typeIcon = Icons.repeat;
        break;
      case 'sip':
        typeColor = AppColors.sip;
        typeIcon = Icons.show_chart;
        break;
      case 'chitty':
        typeColor = AppColors.chitty;
        typeIcon = Icons.groups_outlined;
        break;
      case 'gold':
        typeColor = AppColors.gold;
        typeIcon = Icons.scale;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _openInvestmentStudio(context, inv);
        },
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
                          radius: 18,
                          backgroundColor: typeColor.withValues(alpha: 0.15),
                          child: Icon(typeIcon, color: typeColor, size: 20),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inv.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Period: ${DateFormat('dd MMM yyyy').format(inv.startDate)}${inv.maturityDate != null ? " → ${DateFormat('dd MMM yyyy').format(inv.maturityDate!)}" : ""}',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 10, color: isDark ? Colors.amber.shade300 : Colors.brown),
                        const Gap(4),
                        Text(
                          'Matured / Closed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Committed Principal', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                      const Gap(2),
                      Text(
                        CurrencyFormatter.format(inv.totalCommittedAmount ?? inv.purchasePrice ?? 0.0),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'View Statement',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: typeColor),
                      ),
                      const Gap(4),
                      Icon(Icons.arrow_forward_ios, size: 12, color: typeColor),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openInvestmentStudio(BuildContext context, Investment inv) {
    switch (inv.type) {
      case 'ppf':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PpfStudioScreen(ppfInvestment: inv)),
        );
        break;
      case 'fd':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FdStudioScreen(fdInvestment: inv)),
        );
        break;
      case 'rd':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RdStudioScreen(rdInvestment: inv)),
        );
        break;
      case 'chitty':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChittyStudioScreen(chittyInvestment: inv)),
        );
        break;
      case 'sip':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SipStudioScreen(sipInvestment: inv)),
        );
        break;
      case 'gold':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GoldStudioScreen(investment: inv)),
        );
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => InvestmentDetailsScreen(investment: inv)),
        );
    }
  }
}
