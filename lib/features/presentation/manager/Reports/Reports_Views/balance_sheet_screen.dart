import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:open_file/open_file.dart';
import '../Reports_ViewModel/balance_sheet_view_model.dart';
import '../../../../domain/entities/balance_sheet.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_period_selector.dart';

class BalanceSheetScreen extends ConsumerStatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  ConsumerState<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends ConsumerState<BalanceSheetScreen> {
  bool isChartView = true;
  bool isAssetsExpanded = true;
  bool isLiabilitiesExpanded = true;
  bool isEquityExpanded = true;
  
  // Chart state

  @override
  void initState() {
    super.initState();
    // Load balance sheet list only
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(balanceSheetViewModelProvider);
      if (state.balanceSheets == null && !state.isLoading) {
        ref.read(balanceSheetViewModelProvider.notifier).loadAllBalanceSheets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceSheetState = ref.watch(balanceSheetViewModelProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Balance Sheet',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (balanceSheetState.hasData)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(balanceSheetState),
    );
  }

  Widget _buildBody(BalanceSheetState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading balance sheet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (!state.hasData || state.selectedBalanceSheet == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No balance sheet available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a balance sheet to view data',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          // Period Selector
          if (state.balanceSheets != null && state.balanceSheets!.length > 1)
            _buildPeriodSelector(state),
          
          // Professional Header (white, subtle border)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Color(0xFF8B5CF6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Balance Sheet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Financial position as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Total Assets',
                        '\$${state.selectedBalanceSheet!.totals.totalAssets.toStringAsFixed(2)}',
                        const Color(0xFF10B981),
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Total Liabilities',
                        '\$${state.selectedBalanceSheet!.totals.totalLiabilities.toStringAsFixed(2)}',
                        const Color(0xFFEF4444),
                        Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Total Equity',
                        '\$${state.selectedBalanceSheet!.totals.totalEquity.toStringAsFixed(2)}',
                        const Color(0xFF3B82F6),
                        Icons.account_balance_wallet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Professional View Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isChartView = true),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: isChartView 
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                        color: isChartView ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isChartView ? [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 18,
                              color: isChartView ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Chart View',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isChartView ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isChartView = false),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: !isChartView 
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                        color: !isChartView ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !isChartView ? [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_chart,
                              size: 18,
                              color: !isChartView ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Table View',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !isChartView ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Content
          isChartView ? _buildChartView(state) : _buildTableView(state.selectedBalanceSheet!),
          
          const SizedBox(height: 20),
          
          // Download Report Button (visible in both views)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showDownloadOptions(context, state.selectedBalanceSheet!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Download Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChartView(BalanceSheetState balanceSheetState) {
    return Column(
        children: [
        const SizedBox(height: 20),

        // Professional Chart Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 380,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: RepaintBoundary(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue(balanceSheetState.selectedBalanceSheet!),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(0)}\n${_getTooltipText(group.x.toDouble(), rodIndex)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Assets', style: style);
                          case 1:
                            return const Text('Liabilities + Equity', style: style);
                          default:
                            return const Text('');
                        }
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _getMaxValue(balanceSheetState.selectedBalanceSheet!) > 0 ? _getMaxValue(balanceSheetState.selectedBalanceSheet!) / 5 : 1000,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '\$${(value / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _getBarGroups(balanceSheetState.selectedBalanceSheet!),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue(balanceSheetState.selectedBalanceSheet!) > 0 ? _getMaxValue(balanceSheetState.selectedBalanceSheet!) / 5 : 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          ),

        ],
      );
    }

  Widget _buildTableView(BalanceSheet balanceSheet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header with Export
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Balance Sheet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 8),

          // Date
          Row(
            children: [
              Text(
                'As of monthly',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Balance Sheet Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Assets Section - using dynamic data from summary
                _buildCollapsibleSectionHeader(
                  'Assets', 
                  '\$${balanceSheet.totals.totalAssets.toStringAsFixed(2)}', 
                  isAssetsExpanded,
                  () => setState(() => isAssetsExpanded = !isAssetsExpanded),
                ),
                if (isAssetsExpanded) ...[
                  _buildSubSection('Current Assets', '(Short-term, highly liquid)'),
                  _buildBalanceSheetRow('Crypto Holdings', '\$${balanceSheet.assets.currentAssets.cryptoHoldings.totalValue.toStringAsFixed(2)}'),
                  // Detailed Crypto Breakdown
                  if (balanceSheet.assets.currentAssets.cryptoHoldings.holdings.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildCryptoBreakdown(balanceSheet.assets.currentAssets.cryptoHoldings),
                  ],
                  _buildTotalRow('Total Current Assets', '\$${balanceSheet.assets.currentAssets.total.toStringAsFixed(2)}'),
                  
                  const SizedBox(height: 16),
                  
                  _buildSubSection('Non-Current Assets', '(Long-term investments)'),
                  _buildBalanceSheetRow('Long-term Investments', '\$${balanceSheet.assets.nonCurrentAssets.longTermInvestments.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Equipment', '\$${balanceSheet.assets.nonCurrentAssets.equipment.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Other', '\$${balanceSheet.assets.nonCurrentAssets.other.toStringAsFixed(2)}'),
                  _buildTotalRow('Total Non-Current Assets', '\$${balanceSheet.assets.nonCurrentAssets.total.toStringAsFixed(2)}'),
                ],

                const SizedBox(height: 20),

                // Liabilities Section - using dynamic data from summary
                _buildCollapsibleSectionHeader(
                  'Liabilities', 
                  '\$${balanceSheet.totals.totalLiabilities.toStringAsFixed(2)}', 
                  isLiabilitiesExpanded,
                  () => setState(() => isLiabilitiesExpanded = !isLiabilitiesExpanded),
                ),
                if (isLiabilitiesExpanded) ...[
                  _buildSubSection('Current Liabilities', '(Due within one year)'),
                  _buildBalanceSheetRow('Accounts Payable', '\$${balanceSheet.liabilities.currentLiabilities.accountsPayable.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Accrued Expenses', '\$${balanceSheet.liabilities.currentLiabilities.accruedExpenses.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Short-term Debt', '\$${balanceSheet.liabilities.currentLiabilities.shortTermDebt.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Tax Liabilities', '\$${balanceSheet.liabilities.currentLiabilities.taxLiabilities.toStringAsFixed(2)}'),
                  _buildTotalRow('Total Current Liabilities', '\$${balanceSheet.liabilities.currentLiabilities.total.toStringAsFixed(2)}'),
                  
                  const SizedBox(height: 16),
                  
                  _buildSubSection('Long-term Liabilities', '(Due after one year)'),
                  _buildBalanceSheetRow('Long-term Debt', '\$${balanceSheet.liabilities.longTermLiabilities.longTermDebt.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Deferred Tax', '\$${balanceSheet.liabilities.longTermLiabilities.deferredTax.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Other', '\$${balanceSheet.liabilities.longTermLiabilities.other.toStringAsFixed(2)}'),
                  _buildTotalRow('Total Long-term Liabilities', '\$${balanceSheet.liabilities.longTermLiabilities.total.toStringAsFixed(2)}'),
                ],

                const SizedBox(height: 20),

                // Equity Section - using dynamic data from summary
                _buildCollapsibleSectionHeader(
                  'Equity', 
                  '\$${balanceSheet.totals.totalEquity.toStringAsFixed(2)}', 
                  isEquityExpanded,
                  () => setState(() => isEquityExpanded = !isEquityExpanded),
                ),
                if (isEquityExpanded) ...[
                  _buildSubSection('Equity', '(Owner\'s equity)'),
                  _buildBalanceSheetRow('Retained Earnings', '\$${balanceSheet.equity.retainedEarnings.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Unrealized Gains/Losses', '\$${balanceSheet.equity.unrealizedGainsLosses.toStringAsFixed(2)}'),
                  _buildTotalRow('Total Equity', '\$${balanceSheet.equity.total.toStringAsFixed(2)}'),
                ],
                const SizedBox(height: 20),

                // Summary Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Total Assets', '\$${balanceSheet.totals.totalAssets.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Total Liabilities', '\$${balanceSheet.totals.totalLiabilities.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Total Equity', '\$${balanceSheet.totals.totalEquity.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Liabilities + Equity', '\$${(balanceSheet.totals.totalLiabilities + balanceSheet.totals.totalEquity).toStringAsFixed(2)}', isTotal: true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }


  Widget _buildCollapsibleSectionHeader(String title, String amount, bool isExpanded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSheetRow(String item, String amount, {bool isNegative = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        children: [
          Text(
            item,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              color: isNegative ? Colors.red[600] : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Helper methods for Y-axis formatting

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoBreakdown(CryptoHoldings cryptoHoldings) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crypto Breakdown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          ...cryptoHoldings.holdings.entries.map((entry) {
            final symbol = entry.key;
            final asset = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '\$${asset.currentValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCryptoDetail('Balance', '${asset.balance.toStringAsFixed(4)} $symbol'),
                      ),
                      Expanded(
                        child: _buildCryptoDetail('Price', '\$${asset.currentPrice.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCryptoDetail('Cost Basis', '\$${asset.costBasis.toStringAsFixed(2)}'),
                      ),
                      Expanded(
                        child: _buildCryptoDetail('Avg Cost', '\$${asset.averageCost.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCryptoDetail(
                          'Unrealized P&L', 
                          '\$${asset.unrealizedGainLoss.toStringAsFixed(2)}',
                          color: asset.unrealizedGainLoss >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCryptoDetail(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _showDownloadOptions(BuildContext context, BalanceSheet balanceSheet) async {
    showDownloadReportOptions(
      context: context,
      onPdfDownload: () => _downloadPdf(context, balanceSheet),
      onExcelDownload: () => _exportToExcel(context, balanceSheet),
    );
  }

  Future<void> _exportToExcel(BuildContext context, BalanceSheet balanceSheet) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate Excel file
      final filePath = await ExcelExportHelper.exportBalanceSheetToExcel(balanceSheet);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file saved successfully!\nTap to open: ${filePath.split('/').last}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open file: $e'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate Excel file: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context, BalanceSheet balanceSheet) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert BalanceSheet to report data format for PDF generation
      final reportData = {
        'summary': {
          'total_assets': balanceSheet.totals.totalAssets,
          'total_liabilities': balanceSheet.totals.totalLiabilities,
          'total_equity': balanceSheet.totals.totalEquity,
        },
        'assets': {
          'current_assets': {
            'crypto_holdings': balanceSheet.assets.currentAssets.cryptoHoldings.totalValue,
            'cash_equivalents': balanceSheet.assets.currentAssets.cashEquivalents,
            'receivables': balanceSheet.assets.currentAssets.receivables.toDouble(),
            'total': balanceSheet.assets.currentAssets.total,
          },
          'non_current_assets': {
            'long_term_investments': balanceSheet.assets.nonCurrentAssets.longTermInvestments,
            'equipment': balanceSheet.assets.nonCurrentAssets.equipment,
            'other': balanceSheet.assets.nonCurrentAssets.other,
            'total': balanceSheet.assets.nonCurrentAssets.total,
          },
          'total': balanceSheet.assets.total,
        },
        'liabilities': {
          'current_liabilities': {
            'accounts_payable': balanceSheet.liabilities.currentLiabilities.accountsPayable.toDouble(),
            'accrued_expenses': balanceSheet.liabilities.currentLiabilities.accruedExpenses,
            'short_term_debt': balanceSheet.liabilities.currentLiabilities.shortTermDebt,
            'tax_liabilities': balanceSheet.liabilities.currentLiabilities.taxLiabilities,
            'total': balanceSheet.liabilities.currentLiabilities.total,
          },
          'long_term_liabilities': {
            'long_term_debt': balanceSheet.liabilities.longTermLiabilities.longTermDebt,
            'deferred_tax': balanceSheet.liabilities.longTermLiabilities.deferredTax,
            'other': balanceSheet.liabilities.longTermLiabilities.other,
            'total': balanceSheet.liabilities.longTermLiabilities.total,
          },
          'total': balanceSheet.liabilities.total,
        },
        'equity': {
          'retained_earnings': balanceSheet.equity.retainedEarnings.toDouble(),
          'unrealized_gains_losses': balanceSheet.equity.unrealizedGainsLosses,
          'total': balanceSheet.equity.total,
        },
      };

      // Generate PDF
      final filePath = await PdfGenerationHelper.generateBalanceSheetPdf(reportData);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully!\nTap to open: ${filePath.split('/').last}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open file: $e'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildPeriodSelector(BalanceSheetState state) {
    if (state.balanceSheets == null || state.balanceSheets!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ReportPeriodSelector<BalanceSheet>(
      items: state.balanceSheets!,
      selectedItem: state.selectedBalanceSheet!,
      formatPeriod: (balanceSheet) {
        final start = balanceSheet.periodStart;
        final end = balanceSheet.periodEnd;
        return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
      },
      onPeriodChanged: (balanceSheet) {
        ref.read(balanceSheetViewModelProvider.notifier).selectBalanceSheet(balanceSheet);
      },
    );
  }

  double _getMaxValue(BalanceSheet balanceSheet) {
    final assets = balanceSheet.totals.totalAssets.abs();
    final liabilities = balanceSheet.totals.totalLiabilities.abs();
    final equity = balanceSheet.totals.totalEquity.abs();
    final maxValue = (assets > liabilities + equity ? assets : liabilities + equity) * 1.1;
    
    // Ensure we never return 0 to prevent chart interval issues
    if (maxValue == 0) {
      return 10000; // Default range for empty data
    }
    
    return maxValue;
  }

  List<BarChartGroupData> _getBarGroups(BalanceSheet balanceSheet) {
    return [
      // Assets Bar
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: balanceSheet.totals.totalAssets.abs(),
            color: const Color(0xFF10B981), // Green for assets
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
      // Liabilities + Equity Bar
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: (balanceSheet.totals.totalLiabilities + balanceSheet.totals.totalEquity).abs(),
            color: const Color(0xFFEF4444), // Red for liabilities + equity
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
    ];
  }

  String _getTooltipText(double x, int rodIndex) {
    switch (x.toInt()) {
      case 0:
        return 'Total Assets';
      case 1:
        return 'Liabilities + Equity';
      default:
        return '';
    }
  }
}
