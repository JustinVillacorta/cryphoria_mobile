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
    // Load cash flow when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashFlowViewModelProvider.notifier).loadCashFlow();
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

    return Column(
      children: [
        // Professional Header
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF10B981).withOpacity(0.1),
                const Color(0xFF3B82F6).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.1),
                blurRadius: 20,
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF10B981),
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
                  _buildMetricCard(
                    'Operating Cash Flow',
                    '\$${state.cashFlow!.summary.netCashFromOperations.toStringAsFixed(2)}',
                    const Color(0xFF10B981),
                    Icons.trending_up,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    'Investing Cash Flow',
                    '\$${state.cashFlow!.summary.netCashFromInvesting.toStringAsFixed(2)}',
                    const Color(0xFFEF4444),
                    Icons.trending_down,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    'Net Change',
                    '\$${state.cashFlow!.summary.netChangeInCash.toStringAsFixed(2)}',
                    const Color(0xFF3B82F6),
                    Icons.account_balance_wallet,
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
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                      color: isChartView ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isChartView ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
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
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                      color: !isChartView ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: !isChartView ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
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
          Expanded(
            child: isChartView ? _buildChartView(state.cashFlow!) : _buildTableView(state.cashFlow!),
          ),
        ],
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
            height: 300,
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
                      interval: 2500,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value == 0) {
                          return const Text('0', style: TextStyle(color: Colors.grey, fontSize: 10));
                        }
                        return Text(
                          '${(value / 1000).toInt()}K',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 42,
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
                minY: -1500,
                maxY: 5000,
                lineBarsData: [
                  // Blue line (Operating Cash Flow)
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 4000),
                      FlSpot(1, 4200),
                      FlSpot(2, 3800),
                      FlSpot(3, 4500),
                      FlSpot(4, 4100),
                      FlSpot(5, 4300),
                    ],
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
                    spots: [
                      FlSpot(0, -500),
                      FlSpot(1, -800),
                      FlSpot(2, -1200),
                      FlSpot(3, -600),
                      FlSpot(4, -900),
                      FlSpot(5, -700),
                    ],
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

          const SizedBox(height: 20),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple[700],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your financial performance shows a 15% increase in revenue compared to the previous period, with expenses growing at a slower rate of 8%.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
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
              color: color,
              fontWeight: FontWeight.w500,
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, Color color, {bool isTotal = false}) {
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
            color: color,
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
    
    // If operating cash flow is zero, provide sample data for demonstration
    if (operatingCashFlow == 0.0) {
      final spots = [
        FlSpot(0, 4000),
        FlSpot(1, 4200),
        FlSpot(2, 3800),
        FlSpot(3, 4500),
        FlSpot(4, 4100),
        FlSpot(5, 4300),
      ];
      print("📊 Operating Cash Flow Spots (Sample): $spots");
      return spots;
    }
    
    final spots = [
      FlSpot(0, operatingCashFlow * 0.8),
      FlSpot(1, operatingCashFlow * 0.9),
      FlSpot(2, operatingCashFlow * 0.85),
      FlSpot(3, operatingCashFlow * 0.95),
      FlSpot(4, operatingCashFlow * 0.88),
      FlSpot(5, operatingCashFlow),
    ];
    print("📊 Operating Cash Flow Spots (Real): $spots");
    return spots;
  }

  List<FlSpot> _getInvestingCashFlowSpots(CashFlow cashFlow) {
    // Generate 6 data points based on investing cash flow
    final investingCashFlow = cashFlow.summary.netCashFromInvesting;
    
    print("📊 Investing Cash Flow: $investingCashFlow");
    
    // If investing cash flow is zero, provide sample data for demonstration
    if (investingCashFlow == 0.0) {
      final spots = [
        FlSpot(0, -500),
        FlSpot(1, -800),
        FlSpot(2, -1200),
        FlSpot(3, -600),
        FlSpot(4, -900),
        FlSpot(5, -700),
      ];
      print("📊 Investing Cash Flow Spots (Sample): $spots");
      return spots;
    }
    
    final spots = [
      FlSpot(0, investingCashFlow * 0.5),
      FlSpot(1, investingCashFlow * 0.7),
      FlSpot(2, investingCashFlow * 0.6),
      FlSpot(3, investingCashFlow * 0.8),
      FlSpot(4, investingCashFlow * 0.9),
      FlSpot(5, investingCashFlow),
    ];
    print("📊 Investing Cash Flow Spots (Real): $spots");
    return spots;
  }

  double _getMinY(CashFlow cashFlow) {
    final operatingCashFlow = cashFlow.summary.netCashFromOperations;
    final investingCashFlow = cashFlow.summary.netCashFromInvesting;
    
    // If both are zero, use sample data range
    if (operatingCashFlow == 0.0 && investingCashFlow == 0.0) {
      print("📊 Y-Axis Min (Sample): -1500");
      return -1500; // Reasonable range for sample data
    }
    
    final minValue = [operatingCashFlow * 0.5, investingCashFlow * 0.5].reduce((a, b) => a < b ? a : b);
    final result = minValue - (minValue.abs() * 0.1);
    print("📊 Y-Axis Min (Real): $result");
    return result;
  }

  double _getMaxY(CashFlow cashFlow) {
    final operatingCashFlow = cashFlow.summary.netCashFromOperations;
    final investingCashFlow = cashFlow.summary.netCashFromInvesting;
    
    // If both are zero, use sample data range
    if (operatingCashFlow == 0.0 && investingCashFlow == 0.0) {
      print("📊 Y-Axis Max (Sample): 5000");
      return 5000; // Reasonable range for sample data
    }
    
    final maxValue = [operatingCashFlow, investingCashFlow].reduce((a, b) => a > b ? a : b);
    final result = maxValue + (maxValue.abs() * 0.1);
    print("📊 Y-Axis Max (Real): $result");
    return result;
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
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
