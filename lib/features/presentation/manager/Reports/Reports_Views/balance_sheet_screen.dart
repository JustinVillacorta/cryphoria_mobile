import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Reports_ViewModel/balance_sheet_view_model.dart';
import '../../../../domain/entities/balance_sheet.dart';
import '../../../widgets/excel_export_helper.dart';
import '../../../widgets/pdf_generation_helper.dart';

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
  
  // Cached chart data to avoid recalculation
  List<FlSpot>? _cachedAssetsSpots;
  List<FlSpot>? _cachedLiabilitiesSpots;
  double? _cachedMinY;
  double? _cachedMaxY;
  BalanceSheet? _lastBalanceSheet;

  @override
  void initState() {
    super.initState();
    // Load balance sheet only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(balanceSheetViewModelProvider);
      if (state.balanceSheet == null && !state.isLoading) {
        ref.read(balanceSheetViewModelProvider.notifier).loadBalanceSheet();
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

    if (!state.hasData || state.balanceSheet == null) {
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
                        '\$${state.balanceSheet!.totals.totalAssets.toStringAsFixed(2)}',
                        const Color(0xFF10B981),
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Total Liabilities',
                        '\$${state.balanceSheet!.totals.totalLiabilities.toStringAsFixed(2)}',
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
                        '\$${state.balanceSheet!.totals.totalEquity.toStringAsFixed(2)}',
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
          isChartView ? _buildChartView(state.balanceSheet!) : _buildTableView(state.balanceSheet!),
        ],
      ),
    );
  }

  Widget _buildChartView(BalanceSheet balanceSheet) {
    return Column(
        children: [
        // Professional Chart Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Performance Trend',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Assets vs Liabilities over time',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.purple[600]),
                        const SizedBox(width: 6),
                        Text(
                          'Monthly',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.purple[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Professional Chart Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 350,
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('Jan', style: style);
                            break;
                          case 1:
                            text = const Text('Feb', style: style);
                            break;
                          case 2:
                            text = const Text('Mar', style: style);
                            break;
                          case 3:
                            text = const Text('Apr', style: style);
                            break;
                          case 4:
                            text = const Text('May', style: style);
                            break;
                          case 5:
                            text = const Text('Jun', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _getYAxisInterval(balanceSheet),
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            _formatYAxisLabel(value),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: _getMinY(balanceSheet),
                maxY: _getMaxY(balanceSheet),
                lineBarsData: [
                  // Blue line (Assets)
                  LineChartBarData(
                    spots: _getAssetsSpots(balanceSheet),
                    isCurved: false,
                    color: Colors.blue,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.blue,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Green line (Liabilities)
                  LineChartBarData(
                    spots: _getLiabilitiesSpots(balanceSheet),
                    isCurved: false,
                    color: Colors.green,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.green,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          ),

          const SizedBox(height: 20),

        // Professional Summary Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.05),
                const Color(0xFF3B82F6).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Financial Insights',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Your balance sheet shows a healthy financial position with assets exceeding liabilities, indicating strong financial stability and growth potential.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),

          const SizedBox(height: 20),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
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
                  onPressed: () => _downloadPdf(context, balanceSheet),
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
              GestureDetector(
                onTap: () => _exportToExcel(context, balanceSheet),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download, size: 14, color: Colors.green[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Export to Excel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  _buildBalanceSheetRow('Cash Equivalents', '\$${balanceSheet.assets.currentAssets.cashEquivalents.toStringAsFixed(2)}'),
                  _buildBalanceSheetRow('Receivables', '\$${balanceSheet.assets.currentAssets.receivables.toStringAsFixed(2)}'),
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
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Balance Sheet is balanced',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                      ),
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
  String _formatYAxisLabel(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  double _getYAxisInterval(BalanceSheet balanceSheet) {
    final maxValue = _getMaxY(balanceSheet);
    if (maxValue <= 1000) return 100;
    if (maxValue <= 10000) return 1000;
    if (maxValue <= 100000) return 10000;
    if (maxValue <= 1000000) return 100000;
    return 1000000;
  }

  // Helper methods for generating dynamic chart data with caching
  List<FlSpot> _getAssetsSpots(BalanceSheet balanceSheet) {
    // Use cached data if available and balance sheet hasn't changed
    if (_cachedAssetsSpots != null && _lastBalanceSheet == balanceSheet) {
      return _cachedAssetsSpots!;
    }
    
    // Generate 6 data points based on total assets
    final totalAssets = balanceSheet.totals.totalAssets;
    
    // If total assets is zero, return empty data
    if (totalAssets == 0.0) {
      _cachedAssetsSpots = [];
      _lastBalanceSheet = balanceSheet;
      return [];
    }
    
    _cachedAssetsSpots = [
      FlSpot(0, totalAssets * 0.8),
      FlSpot(1, totalAssets * 0.9),
      FlSpot(2, totalAssets * 0.85),
      FlSpot(3, totalAssets * 0.95),
      FlSpot(4, totalAssets * 0.88),
      FlSpot(5, totalAssets),
    ];
    _lastBalanceSheet = balanceSheet;
    return _cachedAssetsSpots!;
  }

  List<FlSpot> _getLiabilitiesSpots(BalanceSheet balanceSheet) {
    // Use cached data if available and balance sheet hasn't changed
    if (_cachedLiabilitiesSpots != null && _lastBalanceSheet == balanceSheet) {
      return _cachedLiabilitiesSpots!;
    }
    
    // Generate 6 data points based on total liabilities
    final totalLiabilities = balanceSheet.totals.totalLiabilities;
    
    // If total liabilities is zero, return empty data
    if (totalLiabilities == 0.0) {
      _cachedLiabilitiesSpots = [];
      _lastBalanceSheet = balanceSheet;
      return [];
    }
    
    _cachedLiabilitiesSpots = [
      FlSpot(0, totalLiabilities * 0.7),
      FlSpot(1, totalLiabilities * 0.8),
      FlSpot(2, totalLiabilities * 0.75),
      FlSpot(3, totalLiabilities * 0.85),
      FlSpot(4, totalLiabilities * 0.9),
      FlSpot(5, totalLiabilities),
    ];
    _lastBalanceSheet = balanceSheet;
    return _cachedLiabilitiesSpots!;
  }

  double _getMinY(BalanceSheet balanceSheet) {
    // Use cached data if available and balance sheet hasn't changed
    if (_cachedMinY != null && _lastBalanceSheet == balanceSheet) {
      return _cachedMinY!;
    }
    
    final totalAssets = balanceSheet.totals.totalAssets;
    final totalLiabilities = balanceSheet.totals.totalLiabilities;
    
    // If both are zero, return 0 for empty chart
    if (totalAssets == 0.0 && totalLiabilities == 0.0) {
      _cachedMinY = 0.0;
      _lastBalanceSheet = balanceSheet;
      return 0;
    }
    
    final minValue = [totalAssets * 0.7, totalLiabilities * 0.7].reduce((a, b) => a < b ? a : b);
    _cachedMinY = minValue - (minValue * 0.1);
    _lastBalanceSheet = balanceSheet;
    return _cachedMinY!;
  }

  double _getMaxY(BalanceSheet balanceSheet) {
    // Use cached data if available and balance sheet hasn't changed
    if (_cachedMaxY != null && _lastBalanceSheet == balanceSheet) {
      return _cachedMaxY!;
    }
    
    final totalAssets = balanceSheet.totals.totalAssets;
    final totalLiabilities = balanceSheet.totals.totalLiabilities;
    
    // If both are zero, return 100 for empty chart
    if (totalAssets == 0.0 && totalLiabilities == 0.0) {
      _cachedMaxY = 100.0;
      _lastBalanceSheet = balanceSheet;
      return 100;
    }
    
    final maxValue = [totalAssets, totalLiabilities].reduce((a, b) => a > b ? a : b);
    _cachedMaxY = maxValue + (maxValue * 0.1);
    _lastBalanceSheet = balanceSheet;
    return _cachedMaxY!;
  }

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
            content: Text('Excel file saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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
            content: Text('PDF saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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
}
