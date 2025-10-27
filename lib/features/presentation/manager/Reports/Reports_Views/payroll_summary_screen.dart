import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Reports_ViewModel/payroll_reports_view_model.dart';
import '../../../../domain/entities/payslip.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_screen_layout.dart';
import '../../../widgets/reports/report_header_card.dart';
import '../../../widgets/reports/report_view_toggle.dart';
import '../../../widgets/reports/report_action_buttons.dart';
import '../../../widgets/reports/report_state_widgets.dart';
import '../../../widgets/reports/report_download_handler.dart';
import '../../../widgets/skeletons/reports_skeleton.dart';

class PayrollSummaryScreen extends ConsumerStatefulWidget {
  const PayrollSummaryScreen({super.key});

  @override
  ConsumerState<PayrollSummaryScreen> createState() => _PayrollSummaryScreenState();
}

class _PayrollSummaryScreenState extends ConsumerState<PayrollSummaryScreen> {
  bool isChartView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(payrollReportsViewModelProvider);
      if (state.payslipsResponse == null && !state.isLoading) {
        ref.read(payrollReportsViewModelProvider.notifier).loadPayrollReports();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final payrollReportsState = ref.watch(payrollReportsViewModelProvider);

    return ReportScreenLayout(
      title: 'Payroll Summary',
      hasData: payrollReportsState.hasData,
      isLoading: payrollReportsState.isLoading,
      onRefresh: () => ref.read(payrollReportsViewModelProvider.notifier).refresh(),
      builder: (context, responsive) => _buildBody(payrollReportsState, responsive),
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildBody(PayrollReportsState state, ResponsiveInfo responsive) {
    if (state.isLoading) {
      return const ReportsSkeleton();
    }

    if (state.error != null) {
      return ReportErrorState(
        title: 'Error loading payroll reports',
        message: state.error!,
        onRetry: () => ref.read(payrollReportsViewModelProvider.notifier).refresh(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    if (!state.hasData || state.payslipsResponse == null) {
      return ReportEmptyState(
        title: 'No payroll data available',
        message: 'Generate payroll reports to view data',
        icon: Icons.payment_outlined,
        onAction: () => ref.read(payrollReportsViewModelProvider.notifier).refresh(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    final totalPayroll = state.payslipsResponse!.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay);
    final avgSalary = totalPayroll / state.payslipsResponse!.payslips.length;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: responsive.isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportHeaderCard(
              title: 'Payroll Summary',
              subtitle: 'Payroll overview as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              icon: Icons.payment_outlined,
              metrics: [
                MetricData(
                  title: 'Total Payslips',
                  value: '${state.payslipsResponse!.payslips.length}',
                  color: const Color(0xFF10B981),
                  icon: Icons.assignment_outlined,
                ),
                MetricData(
                  title: 'Total Payroll',
                  value: '\$${totalPayroll.toStringAsFixed(2)}',
                  color: const Color(0xFF3B82F6),
                  icon: Icons.account_balance_wallet_outlined,
                ),
                MetricData(
                  title: 'Avg Salary',
                  value: '\$${avgSalary.toStringAsFixed(2)}',
                  color: const Color(0xFFF59E0B),
                  icon: Icons.trending_up,
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
            ? _buildChartView(state.payslipsResponse!, responsive)
            : _buildTableView(state.payslipsResponse!, responsive),

          SizedBox(height: responsive.isSmallScreen ? 20 : 24),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportActionButtons(
              onClose: () => Navigator.pop(context),
              onDownload: () => _showDownloadOptions(context, state.payslipsResponse!),
              isSmallScreen: responsive.isSmallScreen,
              isTablet: responsive.isTablet,
            ),
          ),

          SizedBox(height: responsive.isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildChartView(PayslipsResponse payslipsResponse, ResponsiveInfo responsive) {
    final employeePayrollMap = <String, double>{};
    for (final payslip in payslipsResponse.payslips) {
      final employeeName = payslip.employeeName ?? 'Unknown Employee';
      employeePayrollMap[employeeName] = (employeePayrollMap[employeeName] ?? 0) + payslip.finalNetPay;
    }

    final sortedEmployees = employeePayrollMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmployees = sortedEmployees.take(5).toList();

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
                  'Payroll Overview',
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
                        maxY: _getPayrollMaxY(topEmployees),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => const Color(0xFF1A1A1A),
                            tooltipBorderRadius: BorderRadius.circular(8),
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final employeeName = topEmployees[group.x.toInt()].key;
                              return BarTooltipItem(
                                '$employeeName\n\$${rod.toY.toStringAsFixed(0)}',
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
                                if (value.toInt() < topEmployees.length) {
                                  final employeeName = topEmployees[value.toInt()].key;
                                  final displayName = employeeName.length > 12 
                                      ? '${employeeName.substring(0, 12)}...'
                                      : employeeName;

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      displayName,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF1A1A1A),
                                        fontWeight: FontWeight.w600,
                                        fontSize: responsive.isTablet ? 11 : 10,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: responsive.isTablet ? 45 : 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: responsive.isTablet ? 50 : 45,
                              interval: _getPayrollMaxY(topEmployees) / 5,
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
                        barGroups: List.generate(
                          topEmployees.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: topEmployees[index].value,
                                color: const Color(0xFF9747FF),
                                width: 40,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getPayrollMaxY(topEmployees) / 5,
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
                  'Key Metrics',
                  style: GoogleFonts.inter(
                    fontSize: responsive.isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: responsive.isSmallScreen ? 14 : 16),
                _buildMetricRow('Total Employees', payslipsResponse.payslips.map((p) => p.employeeName ?? 'Unknown').toSet().length.toString(), responsive.isTablet),
                _buildMetricRow('Total Payroll', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}', responsive.isTablet),
                _buildMetricRow('Average Salary', '\$${(payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay) / payslipsResponse.payslips.length).toStringAsFixed(2)}', responsive.isTablet),
                _buildMetricRow('Total Deductions', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.totalDeductions).toStringAsFixed(2)}', responsive.isTablet, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool isTablet, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isTablet ? 15 : 14,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(PayslipsResponse payslipsResponse, ResponsiveInfo responsive) {
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
                  'Employee Payslips',
                  style: GoogleFonts.inter(
                fontSize: responsive.isTablet ? 19 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
            SizedBox(height: responsive.isSmallScreen ? 18 : 22),

            ...payslipsResponse.payslips.take(10).map((payslip) => _buildPayslipRow(payslip, rowSize, responsive.isTablet)),

                Container(
              margin: EdgeInsets.only(top: responsive.isSmallScreen ? 18 : 22),
              padding: EdgeInsets.all(responsive.isTablet ? 20 : 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Total Payslips', payslipsResponse.payslips.length.toString(), rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 8 : 10),
                      _buildSummaryRow('Total Payroll', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}', rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 8 : 10),
                      _buildSummaryRow('Total Deductions', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.totalDeductions).toStringAsFixed(2)}', rowSize),
                  SizedBox(height: responsive.isSmallScreen ? 12 : 14),
                      Container(height: 1, color: const Color(0xFFE5E5E5)),
                  SizedBox(height: responsive.isSmallScreen ? 12 : 14),
                      _buildSummaryRow('Net Pay Total', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}', rowSize, isTotal: true),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildPayslipRow(Payslip payslip, double fontSize, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payslip.employeeName ?? 'Unknown Employee',
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4),
                Text(
                  payslip.department ?? 'No department',
                  style: GoogleFonts.inter(
                    fontSize: fontSize - 2,
                    color: const Color(0xFF6B6B6B),
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${payslip.finalNetPay.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 4),
                Text(
                  payslip.status ?? 'Unknown',
                  style: GoogleFonts.inter(
                    fontSize: fontSize - 2,
                    color: (payslip.status ?? '') == 'GENERATED' 
                        ? Colors.green[600] 
                        : Colors.orange[600],
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, double fontSize, {bool isTotal = false}) {
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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: isTotal ? fontSize + 1 : fontSize,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            height: 1.3,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Future<void> _showDownloadOptions(BuildContext context, PayslipsResponse payslipsResponse) async {
    showDownloadReportOptions(
      context: context,
      onPdfDownload: () => _downloadPdf(context, payslipsResponse),
      onExcelDownload: () => _exportToExcel(context, payslipsResponse),
    );
  }

  Future<void> _exportToExcel(BuildContext context, PayslipsResponse payslipsResponse) async {
    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => ExcelExportHelper.exportPayrollSummaryToExcel(payslipsResponse),
      fileType: 'Excel',
    );
  }

  Future<void> _downloadPdf(BuildContext context, PayslipsResponse payslipsResponse) async {
    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () async {
      final reportData = {
        'summary': {
          'total_employees': payslipsResponse.payslips.length,
          'total_amount': payslipsResponse.payslips.fold(0.0, (sum, payslip) => sum + payslip.finalNetPay),
          'currency': 'USD',
        },
        'payslips': payslipsResponse.payslips.map((payslip) => {
          'employee_name': payslip.employeeName ?? 'Unknown',
          'final_net_pay': payslip.finalNetPay,
          'tax_deduction': payslip.taxDeduction,
        }).toList(),
      };
        return await PdfGenerationHelper.generatePayrollSummaryPdf(reportData);
      },
      fileType: 'PDF',
    );
  }

  double _getPayrollMaxY(List<MapEntry<String, double>> topEmployees) {
    if (topEmployees.isEmpty) return 1000;
    final maxValue = topEmployees.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2;
  }
}
