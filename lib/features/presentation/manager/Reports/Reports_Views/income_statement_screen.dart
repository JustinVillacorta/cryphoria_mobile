import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Reports_ViewModel/income_statement_viewmodel.dart';
import '../../../../domain/entities/income_statement.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_period_selector.dart';
import '../../../widgets/reports/report_screen_layout.dart';
import '../../../widgets/reports/report_header_card.dart';
import '../../../widgets/reports/report_view_toggle.dart';
import '../../../widgets/reports/report_action_buttons.dart';
import '../../../widgets/reports/report_state_widgets.dart';
import '../../../widgets/reports/report_download_handler.dart';
import '../../../widgets/skeletons/reports_skeleton.dart';

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

    return ReportScreenLayout(
      title: 'Income Statement',
      hasData: incomeStatementState.hasData,
      isLoading: incomeStatementState.isLoading,
      onRefresh: () => ref.read(incomeStatementViewModelProvider.notifier).refresh(),
      builder: (context, responsive) => _buildBody(incomeStatementState, responsive),
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildBody(IncomeStatementState state, ResponsiveInfo responsive) {
    if (state.isLoading) {
      return const ReportsSkeleton();
    }

    if (state.hasError) {
      return ReportErrorState(
        title: 'Error loading income statement',
        message: state.error!,
        onRetry: () => ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    if (!state.hasData) {
      return ReportEmptyState(
        title: 'No income statement available',
        message: 'Income statement data will appear here once available',
        icon: Icons.assessment_outlined,
        onAction: () => ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: responsive.isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          if (state.incomeStatements != null && state.incomeStatements!.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: _buildPeriodSelector(state),
            ),

          SizedBox(height: responsive.isSmallScreen ? 12 : 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportHeaderCard(
              title: 'Income Statement',
              subtitle: 'Financial performance as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              icon: Icons.assessment_outlined,
              metrics: [
                MetricData(
                  title: 'Total Revenue',
                  value: '\$${state.selectedIncomeStatement!.revenue.totalRevenue.toStringAsFixed(2)}',
                  color: const Color(0xFF10B981),
                  icon: Icons.trending_up,
                ),
                MetricData(
                  title: 'Total Expenses',
                  value: '\$${state.selectedIncomeStatement!.expenses.totalExpenses.toStringAsFixed(2)}',
                  color: const Color(0xFFEF4444),
                  icon: Icons.trending_down,
                ),
                MetricData(
                  title: 'Net Income',
                  value: '\$${state.selectedIncomeStatement!.netIncome.netIncome.toStringAsFixed(2)}',
                  color: state.selectedIncomeStatement!.netIncome.isProfitable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  icon: state.selectedIncomeStatement!.netIncome.isProfitable ? Icons.trending_up : Icons.trending_down,
                ),
              ],
              isSmallScreen: responsive.isSmallScreen,
              isTablet: responsive.isTablet,
              isDesktop: responsive.isDesktop,
            ),
          ),

          SizedBox(height: responsive.isSmallScreen ? 16 : 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportViewToggle(
              isChartView: isChartView,
              onToggle: (view) => setState(() => isChartView = view),
              isSmallScreen: responsive.isSmallScreen,
              isTablet: responsive.isTablet,
            ),
          ),

          SizedBox(height: responsive.isSmallScreen ? 16 : 20),

          isChartView 
            ? _buildChartView(state.selectedIncomeStatement!, responsive)
            : _buildTableView(state.selectedIncomeStatement!, responsive),

          SizedBox(height: responsive.isSmallScreen ? 16 : 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: _buildMetadata(state.selectedIncomeStatement!, responsive),
          ),

          SizedBox(height: responsive.isSmallScreen ? 20 : 24),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportActionButtons(
              onClose: () => Navigator.pop(context),
              onDownload: () => _showDownloadOptions(context, state.selectedIncomeStatement!),
              isSmallScreen: responsive.isSmallScreen,
              isTablet: responsive.isTablet,
            ),
          ),

          SizedBox(height: responsive.isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildChartView(IncomeStatement incomeStatement, ResponsiveInfo responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: Container(
        height: responsive.isDesktop ? 420 : responsive.isTablet ? 400 : 380,
        padding: EdgeInsets.all(responsive.isDesktop ? 28 : responsive.isTablet ? 24 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue vs Expenses',
              style: GoogleFonts.inter(
                fontSize: responsive.isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: responsive.isSmallScreen ? 16 : 20),
            Expanded(
              child: RepaintBoundary(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getWaterfallMaxY(incomeStatement),
                    minY: _getWaterfallMinY(incomeStatement),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => const Color(0xFF1A1A1A),
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '\$${rod.toY.abs().toStringAsFixed(0)}\n${_getWaterfallTooltipText(group.x.toDouble())}',
                            GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1.4,
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
                            final style = GoogleFonts.inter(
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                              fontSize: responsive.isTablet ? 14 : 13,
                              height: 1.2,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getWaterfallLabel(value.toInt()),
                                style: style,
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                          reservedSize: responsive.isTablet ? 50 : 45,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: responsive.isTablet ? 50 : 45,
                          interval: _getWaterfallMaxY(incomeStatement) > 0 
                              ? _getWaterfallMaxY(incomeStatement) / 5 
                              : 1000,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              '\$${(value / 1000).toStringAsFixed(0)}K',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF6B6B6B),
                                fontWeight: FontWeight.w500,
                                fontSize: responsive.isTablet ? 13 : 12,
                                height: 1.2,
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
                      horizontalInterval: _getWaterfallMaxY(incomeStatement) > 0 
                          ? _getWaterfallMaxY(incomeStatement) / 5 
                          : 1000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: const Color(0xFFE5E5E5),
                          strokeWidth: 1,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView(IncomeStatement incomeStatement, ResponsiveInfo responsive) {
    final sectionTitleSize = responsive.isTablet ? 17.0 : 16.0;
    final rowSize = responsive.isTablet ? 15.0 : 14.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: Container(
        padding: EdgeInsets.all(responsive.isDesktop ? 24 : responsive.isTablet ? 20 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Breakdown',
              style: GoogleFonts.inter(
                fontSize: responsive.isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            _buildTableSection(
              'Revenue',
              [
                _buildTableRow('Total Revenue', incomeStatement.revenue.totalRevenue, rowSize, responsive.isTablet),
                _buildTableRow('Trading Revenue', incomeStatement.revenue.tradingRevenue, rowSize, responsive.isTablet),
                _buildTableRow('Other Income', incomeStatement.revenue.otherIncome, rowSize, responsive.isTablet),
              ],
              const Color(0xFF10B981),
              sectionTitleSize,
              responsive.isSmallScreen,
              responsive.isTablet,
            ),

            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            _buildTableSection(
              'Expenses',
              [
                _buildTableRow('Total Expenses', incomeStatement.expenses.totalExpenses, rowSize, responsive.isTablet),
                _buildTableRow('Transaction Fees', incomeStatement.expenses.transactionFees, rowSize, responsive.isTablet),
                _buildTableRow('Operational Expenses', incomeStatement.expenses.operationalExpenses, rowSize, responsive.isTablet),
                _buildTableRow('Tax Expenses', incomeStatement.expenses.taxExpenses, rowSize, responsive.isTablet),
              ],
              const Color(0xFFEF4444),
              sectionTitleSize,
              responsive.isSmallScreen,
              responsive.isTablet,
            ),

            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            _buildTableSection(
              'Profitability',
              [
                _buildTableRow('Gross Profit', incomeStatement.grossProfit.grossProfit, rowSize, responsive.isTablet),
                _buildTableRow('Gross Profit Margin', incomeStatement.grossProfit.grossProfitMargin, rowSize, responsive.isTablet, isPercentage: true),
                _buildTableRow('Net Income', incomeStatement.netIncome.netIncome, rowSize, responsive.isTablet),
                _buildTableRow('Net Profit Margin', incomeStatement.netIncome.netProfitMargin, rowSize, responsive.isTablet, isPercentage: true),
              ],
              const Color(0xFF3B82F6),
              sectionTitleSize,
              responsive.isSmallScreen,
              responsive.isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(String title, List<Widget> rows, Color color, double titleSize, bool isSmallScreen, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14 : 12,
            vertical: isTablet ? 10 : 8,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 14),
        ...rows,
      ],
    );
  }

  Widget _buildTableRow(String label, double amount, double fontSize, bool isTablet, {bool isPercentage = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          Text(
            isPercentage ? '${amount.toStringAsFixed(1)}%' : '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(IncomeStatement incomeStatement, ResponsiveInfo responsive) {
    final titleSize = responsive.isTablet ? 17.0 : 16.0;
    final rowSize = responsive.isTablet ? 15.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(responsive.isTablet ? 20 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Information',
            style: GoogleFonts.inter(
              fontSize: titleSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.2,
              height: 1.3,
            ),
          ),
          SizedBox(height: responsive.isSmallScreen ? 14 : 16),
          _buildMetadataRow('Period', '${incomeStatement.periodStart.day}/${incomeStatement.periodStart.month}/${incomeStatement.periodStart.year} - ${incomeStatement.periodEnd.day}/${incomeStatement.periodEnd.month}/${incomeStatement.periodEnd.year}', rowSize),
          _buildMetadataRow('Currency', incomeStatement.currency, rowSize),
          _buildMetadataRow('Generated', '${incomeStatement.generatedAt.day}/${incomeStatement.generatedAt.month}/${incomeStatement.generatedAt.year}', rowSize),
          _buildMetadataRow('Transactions', incomeStatement.metadata.transactionCount.toString(), rowSize),
          _buildMetadataRow('Payroll Entries', incomeStatement.metadata.payrollCount.toString(), rowSize),
          _buildMetadataRow('Period Length', '${incomeStatement.metadata.periodLengthDays} days', rowSize),
          _buildMetadataRow('Revenue Source', incomeStatement.summary.primaryRevenueSource, rowSize, isLast: true),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, double fontSize, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ),
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

  Future<void> _showDownloadOptions(BuildContext context, IncomeStatement incomeStatement) async {
    showDownloadReportOptions(
      context: context,
      onPdfDownload: () => _downloadPdf(context, incomeStatement),
      onExcelDownload: () => _downloadExcel(context, incomeStatement),
    );
  }

  Future<void> _downloadPdf(BuildContext context, IncomeStatement incomeStatement) async {
    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => PdfGenerationHelper.generateIncomeStatementPdf(incomeStatement),
      fileType: 'PDF',
    );
  }

  Future<void> _downloadExcel(BuildContext context, IncomeStatement incomeStatement) async {
    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => ExcelExportHelper.exportIncomeStatementToExcel(incomeStatement),
      fileType: 'Excel',
    );
  }

  double _getWaterfallMaxY(IncomeStatement incomeStatement) {
    final maxValue = [
      incomeStatement.revenue.totalRevenue,
      incomeStatement.grossProfit.grossProfit,
      incomeStatement.netIncome.netIncome.abs(),
    ].reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) {
      return 10000;
    }

    return maxValue * 1.2;
  }

  double _getWaterfallMinY(IncomeStatement incomeStatement) {
    final minValue = incomeStatement.expenses.totalExpenses;
    return -minValue * 1.2;
  }

  List<BarChartGroupData> _getWaterfallBarGroups(IncomeStatement incomeStatement) {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: incomeStatement.revenue.totalRevenue,
            color: const Color(0xFF10B981),
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            fromY: -incomeStatement.expenses.totalExpenses,
            toY: 0,
            color: const Color(0xFFEF4444),
            width: 40,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
          ),
        ],
      ),
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
            borderRadius: BorderRadius.circular(6),
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