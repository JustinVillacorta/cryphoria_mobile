import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../Reports_ViewModel/tax_reports_view_model.dart';
import '../../../../domain/entities/tax_report.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_period_selector.dart';
import '../../../widgets/skeletons/reports_skeleton.dart';

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
          'Tax Reports',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        actions: [
          if (taxReportsState.hasData)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: const Color(0xFF1A1A1A),
                size: isTablet ? 24 : 22,
              ),
              onPressed: () => ref.read(taxReportsViewModelProvider.notifier).refresh(),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: _buildBody(taxReportsState, isSmallScreen, isTablet, isDesktop, horizontalPadding),
        ),
      ),
    );
  }

  Widget _buildBody(TaxReportsState state, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
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
                'Error loading tax reports',
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
                onPressed: () => ref.read(taxReportsViewModelProvider.notifier).refresh(),
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

    if (!state.hasData || state.selectedReport == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: isTablet ? 64 : 56,
                color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              Text(
                'No tax reports available',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                'Generate a tax report to view data',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 28),
              ElevatedButton(
                onPressed: () => ref.read(taxReportsViewModelProvider.notifier).refresh(),
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
          if (state.taxReports.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: _buildPeriodSelector(state),
            ),

          SizedBox(height: isSmallScreen ? 12 : 16),

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
            ? _buildChartView(state.selectedReport!, isSmallScreen, isTablet, isDesktop, horizontalPadding)
            : _buildTableView(state.selectedReport!, isSmallScreen, isTablet, isDesktop, horizontalPadding),

          SizedBox(height: isSmallScreen ? 20 : 24),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildActionButtons(state, isSmallScreen, isTablet),
          ),

          SizedBox(height: isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(TaxReportsState state, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
                  Icons.receipt_long_outlined,
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
                      'Tax Report',
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
                      'Generated: ${_formatDate(state.selectedReport!.reportDate.toString())}',
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    Text(
                      'Period: ${_formatDate(state.selectedReport!.periodStart.toString())} - ${_formatDate(state.selectedReport!.periodEnd.toString())}',
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize - 1,
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
                  'Capital Gains',
                  '\$${(state.selectedReport!.totalGains ?? 0).toStringAsFixed(2)}',
                  const Color(0xFF10B981),
                  Icons.trending_up,
                  isSmallScreen,
                  isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildMetricCard(
                  'Capital Losses',
                  '\$${(state.selectedReport!.totalLosses ?? 0).toStringAsFixed(2)}',
                  const Color(0xFFEF4444),
                  Icons.trending_down,
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
                  'Net P&L',
                  '\$${(state.selectedReport!.netPnl ?? 0).toStringAsFixed(2)}',
                  const Color(0xFF3B82F6),
                  Icons.account_balance_wallet_outlined,
                  isSmallScreen,
                  isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildMetricCard(
                  'Total Expenses',
                  '\$${(state.selectedReport!.totalExpenses ?? 0).toStringAsFixed(2)}',
                  const Color(0xFFF59E0B),
                  Icons.payments_outlined,
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

  Widget _buildChartView(TaxReport taxReport, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
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
                  'Financial Performance',
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
                                      fontSize: isTablet ? 11 : 10,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                              reservedSize: isTablet ? 40 : 35,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: isTablet ? 50 : 45,
                              interval: _getMaxValue(taxReport) / 5,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '\$${(value / 1000).toStringAsFixed(0)}K',
                                  style: GoogleFonts.inter(
                                    fontSize: isTablet ? 13 : 12,
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
                  'AI Analysis',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 14),
                Text(
                  taxReport.llmAnalysis ?? 'No analysis available for this report.',
                  style: GoogleFonts.inter(
                    fontSize: isTablet ? 15 : 14,
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

  Widget _buildTableView(TaxReport taxReport, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    final rowSize = isTablet ? 15.0 : 14.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
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
              'Tax Report Details',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: isSmallScreen ? 18 : 22),

            _buildTableRow('Capital Gains', '\$${(taxReport.totalGains ?? 0).toStringAsFixed(2)}', rowSize),
            _buildTableRow('Capital Losses', '\$${(taxReport.totalLosses ?? 0).toStringAsFixed(2)}', rowSize),
            _buildTableRow('Net P&L', '\$${(taxReport.netPnl ?? 0).toStringAsFixed(2)}', rowSize),
            _buildTableRow('Total Expenses', '\$${(taxReport.totalExpenses ?? 0).toStringAsFixed(2)}', rowSize),
            _buildTableRow('Report Type', taxReport.reportType, rowSize),
            _buildTableRow('Period', '${_formatDate(taxReport.periodStart.toString())} - ${_formatDate(taxReport.periodEnd.toString())}', rowSize),
            _buildTableRow('Transactions', '${taxReport.metadata['transaction_count'] ?? 0}', rowSize, isLast: true),

            SizedBox(height: isSmallScreen ? 18 : 22),

            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Capital Gains', '\$${(taxReport.totalGains ?? 0).toStringAsFixed(2)}', rowSize),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Capital Losses', '\$${(taxReport.totalLosses ?? 0).toStringAsFixed(2)}', rowSize),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Net P&L', '\$${(taxReport.netPnl ?? 0).toStringAsFixed(2)}', rowSize),
                  SizedBox(height: isSmallScreen ? 12 : 14),
                  Container(height: 1, color: const Color(0xFFE5E5E5)),
                  SizedBox(height: isSmallScreen ? 12 : 14),
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

  Widget _buildActionButtons(TaxReportsState state, bool isSmallScreen, bool isTablet) {
    final fontSize = isTablet ? 16.0 : 15.0;

    return Row(
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
                fontSize: fontSize,
                height: 1.2,
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 14 : 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showDownloadOptions(context, state.selectedReport!),
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
                    fontSize: fontSize,
                    height: 1.2,
                  ),
                ),
              ],
            ),
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

      final filePath = await ExcelExportHelper.exportTaxReportToExcel(taxReport);

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

  Future<void> _downloadPdf(BuildContext context, TaxReport taxReport) async {
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

      final filePath = await PdfGenerationHelper.generateTaxReportPdf(reportData);

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
