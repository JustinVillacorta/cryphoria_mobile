import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Reports_ViewModel/portfolio_view_model.dart';
import '../../../../domain/entities/portfolio.dart';

class IncomeStatementScreen extends ConsumerStatefulWidget {
  const IncomeStatementScreen({super.key});

  @override
  ConsumerState<IncomeStatementScreen> createState() => _IncomeStatementScreenState();
}

class _IncomeStatementScreenState extends ConsumerState<IncomeStatementScreen> {
  bool isChartView = true;

  @override
  void initState() {
    super.initState();
    // Load portfolio data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioViewModelProvider.notifier).loadPortfolioValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioViewModelProvider);
    
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
          'Income Statement',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (portfolioState.hasData)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () => ref.read(portfolioViewModelProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(portfolioState),
    );
  }

  Widget _buildBody(PortfolioState state) {
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
              'Error loading portfolio data',
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
              onPressed: () => ref.read(portfolioViewModelProvider.notifier).refresh(),
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

    if (!state.hasData || state.portfolio == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No portfolio data available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate portfolio data to view income statement',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(portfolioViewModelProvider.notifier).refresh(),
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
                const Color(0xFF3B82F6).withOpacity(0.1),
                const Color(0xFF8B5CF6).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
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
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bar_chart,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Income Statement',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Revenue and expenses as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
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
                    'Revenue',
                    '\$${state.portfolio!.totalValue.abs().toStringAsFixed(2)}',
                    const Color(0xFF10B981),
                    Icons.trending_up,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    'Expenses',
                    '\$0.00',
                    const Color(0xFFEF4444),
                    Icons.trending_down,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    'Net Income',
                    '\$${state.portfolio!.totalValue.abs().toStringAsFixed(2)}',
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
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                      color: isChartView ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isChartView ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
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
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                      color: !isChartView ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: !isChartView ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
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
          child: isChartView ? _buildChartView(state.portfolio!) : _buildTableView(state.portfolio!),
        ),
      ],
    );
  }

  Widget _buildChartView(Portfolio portfolio) {
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
                      interval: 2500,
                      getTitlesWidget: (double value, TitleMeta meta) {
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
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: _getMinY(portfolio),
                maxY: _getMaxY(portfolio),
                lineBarsData: [
                  // Blue line (Portfolio Value)
                  LineChartBarData(
                    spots: _getPortfolioValueSpots(portfolio),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.8),
                        Colors.blue.withOpacity(0.8),
                      ],
                    ),
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
                  // Green line (Individual Holdings)
                  LineChartBarData(
                    spots: _getHoldingsSpots(portfolio),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.8),
                        Colors.green.withOpacity(0.8),
                      ],
                    ),
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
                  onPressed: () {},
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

  Widget _buildTableView(Portfolio portfolio) {
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
                    Icon(Icons.bar_chart, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    const Text(
                      'Income Statement',
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

          // Income Statement Table
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
                // Table Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF3F4F6)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Income Statement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.file_download,
                            color: Colors.green[600],
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Export to Excel',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Date
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
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
                ),

                const SizedBox(height: 20),

                // Income Statement Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Revenue Section
                      _buildIncomeStatementRow(
                        'REVENUE',
                        '\$${portfolio.totalValue.abs().toStringAsFixed(2)}',
                        isHeader: true,
                        backgroundColor: Colors.green[50],
                      ),

                      const SizedBox(height: 20),

                      // Expenses Section
                      _buildIncomeStatementRow(
                        'EXPENSES',
                        '\$0.00',
                        isHeader: true,
                        backgroundColor: Colors.red[50],
                      ),

                      const SizedBox(height: 20),

                      // Net Income Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: _buildIncomeStatementRow(
                          'NET INCOME',
                          '\$${portfolio.totalValue.abs().toStringAsFixed(2)}',
                          isHeader: true,
                          backgroundColor: Colors.blue[50],
                        ),
                      ),
                    ],
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
                  onPressed: () {},
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



  Widget _buildIncomeStatementRow(
    String item, 
    String amount, {
    bool isHeader = false,
    bool isSubItem = false,
    Color? backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSubItem ? 40 : 20,
        vertical: isHeader ? 16 : 8,
      ),
      decoration: backgroundColor != null 
        ? BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          )
        : null,
      child: Row(
        children: [
          Text(
            item,
            style: TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
              color: isHeader ? Colors.black87 : Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
              color: isHeader ? Colors.black87 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }


  List<FlSpot> _getPortfolioValueSpots(Portfolio portfolio) {
    // Generate dynamic chart data based on portfolio value
    final totalValue = portfolio.totalValue.abs();
    
    // If total value is zero, provide sample data for demonstration
    if (totalValue == 0.0) {
      return [
        FlSpot(0, 50000),
        FlSpot(1, 45000),
        FlSpot(2, 55000),
        FlSpot(3, 40000),
        FlSpot(4, 60000),
        FlSpot(5, 52000),
      ];
    }
    
    return [
      FlSpot(0, totalValue * 0.8),
      FlSpot(1, totalValue * 0.7),
      FlSpot(2, totalValue * 0.9),
      FlSpot(3, totalValue * 0.6),
      FlSpot(4, totalValue * 1.0),
      FlSpot(5, totalValue * 0.85),
    ];
  }

  List<FlSpot> _getHoldingsSpots(Portfolio portfolio) {
    // Generate dynamic chart data based on individual holdings
    if (portfolio.breakdown.isNotEmpty) {
      final avgHoldingValue = portfolio.breakdown.fold(0.0, (sum, holding) => sum + holding.value.abs()) / portfolio.breakdown.length;
      return [
        FlSpot(0, avgHoldingValue * 0.8),
        FlSpot(1, avgHoldingValue * 0.7),
        FlSpot(2, avgHoldingValue * 0.9),
        FlSpot(3, avgHoldingValue * 0.6),
        FlSpot(4, avgHoldingValue * 0.95),
        FlSpot(5, avgHoldingValue * 0.85),
      ];
    }
    
    // If no holdings, provide sample data for demonstration
    return [
      FlSpot(0, 10000),
      FlSpot(1, 8000),
      FlSpot(2, 12000),
      FlSpot(3, 7000),
      FlSpot(4, 15000),
      FlSpot(5, 11000),
    ];
  }

  double _getMinY(Portfolio portfolio) {
    final totalValue = portfolio.totalValue.abs();
    final avgHoldingValue = portfolio.breakdown.isNotEmpty 
        ? portfolio.breakdown.fold(0.0, (sum, holding) => sum + holding.value.abs()) / portfolio.breakdown.length
        : 0.0;
    final minValue = [totalValue * 0.5, avgHoldingValue * 0.5].reduce((a, b) => a < b ? a : b);
    return minValue - (minValue * 0.1);
  }

  double _getMaxY(Portfolio portfolio) {
    final totalValue = portfolio.totalValue.abs();
    final avgHoldingValue = portfolio.breakdown.isNotEmpty 
        ? portfolio.breakdown.fold(0.0, (sum, holding) => sum + holding.value.abs()) / portfolio.breakdown.length
        : 0.0;
    final maxValue = [totalValue, avgHoldingValue].reduce((a, b) => a > b ? a : b);
    return maxValue + (maxValue * 0.1);
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
}
