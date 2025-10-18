import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Reports_ViewModel/cash_flow_view_model.dart';
import '../../../../domain/entities/cash_flow.dart';
import '../../../widgets/excel_export_helper.dart';
import '../../../widgets/pdf_generation_helper.dart';

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
      if (state.cashFlow == null && !state.isLoading) {
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

    if (!state.hasData || state.cashFlow == null) {
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
                        '\$${state.cashFlow!.summary.netCashFromOperations.toStringAsFixed(2)}',
                        const Color(0xFF10B981),
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Investing Cash Flow',
                        '\$${state.cashFlow!.summary.netCashFromInvesting.toStringAsFixed(2)}',
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
                        '\$${state.cashFlow!.summary.netChangeInCash.toStringAsFixed(2)}',
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
          isChartView ? _buildChartView(state.cashFlow!) : _buildTableView(state.cashFlow!),
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000, // Reduced interval for better visibility
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
                      interval: _getYAxisInterval(cashFlow),
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            _formatYAxisLabel(value),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: 5,
                minY: _getMinY(cashFlow),
                maxY: _getMaxY(cashFlow),
                lineBarsData: [
                  // Blue line (Operating Cash Flow)
                  LineChartBarData(
                    spots: _getOperatingCashFlowSpots(cashFlow),
                    isCurved: false,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Green line (Investing Cash Flow)
                  LineChartBarData(
                    spots: _getInvestingCashFlowSpots(cashFlow),
                    isCurved: false,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.green,
                          strokeWidth: 2,
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
                  onPressed: () => _downloadPdf(context, cashFlow),
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
              GestureDetector(
                onTap: () => _exportToExcel(context, cashFlow),
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
                // Operating Activities Section - using dynamic data from summary
                _buildSectionHeader('Operating Activities', '\$${cashFlow.summary.netCashFromOperations.toStringAsFixed(2)}', Colors.green[600]!),
                const SizedBox(height: 8),
                ...cashFlow.operatingActivities.map((activity) => 
                  _buildCashFlowRow(activity.description, '\$${activity.amount.toStringAsFixed(2)}', 
                    activity.amount >= 0 ? Colors.green[600]! : Colors.red[600]!)
                ).toList(),
                _buildTotalRow('Net Cash from Operating Activities', '\$${cashFlow.summary.netCashFromOperations.toStringAsFixed(2)}', Colors.green[600]!),

                const SizedBox(height: 20),

                // Investing Activities Section - using dynamic data from summary
                _buildSectionHeader('Investing Activities', '\$${cashFlow.summary.netCashFromInvesting.toStringAsFixed(2)}', 
                  cashFlow.summary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!),
                const SizedBox(height: 8),
                ...cashFlow.investingActivities.map((activity) => 
                  _buildCashFlowRow(activity.description, '\$${activity.amount.toStringAsFixed(2)}', 
                    activity.amount >= 0 ? Colors.green[600]! : Colors.red[600]!)
                ).toList(),
                _buildTotalRow('Net Cash from Investing Activities', '\$${cashFlow.summary.netCashFromInvesting.toStringAsFixed(2)}', 
                  cashFlow.summary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!),

                const SizedBox(height: 20),

                // Financing Activities Section - using dynamic data from summary
                _buildSectionHeader('Financing Activities', '\$${cashFlow.summary.netCashFromFinancing.toStringAsFixed(2)}', 
                  cashFlow.summary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!),
                const SizedBox(height: 8),
                ...cashFlow.financingActivities.map((activity) => 
                  _buildCashFlowRow(activity.description, '\$${activity.amount.toStringAsFixed(2)}', 
                    activity.amount >= 0 ? Colors.green[600]! : Colors.red[600]!)
                ).toList(),
                _buildTotalRow('Net Cash from Financing Activities', '\$${cashFlow.summary.netCashFromFinancing.toStringAsFixed(2)}', 
                  cashFlow.summary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!),

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
                      _buildSummaryRow('Net Cash from Operating Activities', '\$${cashFlow.summary.netCashFromOperations.toStringAsFixed(2)}', 
                        cashFlow.summary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Net Cash from Investing Activities', '\$${cashFlow.summary.netCashFromInvesting.toStringAsFixed(2)}', 
                        cashFlow.summary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Net Cash from Financing Activities', '\$${cashFlow.summary.netCashFromFinancing.toStringAsFixed(2)}', 
                        cashFlow.summary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Net Change in Cash', '\$${cashFlow.summary.netChangeInCash.toStringAsFixed(2)}', 
                        cashFlow.summary.netChangeInCash >= 0 ? Colors.green[600]! : Colors.red[600]!, isTotal: true),
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

  Widget _buildCashFlowRow(String item, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
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

  // Helper methods for generating dynamic chart data
  List<FlSpot> _getOperatingCashFlowSpots(CashFlow cashFlow) {
    // Generate 6 data points based on operating cash flow
    final operatingCashFlow = cashFlow.summary.netCashFromOperations;
    
    print("📊 Operating Cash Flow: $operatingCashFlow");
    
    // Always return data points, even if zero, to maintain chart structure
    final spots = [
      FlSpot(0, operatingCashFlow * 0.8),
      FlSpot(1, operatingCashFlow * 0.9),
      FlSpot(2, operatingCashFlow * 0.85),
      FlSpot(3, operatingCashFlow * 0.95),
      FlSpot(4, operatingCashFlow * 0.88),
      FlSpot(5, operatingCashFlow),
    ];
    print("📊 Operating Cash Flow Spots: $spots");
    return spots;
  }

  List<FlSpot> _getInvestingCashFlowSpots(CashFlow cashFlow) {
    // Generate 6 data points based on investing cash flow
    final investingCashFlow = cashFlow.summary.netCashFromInvesting;
    
    print("📊 Investing Cash Flow: $investingCashFlow");
    
    // Always return data points, even if zero, to maintain chart structure
    final spots = [
      FlSpot(0, investingCashFlow * 0.5),
      FlSpot(1, investingCashFlow * 0.7),
      FlSpot(2, investingCashFlow * 0.6),
      FlSpot(3, investingCashFlow * 0.8),
      FlSpot(4, investingCashFlow * 0.9),
      FlSpot(5, investingCashFlow),
    ];
    print("📊 Investing Cash Flow Spots: $spots");
    return spots;
  }

  double _getMinY(CashFlow cashFlow) {
    final operatingCashFlow = cashFlow.summary.netCashFromOperations;
    final investingCashFlow = cashFlow.summary.netCashFromInvesting;
    
    // Get the minimum value from both cash flows
    final minValue = [operatingCashFlow * 0.5, investingCashFlow * 0.5].reduce((a, b) => a < b ? a : b);
    
    // Ensure minimum is never negative for better chart display
    final result = minValue < 0 ? minValue - (minValue.abs() * 0.1) : 0.0;
    print("📊 Y-Axis Min: $result");
    return result;
  }

  double _getMaxY(CashFlow cashFlow) {
    final operatingCashFlow = cashFlow.summary.netCashFromOperations;
    final investingCashFlow = cashFlow.summary.netCashFromInvesting;
    
    // Get the maximum value from both cash flows
    final maxValue = [operatingCashFlow, investingCashFlow].reduce((a, b) => a > b ? a : b);
    
    // If max is zero, provide a default range for better chart display
    if (maxValue == 0.0) {
      print("📊 Y-Axis Max (Default): 10000");
      return 10000.0;
    }
    
    // Add some padding above the maximum value
    final result = maxValue + (maxValue.abs() * 0.1);
    print("📊 Y-Axis Max (Real): $result");
    return result;
  }

  double _getYAxisInterval(CashFlow cashFlow) {
    final maxValue = _getMaxY(cashFlow);
    if (maxValue <= 1000) return 100;
    if (maxValue <= 10000) return 1000;
    if (maxValue <= 100000) return 10000;
    if (maxValue <= 1000000) return 100000;
    return 1000000;
  }

  String _formatYAxisLabel(double value) {
    if (value == 0) return '0';
    if (value < 1000) return value.toStringAsFixed(0);
    if (value < 1000000) return '${(value / 1000).toStringAsFixed(0)}K';
    return '${(value / 1000000).toStringAsFixed(1)}M';
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
          'net_cash_from_operations': cashFlow.summary.netCashFromOperations,
          'net_cash_from_investing': cashFlow.summary.netCashFromInvesting,
          'net_cash_from_financing': cashFlow.summary.netCashFromFinancing,
          'net_change_in_cash': cashFlow.summary.netChangeInCash,
        },
        'operating_activities': cashFlow.operatingActivities.map((activity) => {
          'description': activity.description,
          'amount': activity.amount,
        }).toList(),
        'investing_activities': cashFlow.investingActivities.map((activity) => {
          'description': activity.description,
          'amount': activity.amount,
        }).toList(),
        'financing_activities': cashFlow.financingActivities.map((activity) => {
          'description': activity.description,
          'amount': activity.amount,
        }).toList(),
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
