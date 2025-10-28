import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ViewModels/tax_reports_view_model.dart';
import '../../../../domain/entities/tax_report.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_period_selector.dart';
import '../../../widgets/skeletons/reports_skeleton.dart';
import '../../../widgets/reports/report_screen_layout.dart';
import '../../../widgets/reports/report_header_card.dart';
import '../../../widgets/reports/report_view_toggle.dart';
import '../../../widgets/reports/report_action_buttons.dart';
import '../../../widgets/reports/report_state_widgets.dart';
import '../../../widgets/reports/report_download_handler.dart';

class TaxReportsScreen extends ConsumerStatefulWidget {
  const TaxReportsScreen({super.key});

  @override
  ConsumerState<TaxReportsScreen> createState() => _TaxReportsScreenState();
}

class _TaxReportsScreenState extends ConsumerState<TaxReportsScreen> {
  bool isChartView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(taxReportsViewModelProvider);
      if (state.taxReports.isEmpty && !state.isLoading) {
        ref.read(taxReportsViewModelProvider.notifier).loadTaxReports();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taxReportsState = ref.watch(taxReportsViewModelProvider);

    return ReportScreenLayout(
      title: 'Tax Reports',
      hasData: taxReportsState.hasData,
      isLoading: taxReportsState.isLoading,
      onRefresh: () => ref.read(taxReportsViewModelProvider.notifier).refresh(),
      child: _buildBody(taxReportsState, const ResponsiveInfo(
        isSmallScreen: false,
        isTablet: false,
        isDesktop: false,
        horizontalPadding: 20.0,
        maxContentWidth: double.infinity,
      )),
      builder: (context, responsive) => _buildBody(taxReportsState, responsive),
    );
  }

  Widget _buildBody(TaxReportsState state, ResponsiveInfo responsive) {
    if (state.isLoading) {
      return const ReportsSkeleton();
    }

    if (state.error != null) {
      return ReportErrorState(
        title: 'Error loading tax reports',
        message: state.error!,
        onRetry: () => ref.read(taxReportsViewModelProvider.notifier).refresh(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    if (!state.hasData || state.selectedReport == null) {
      return ReportEmptyState(
        title: 'No tax reports available',
        message: 'Generate a tax report to view data',
        icon: Icons.receipt_long_outlined,
        onAction: () => ref.read(taxReportsViewModelProvider.notifier).refresh(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    final report = state.selectedReport!;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: responsive.isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          if (state.taxReports.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: _buildPeriodSelector(state),
            ),

          SizedBox(height: responsive.isSmallScreen ? 12 : 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportHeaderCard(
              title: 'Tax Summary',
              subtitle: '${report.periodStart.day}/${report.periodStart.month}/${report.periodStart.year} - ${report.periodEnd.day}/${report.periodEnd.month}/${report.periodEnd.year}',
              icon: Icons.receipt_long,
              metrics: [
                MetricData(
                  title: 'Total Income',
                  value: '\$${report.summary.totalIncome.toStringAsFixed(2)}',
                  color: const Color(0xFF10B981),
                  icon: Icons.trending_up,
                ),
                MetricData(
                  title: 'Total Deductions',
                  value: '\$${report.summary.totalDeductions.toStringAsFixed(2)}',
                  color: const Color(0xFFEF4444),
                  icon: Icons.trending_down,
                ),
                MetricData(
                  title: 'Net Tax Owed',
                  value: '\$${report.summary.netTaxOwed.toStringAsFixed(2)}',
                  color: const Color(0xFF3B82F6),
                  icon: Icons.account_balance_wallet,
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
              onToggle: (value) => setState(() => isChartView = value),
              isSmallScreen: responsive.isSmallScreen,
              isTablet: responsive.isTablet,
            ),
          ),

          SizedBox(height: responsive.isSmallScreen ? 16 : 20),

          isChartView 
            ? _buildChartView(state.selectedReport!, responsive)
            : _buildTableView(state.selectedReport!, responsive),

          SizedBox(height: responsive.isSmallScreen ? 20 : 24),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportActionButtons(
              onClose: () => Navigator.pop(context),
              onDownload: () => _showDownloadOptions(context, report),
              isSmallScreen: responsive.isSmallScreen,
              isTablet: responsive.isTablet,
            ),
          ),

          SizedBox(height: responsive.isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildChartView(TaxReport taxReport, ResponsiveInfo responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: Column(
        children: [
          Container(
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
                  'Financial Performance',
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
                        maxY: _getMaxValue(taxReport),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => const Color(0xFF1A1A1A),
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '\$${rod.toY.toStringAsFixed(0)}\n${_getTooltipText(group.x.toDouble())}',
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
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getChartLabel(value.toInt()),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w600,
                                      fontSize: responsive.isTablet ? 11 : 10,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                              reservedSize: responsive.isTablet ? 40 : 35,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: responsive.isTablet ? 50 : 45,
                              interval: _getMaxValue(taxReport) / 5,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '\$${(value / 1000).toStringAsFixed(0)}K',
                                  style: GoogleFonts.inter(
                                    fontSize: responsive.isTablet ? 13 : 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B6B6B),
                                    height: 1.2,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _getBarGroups(taxReport),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getMaxValue(taxReport) / 5,
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

          SizedBox(height: responsive.isSmallScreen ? 16 : 20),

          Container(
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
                  'AI Analysis',
                  style: GoogleFonts.inter(
                    fontSize: responsive.isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: responsive.isSmallScreen ? 12 : 14),
                Text(
                  taxReport.llmAnalysis ?? 'No analysis available for this report.',
                  style: GoogleFonts.inter(
                    fontSize: responsive.isTablet ? 15 : 14,
                    color: const Color(0xFF6B6B6B),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(TaxReport taxReport, ResponsiveInfo responsive) {
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
              'Tax Report Details',
              style: GoogleFonts.inter(
                fontSize: responsive.isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            _buildTableRow('Capital Gains', '\$${(taxReport.totalGains ?? 0).toStringAsFixed(2)}', rowSize),
            _buildTableRow('Capital Losses', '\$${(taxReport.totalLosses ?? 0).toStringAsFixed(2)}', rowSize),
            _buildTableRow('Net P&L', '\$${(taxReport.netPnl ?? 0).toStringAsFixed(2)}', rowSize),
            _buildTableRow('Total Expenses', '\$${(taxReport.totalExpenses ?? 0).toStringAsFixed(2)}', rowSize),
            _buildTableRow('Report Type', taxReport.reportType, rowSize),
            _buildTableRow('Period', '${_formatDate(taxReport.periodStart.toString())} - ${_formatDate(taxReport.periodEnd.toString())}', rowSize),
            _buildTableRow('Transactions', '${taxReport.metadata['transaction_count'] ?? 0}', rowSize, isLast: true),

            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            Container(
              padding: EdgeInsets.all(responsive.isTablet ? 20 : 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Capital Gains', '\$${(taxReport.totalGains ?? 0).toStringAsFixed(2)}', rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Capital Losses', '\$${(taxReport.totalLosses ?? 0).toStringAsFixed(2)}', rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Net P&L', '\$${(taxReport.netPnl ?? 0).toStringAsFixed(2)}', rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 12 : 14),
                  Container(height: 1, color: const Color(0xFFE5E5E5)),
                  SizedBox(height: responsive.isSmallScreen ? 12 : 14),
                  _buildSummaryRow('Total Expenses', '\$${(taxReport.totalExpenses ?? 0).toStringAsFixed(2)}', rowSize + 1, isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String label, String value, double fontSize, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
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
            value,
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

  Widget _buildSummaryRow(String label, String amount, double fontSize, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? fontSize : fontSize,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: isTotal ? fontSize : fontSize,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(TaxReportsState state) {
    if (state.taxReports.isEmpty) {
      return const SizedBox.shrink();
    }

    return ReportPeriodSelector<TaxReport>(
      items: state.taxReports,
      selectedItem: state.selectedReport!,
      formatPeriod: (taxReport) {
        final start = taxReport.periodStart;
        final end = taxReport.periodEnd;
        return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
      },
      onPeriodChanged: (taxReport) {
        ref.read(taxReportsViewModelProvider.notifier).selectTaxReport(taxReport);
      },
    );
  }

  Future<void> _showDownloadOptions(BuildContext context, TaxReport taxReport) async {
    showDownloadReportOptions(
      context: context,
      onPdfDownload: () => _downloadPdf(context, taxReport),
      onExcelDownload: () => _exportToExcel(context, taxReport),
    );
  }

  Future<void> _exportToExcel(BuildContext context, TaxReport taxReport) async {
    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => ExcelExportHelper.exportTaxReportToExcel(taxReport),
      fileType: 'Excel',
    );
  }

  Future<void> _downloadPdf(BuildContext context, TaxReport taxReport) async {
    final reportData = {
      'report_info': {
        'report_id': taxReport.reportId,
        'report_type': taxReport.reportType,
        'period_start': taxReport.periodStart.toString(),
        'period_end': taxReport.periodEnd.toString(),
        'generated_at': taxReport.reportDate.toString(),
        'status': taxReport.status,
      },
      'financial_data': {
        'capital_gains': taxReport.totalGains ?? 0,
        'capital_losses': taxReport.totalLosses ?? 0,
        'net_pnl': taxReport.netPnl ?? 0,
        'total_income': taxReport.totalIncome ?? 0,
        'total_expenses': taxReport.totalExpenses ?? 0,
      },
      'summary': {
        'total_income': taxReport.summary.totalIncome,
        'total_deductions': taxReport.summary.totalDeductions,
        'taxable_income': taxReport.summary.taxableIncome,
        'total_tax_owed': taxReport.summary.totalTaxOwed,
      },
      'metadata': {
        'transaction_count': taxReport.metadata['transaction_count'] ?? 0,
        'accounting_method': taxReport.metadata['accounting_method'] ?? 'N/A',
        'tax_year': taxReport.metadata['tax_year'] ?? DateTime.now().year,
      },
      'analysis': taxReport.llmAnalysis ?? 'No analysis available for this report.',
    };

    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => PdfGenerationHelper.generateTaxReportPdf(reportData),
      fileType: 'PDF',
    );
  }

  double _getMaxValue(TaxReport taxReport) {
    final gains = (taxReport.totalGains ?? 0).abs();
    final losses = (taxReport.totalLosses ?? 0).abs();
    final netPnl = (taxReport.netPnl ?? 0).abs();
    final expenses = (taxReport.totalExpenses ?? 0).abs();

    final maxValue = [gains, losses, netPnl, expenses].reduce((a, b) => a > b ? a : b) * 1.2;

    if (maxValue == 0) {
      return 1000;
    }

    return maxValue;
  }

  List<BarChartGroupData> _getBarGroups(TaxReport taxReport) {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: taxReport.totalGains ?? 0,
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
            toY: taxReport.totalLosses ?? 0,
            color: const Color(0xFFEF4444),
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: (taxReport.netPnl ?? 0).abs(),
            color: const Color(0xFF3B82F6),
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: taxReport.totalExpenses ?? 0,
            color: const Color(0xFFF59E0B),
            width: 40,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      ),
    ];
  }

  String _getChartLabel(int index) {
    const labels = ['Gains', 'Losses', 'Net P&L', 'Expenses'];
    return labels[index];
  }

  String _getTooltipText(double x) {
    const tooltips = ['Capital Gains', 'Capital Losses', 'Net P&L', 'Total Expenses'];
    return tooltips[x.toInt()];
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
