import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ViewModels/cash_flow_view_model.dart';
import '../../../../domain/entities/cash_flow.dart';
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

    return ReportScreenLayout(
      title: 'Cash Flow',
      hasData: cashFlowState.hasData,
      isLoading: cashFlowState.isLoading,
      onRefresh: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
      builder: (context, responsive) => _buildBody(cashFlowState, responsive),
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildBody(CashFlowState state, ResponsiveInfo responsive) {
    if (state.isLoading) {
      return const ReportsSkeleton();
    }

    if (state.error != null) {
      return ReportErrorState(
        title: 'Error loading cash flow',
        message: state.error!,
        onRetry: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    if (!state.hasData || state.selectedCashFlow == null) {
      return ReportEmptyState(
        title: 'No cash flow data available',
        message: 'Generate a cash flow report to view data',
        icon: Icons.trending_up_outlined,
        onAction: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: responsive.isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          if (state.cashFlowListResponse != null && state.cashFlowListResponse!.cashFlowStatements.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: _buildPeriodSelector(state),
            ),

          SizedBox(height: responsive.isSmallScreen ? 12 : 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportHeaderCard(
              title: 'Cash Flow Statement',
              subtitle: 'Cash movements as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              icon: Icons.trending_up_outlined,
              metrics: [
                MetricData(
                  title: 'Operating Cash Flow',
                  value: '\$${state.selectedCashFlow!.cashSummary.netCashFromOperations.toStringAsFixed(2)}',
                  color: const Color(0xFF10B981),
                  icon: Icons.trending_up,
                ),
                MetricData(
                  title: 'Investing Cash Flow',
                  value: '\$${state.selectedCashFlow!.cashSummary.netCashFromInvesting.toStringAsFixed(2)}',
                  color: const Color(0xFFEF4444),
                  icon: Icons.trending_down,
                ),
                MetricData(
                  title: 'Net Change',
                  value: '\$${state.selectedCashFlow!.cashSummary.netChangeInCash.toStringAsFixed(2)}',
                  color: const Color(0xFF3B82F6),
                  icon: Icons.account_balance_wallet_outlined,
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
            ? _buildChartView(state.selectedCashFlow!, responsive)
            : _buildTableView(state.selectedCashFlow!, responsive),

          SizedBox(height: responsive.isSmallScreen ? 20 : 24),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportActionButtons(
              onClose: () => Navigator.pop(context),
              onDownload: () => _showDownloadOptions(context, state.selectedCashFlow!),
              isSmallScreen: responsive.isSmallScreen,
              isTablet: responsive.isTablet,
            ),
          ),

          SizedBox(height: responsive.isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildChartView(CashFlow cashFlow, ResponsiveInfo responsive) {
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
              'Cash Flow Waterfall',
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
                    maxY: _getWaterfallMaxY(cashFlow),
                    minY: _getWaterfallMinY(cashFlow),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => const Color(0xFF1A1A1A),
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String tooltipText;
                          double tooltipValue;

                          switch (group.x.toInt()) {
                            case 0:
                              tooltipText = 'Beginning Cash';
                              tooltipValue = cashFlow.cashSummary.beginningCash;
                              break;
                            case 1:
                              tooltipText = 'Operating Activities';
                              tooltipValue = cashFlow.cashSummary.netCashFromOperations;
                              break;
                            case 2:
                              tooltipText = 'Investing Activities';
                              tooltipValue = cashFlow.cashSummary.netCashFromInvesting;
                              break;
                            case 3:
                              tooltipText = 'Financing Activities';
                              tooltipValue = cashFlow.cashSummary.netCashFromFinancing;
                              break;
                            case 4:
                              tooltipText = 'Ending Cash';
                              tooltipValue = cashFlow.cashSummary.endingCash;
                              break;
                            default:
                              tooltipText = 'Unknown';
                              tooltipValue = rod.toY;
                          }

                          return BarTooltipItem(
                            '$tooltipText\n\$${tooltipValue.toStringAsFixed(0)}',
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
                          reservedSize: responsive.isTablet ? 45 : 40,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getWaterfallLabel(value.toInt()),
                                style: GoogleFonts.inter(
                                  fontSize: responsive.isTablet ? 11 : 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                  height: 1.2,
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
                          reservedSize: responsive.isTablet ? 50 : 45,
                          interval: _getWaterfallMaxY(cashFlow) > 0 ? _getWaterfallMaxY(cashFlow) / 5 : 1000,
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
                    barGroups: _getWaterfallBarGroups(cashFlow),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getWaterfallMaxY(cashFlow) > 0 ? _getWaterfallMaxY(cashFlow) / 5 : 1000,
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

  Widget _buildTableView(CashFlow cashFlow, ResponsiveInfo responsive) {
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
              'Cash Flow Statement',
              style: GoogleFonts.inter(
                fontSize: responsive.isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            _buildSectionHeader('Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!, sectionTitleSize, responsive.isTablet),
            SizedBox(height: responsive.isSmallScreen ? 8 : 10),
            _buildTotalRow('Net Cash from Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize, responsive.isTablet),

            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            _buildSectionHeader('Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!, sectionTitleSize, responsive.isTablet),
            SizedBox(height: responsive.isSmallScreen ? 8 : 10),
            _buildTotalRow('Net Cash from Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize, responsive.isTablet),

            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            _buildSectionHeader('Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!, sectionTitleSize, responsive.isTablet),
            SizedBox(height: responsive.isSmallScreen ? 8 : 10),
            _buildTotalRow('Net Cash from Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize, responsive.isTablet),

            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            Container(
              padding: EdgeInsets.all(responsive.isTablet ? 20 : 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Beginning Cash', '\$${cashFlow.cashSummary.beginningCash.toStringAsFixed(2)}', Colors.blue[600]!, rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Net Cash from Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
                    cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Net Cash from Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
                    cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Net Cash from Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
                    cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 12 : 14),
                  Container(height: 1, color: const Color(0xFFE5E5E5)),
                  SizedBox(height: responsive.isSmallScreen ? 12 : 14),
                  _buildSummaryRow('Net Change in Cash', '\$${cashFlow.cashSummary.netChangeInCash.toStringAsFixed(2)}', 
                    cashFlow.cashSummary.netChangeInCash >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize, isTotal: true),
                  SizedBox(height: responsive.isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Ending Cash', '\$${cashFlow.cashSummary.endingCash.toStringAsFixed(2)}', Colors.blue[600]!, rowSize, isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String amount, Color color, double fontSize, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 14 : 12,
        vertical: isTablet ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.3,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
                height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, Color color, double fontSize, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 18,
        vertical: isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, Color color, double fontSize, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? fontSize + 1 : fontSize,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: isTotal ? fontSize + 1 : fontSize,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: color,
            height: 1.3,
          ),
        ),
      ],
    );
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

  Future<void> _showDownloadOptions(BuildContext context, CashFlow cashFlow) async {
    showDownloadReportOptions(
      context: context,
      onPdfDownload: () => _downloadPdf(context, cashFlow),
      onExcelDownload: () => _exportToExcel(context, cashFlow),
    );
  }

  Future<void> _exportToExcel(BuildContext context, CashFlow cashFlow) async {
    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => ExcelExportHelper.exportCashFlowToExcel(cashFlow),
      fileType: 'Excel',
    );
  }

  Future<void> _downloadPdf(BuildContext context, CashFlow cashFlow) async {
    final reportData = {
      'summary': {
        'beginning_cash': cashFlow.cashSummary.beginningCash,
        'net_cash_from_operations': cashFlow.cashSummary.netCashFromOperations,
        'net_cash_from_investing': cashFlow.cashSummary.netCashFromInvesting,
        'net_cash_from_financing': cashFlow.cashSummary.netCashFromFinancing,
        'net_change_in_cash': cashFlow.cashSummary.netChangeInCash,
        'ending_cash': cashFlow.cashSummary.endingCash,
      },
      'period_info': {
        'period_start': cashFlow.periodStart.toIso8601String().split('T')[0],
        'period_end': cashFlow.periodEnd.toIso8601String().split('T')[0],
        'report_type': cashFlow.reportType,
        'currency': cashFlow.currency,
      },
    };

    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => PdfGenerationHelper.generateCashFlowPdf(reportData),
      fileType: 'PDF',
    );
  }

  double _getWaterfallMaxY(CashFlow cashFlow) {
    final maxValue = [
      cashFlow.cashSummary.beginningCash,
      cashFlow.cashSummary.endingCash,
      cashFlow.cashSummary.netCashFromOperations.abs(),
      cashFlow.cashSummary.netCashFromInvesting.abs(),
      cashFlow.cashSummary.netCashFromFinancing.abs(),
    ].reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) {
      return 10000;
    }

    return maxValue * 1.2;
  }

  double _getWaterfallMinY(CashFlow cashFlow) {
    final minValue = [
      cashFlow.cashSummary.netCashFromOperations,
      cashFlow.cashSummary.netCashFromInvesting,
      cashFlow.cashSummary.netCashFromFinancing,
    ].reduce((a, b) => a < b ? a : b);
    return minValue < 0 ? minValue * 1.2 : 0.0;
  }

  List<BarChartGroupData> _getWaterfallBarGroups(CashFlow cashFlow) {
    final beginningCash = cashFlow.cashSummary.beginningCash;
    final operatingFlow = cashFlow.cashSummary.netCashFromOperations;
    final investingFlow = cashFlow.cashSummary.netCashFromInvesting;
    final financingFlow = cashFlow.cashSummary.netCashFromFinancing;
    final endingCash = cashFlow.cashSummary.endingCash;

    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: beginningCash,
            color: const Color(0xFF2196F3),
            width: 45,
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
            fromY: operatingFlow >= 0 ? 0 : operatingFlow,
            toY: operatingFlow >= 0 ? operatingFlow : 0,
            color: operatingFlow >= 0 
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
            width: 40,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            fromY: investingFlow >= 0 ? 0 : investingFlow,
            toY: investingFlow >= 0 ? investingFlow : 0,
            color: investingFlow >= 0 
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
            width: 40,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            fromY: financingFlow >= 0 ? 0 : financingFlow,
            toY: financingFlow >= 0 ? financingFlow : 0,
            color: financingFlow >= 0 
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
            width: 40,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: endingCash,
            color: const Color(0xFF2196F3),
            width: 45,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
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