import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../Reports_ViewModel/payroll_reports_view_model.dart';
import '../../../../domain/entities/payslip.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF1A1A1A),
            size: isTablet ? 26 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payroll Summary',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        actions: [
          if (payrollReportsState.hasData)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: const Color(0xFF1A1A1A),
                size: isTablet ? 24 : 22,
              ),
              onPressed: () => ref.read(payrollReportsViewModelProvider.notifier).refresh(),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: _buildBody(payrollReportsState, isSmallScreen, isTablet, isDesktop, horizontalPadding),
        ),
      ),
    );
  }

  Widget _buildBody(PayrollReportsState state, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    if (state.isLoading) {
      return const ReportsSkeleton();
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: isTablet ? 64 : 56,
                color: Colors.red.shade400,
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              Text(
                'Error loading payroll reports',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 28),
              ElevatedButton(
                onPressed: () => ref.read(payrollReportsViewModelProvider.notifier).refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 28 : 24,
                    vertical: isTablet ? 14 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.hasData || state.payslipsResponse == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.payment_outlined,
                size: isTablet ? 64 : 56,
                color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              Text(
                'No payroll data available',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                'Generate payroll reports to view data',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 28),
              ElevatedButton(
                onPressed: () => ref.read(payrollReportsViewModelProvider.notifier).refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 28 : 24,
                    vertical: isTablet ? 14 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Refresh',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildHeaderCard(state, isSmallScreen, isTablet, isDesktop),
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildViewToggle(isSmallScreen, isTablet),
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          isChartView 
            ? _buildChartView(state.payslipsResponse!, isSmallScreen, isTablet, isDesktop, horizontalPadding)
            : _buildTableView(state.payslipsResponse!, isSmallScreen, isTablet, isDesktop, horizontalPadding),

          SizedBox(height: isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(PayrollReportsState state, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final titleSize = isDesktop ? 22.0 : isTablet ? 21.0 : 20.0;
    final subtitleSize = isDesktop ? 15.0 : isTablet ? 14.0 : 13.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : 22.0;
    final iconContainerSize = isDesktop ? 48.0 : isTablet ? 44.0 : 40.0;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
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
          Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF9747FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payment_outlined,
                  color: const Color(0xFF9747FF),
                  size: iconSize,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payroll Summary',
                      style: GoogleFonts.inter(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Payroll overview as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Payslips',
                  '${state.payslipsResponse!.payslips.length}',
                  const Color(0xFF10B981),
                  Icons.assignment_outlined,
                  isSmallScreen,
                  isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildMetricCard(
                  'Total Payroll',
                  '\$${state.payslipsResponse!.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}',
                  const Color(0xFF3B82F6),
                  Icons.account_balance_wallet_outlined,
                  isSmallScreen,
                  isTablet,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 14 : 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Avg Salary',
                  '\$${(state.payslipsResponse!.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay) / state.payslipsResponse!.payslips.length).toStringAsFixed(2)}',
                  const Color(0xFFF59E0B),
                  Icons.trending_up,
                  isSmallScreen,
                  isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon, bool isSmallScreen, bool isTablet) {
    final titleSize = isTablet ? 13.0 : 12.0;
    final valueSize = isTablet ? 17.0 : 16.0;
    final iconSize = isTablet ? 18.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1.5,
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
                size: iconSize,
              ),
              SizedBox(width: isTablet ? 10 : 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B6B6B),
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(bool isSmallScreen, bool isTablet) {
    final fontSize = isTablet ? 15.0 : 14.0;
    final iconSize = isTablet ? 20.0 : 18.0;

    return Container(
      height: isTablet ? 54 : 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
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
                  color: isChartView ? const Color(0xFF9747FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isChartView ? [
                    BoxShadow(
                      color: const Color(0xFF9747FF).withValues(alpha: 0.3),
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
                        Icons.bar_chart_outlined,
                        size: iconSize,
                        color: isChartView ? Colors.white : const Color(0xFF6B6B6B),
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        'Chart View',
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: isChartView ? Colors.white : const Color(0xFF6B6B6B),
                          height: 1.2,
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
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isChartView ? const Color(0xFF9747FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !isChartView ? [
                    BoxShadow(
                      color: const Color(0xFF9747FF).withValues(alpha: 0.3),
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
                        Icons.table_chart_outlined,
                        size: iconSize,
                        color: !isChartView ? Colors.white : const Color(0xFF6B6B6B),
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        'Table View',
                        style: GoogleFonts.inter(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: !isChartView ? Colors.white : const Color(0xFF6B6B6B),
                          height: 1.2,
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
    );
  }

  Widget _buildChartView(PayslipsResponse payslipsResponse, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    final employeePayrollMap = <String, double>{};
    for (final payslip in payslipsResponse.payslips) {
      final employeeName = payslip.employeeName ?? 'Unknown Employee';
      employeePayrollMap[employeeName] = (employeePayrollMap[employeeName] ?? 0) + payslip.finalNetPay;
    }

    final sortedEmployees = employeePayrollMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmployees = sortedEmployees.take(5).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Container(
            height: isDesktop ? 420 : isTablet ? 400 : 380,
            padding: EdgeInsets.all(isDesktop ? 28 : isTablet ? 24 : 20),
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
                    fontSize: isTablet ? 19 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
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
                                        fontSize: isTablet ? 11 : 10,
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
                              reservedSize: isTablet ? 45 : 40,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: isTablet ? 50 : 45,
                              interval: _getPayrollMaxY(topEmployees) / 5,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '\$${(value / 1000).toStringAsFixed(0)}K',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF6B6B6B),
                                    fontWeight: FontWeight.w500,
                                    fontSize: isTablet ? 13 : 12,
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

          SizedBox(height: isSmallScreen ? 16 : 20),

          Container(
            padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
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
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 14 : 16),
                _buildMetricRow('Total Employees', payslipsResponse.payslips.map((p) => p.employeeName ?? 'Unknown').toSet().length.toString(), isTablet),
                _buildMetricRow('Total Payroll', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}', isTablet),
                _buildMetricRow('Average Salary', '\$${(payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay) / payslipsResponse.payslips.length).toStringAsFixed(2)}', isTablet),
                _buildMetricRow('Total Deductions', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.totalDeductions).toStringAsFixed(2)}', isTablet, isLast: true),
              ],
            ),
          ),

          SizedBox(height: isSmallScreen ? 20 : 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 15,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDownloadOptions(context, payslipsResponse),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9747FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_outlined, size: isTablet ? 18 : 16),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        'Download',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 16 : 15,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildTableView(PayslipsResponse payslipsResponse, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    final rowSize = isTablet ? 15.0 : 14.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 18),
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
                    fontSize: isTablet ? 19 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 18 : 22),

                ...payslipsResponse.payslips.take(10).map((payslip) => _buildPayslipRow(payslip, rowSize, isTablet)),

                Container(
                  margin: EdgeInsets.only(top: isSmallScreen ? 18 : 22),
                  padding: EdgeInsets.all(isTablet ? 20 : 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Total Payslips', payslipsResponse.payslips.length.toString(), rowSize),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      _buildSummaryRow('Total Payroll', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}', rowSize),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      _buildSummaryRow('Total Deductions', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.totalDeductions).toStringAsFixed(2)}', rowSize),
                      SizedBox(height: isSmallScreen ? 12 : 14),
                      Container(height: 1, color: const Color(0xFFE5E5E5)),
                      SizedBox(height: isSmallScreen ? 12 : 14),
                      _buildSummaryRow('Net Pay Total', '\$${payslipsResponse.payslips.fold(0.0, (sum, p) => sum + p.finalNetPay).toStringAsFixed(2)}', rowSize, isTotal: true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isSmallScreen ? 20 : 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16 : 15,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDownloadOptions(context, payslipsResponse),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9747FF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_outlined, size: isTablet ? 18 : 16),
                      SizedBox(width: isTablet ? 10 : 8),
                      Text(
                        'Download',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 16 : 15,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
    final scaffoldContext = context;
    try {
      showDialog(
        context: scaffoldContext,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
        ),
      );

      final filePath = await ExcelExportHelper.exportPayrollSummaryToExcel(payslipsResponse);

      if (scaffoldContext.mounted) {
        Navigator.of(scaffoldContext, rootNavigator: true).pop();
      }

      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              'Excel file saved successfully!\nTap to open: ${filePath.split('/').last}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Could not open file: $e',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Colors.orange[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate Excel file: $e',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context, PayslipsResponse payslipsResponse) async {
    final scaffoldContext = context;
    try {
      showDialog(
        context: scaffoldContext,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
        ),
      );

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

      final filePath = await PdfGenerationHelper.generatePayrollSummaryPdf(reportData);

      if (scaffoldContext.mounted) {
        Navigator.of(scaffoldContext, rootNavigator: true).pop();
      }

      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              'PDF saved successfully!\nTap to open: ${filePath.split('/').last}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Could not open file: $e',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Colors.orange[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate PDF: $e',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  double _getPayrollMaxY(List<MapEntry<String, double>> topEmployees) {
    if (topEmployees.isEmpty) return 1000;
    final maxValue = topEmployees.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2;
  }
}