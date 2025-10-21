import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:open_file/open_file.dart';
import '../Reports_ViewModel/income_statement_viewmodel.dart';
import '../../../../domain/entities/income_statement.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../widgets/excel_export_helper.dart';
import '../../../widgets/pdf_generation_helper.dart';
import '../../../widgets/download_report_bottom_sheet.dart';
import '../../../widgets/report_period_selector.dart';

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
    // Load income statement data only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(incomeStatementViewModelProvider);
      if (!state.hasData && !state.isLoading) {
        ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final incomeStatementState = ref.watch(incomeStatementViewModelProvider);
    
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
          if (incomeStatementState.hasData)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () => ref.read(incomeStatementViewModelProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(incomeStatementState),
    );
  }

  Widget _buildBody(IncomeStatementState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      );
    }

    if (state.hasError) {
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
              'Error loading income statement data',
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
              onPressed: () {
                ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!state.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Income Statement Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Income statement data will appear here once available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements();
              },
              child: const Text('Refresh'),
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
          if (state.incomeStatements != null && state.incomeStatements!.length > 1)
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
                        Icons.assessment,
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
                            'Income Statement',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Financial performance as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
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
                        'Total Revenue',
                        '\$${state.selectedIncomeStatement!.revenue.totalRevenue.toStringAsFixed(2)}',
                        const Color(0xFF10B981),
                        Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'Total Expenses',
                        '\$${state.selectedIncomeStatement!.expenses.totalExpenses.toStringAsFixed(2)}',
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
                        'Net Income',
                        '\$${state.selectedIncomeStatement!.netIncome.netIncome.toStringAsFixed(2)}',
                        state.selectedIncomeStatement!.netIncome.isProfitable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        state.selectedIncomeStatement!.netIncome.isProfitable ? Icons.trending_up : Icons.trending_down,
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

          const SizedBox(height: 8),

          // Content (Charts or Table)
          if (isChartView)
            _buildChartView(state.selectedIncomeStatement!)
          else
            _buildTableView(state.selectedIncomeStatement!),
          
          const SizedBox(height: 8),
          
          // Metadata
          _buildMetadata(state.selectedIncomeStatement!),
          
          const SizedBox(height: 8),
          
          // Export Buttons
          _buildExportButtons(state.selectedIncomeStatement!),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(IncomeStatementState state) {
    if (state.incomeStatements == null || state.incomeStatements!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ReportPeriodSelector<IncomeStatement>(
      items: state.incomeStatements!,
      selectedItem: state.selectedIncomeStatement!,
      formatPeriod: (statement) {
        final start = statement.periodStart;
        final end = statement.periodEnd;
        return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
      },
      onPeriodChanged: (statement) {
        ref.read(incomeStatementViewModelProvider.notifier).selectIncomeStatement(statement);
      },
    );
  }


  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
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
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


  Widget _buildChartView(IncomeStatement incomeStatement) {
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
                      'Financial Overview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.bar_chart, size: 16, color: Colors.purple[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Charts',
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
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
                const Text(
                  'Revenue vs Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getWaterfallMaxY(incomeStatement),
                      minY: _getWaterfallMinY(incomeStatement),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toStringAsFixed(0)}\n${_getWaterfallTooltipText(group.x.toDouble())}',
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
                            interval: _getWaterfallMaxY(incomeStatement) / 5,
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
                      barGroups: _getWaterfallBarGroups(incomeStatement),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getWaterfallMaxY(incomeStatement) / 5,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(IncomeStatement incomeStatement) {
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
                      'Income Statement Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.table_chart, size: 16, color: Colors.purple[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Table',
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

          // Table Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
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
                const Text(
                  'Financial Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Revenue Section
                _buildTableSection('Revenue', [
                  _buildTableRow('Total Revenue', incomeStatement.revenue.totalRevenue),
                  _buildTableRow('Trading Revenue', incomeStatement.revenue.tradingRevenue),
                  _buildTableRow('Payroll Income', incomeStatement.revenue.payrollIncome),
                  _buildTableRow('Other Income', incomeStatement.revenue.otherIncome),
                ], const Color(0xFF4CAF50)),
                
                const SizedBox(height: 16),
                
                // Expenses Section
                _buildTableSection('Expenses', [
                  _buildTableRow('Total Expenses', incomeStatement.expenses.totalExpenses),
                  _buildTableRow('Transaction Fees', incomeStatement.expenses.transactionFees),
                  _buildTableRow('Trading Losses', incomeStatement.expenses.tradingLosses),
                  _buildTableRow('Operational Expenses', incomeStatement.expenses.operationalExpenses),
                  _buildTableRow('Tax Expenses', incomeStatement.expenses.taxExpenses),
                ], const Color(0xFFF44336)),
                
                const SizedBox(height: 16),
                
                // Profitability Section
                _buildTableSection('Profitability', [
                  _buildTableRow('Gross Profit', incomeStatement.grossProfit.grossProfit),
                  _buildTableRow('Gross Profit Margin', incomeStatement.grossProfit.grossProfitMargin, isPercentage: true),
                  _buildTableRow('Net Income', incomeStatement.netIncome.netIncome),
                  _buildTableRow('Net Profit Margin', incomeStatement.netIncome.netProfitMargin, isPercentage: true),
                ], const Color(0xFF2196F3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection(String title, List<Widget> rows, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  Widget _buildTableRow(String label, double amount, {bool isPercentage = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            isPercentage ? '${amount.toStringAsFixed(1)}%' : '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(IncomeStatement incomeStatement) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetadataRow('Period', '${incomeStatement.periodStart.day}/${incomeStatement.periodStart.month}/${incomeStatement.periodStart.year} - ${incomeStatement.periodEnd.day}/${incomeStatement.periodEnd.month}/${incomeStatement.periodEnd.year}'),
            _buildMetadataRow('Currency', incomeStatement.currency),
            _buildMetadataRow('Generated', '${incomeStatement.generatedAt.day}/${incomeStatement.generatedAt.month}/${incomeStatement.generatedAt.year}'),
            _buildMetadataRow('Transactions Processed', incomeStatement.metadata.transactionCount.toString()),
            _buildMetadataRow('Payroll Entries', incomeStatement.metadata.payrollCount.toString()),
            _buildMetadataRow('Period Length', '${incomeStatement.metadata.periodLengthDays} days'),
            _buildMetadataRow('Primary Revenue Source', incomeStatement.summary.primaryRevenueSource),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(IncomeStatement incomeStatement) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Center(
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showDownloadOptions(context, incomeStatement),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Download Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDownloadOptions(BuildContext context, IncomeStatement incomeStatement) async {
    showDownloadReportOptions(
      context: context,
      onPdfDownload: () => _downloadPdf(context, incomeStatement),
      onExcelDownload: () => _downloadExcel(context, incomeStatement),
    );
  }

  Future<void> _downloadPdf(BuildContext context, IncomeStatement incomeStatement) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate PDF
      final filePath = await PdfGenerationHelper.generateIncomeStatementPdf(incomeStatement);

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

  Future<void> _downloadExcel(BuildContext context, IncomeStatement incomeStatement) async {
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
      final filePath = await ExcelExportHelper.exportIncomeStatementToExcel(incomeStatement);

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

  // Waterfall Chart Helper Methods
  double _getWaterfallMaxY(IncomeStatement incomeStatement) {
    final maxValue = [
      incomeStatement.revenue.totalRevenue,
      incomeStatement.grossProfit.grossProfit,
      incomeStatement.netIncome.netIncome.abs(),
    ].reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2;
  }

  double _getWaterfallMinY(IncomeStatement incomeStatement) {
    // For waterfall, we need negative space for expenses
    final minValue = incomeStatement.expenses.totalExpenses;
    return -minValue * 1.2;
  }

  List<BarChartGroupData> _getWaterfallBarGroups(IncomeStatement incomeStatement) {
    return [
      // 1. Total Revenue (Starting point)
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: incomeStatement.revenue.totalRevenue,
            color: const Color(0xFF10B981), // Green
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
      // 2. Total Expenses (negative bar)
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            fromY: -incomeStatement.expenses.totalExpenses,
            toY: 0,
            color: const Color(0xFFEF4444), // Red
            width: 40,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
        ],
      ),
      // 3. Net Income (Final result)
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            fromY: incomeStatement.netIncome.netIncome < 0 ? incomeStatement.netIncome.netIncome : 0,
            toY: incomeStatement.netIncome.netIncome > 0 ? incomeStatement.netIncome.netIncome : 0,
            color: incomeStatement.netIncome.isProfitable 
              ? const Color(0xFF059669) 
              : const Color(0xFFDC2626),
            width: 45,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ];
  }

  String _getWaterfallLabel(int index) {
    const labels = [
      'Total\nRevenue',
      'Total\nExpenses',
      'Net\nIncome',
    ];
    return labels[index];
  }

  String _getWaterfallTooltipText(double x) {
    const tooltips = [
      'Total Revenue',
      'Total Expenses',
      'Net Income',
    ];
    return tooltips[x.toInt()];
  }
}