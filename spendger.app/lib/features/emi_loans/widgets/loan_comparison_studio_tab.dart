import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/financial_math.dart';
import 'add_loan_dialog.dart';

class LoanComparisonStudioTab extends ConsumerStatefulWidget {
  const LoanComparisonStudioTab({super.key});

  @override
  ConsumerState<LoanComparisonStudioTab> createState() => _LoanComparisonStudioTabState();
}

class _LoanComparisonStudioTabState extends ConsumerState<LoanComparisonStudioTab> {
  // Local fallback mock comparison list if database is empty initially
  List<LoanComparisonOffer> _inMemoryOffers = [];

  @override
  Widget build(BuildContext context) {
    final comparisonsAsync = ref.watch(loanComparisonsStreamProvider);
    final dbComparisons = comparisonsAsync.value ?? [];

    final List<LoanComparisonOffer> activeOffers;
    if (dbComparisons.isNotEmpty) {
      activeOffers = dbComparisons.map((c) {
        return LoanComparisonOffer(
          id: c.id,
          lenderName: c.lenderName,
          loanCategory: c.loanCategory,
          principalAmount: c.principalAmount,
          annualInterestRate: c.annualInterestRate,
          tenureMonths: c.tenureMonths,
          processingFee: c.processingFee,
          isProcessingFeePercentage: c.isProcessingFeePercentage,
          gstRateOnFees: c.gstRateOnFees,
        );
      }).toList();
    } else {
      if (_inMemoryOffers.isEmpty) {
        _inMemoryOffers = [
          LoanComparisonOffer(
            id: 'mock_1',
            lenderName: 'HDFC Bank',
            loanCategory: 'personal_bank',
            principalAmount: 300000.0,
            annualInterestRate: 10.75,
            tenureMonths: 36,
            processingFee: 1.5,
            isProcessingFeePercentage: true,
            gstRateOnFees: 18.0,
          ),
          LoanComparisonOffer(
            id: 'mock_2',
            lenderName: 'SBI Personal Loan',
            loanCategory: 'personal_bank',
            principalAmount: 300000.0,
            annualInterestRate: 11.25,
            tenureMonths: 36,
            processingFee: 1000.0,
            isProcessingFeePercentage: false,
            gstRateOnFees: 18.0,
          ),
          LoanComparisonOffer(
            id: 'mock_3',
            lenderName: 'Friend / Family (P2P)',
            loanCategory: 'friend_family',
            principalAmount: 300000.0,
            annualInterestRate: 0.0,
            tenureMonths: 36,
            processingFee: 0.0,
            isProcessingFeePercentage: false,
            gstRateOnFees: 0.0,
          ),
        ];
      }
      activeOffers = _inMemoryOffers;
    }

    final comparisonResults = FinancialMath.compareLoanOffers(activeOffers);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Studio Workspace Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
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
                  const Row(
                    children: [
                      Icon(Icons.compare_arrows, color: AppColors.primaryLight, size: 22),
                      Gap(8),
                      Text('Mock Loan Comparison', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => _openAddEditOfferDialog(null),
                  ),
                ],
              ),
              const Gap(8),
              const Text(
                'Evaluate competing bank loans, 0% friend loans, upfront processing fees, and effective APR to choose the best deal.',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        const Gap(16),

        if (comparisonResults.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.calculate_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.4)),
                  const Gap(12),
                  const Text('No loan comparison offers yet', style: TextStyle(color: Colors.grey)),
                  const Gap(8),
                  ElevatedButton(
                    onPressed: () => _openAddEditOfferDialog(null),
                    child: const Text('Add First Comparison Offer'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          // Offer Cards List
          ...comparisonResults.map((result) => _buildOfferCard(result)),
          const Gap(16),

          // Comparative Side-by-Side Summary
          if (comparisonResults.length > 1) _buildComparisonSummaryTable(comparisonResults),
        ],
        const Gap(24),
      ],
    );
  }

  Widget _buildOfferCard(LoanOfferComparisonResult res) {
    final offer = res.offer;
    final isBest = res.isBestOffer;
    final isFriendLoan = offer.loanCategory == 'friend_family' || offer.annualInterestRate == 0;

    final categoryLabel = switch (offer.loanCategory) {
      'personal_bank' => 'Personal Loan',
      'asset_vehicle' => 'Vehicle / Asset',
      'friend_family' => 'Friend / Family (0%)',
      _ => 'Custom Loan',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isBest ? AppColors.income.withValues(alpha: 0.7) : Colors.white10,
          width: isBest ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Lender Name, Category Badge, Best Value Pill
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: (isFriendLoan ? AppColors.income : (isBest ? AppColors.loan : AppColors.primary))
                      .withValues(alpha: 0.2),
                  child: Icon(
                    isFriendLoan ? Icons.people_outline : Icons.account_balance,
                    size: 16,
                    color: isFriendLoan ? AppColors.incomeLight : (isBest ? AppColors.loanLight : AppColors.primaryLight),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.lenderName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        categoryLabel,
                        style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                if (isBest) ...[
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.income.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.income.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: AppColors.incomeLight),
                        Gap(4),
                        Text(
                          'LOWEST COST',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.incomeLight),
                        ),
                      ],
                    ),
                  ),
                ],
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _openAddEditOfferDialog(offer);
                    } else if (val == 'delete') {
                      _deleteOffer(offer.id);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Offer')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete Offer', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const Gap(14),

            // Key Highlights Metric Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem('Monthly EMI', CurrencyFormatter.format(res.calculatedEmi), isHighlight: true, color: AppColors.loanLight),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _buildMetricItem('Principal', CurrencyFormatter.format(offer.principalAmount)),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _buildMetricItem('Interest Rate', '${offer.annualInterestRate.toStringAsFixed(1)}% p.a.'),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem('Total Interest', CurrencyFormatter.format(res.totalInterest)),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _buildMetricItem('Processing Fee', CurrencyFormatter.format(res.upfrontProcessingFee)),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _buildMetricItem('Effective APR', '${res.effectiveApr.toStringAsFixed(1)}%'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(14),

            // Financial Bottom Line & Activation Button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Overall Cost', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      const Gap(2),
                      Text(
                        CurrencyFormatter.format(res.totalCostOfLoan),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (res.costDeltaFromBest > 0)
                        Text(
                          '+ ${CurrencyFormatter.format(res.costDeltaFromBest)} vs best deal',
                          style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                const Gap(8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBest ? AppColors.incomeLight : AppColors.loan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 15),
                  label: const Text(
                    'Finalize & Activate',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddLoanDialog(initialComparisonOffer: offer),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, {bool isHighlight = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const Gap(2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildComparisonSummaryTable(List<LoanOfferComparisonResult> results) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.table_chart_outlined, size: 18, color: AppColors.primaryLight),
                Gap(8),
                Text('Side-by-Side Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const Gap(12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                headingRowHeight: 36,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 42,
                columns: const [
                  DataColumn(label: Text('Lender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('EMI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Fees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Interest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('Total Cost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  DataColumn(label: Text('APR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                ],
                rows: results.map((r) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            if (r.isBestOffer) const Icon(Icons.star, size: 12, color: AppColors.incomeLight),
                            if (r.isBestOffer) const Gap(4),
                            Text(r.offer.lenderName, style: TextStyle(fontWeight: r.isBestOffer ? FontWeight.bold : FontWeight.normal, fontSize: 11)),
                          ],
                        ),
                      ),
                      DataCell(Text('${r.offer.annualInterestRate}%', style: const TextStyle(fontSize: 11))),
                      DataCell(Text(CurrencyFormatter.format(r.calculatedEmi), style: const TextStyle(fontSize: 11))),
                      DataCell(Text(CurrencyFormatter.format(r.upfrontProcessingFee), style: const TextStyle(fontSize: 11))),
                      DataCell(Text(CurrencyFormatter.format(r.totalInterest), style: const TextStyle(fontSize: 11))),
                      DataCell(Text(
                        CurrencyFormatter.format(r.totalCostOfLoan),
                        style: TextStyle(fontWeight: FontWeight.bold, color: r.isBestOffer ? AppColors.incomeLight : null, fontSize: 11),
                      )),
                      DataCell(Text('${r.effectiveApr.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddEditOfferDialog(LoanComparisonOffer? existing) {
    AddEditLoanOfferDialog.show(context, ref, existing, (offer) {
      setState(() {
        _inMemoryOffers.removeWhere((o) => o.id == offer.id);
        _inMemoryOffers.add(offer);
      });
    });
  }

  void _deleteOffer(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteLoanComparison(id);
    setState(() {
      _inMemoryOffers.removeWhere((o) => o.id == id);
    });
  }
}

class AddEditLoanOfferDialog extends StatefulWidget {
  final LoanComparisonOffer? offerToEdit;
  final ValueChanged<LoanComparisonOffer> onSave;

  const AddEditLoanOfferDialog({super.key, this.offerToEdit, required this.onSave});

  static void show(
    BuildContext context,
    WidgetRef ref, [
    LoanComparisonOffer? existing,
    ValueChanged<LoanComparisonOffer>? onSavedCallback,
  ]) {
    showDialog(
      context: context,
      builder: (_) => AddEditLoanOfferDialog(
        offerToEdit: existing,
        onSave: (offer) async {
          final db = ref.read(databaseProvider);
          const uuid = Uuid();
          final id = offer.id.isNotEmpty ? offer.id : uuid.v4();

          final companion = LoanComparisonsCompanion.insert(
            id: id,
            groupName: const drift.Value('General Comparison'),
            lenderName: offer.lenderName,
            loanCategory: drift.Value(offer.loanCategory),
            principalAmount: offer.principalAmount,
            annualInterestRate: offer.annualInterestRate,
            tenureMonths: offer.tenureMonths,
            processingFee: drift.Value(offer.processingFee),
            isProcessingFeePercentage: drift.Value(offer.isProcessingFeePercentage),
            gstRateOnFees: drift.Value(offer.gstRateOnFees),
            isFinalized: const drift.Value(false),
            createdAt: DateTime.now(),
          );

          await db.upsertLoanComparison(companion);
          onSavedCallback?.call(offer);
        },
      ),
    );
  }

  @override
  State<AddEditLoanOfferDialog> createState() => _AddEditLoanOfferDialogState();
}

class _AddEditLoanOfferDialogState extends State<AddEditLoanOfferDialog> {
  final _lenderController = TextEditingController();
  final _principalController = TextEditingController(text: '300000');
  final _rateController = TextEditingController(text: '10.5');
  final _tenureController = TextEditingController(text: '36');
  final _feeController = TextEditingController(text: '1.0');

  String _loanCategory = 'personal_bank';
  bool _isPercentageFee = true;
  bool _includeGst = true;

  @override
  void initState() {
    super.initState();
    if (widget.offerToEdit != null) {
      final o = widget.offerToEdit!;
      _lenderController.text = o.lenderName;
      _principalController.text = o.principalAmount.truncateToDouble() == o.principalAmount
          ? o.principalAmount.toInt().toString()
          : o.principalAmount.toString();
      _rateController.text = o.annualInterestRate.toString();
      _tenureController.text = o.tenureMonths.toString();
      _feeController.text = o.processingFee.toString();
      _loanCategory = o.loanCategory;
      _isPercentageFee = o.isProcessingFeePercentage;
      _includeGst = o.gstRateOnFees > 0;
    }
  }

  @override
  void dispose() {
    _lenderController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        widget.offerToEdit != null ? 'Edit Loan Offer' : 'Add Loan Offer to Compare',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(8),
              // Category Selector
              DropdownButtonFormField<String>(
                initialValue: _loanCategory,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Loan Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'personal_bank',
                    child: Text('Personal Loan (Bank)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'asset_vehicle',
                    child: Text('Vehicle / Bike Loan', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'friend_family',
                    child: Text('Friend / Relative (0% Interest)', overflow: TextOverflow.ellipsis),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('Other / Custom Loan', overflow: TextOverflow.ellipsis),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _loanCategory = val;
                      if (val == 'friend_family') {
                        _rateController.text = '0.0';
                        _feeController.text = '0.0';
                      }
                    });
                  }
                },
              ),
              const Gap(10),

              TextField(
                controller: _lenderController,
                decoration: InputDecoration(
                  labelText: _loanCategory == 'friend_family' ? 'Friend / Relative Name' : 'Bank / Lender Name',
                  hintText: _loanCategory == 'friend_family' ? 'e.g. John Doe' : 'e.g. HDFC, ICICI, SBI',
                  prefixIcon: const Icon(Icons.account_balance),
                ),
              ),
              const Gap(10),

              TextField(
                controller: _principalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Principal Amount (₹)', prefixIcon: Icon(Icons.currency_rupee)),
              ),
              const Gap(10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _loanCategory == 'friend_family' ? 'Rate (0%)' : 'Rate (% p.a.)',
                        prefixIcon: const Icon(Icons.percent),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: TextField(
                      controller: _tenureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tenure (Mo)', prefixIcon: Icon(Icons.calendar_month)),
                    ),
                  ),
                ],
              ),
              const Gap(10),

              if (_loanCategory != 'friend_family') ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _feeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: _isPercentageFee ? 'Fee (%)' : 'Fixed Fee (₹)',
                          prefixIcon: Icon(_isPercentageFee ? Icons.percent : Icons.currency_rupee),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isPercentageFee = true),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _isPercentageFee ? AppColors.primary : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                                  ),
                                  child: Text(
                                    '%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: _isPercentageFee ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isPercentageFee = false),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: !_isPercentageFee ? AppColors.primary : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                                  ),
                                  child: Text(
                                    '₹',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: !_isPercentageFee ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                InkWell(
                  onTap: () => setState(() => _includeGst = !_includeGst),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _includeGst,
                        activeColor: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) => setState(() => _includeGst = val ?? true),
                      ),
                      const Expanded(
                        child: Text('+ 18% GST on processing fees', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          onPressed: () {
            final lender = _lenderController.text.trim();
            final principal = double.tryParse(_principalController.text.trim());
            final rate = double.tryParse(_rateController.text.trim());
            final tenure = int.tryParse(_tenureController.text.trim());
            final fee = double.tryParse(_feeController.text.trim()) ?? 0.0;

            if (lender.isEmpty || principal == null || rate == null || tenure == null || principal <= 0 || tenure <= 0 || rate < 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid offer details')));
              return;
            }

            final offer = LoanComparisonOffer(
              id: widget.offerToEdit?.id ?? '',
              lenderName: lender,
              loanCategory: _loanCategory,
              principalAmount: principal,
              annualInterestRate: rate,
              tenureMonths: tenure,
              processingFee: fee,
              isProcessingFeePercentage: _isPercentageFee,
              gstRateOnFees: _includeGst ? 18.0 : 0.0,
            );

            widget.onSave(offer);
            Navigator.of(context).pop();
          },
          child: const Text('Save Offer'),
        ),
      ],
    );
  }
}
