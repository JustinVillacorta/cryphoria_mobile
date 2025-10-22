import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:open_file/open_file.dart';
import '../Reports_ViewModel/cash_flow_view_model.dart';
import '../../../../domain/entities/cash_flow.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_period_selector.dart';

class CashFlowScreen extends ConsumerStatefulWidget {
  const CashFlowScreen({super.key});

  @override
  ConsumerState<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends ConsumerState<CashFlowScreen> {
  bool isChartView = true;

  @override
  void initState() {
    super.initState();
    // Load cash flow only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(cashFlowViewModelProvider);
      if (state.selectedCashFlow == null && !state.isLoading) {
        ref.read(cashFlowViewModelProvider.notifier).loadCashFlow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cashFlowState = ref.watch(cashFlowViewModelProvider);
    
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
          'Cash Flow',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (cashFlowState.hasData)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(cashFlowState),
    );
  }

  Widget _buildBody(CashFlowState state) {
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
              'Error loading cash flow',
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
              onPressed: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
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

    if (!state.hasData || state.selectedCashFlow == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No cash flow data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a cash flow report to view data',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
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
          if (state.cashFlowListResponse != null && state.cashFlowListResponse!.cashFlowStatements.length > 1)
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.trending_up,
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
                            'Cash Flow Statement',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cash movements as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
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
                        'Operating Cash Flow',
                        '\$${state.selectedCashFlow!.cashSummary.netCashFromOperations.toStringAsFixed(2)}',
                        const Color(0xFF10B981),
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Investing Cash Flow',
                        '\$${state.selectedCashFlow!.cashSummary.netCashFromInvesting.toStringAsFixed(2)}',
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
                        'Net Change',
                        '\$${state.selectedCashFlow!.cashSummary.netChangeInCash.toStringAsFixed(2)}',
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
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
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
          isChartView ? _buildChartView(state.selectedCashFlow!) : _buildTableView(state.selectedCashFlow!),
        ],
      ),
    );
  }

  Widget _buildChartView(CashFlow cashFlow) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Filter and Report Type
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
                    const Text(
                      'Daily Report',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.filter_list, size: 16, color: Colors.purple[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart Container
          Container(
            height: 320,
            padding: const EdgeInsets.all(20),
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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getWaterfallMaxY(cashFlow),
                minY: _getWaterfallMinY(cashFlow),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      // Use only fields present in API response
                      String tooltipText;
                      double tooltipValue;
                      
                      switch (group.x.toInt()) {
                        case 0: // Beginning Cash
                          tooltipText = 'Beginning Cash';
                          tooltipValue = cashFlow.cashSummary.beginningCash;
                          break;
                        case 1: // Operating Activities
                          tooltipText = 'Operating Activities';
                          tooltipValue = cashFlow.cashSummary.netCashFromOperations;
                          break;
                        case 2: // Investing Activities
                          tooltipText = 'Investing Activities';
                          tooltipValue = cashFlow.cashSummary.netCashFromInvesting;
                          break;
                        case 3: // Financing Activities
                          tooltipText = 'Financing Activities';
                          tooltipValue = cashFlow.cashSummary.netCashFromFinancing;
                          break;
                        case 4: // Ending Cash
                          tooltipText = 'Ending Cash';
                          tooltipValue = cashFlow.cashSummary.endingCash;
                          break;
                        default:
                          tooltipText = 'Unknown';
                          tooltipValue = rod.toY;
                      }
                      
                      return BarTooltipItem(
                        '$tooltipText\n\$${tooltipValue.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getWaterfallLabel(value.toInt()),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: _getWaterfallMaxY(cashFlow) > 0 ? _getWaterfallMaxY(cashFlow) / 5 : 1000,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '\$${(value / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _getWaterfallBarGroups(cashFlow),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getWaterfallMaxY(cashFlow) > 0 ? _getWaterfallMaxY(cashFlow) / 5 : 1000,
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


          // Action Buttons
          Row(
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
                  onPressed: () => _showDownloadOptions(context, cashFlow),
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTableView(CashFlow cashFlow) {
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
                    Icon(Icons.trending_up, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Cash Flow',
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

          // Cash Flow Statement Table
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
                // Operating Activities Section - using only cash_summary data
                _buildSectionHeader('Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
                  cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!),
                const SizedBox(height: 8),
                _buildTotalRow('Net Cash from Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
                  cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!),

                const SizedBox(height: 20),

                // Investing Activities Section - using only cash_summary data
                _buildSectionHeader('Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
                  cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!),
                const SizedBox(height: 8),
                _buildTotalRow('Net Cash from Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
                  cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!),

                const SizedBox(height: 20),

                // Financing Activities Section - using only cash_summary data
                _buildSectionHeader('Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
                  cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!),
                const SizedBox(height: 8),
                _buildTotalRow('Net Cash from Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
                  cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!),

                const SizedBox(height: 20),

                // Summary Section - using only cash_summary data
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
                      _buildSummaryRow('Beginning Cash', '\$${cashFlow.cashSummary.beginningCash.toStringAsFixed(2)}', Colors.blue[600]!),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Net Cash from Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
                        cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Net Cash from Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
                        cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Net Cash from Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
                        cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Net Change in Cash', '\$${cashFlow.cashSummary.netChangeInCash.toStringAsFixed(2)}', 
                        cashFlow.cashSummary.netChangeInCash >= 0 ? Colors.green[600]! : Colors.red[600]!, isTotal: true),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Ending Cash', '\$${cashFlow.cashSummary.endingCash.toStringAsFixed(2)}', Colors.blue[600]!, isTotal: true),
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

  Widget _buildSectionHeader(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, Color color, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // Waterfall Chart Helper Methods - Using Real Data Only
  double _getWaterfallMaxY(CashFlow cashFlow) {
    // Use only fields present in API response
    final maxValue = [
      cashFlow.cashSummary.beginningCash,
      cashFlow.cashSummary.endingCash,
    ].reduce((a, b) => a > b ? a : b);
    
    // Ensure we never return 0 to prevent chart interval issues
    if (maxValue == 0) {
      return 10000; // Default range for empty data
    }
    
    return maxValue * 1.2;
  }

  double _getWaterfallMinY(CashFlow cashFlow) {
    // Use only fields present in API response
    final minValue = [
      cashFlow.cashSummary.netCashFromOperations,
      cashFlow.cashSummary.netCashFromInvesting,
      cashFlow.cashSummary.netCashFromFinancing,
    ].reduce((a, b) => a < b ? a : b);
    return minValue < 0 ? minValue * 1.2 : 0.0;
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDownloadOptions(BuildContext context, CashFlow cashFlow) async {
    showDownloadReportOptions(
      context: context,
      onPdfDownload: () => _downloadPdf(context, cashFlow),
      onExcelDownload: () => _exportToExcel(context, cashFlow),
    );
  }

  Future<void> _exportToExcel(BuildContext context, CashFlow cashFlow) async {
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
      final filePath = await ExcelExportHelper.exportCashFlowToExcel(cashFlow);

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

  Future<void> _downloadPdf(BuildContext context, CashFlow cashFlow) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert CashFlow to report data format for PDF generation
      final reportData = {
        'summary': {
          'net_cash_from_operations': cashFlow.cashSummary.netCashFromOperations,
          'net_cash_from_investing': cashFlow.cashSummary.netCashFromInvesting,
          'net_cash_from_financing': cashFlow.cashSummary.netCashFromFinancing,
          'net_change_in_cash': cashFlow.cashSummary.netChangeInCash,
        },
        'operating_activities': [
          {'description': 'Cash Receipts', 'amount': cashFlow.operatingActivities.cashReceipts.total},
          {'description': 'Cash Payments', 'amount': cashFlow.operatingActivities.cashPayments.total},
        ],
        'investing_activities': [
          {'description': 'Cash Receipts', 'amount': cashFlow.investingActivities.cashReceipts.total},
          {'description': 'Cash Payments', 'amount': cashFlow.investingActivities.cashPayments.total},
        ],
        'financing_activities': [
          {'description': 'Cash Receipts', 'amount': cashFlow.financingActivities.cashReceipts.total},
          {'description': 'Cash Payments', 'amount': cashFlow.financingActivities.cashPayments.total},
        ],
      };

      // Generate PDF
      final filePath = await PdfGenerationHelper.generateCashFlowPdf(reportData);

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

  Widget _buildPeriodSelector(CashFlowState state) {
    final cashFlowStatements = state.cashFlowListResponse!.cashFlowStatements;
    
    return ReportPeriodSelector<CashFlow>(
      items: cashFlowStatements,
      selectedItem: state.selectedCashFlow!,
      formatPeriod: (cashFlow) {
        final start = DateTime.parse(cashFlow.periodStart.toIso8601String());
        final end = DateTime.parse(cashFlow.periodEnd.toIso8601String());
        return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
      },
      onPeriodChanged: (cashFlow) {
        ref.read(cashFlowViewModelProvider.notifier).selectCashFlow(cashFlow);
      },
    );
  }

  // Waterfall Chart Helper Methods
  List<BarChartGroupData> _getWaterfallBarGroups(CashFlow cashFlow) {
    // Use only the fields that are present in the API response
    final beginningCash = cashFlow.cashSummary.beginningCash;
    final operatingFlow = cashFlow.cashSummary.netCashFromOperations;
    final investingFlow = cashFlow.cashSummary.netCashFromInvesting;
    final financingFlow = cashFlow.cashSummary.netCashFromFinancing;
    final endingCash = cashFlow.cashSummary.endingCash;
    
    // Calculate cumulative positions for proper waterfall effect
    final afterOperating = beginningCash + operatingFlow;
    final afterInvesting = afterOperating + investingFlow;
    final afterFinancing = afterInvesting + financingFlow;
    
    return [
      // 1. Beginning Cash (Starting point)
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: beginningCash,
            color: const Color(0xFF2196F3), // Blue
            width: 45,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
      // 2. Operating Activities (shows change from beginning)
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            fromY: beginningCash,
            toY: afterOperating,
            color: operatingFlow >= 0 
              ? const Color(0xFF10B981) // Green if positive
              : const Color(0xFFEF4444), // Red if negative
            width: 40,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      // 3. Investing Activities (shows change from after operating)
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            fromY: afterOperating,
            toY: afterInvesting,
            color: investingFlow >= 0 
              ? const Color(0xFF10B981) // Green if positive
              : const Color(0xFFEF4444), // Red if negative
            width: 40,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      // 4. Financing Activities (shows change from after investing)
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            fromY: afterInvesting,
            toY: afterFinancing,
            color: financingFlow >= 0 
              ? const Color(0xFF10B981) // Green if positive
              : const Color(0xFFEF4444), // Red if negative
            width: 40,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      // 5. Ending Cash (Final result - should match afterFinancing)
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: endingCash,
            color: const Color(0xFF2196F3), // Blue
            width: 45,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
    ];
  }

  String _getWaterfallLabel(int index) {
    const labels = [
      'Beginning\nCash',
      'Operating\nActivities',
      'Investing\nActivities',
      'Financing\nActivities',
      'Ending\nCash',
    ];
    return labels[index];
  }
}
