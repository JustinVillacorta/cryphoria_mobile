import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../Reports_ViewModel/cash_flow_view_model.dart';
import '../../../../domain/entities/cash_flow.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_period_selector.dart';
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
          'Cash Flow',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        actions: [
          if (cashFlowState.hasData)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: const Color(0xFF1A1A1A),
                size: isTablet ? 24 : 22,
              ),
              onPressed: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: _buildBody(cashFlowState, isSmallScreen, isTablet, isDesktop, horizontalPadding),
        ),
      ),
    );
  }

  Widget _buildBody(CashFlowState state, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
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
                'Error loading cash flow',
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
                onPressed: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
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

    if (!state.hasData || state.selectedCashFlow == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up_outlined,
                size: isTablet ? 64 : 56,
                color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              Text(
                'No cash flow data available',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                'Generate a cash flow report to view data',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 28),
              ElevatedButton(
                onPressed: () => ref.read(cashFlowViewModelProvider.notifier).refresh(),
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
          if (state.cashFlowListResponse != null && state.cashFlowListResponse!.cashFlowStatements.length > 1)
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
            ? _buildChartView(state.selectedCashFlow!, isSmallScreen, isTablet, isDesktop, horizontalPadding)
            : _buildTableView(state.selectedCashFlow!, isSmallScreen, isTablet, isDesktop, horizontalPadding),

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

  Widget _buildHeaderCard(CashFlowState state, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
                  Icons.trending_up_outlined,
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
                      'Cash Flow Statement',
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
                      'Cash movements as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
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
                  'Operating Cash Flow',
                  '\$${state.selectedCashFlow!.cashSummary.netCashFromOperations.toStringAsFixed(2)}',
                  const Color(0xFF10B981),
                  Icons.trending_up,
                  isSmallScreen,
                  isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildMetricCard(
                  'Investing Cash Flow',
                  '\$${state.selectedCashFlow!.cashSummary.netCashFromInvesting.toStringAsFixed(2)}',
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
                  'Net Change',
                  '\$${state.selectedCashFlow!.cashSummary.netChangeInCash.toStringAsFixed(2)}',
                  const Color(0xFF3B82F6),
                  Icons.account_balance_wallet_outlined,
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

  Widget _buildChartView(CashFlow cashFlow, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
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
              'Cash Flow Waterfall',
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
                          reservedSize: isTablet ? 45 : 40,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getWaterfallLabel(value.toInt()),
                                style: GoogleFonts.inter(
                                  fontSize: isTablet ? 11 : 10,
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
                          reservedSize: isTablet ? 50 : 45,
                          interval: _getWaterfallMaxY(cashFlow) > 0 ? _getWaterfallMaxY(cashFlow) / 5 : 1000,
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

  Widget _buildTableView(CashFlow cashFlow, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    final sectionTitleSize = isTablet ? 17.0 : 16.0;
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
              'Cash Flow Statement',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: isSmallScreen ? 18 : 22),

            _buildSectionHeader('Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!, sectionTitleSize, isTablet),
            SizedBox(height: isSmallScreen ? 8 : 10),
            _buildTotalRow('Net Cash from Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize, isTablet),

            SizedBox(height: isSmallScreen ? 18 : 22),

            _buildSectionHeader('Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!, sectionTitleSize, isTablet),
            SizedBox(height: isSmallScreen ? 8 : 10),
            _buildTotalRow('Net Cash from Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize, isTablet),

            SizedBox(height: isSmallScreen ? 18 : 22),

            _buildSectionHeader('Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!, sectionTitleSize, isTablet),
            SizedBox(height: isSmallScreen ? 8 : 10),
            _buildTotalRow('Net Cash from Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
              cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize, isTablet),

            SizedBox(height: isSmallScreen ? 18 : 22),

            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Beginning Cash', '\$${cashFlow.cashSummary.beginningCash.toStringAsFixed(2)}', Colors.blue[600]!, rowSize),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Net Cash from Operating Activities', '\$${cashFlow.cashSummary.netCashFromOperations.toStringAsFixed(2)}', 
                    cashFlow.cashSummary.netCashFromOperations >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Net Cash from Investing Activities', '\$${cashFlow.cashSummary.netCashFromInvesting.toStringAsFixed(2)}', 
                    cashFlow.cashSummary.netCashFromInvesting >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize),
                  SizedBox(height: isSmallScreen ? 8 : 10),
                  _buildSummaryRow('Net Cash from Financing Activities', '\$${cashFlow.cashSummary.netCashFromFinancing.toStringAsFixed(2)}', 
                    cashFlow.cashSummary.netCashFromFinancing >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize),
                  SizedBox(height: isSmallScreen ? 12 : 14),
                  Container(height: 1, color: const Color(0xFFE5E5E5)),
                  SizedBox(height: isSmallScreen ? 12 : 14),
                  _buildSummaryRow('Net Change in Cash', '\$${cashFlow.cashSummary.netChangeInCash.toStringAsFixed(2)}', 
                    cashFlow.cashSummary.netChangeInCash >= 0 ? Colors.green[600]! : Colors.red[600]!, rowSize, isTotal: true),
                  SizedBox(height: isSmallScreen ? 8 : 10),
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

  Widget _buildActionButtons(CashFlowState state, bool isSmallScreen, bool isTablet) {
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
            onPressed: () => _showDownloadOptions(context, state.selectedCashFlow!),
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

      final filePath = await ExcelExportHelper.exportCashFlowToExcel(cashFlow);

      if (scaffoldContext.mounted) {
        Navigator.of(scaffoldContext).pop();
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
        Navigator.of(context).pop();
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

  Future<void> _downloadPdf(BuildContext context, CashFlow cashFlow) async {
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

      final filePath = await PdfGenerationHelper.generateCashFlowPdf(reportData);

      if (scaffoldContext.mounted) {
        Navigator.of(scaffoldContext).pop();
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
        Navigator.of(context).pop();
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