import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/icon_helper.dart';
import 'widgets/quick_add_sheet.dart';
import 'widgets/transaction_tile.dart';

enum DateFilterMode {
  all,
  thisMonth,
  particularDate,
  dateRange,
}

enum SortOrder {
  dateDesc,
  dateAsc,
  amountHighToLow,
  amountLowToHigh,
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filterType = 'all'; // 'all', 'expense', 'income', 'transfer'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategoryId; // null = all subheaders/categories
  DateFilterMode _dateFilterMode = DateFilterMode.all;
  DateTime? _particularDate;
  DateTimeRange? _dateRange;
  SortOrder _sortOrder = SortOrder.dateDesc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _filterType = 'all';
      _selectedCategoryId = null;
      _dateFilterMode = DateFilterMode.all;
      _particularDate = null;
      _dateRange = null;
      _sortOrder = SortOrder.dateDesc;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  bool get _hasActiveFilters =>
      _filterType != 'all' ||
      _selectedCategoryId != null ||
      _dateFilterMode != DateFilterMode.all ||
      _sortOrder != SortOrder.dateDesc ||
      _searchQuery.isNotEmpty;

  String _getDateFilterLabel() {
    switch (_dateFilterMode) {
      case DateFilterMode.all:
        return 'All Time';
      case DateFilterMode.thisMonth:
        return 'This Month';
      case DateFilterMode.particularDate:
        if (_particularDate != null) {
          return DateFormat('dd MMM yyyy').format(_particularDate!);
        }
        return 'Specific Date';
      case DateFilterMode.dateRange:
        if (_dateRange != null) {
          return '${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM').format(_dateRange!.end)}';
        }
        return 'Date Range';
    }
  }

  String _getSortOrderLabel() {
    switch (_sortOrder) {
      case SortOrder.dateDesc:
        return 'Newest First';
      case SortOrder.dateAsc:
        return 'Oldest First';
      case SortOrder.amountHighToLow:
        return 'Amount (High-Low)';
      case SortOrder.amountLowToHigh:
        return 'Amount (Low-High)';
    }
  }

  Future<void> _selectParticularDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _particularDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        _dateFilterMode = DateFilterMode.particularDate;
        _particularDate = picked;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
    );
    if (picked != null) {
      setState(() {
        _dateFilterMode = DateFilterMode.dateRange;
        _dateRange = picked;
      });
    }
  }

  void _showCategoryPicker(List<Category> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        // Filter categories matching current type if type is selected
        final filteredCats = _filterType == 'all'
            ? categories
            : categories.where((c) => c.type == _filterType).toList();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Subheader / Category',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (_selectedCategoryId != null)
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedCategoryId = null);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.apps_rounded, color: AppColors.primaryLight, size: 20),
                        ),
                        title: const Text('All Subheaders / Categories'),
                        trailing: _selectedCategoryId == null
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onTap: () {
                          setState(() => _selectedCategoryId = null);
                          Navigator.pop(ctx);
                        },
                      ),
                      ...filteredCats.map((cat) {
                        final isSelected = _selectedCategoryId == cat.id;
                        final color = Color(cat.colorValue);
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(IconHelper.getIcon(cat.iconCode), color: color, size: 20),
                          ),
                          title: Text(cat.name),
                          subtitle: Text(
                            cat.type.toUpperCase(),
                            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: color)
                              : null,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onTap: () {
                            setState(() => _selectedCategoryId = cat.id);
                            Navigator.pop(ctx);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDateFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                      const Gap(8),
                      Text(
                        'Filter by Date',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.all_inclusive),
                  title: const Text('All Time'),
                  trailing: _dateFilterMode == DateFilterMode.all
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _dateFilterMode = DateFilterMode.all;
                      _particularDate = null;
                      _dateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('This Month'),
                  trailing: _dateFilterMode == DateFilterMode.thisMonth
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _dateFilterMode = DateFilterMode.thisMonth;
                      _particularDate = null;
                      _dateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Particular Date'),
                  subtitle: _dateFilterMode == DateFilterMode.particularDate && _particularDate != null
                      ? Text(DateFormat('EEEE, dd MMM yyyy').format(_particularDate!))
                      : const Text('Pick a single day'),
                  trailing: _dateFilterMode == DateFilterMode.particularDate
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    Navigator.pop(ctx);
                    _selectParticularDate();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range_outlined),
                  title: const Text('Custom Date Range'),
                  subtitle: _dateFilterMode == DateFilterMode.dateRange && _dateRange != null
                      ? Text(
                          '${DateFormat('dd MMM yyyy').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}')
                      : const Text('Pick start & end dates'),
                  trailing: _dateFilterMode == DateFilterMode.dateRange
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    Navigator.pop(ctx);
                    _selectDateRange();
                  },
                ),
                const Gap(8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider(null));
    final accountsAsync = ref.watch(accountsStreamProvider);

    final transactions = transactionsAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];
    final accounts = accountsAsync.value ?? [];

    final catMap = {for (var c in categories) c.id: c};
    final accMap = {for (var a in accounts) a.id: a};

    final now = DateTime.now();

    // Filter Logic
    final filtered = transactions.where((t) {
      // 1. Type Filter
      if (_filterType != 'all' && t.type != _filterType) return false;

      // 2. Category Filter
      if (_selectedCategoryId != null && t.categoryId != _selectedCategoryId) {
        return false;
      }

      // 3. Date Filter
      switch (_dateFilterMode) {
        case DateFilterMode.all:
          break;
        case DateFilterMode.thisMonth:
          if (t.transactionDate.year != now.year || t.transactionDate.month != now.month) {
            return false;
          }
          break;
        case DateFilterMode.particularDate:
          if (_particularDate != null) {
            if (t.transactionDate.year != _particularDate!.year ||
                t.transactionDate.month != _particularDate!.month ||
                t.transactionDate.day != _particularDate!.day) {
              return false;
            }
          }
          break;
        case DateFilterMode.dateRange:
          if (_dateRange != null) {
            final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
            final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day, 23, 59, 59);
            if (t.transactionDate.isBefore(start) || t.transactionDate.isAfter(end)) {
              return false;
            }
          }
          break;
      }

      // 4. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final catName = catMap[t.categoryId]?.name.toLowerCase() ?? '';
        final notes = t.notes?.toLowerCase() ?? '';
        final fromAccName = accMap[t.accountId]?.name.toLowerCase() ?? '';
        final toAccName = accMap[t.toAccountId]?.name.toLowerCase() ?? '';
        final q = _searchQuery.toLowerCase();
        return catName.contains(q) || notes.contains(q) || fromAccName.contains(q) || toAccName.contains(q);
      }

      return true;
    }).toList();

    // Sorting Logic
    filtered.sort((a, b) {
      switch (_sortOrder) {
        case SortOrder.dateDesc:
          return b.transactionDate.compareTo(a.transactionDate);
        case SortOrder.dateAsc:
          return a.transactionDate.compareTo(b.transactionDate);
        case SortOrder.amountHighToLow:
          return b.amount.compareTo(a.amount);
        case SortOrder.amountLowToHigh:
          return a.amount.compareTo(b.amount);
      }
    });

    final isDateSorted = _sortOrder == SortOrder.dateDesc || _sortOrder == SortOrder.dateAsc;

    // Group by Date if sorted by date
    final Map<String, List<Transaction>> grouped = {};
    if (isDateSorted) {
      for (final tx in filtered) {
        final dateKey = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
        grouped.putIfAbsent(dateKey, () => []).add(tx);
      }
    }

    final theme = Theme.of(context);
    final selectedCategory = _selectedCategoryId != null ? catMap[_selectedCategoryId] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryLight, size: 28),
            tooltip: 'Add Transaction',
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
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes, category, account...',
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // 4 Type Filter Chips: All, Expenses, Income, Intra Transfers
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildTypeChip('All', 'all'),
                const Gap(8),
                _buildTypeChip('Expenses', 'expense', color: AppColors.expense),
                const Gap(8),
                _buildTypeChip('Income', 'income', color: AppColors.income),
                const Gap(8),
                _buildTypeChip('Intra Transfers', 'transfer', color: AppColors.transfer),
              ],
            ),
          ),

          // Secondary Filter & Sort Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Category / Subheader Filter Button
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showCategoryPicker(categories),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedCategory != null
                            ? Color(selectedCategory.colorValue).withValues(alpha: 0.15)
                            : theme.cardColor.withValues(alpha: 0.6),
                        border: Border.all(
                          color: selectedCategory != null
                              ? Color(selectedCategory.colorValue).withValues(alpha: 0.5)
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedCategory != null
                                ? IconHelper.getIcon(selectedCategory.iconCode)
                                : Icons.category_outlined,
                            size: 16,
                            color: selectedCategory != null
                                ? Color(selectedCategory.colorValue)
                                : Colors.grey,
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              selectedCategory?.name ?? 'All Categories',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selectedCategory != null ? FontWeight.bold : FontWeight.normal,
                                color: selectedCategory != null
                                    ? Color(selectedCategory.colorValue)
                                    : null,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(8),

                // Date Filter Button
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _showDateFilterMenu,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _dateFilterMode != DateFilterMode.all
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : theme.cardColor.withValues(alpha: 0.6),
                      border: Border.all(
                        color: _dateFilterMode != DateFilterMode.all
                            ? AppColors.primaryLight.withValues(alpha: 0.5)
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: _dateFilterMode != DateFilterMode.all ? AppColors.primaryLight : Colors.grey,
                        ),
                        const Gap(6),
                        Text(
                          _getDateFilterLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _dateFilterMode != DateFilterMode.all ? FontWeight.bold : FontWeight.normal,
                            color: _dateFilterMode != DateFilterMode.all ? AppColors.primaryLight : null,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const Gap(8),

                // Sort Order Popup Menu
                PopupMenuButton<SortOrder>(
                  tooltip: 'Sort Order',
                  initialValue: _sortOrder,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (order) => setState(() => _sortOrder = order),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: SortOrder.dateDesc,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 18),
                          Gap(8),
                          Text('Newest First'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: SortOrder.dateAsc,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 18),
                          Gap(8),
                          Text('Oldest First'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: SortOrder.amountHighToLow,
                      child: Row(
                        children: [
                          Icon(Icons.trending_down, size: 18),
                          Gap(8),
                          Text('Amount: High → Low'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: SortOrder.amountLowToHigh,
                      child: Row(
                        children: [
                          Icon(Icons.trending_up, size: 18),
                          Gap(8),
                          Text('Amount: Low → High'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: _sortOrder != SortOrder.dateDesc
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : theme.cardColor.withValues(alpha: 0.6),
                      border: Border.all(
                        color: _sortOrder != SortOrder.dateDesc
                            ? AppColors.accent.withValues(alpha: 0.5)
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.sort_rounded,
                      size: 18,
                      color: _sortOrder != SortOrder.dateDesc ? AppColors.accent : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active Filter Chips & Reset Bar
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_filterType != 'all')
                            _buildActiveBadge(
                              label: _filterType == 'expense'
                                  ? 'Expenses'
                                  : (_filterType == 'income' ? 'Income' : 'Transfers'),
                              onDelete: () => setState(() => _filterType = 'all'),
                            ),
                          if (selectedCategory != null)
                            _buildActiveBadge(
                              label: selectedCategory.name,
                              color: Color(selectedCategory.colorValue),
                              onDelete: () => setState(() => _selectedCategoryId = null),
                            ),
                          if (_dateFilterMode != DateFilterMode.all)
                            _buildActiveBadge(
                              label: _getDateFilterLabel(),
                              onDelete: () => setState(() {
                                _dateFilterMode = DateFilterMode.all;
                                _particularDate = null;
                                _dateRange = null;
                              }),
                            ),
                          if (_sortOrder != SortOrder.dateDesc)
                            _buildActiveBadge(
                              label: _getSortOrderLabel(),
                              color: AppColors.accent,
                              onDelete: () => setState(() => _sortOrder = SortOrder.dateDesc),
                            ),
                          if (_searchQuery.isNotEmpty)
                            _buildActiveBadge(
                              label: '"$_searchQuery"',
                              onDelete: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Reset', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          const Divider(height: 12),

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
                        if (_hasActiveFilters) ...[
                          const Gap(8),
                          OutlinedButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                            label: const Text('Clear All Filters'),
                          ),
                        ] else ...[
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
                      ],
                    ),
                  )
                : isDateSorted
                    ? ListView.builder(
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, index) {
                          final dateKey = grouped.keys.elementAt(index);
                          final dateTransactions = grouped[dateKey]!;
                          final parsedDate = DateTime.parse(dateKey);

                          String displayDate;
                          if (parsedDate.year == now.year &&
                              parsedDate.month == now.month &&
                              parsedDate.day == now.day) {
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
                                  toAccount: accMap[tx.toAccountId],
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return TransactionTile(
                            transaction: tx,
                            category: catMap[tx.categoryId],
                            account: accMap[tx.accountId],
                            toAccount: accMap[tx.toAccountId],
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_transactions',
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

  Widget _buildTypeChip(String label, String value, {Color? color}) {
    final isSelected = _filterType == value;
    final activeColor = color ?? AppColors.primary;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: activeColor.withValues(alpha: 0.2),
      checkmarkColor: activeColor,
      side: BorderSide(
        color: isSelected ? activeColor : Colors.grey.withValues(alpha: 0.2),
      ),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? activeColor : null,
      ),
      onSelected: (_) {
        setState(() => _filterType = value);
      },
    );
  }

  Widget _buildActiveBadge({
    required String label,
    required VoidCallback onDelete,
    Color? color,
  }) {
    final c = color ?? AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.only(left: 8, right: 4, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c),
          ),
          const Gap(2),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 12, color: c),
            ),
          ),
        ],
      ),
    );
  }
}
