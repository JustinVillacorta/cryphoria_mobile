import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Reports_ViewModel/investment_report_viewmodel.dart';
import '../../../../domain/entities/investment_report.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../widgets/excel_export_helper.dart';
import '../../../widgets/pdf_generation_helper.dart';

class InvestmentPerformanceScreen extends ConsumerStatefulWidget {
  const InvestmentPerformanceScreen({super.key});

  @override
  ConsumerState<InvestmentPerformanceScreen> createState() => _InvestmentPerformanceScreenState();
}

class _InvestmentPerformanceScreenState extends ConsumerState<InvestmentPerformanceScreen> {
  bool isChartView = true;

  @override
  void initState() {
    super.initState();
    // Load investment report data only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(investmentReportViewModelProvider);
      if (!state.hasData && !state.isLoading) {
        ref.read(investmentReportViewModelProvider.notifier).loadInvestmentReports();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final investmentReportState = ref.watch(investmentReportViewModelProvider);
    
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
          'Investment Performance',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (investmentReportState.hasData)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () => ref.read(investmentReportViewModelProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(investmentReportState),
    );
  }

  Widget _buildBody(InvestmentReportState state) {
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
              'Error loading investment report data',
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
                ref.read(investmentReportViewModelProvider.notifier).loadInvestmentReports();
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
              Icons.trending_up_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Investment Report Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Investment performance data will appear here once available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(investmentReportViewModelProvider.notifier).loadInvestmentReports();
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(state),
          const SizedBox(height: 20),
          
          // Summary Cards
          _buildSummaryCards(state.selectedInvestmentReport!),
          const SizedBox(height: 20),
          
          // View Toggle
          _buildViewToggle(),
          const SizedBox(height: 20),
          
          // Content (Charts or Table)
          if (isChartView)
            _buildChartView(state.selectedInvestmentReport!)
          else
            _buildTableView(state.selectedInvestmentReport!),
          
          const SizedBox(height: 20),
          
          // LLM Analysis Section
          _buildLlmAnalysis(state.selectedInvestmentReport!),
          
          const SizedBox(height: 20),
          
          // Summary Section
          _buildSummarySection(state.selectedInvestmentReport!),
          
          const SizedBox(height: 20),
          
          // Metadata
          _buildMetadata(state.selectedInvestmentReport!),
          
          const SizedBox(height: 20),
          
          // Export Buttons
          _buildExportButtons(state.selectedInvestmentReport!),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(InvestmentReportState state) {
    if (state.investmentReports == null || state.investmentReports!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
              'Select Period',
                            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<InvestmentReport>(
              value: state.selectedInvestmentReport,
              isExpanded: true,
              items: state.investmentReports!.map((report) {
                final startDate = report.periodStart;
                final endDate = report.periodEnd;
                final periodText = '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
                
                return DropdownMenuItem<InvestmentReport>(
                  value: report,
                  child: Text(periodText),
                );
              }).toList(),
              onChanged: (InvestmentReport? newValue) {
                if (newValue != null) {
                  ref.read(investmentReportViewModelProvider.notifier).selectInvestmentReport(newValue);
                }
              },
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSummaryCards(InvestmentReport investmentReport) {
    return Column(
      children: [
                Row(
                  children: [
                    Expanded(
              child: _buildSummaryCard(
                'Portfolio Performance',
                '\$${investmentReport.portfolioPerformance.totalPortfolioValue.toStringAsFixed(2)}',
                const Color(0xFF8B5CF6),
                Icons.trending_up,
                [
                  'Gains: \$${investmentReport.portfolioPerformance.periodGains.toStringAsFixed(2)}',
                  'Losses: \$${investmentReport.portfolioPerformance.periodLosses.toStringAsFixed(2)}',
                  'Net: \$${investmentReport.portfolioPerformance.netPerformance.toStringAsFixed(2)}',
                  'Performance: ${investmentReport.portfolioPerformance.performancePercentage.toStringAsFixed(1)}%',
                ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
              child: _buildSummaryCard(
                'Asset Allocation',
                '\$${investmentReport.assetAllocation.totalValue.toStringAsFixed(2)}',
                const Color(0xFF2196F3),
                Icons.pie_chart,
                [
                  'Diversification: ${investmentReport.assetAllocation.diversificationScore.toStringAsFixed(1)}',
                  'Assets: ${investmentReport.assetAllocation.byCryptocurrency.length}',
                  'Allocations: ${investmentReport.assetAllocation.allocationPercentages.length}',
                ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
              child: _buildSummaryCard(
                'ROI Analysis',
                '${investmentReport.roiAnalysis.roiPercentage.toStringAsFixed(1)}%',
                const Color(0xFF4CAF50),
                Icons.account_balance_wallet,
                [
                  'Invested: \$${investmentReport.roiAnalysis.totalInvested.toStringAsFixed(2)}',
                  'Current: \$${investmentReport.roiAnalysis.currentValue.toStringAsFixed(2)}',
                  'Returns: \$${investmentReport.roiAnalysis.totalReturns.toStringAsFixed(2)}',
                  'Annualized: ${investmentReport.roiAnalysis.annualizedRoi.toStringAsFixed(1)}%',
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Risk Metrics',
                investmentReport.riskMetrics.riskLevel,
                _getRiskColor(investmentReport.riskMetrics.riskLevel),
                _getRiskIcon(investmentReport.riskMetrics.riskLevel),
                [
                  'Volatility: ${investmentReport.riskMetrics.volatilityScore.toStringAsFixed(1)}',
                  'Concentration: ${investmentReport.riskMetrics.concentrationRisk.toStringAsFixed(1)}%',
                  'Liquidity: ${investmentReport.riskMetrics.liquidityRisk.toStringAsFixed(1)}',
                  'Transactions: ${investmentReport.riskMetrics.transactionFrequency}',
                ],
              ),
                ),
              ],
            ),
      ],
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFF44336);
      case 'MEDIUM':
        return const Color(0xFFFF9800);
      case 'LOW':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'HIGH':
        return Icons.warning;
      case 'MEDIUM':
        return Icons.info;
      case 'LOW':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, List<String> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
                          children: [
                Icon(icon, color: color, size: 20),
                            const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
                          ],
                        ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                detail,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isChartView ? null : () => setState(() => isChartView = true),
                icon: const Icon(Icons.bar_chart),
                label: const Text('Charts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChartView ? const Color(0xFF8B5CF6) : Colors.grey[300],
                  foregroundColor: isChartView ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isChartView ? () => setState(() => isChartView = false) : null,
                icon: const Icon(Icons.table_chart),
                label: const Text('Table'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isChartView ? const Color(0xFF8B5CF6) : Colors.grey[300],
                  foregroundColor: !isChartView ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildChartView(InvestmentReport investmentReport) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
              'Performance Overview',
                      style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [
                    investmentReport.portfolioPerformance.periodGains,
                    investmentReport.portfolioPerformance.periodLosses,
                    investmentReport.portfolioPerformance.netPerformance,
                    investmentReport.roiAnalysis.totalReturns,
                  ].reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                          const titles = ['Gains', 'Losses', 'Net Performance', 'ROI Returns'];
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: investmentReport.portfolioPerformance.periodGains,
                          color: const Color(0xFF4CAF50),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: investmentReport.portfolioPerformance.periodLosses,
                          color: const Color(0xFFF44336),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: investmentReport.portfolioPerformance.netPerformance,
                          color: const Color(0xFF8B5CF6),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: investmentReport.roiAnalysis.totalReturns,
                          color: const Color(0xFF2196F3),
                          width: 20,
                        ),
                      ],
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView(InvestmentReport investmentReport) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text(
              'Investment Report Details',
                  style: TextStyle(
                fontSize: 18,
                    fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Portfolio Performance Section
            _buildTableSection('Portfolio Performance', [
              _buildTableRow('Total Portfolio Value', investmentReport.portfolioPerformance.totalPortfolioValue),
              _buildTableRow('Period Gains', investmentReport.portfolioPerformance.periodGains),
              _buildTableRow('Period Losses', investmentReport.portfolioPerformance.periodLosses),
              _buildTableRow('Net Performance', investmentReport.portfolioPerformance.netPerformance),
              _buildTableRow('Performance %', investmentReport.portfolioPerformance.performancePercentage, isPercentage: true),
              _buildTableRow('Best Performing Asset', investmentReport.portfolioPerformance.bestPerformingAsset ?? 'N/A', isText: true),
              _buildTableRow('Worst Performing Asset', investmentReport.portfolioPerformance.worstPerformingAsset ?? 'N/A', isText: true),
            ], const Color(0xFF8B5CF6)),
            
            const SizedBox(height: 16),
            
            // Asset Allocation Section
            _buildTableSection('Asset Allocation', [
              _buildTableRow('Total Value', investmentReport.assetAllocation.totalValue),
              _buildTableRow('Diversification Score', investmentReport.assetAllocation.diversificationScore),
              _buildTableRow('Number of Assets', investmentReport.assetAllocation.byCryptocurrency.length.toDouble()),
            ], const Color(0xFF2196F3)),
            
            const SizedBox(height: 16),
            
            // ROI Analysis Section
            _buildTableSection('ROI Analysis', [
              _buildTableRow('Total Invested', investmentReport.roiAnalysis.totalInvested),
              _buildTableRow('Current Value', investmentReport.roiAnalysis.currentValue),
              _buildTableRow('Total Returns', investmentReport.roiAnalysis.totalReturns),
              _buildTableRow('ROI %', investmentReport.roiAnalysis.roiPercentage, isPercentage: true),
              _buildTableRow('Annualized ROI', investmentReport.roiAnalysis.annualizedRoi, isPercentage: true),
            ], const Color(0xFF4CAF50)),
            
            const SizedBox(height: 16),
            
            // Risk Metrics Section
            _buildTableSection('Risk Metrics', [
              _buildTableRow('Risk Level', investmentReport.riskMetrics.riskLevel, isText: true),
              _buildTableRow('Volatility Score', investmentReport.riskMetrics.volatilityScore),
              _buildTableRow('Concentration Risk', investmentReport.riskMetrics.concentrationRisk, isPercentage: true),
              _buildTableRow('Liquidity Risk', investmentReport.riskMetrics.liquidityRisk),
              _buildTableRow('Transaction Frequency', investmentReport.riskMetrics.transactionFrequency.toDouble()),
            ], _getRiskColor(investmentReport.riskMetrics.riskLevel)),
          ],
        ),
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

  Widget _buildTableRow(String label, dynamic value, {bool isPercentage = false, bool isText = false}) {
    String displayValue;
    if (isText) {
      displayValue = value.toString();
    } else if (isPercentage) {
      displayValue = '${value.toStringAsFixed(1)}%';
    } else {
      displayValue = '\$${value.toStringAsFixed(2)}';
    }

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
            displayValue,
            style: const TextStyle(
              fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
    );
  }

  Widget _buildLlmAnalysis(InvestmentReport investmentReport) {
    if (investmentReport.llmAnalysis.isEmpty || investmentReport.llmAnalysis.contains('Error:')) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'AI Analysis',
                style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              investmentReport.llmAnalysis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildSummarySection(InvestmentReport investmentReport) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                          const Text(
              'Investment Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Performance Summary', investmentReport.summary.performanceSummary),
            _buildSummaryRow('Risk Assessment', investmentReport.summary.riskAssessment),
            if (investmentReport.summary.topPerformer != null)
              _buildSummaryRow('Top Performer', investmentReport.summary.topPerformer!),
            if (investmentReport.summary.concernAreas != null)
              _buildSummaryRow('Concern Areas', investmentReport.summary.concernAreas!),
            _buildSummaryRow('Investment Status', investmentReport.summary.investmentStatus),
            
            if (investmentReport.summary.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Recommendations',
                            style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...investmentReport.summary.recommendations.map((recommendation) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
              ],
            ),
          ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
              Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                          fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMetadata(InvestmentReport investmentReport) {
    return Card(
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
            _buildMetadataRow('Period', '${investmentReport.periodStart.day}/${investmentReport.periodStart.month}/${investmentReport.periodStart.year} - ${investmentReport.periodEnd.day}/${investmentReport.periodEnd.month}/${investmentReport.periodEnd.year}'),
            _buildMetadataRow('Currency', investmentReport.currency),
            _buildMetadataRow('Generated', '${investmentReport.generatedAt.day}/${investmentReport.generatedAt.month}/${investmentReport.generatedAt.year}'),
            _buildMetadataRow('Transaction Count', investmentReport.metadata.transactionCount.toString()),
            _buildMetadataRow('Historical Transactions', investmentReport.metadata.historicalTransactionCount.toString()),
            _buildMetadataRow('Period Length', '${investmentReport.metadata.periodLengthDays} days'),
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

  Widget _buildExportButtons(InvestmentReport investmentReport) {
    return Row(
        children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadPdf(context, investmentReport),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadExcel(context, investmentReport),
            icon: const Icon(Icons.table_chart),
            label: const Text('Export Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            ),
          ),
        ],
    );
  }

  Future<void> _downloadPdf(BuildContext context, InvestmentReport investmentReport) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert InvestmentReport to report data format for PDF generation
      final reportData = {
        'portfolio_performance': {
          'total_portfolio_value': investmentReport.portfolioPerformance.totalPortfolioValue,
          'period_gains': investmentReport.portfolioPerformance.periodGains,
          'period_losses': investmentReport.portfolioPerformance.periodLosses,
          'net_performance': investmentReport.portfolioPerformance.netPerformance,
          'performance_percentage': investmentReport.portfolioPerformance.performancePercentage,
        },
        'asset_allocation': {
          'total_value': investmentReport.assetAllocation.totalValue,
          'diversification_score': investmentReport.assetAllocation.diversificationScore,
        },
        'roi_analysis': {
          'total_invested': investmentReport.roiAnalysis.totalInvested,
          'current_value': investmentReport.roiAnalysis.currentValue,
          'total_returns': investmentReport.roiAnalysis.totalReturns,
          'roi_percentage': investmentReport.roiAnalysis.roiPercentage,
        },
        'risk_metrics': {
          'risk_level': investmentReport.riskMetrics.riskLevel,
          'volatility_score': investmentReport.riskMetrics.volatilityScore,
          'concentration_risk': investmentReport.riskMetrics.concentrationRisk,
        },
        'period': {
          'start': investmentReport.periodStart.toIso8601String(),
          'end': investmentReport.periodEnd.toIso8601String(),
        },
        'metadata': {
          'transaction_count': investmentReport.metadata.transactionCount,
          'period_length_days': investmentReport.metadata.periodLengthDays,
        },
      };

      // Generate PDF
      final filePath = await PdfGenerationHelper.generateInvestmentPerformancePdf(reportData);

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

  Future<void> _downloadExcel(BuildContext context, InvestmentReport investmentReport) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert InvestmentReport to Excel format
      final excelData = {
        'Summary': {
          'Total Portfolio Value': investmentReport.portfolioPerformance.totalPortfolioValue,
          'Period Gains': investmentReport.portfolioPerformance.periodGains,
          'Period Losses': investmentReport.portfolioPerformance.periodLosses,
          'Net Performance': investmentReport.portfolioPerformance.netPerformance,
          'Performance %': investmentReport.portfolioPerformance.performancePercentage,
          'ROI %': investmentReport.roiAnalysis.roiPercentage,
          'Risk Level': investmentReport.riskMetrics.riskLevel,
        },
        'Portfolio Performance': {
          'Total Portfolio Value': investmentReport.portfolioPerformance.totalPortfolioValue,
          'Period Gains': investmentReport.portfolioPerformance.periodGains,
          'Period Losses': investmentReport.portfolioPerformance.periodLosses,
          'Net Performance': investmentReport.portfolioPerformance.netPerformance,
          'Performance %': investmentReport.portfolioPerformance.performancePercentage,
          'Best Performing Asset': investmentReport.portfolioPerformance.bestPerformingAsset ?? 'N/A',
          'Worst Performing Asset': investmentReport.portfolioPerformance.worstPerformingAsset ?? 'N/A',
        },
        'Asset Allocation': {
          'Total Value': investmentReport.assetAllocation.totalValue,
          'Diversification Score': investmentReport.assetAllocation.diversificationScore,
          'Number of Assets': investmentReport.assetAllocation.byCryptocurrency.length.toDouble(),
        },
        'ROI Analysis': {
          'Total Invested': investmentReport.roiAnalysis.totalInvested,
          'Current Value': investmentReport.roiAnalysis.currentValue,
          'Total Returns': investmentReport.roiAnalysis.totalReturns,
          'ROI %': investmentReport.roiAnalysis.roiPercentage,
          'Annualized ROI': investmentReport.roiAnalysis.annualizedRoi,
        },
        'Risk Metrics': {
          'Risk Level': investmentReport.riskMetrics.riskLevel,
          'Volatility Score': investmentReport.riskMetrics.volatilityScore,
          'Concentration Risk': investmentReport.riskMetrics.concentrationRisk,
          'Liquidity Risk': investmentReport.riskMetrics.liquidityRisk,
          'Transaction Frequency': investmentReport.riskMetrics.transactionFrequency.toDouble(),
        },
      };

      // Generate Excel
      final filePath = await ExcelExportHelper.exportInvestmentPerformanceToExcel(excelData);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel saved to: $filePath'),
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
            content: Text('Failed to generate Excel: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}