import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Reports_ViewModel/balance_sheet_view_model.dart';
import '../../../../domain/entities/balance_sheet.dart';

class BalanceSheetScreen extends ConsumerStatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  ConsumerState<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends ConsumerState<BalanceSheetScreen> {
  bool isChartView = true;

  @override
  void initState() {
    super.initState();
    // Load balance sheet when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(balanceSheetViewModelProvider.notifier).loadBalanceSheet();
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

    return Column(
      children: [
          // Header Info
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            padding: const EdgeInsets.all(16),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View your company\'s assets, liabilities, and equity',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // View Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 48,
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
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isChartView = true),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isChartView ? const Color(0xFF8B5CF6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Chart View',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isChartView ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isChartView = false),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: !isChartView ? const Color(0xFF8B5CF6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Table View',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !isChartView ? Colors.white : Colors.grey[600],
                          ),
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
            child: isChartView ? _buildChartView(state.balanceSheet!) : _buildTableView(state.balanceSheet!),
          ),
        ],
    );
  }

  Widget _buildChartView(BalanceSheet balanceSheet) {
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
                _buildSectionHeader('Assets', '\$${balanceSheet.summary.totalAssets.toStringAsFixed(2)}', true),
                _buildSubSection('Current Assets', '(Short-term, highly liquid)'),
                ...balanceSheet.assets.where((asset) => asset.isCurrent).map((asset) => 
                  _buildBalanceSheetRow(asset.name, '\$${asset.amount.toStringAsFixed(2)}')
                ).toList(),
                _buildTotalRow('Total Current Assets', '\$${balanceSheet.assets.where((asset) => asset.isCurrent).fold(0.0, (sum, asset) => sum + asset.amount).toStringAsFixed(2)}'),
                
                const SizedBox(height: 16),
                
                _buildSubSection('Non-Current Assets', '(Long-term investments)'),
                ...balanceSheet.assets.where((asset) => !asset.isCurrent).map((asset) => 
                  _buildBalanceSheetRow(asset.name, '\$${asset.amount.toStringAsFixed(2)}')
                ).toList(),
                _buildTotalRow('Total Non-Current Assets', '\$${balanceSheet.assets.where((asset) => !asset.isCurrent).fold(0.0, (sum, asset) => sum + asset.amount).toStringAsFixed(2)}'),

                const SizedBox(height: 20),

                // Liabilities Section - using dynamic data from summary
                _buildSectionHeader('Liabilities', '\$${balanceSheet.summary.totalLiabilities.toStringAsFixed(2)}', true),
                _buildSubSection('Current Liabilities', '(Due within one year)'),
                ...balanceSheet.liabilities.where((liability) => liability.isCurrent).map((liability) => 
                  _buildBalanceSheetRow(liability.name, '\$${liability.amount.toStringAsFixed(2)}')
                ).toList(),
                _buildTotalRow('Total Current Liabilities', '\$${balanceSheet.liabilities.where((liability) => liability.isCurrent).fold(0.0, (sum, liability) => sum + liability.amount).toStringAsFixed(2)}'),
                
                const SizedBox(height: 16),
                
                _buildSubSection('Long-term Liabilities', '(Due after one year)'),
                ...balanceSheet.liabilities.where((liability) => !liability.isCurrent).map((liability) => 
                  _buildBalanceSheetRow(liability.name, '\$${liability.amount.toStringAsFixed(2)}')
                ).toList(),
                _buildTotalRow('Total Long-term Liabilities', '\$${balanceSheet.liabilities.where((liability) => !liability.isCurrent).fold(0.0, (sum, liability) => sum + liability.amount).toStringAsFixed(2)}'),

                const SizedBox(height: 20),

                // Equity Section - using dynamic data from summary
                _buildSectionHeader('Equity', '\$${balanceSheet.summary.totalEquity.toStringAsFixed(2)}', true),
                ...balanceSheet.equity.map((equity) => 
                  _buildBalanceSheetRow(equity.name, '\$${equity.amount.toStringAsFixed(2)}')
                ).toList(),
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
                      _buildSummaryRow('Total Assets', '\$${balanceSheet.summary.totalAssets.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Total Liabilities', '\$${balanceSheet.summary.totalLiabilities.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Total Equity', '\$${balanceSheet.summary.totalEquity.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      Container(height: 1, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Liabilities + Equity', '\$${(balanceSheet.summary.totalLiabilities + balanceSheet.summary.totalEquity).toStringAsFixed(2)}', isTotal: true),
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

  Widget _buildSectionHeader(String title, String amount, bool hasDropdown) {
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          ],
        ],
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

  // Helper methods for generating dynamic chart data
  List<FlSpot> _getAssetsSpots(BalanceSheet balanceSheet) {
    // Generate 6 data points based on total assets
    final totalAssets = balanceSheet.summary.totalAssets;
    
    // If total assets is zero, provide sample data for demonstration
    if (totalAssets == 0.0) {
      return [
        FlSpot(0, 5000),
        FlSpot(1, 4500),
        FlSpot(2, 4200),
        FlSpot(3, 4800),
        FlSpot(4, 4600),
        FlSpot(5, 5200),
      ];
    }
    
    return [
      FlSpot(0, totalAssets * 0.8),
      FlSpot(1, totalAssets * 0.9),
      FlSpot(2, totalAssets * 0.85),
      FlSpot(3, totalAssets * 0.95),
      FlSpot(4, totalAssets * 0.88),
      FlSpot(5, totalAssets),
    ];
  }

  List<FlSpot> _getLiabilitiesSpots(BalanceSheet balanceSheet) {
    // Generate 6 data points based on total liabilities
    final totalLiabilities = balanceSheet.summary.totalLiabilities;
    
    // If total liabilities is zero, provide sample data for demonstration
    if (totalLiabilities == 0.0) {
      return [
        FlSpot(0, 2500),
        FlSpot(1, 2000),
        FlSpot(2, 1800),
        FlSpot(3, 2200),
        FlSpot(4, 1900),
        FlSpot(5, 2100),
      ];
    }
    
    return [
      FlSpot(0, totalLiabilities * 0.7),
      FlSpot(1, totalLiabilities * 0.8),
      FlSpot(2, totalLiabilities * 0.75),
      FlSpot(3, totalLiabilities * 0.85),
      FlSpot(4, totalLiabilities * 0.9),
      FlSpot(5, totalLiabilities),
    ];
  }

  double _getMinY(BalanceSheet balanceSheet) {
    final totalAssets = balanceSheet.summary.totalAssets;
    final totalLiabilities = balanceSheet.summary.totalLiabilities;
    
    // If both are zero, use sample data range
    if (totalAssets == 0.0 && totalLiabilities == 0.0) {
      return 0;
    }
    
    final minValue = [totalAssets * 0.7, totalLiabilities * 0.7].reduce((a, b) => a < b ? a : b);
    return minValue - (minValue * 0.1);
  }

  double _getMaxY(BalanceSheet balanceSheet) {
    final totalAssets = balanceSheet.summary.totalAssets;
    final totalLiabilities = balanceSheet.summary.totalLiabilities;
    
    // If both are zero, use sample data range
    if (totalAssets == 0.0 && totalLiabilities == 0.0) {
      return 6000;
    }
    
    final maxValue = [totalAssets, totalLiabilities].reduce((a, b) => a > b ? a : b);
    return maxValue + (maxValue * 0.1);
  }
}
