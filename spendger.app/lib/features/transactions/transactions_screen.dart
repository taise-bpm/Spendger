import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import 'widgets/quick_add_sheet.dart';
import 'widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filterType = 'all'; // 'all', 'expense', 'income'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider(null));
    final accountsAsync = ref.watch(accountsStreamProvider);

    final transactions = transactionsAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];
    final accounts = accountsAsync.value ?? [];

    final catMap = {for (var c in categories) c.id: c};
    final accMap = {for (var a in accounts) a.id: a};

    final filtered = transactions.where((t) {
      if (_filterType != 'all' && t.type != _filterType) return false;
      if (_searchQuery.isNotEmpty) {
        final catName = catMap[t.categoryId]?.name.toLowerCase() ?? '';
        final notes = t.notes?.toLowerCase() ?? '';
        final q = _searchQuery.toLowerCase();
        return catName.contains(q) || notes.contains(q);
      }
      return true;
    }).toList();

    // Group by Date
    final Map<String, List<Transaction>> grouped = {};
    for (final tx in filtered) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLight, size: 28),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const QuickAddSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes or categories...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          // Type filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const Gap(8),
                _buildFilterChip('Expenses', 'expense', color: AppColors.expense),
                const Gap(8),
                _buildFilterChip('Income', 'income', color: AppColors.income),
              ],
            ),
          ),
          const Gap(12),
          // Transaction Stream List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                        const Gap(12),
                        Text(
                          'No transactions found',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                        const Gap(8),
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const QuickAddSheet(),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Transaction'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = grouped.keys.elementAt(index);
                      final dateTransactions = grouped[dateKey]!;
                      final parsedDate = DateTime.parse(dateKey);

                      String displayDate;
                      final now = DateTime.now();
                      if (parsedDate.year == now.year && parsedDate.month == now.month && parsedDate.day == now.day) {
                        displayDate = 'Today';
                      } else if (parsedDate.year == now.year &&
                          parsedDate.month == now.month &&
                          parsedDate.day == now.day - 1) {
                        displayDate = 'Yesterday';
                      } else {
                        displayDate = DateFormat('EEEE, MMM dd, yyyy').format(parsedDate);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            child: Text(
                              displayDate,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...dateTransactions.map(
                            (tx) => TransactionTile(
                              transaction: tx,
                              category: catMap[tx.categoryId],
                              account: accMap[tx.accountId],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const QuickAddSheet(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, {Color? color}) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.25),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? (color ?? AppColors.primaryLight) : null,
      ),
      onSelected: (_) {
        setState(() => _filterType = value);
      },
    );
  }
}
