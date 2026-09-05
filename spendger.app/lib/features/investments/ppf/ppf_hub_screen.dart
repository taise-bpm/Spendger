import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../widgets/add_ppf_dialog.dart';
import 'ppf_studio_screen.dart';

class PpfHubScreen extends ConsumerWidget {
  const PpfHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final investmentsAsync = ref.watch(investmentsStreamProvider(null));
    final allInvestments = investmentsAsync.value ?? [];
    final ppfList = allInvestments.where((i) => i.type == 'ppf').toList();

    final activePpfs = ppfList.where((i) => i.status != 'matured' && i.status != 'closed').toList();
    final maturedPpfs = ppfList.where((i) => i.status == 'matured' || i.status == 'closed').toList();

    final double totalActiveValuation = activePpfs.fold(0.0, (sum, i) => sum + i.currentValuation);

    // If there is exactly 1 active PPF and no matured ones, we can jump to it or show the hub
    // Hub allows managing multiple PPFs (Self, Spouse, Child) + viewing Matured PPFs.
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPF Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.ppf, size: 26),
            tooltip: 'New PPF Account',
            onPressed: () {
              showDialog(context: context, builder: (_) => const AddPpfDialog());
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        children: [
          // 1. PPF Hub Portfolio Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ppf.withValues(alpha: 0.25),
                  blurRadius: 10,
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
                          Icon(Icons.shield_outlined, size: 12, color: AppColors.incomeLight),
                          Gap(4),
                          Text('100% TAX-FREE (EEE)', style: TextStyle(color: AppColors.incomeLight, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text(
                      '${activePpfs.length} Active Account${activePpfs.length == 1 ? "" : "s"}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const Gap(12),
                const Text('Total PPF Valuation', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const Gap(2),
                Text(
                  CurrencyFormatter.format(totalActiveValuation),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const Gap(14),
                Container(height: 1, color: Colors.white12),
                const Gap(12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Annual Limit: ₹1.5 Lakh / FY', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    Text('Current Interest: 7.1% p.a.', style: TextStyle(color: AppColors.incomeLight, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Gap(20),

          // 2. Active PPF Accounts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active PPF Accounts', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              if (activePpfs.isNotEmpty)
                Text('${activePpfs.length} Accounts', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            ],
          ),
          const Gap(10),
          if (activePpfs.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.shield_outlined, size: 44, color: Colors.grey.withValues(alpha: 0.4)),
                  const Gap(10),
                  Text('No active PPF accounts found', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Gap(4),
                  Text('Create a new PPF or import your existing passbook to start tracking.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  const Gap(14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.ppf, foregroundColor: Colors.white),
                    onPressed: () {
                      showDialog(context: context, builder: (_) => const AddPpfDialog());
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add PPF Account'),
                  ),
                ],
              ),
            )
          else
            ...activePpfs.map((inv) => _buildPpfCard(context, inv, isDark: isDark, isMatured: false)),

          // 3. Matured & Closed PPF Accounts Section
          if (maturedPpfs.isNotEmpty) ...[
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.archive_outlined, size: 16, color: Colors.grey),
                    const Gap(6),
                    Text('Matured & Closed PPF Accounts', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800)),
                  ],
                ),
                Text('${maturedPpfs.length} Closed', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const Gap(10),
            ...maturedPpfs.map((inv) => _buildPpfCard(context, inv, isDark: isDark, isMatured: true)),
          ],
        ],
      ),
    );
  }

  Widget _buildPpfCard(BuildContext context, Investment inv, {required bool isDark, required bool isMatured}) {
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PpfStudioScreen(ppfInvestment: inv),
            ),
          );
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
                          backgroundColor: isMatured
                              ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                              : AppColors.ppf.withValues(alpha: 0.15),
                          child: Icon(
                            isMatured ? Icons.lock_outline : Icons.shield_outlined,
                            color: isMatured ? Colors.grey : AppColors.ppf,
                            size: 20,
                          ),
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
                                'Started: ${DateFormat('dd MMM yyyy').format(inv.startDate)}',
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
                      color: isMatured
                          ? (isDark ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.amber.shade100)
                          : (isDark ? AppColors.income.withValues(alpha: 0.2) : Colors.green.shade100),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isMatured ? 'Matured / Closed' : 'Active Passbook',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isMatured
                            ? (isDark ? Colors.amber.shade300 : Colors.amber.shade900)
                            : (isDark ? AppColors.incomeLight : Colors.green.shade800),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMatured ? 'Settled Valuation' : 'Passbook Valuation',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                      const Gap(2),
                      Text(
                        CurrencyFormatter.format(inv.currentValuation),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: isMatured ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        isMatured ? 'View Archive' : 'Open Studio',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.ppf),
                      ),
                      const Gap(4),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.ppf),
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
}
