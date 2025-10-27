import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../Reports_ViewModel/income_statement_viewmodel.dart';
import '../../../../domain/entities/income_statement.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_period_selector.dart';
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
          'Income Statement',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        actions: [
          if (incomeStatementState.hasData)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: const Color(0xFF1A1A1A),
                size: isTablet ? 24 : 22,
              ),
              onPressed: () => ref.read(incomeStatementViewModelProvider.notifier).refresh(),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: _buildBody(incomeStatementState, isSmallScreen, isTablet, isDesktop, horizontalPadding),
        ),
      ),
    );
  }

  Widget _buildBody(IncomeStatementState state, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    if (state.isLoading) {
      return const ReportsSkeleton();
    }

    if (state.hasError) {
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
                'Error loading income statement',
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
                onPressed: () => ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements(),
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

    if (!state.hasData) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assessment_outlined,
                size: isTablet ? 64 : 56,
                color: const Color(0xFF6B6B6B).withValues(alpha: 0.4),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              Text(
                'No income statement available',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                'Income statement data will appear here once available',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF6B6B6B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 24 : 28),
              ElevatedButton(
                onPressed: () => ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements(),
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
          if (state.incomeStatements != null && state.incomeStatements!.length > 1)
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
            ? _buildChartView(state.selectedIncomeStatement!, isSmallScreen, isTablet, isDesktop, horizontalPadding)
            : _buildTableView(state.selectedIncomeStatement!, isSmallScreen, isTablet, isDesktop, horizontalPadding),

          SizedBox(height: isSmallScreen ? 16 : 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildMetadata(state.selectedIncomeStatement!, isSmallScreen, isTablet),
          ),

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

  Widget _buildHeaderCard(IncomeStatementState state, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
                  Icons.assessment_outlined,
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
                      'Income Statement',
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
                      'Financial performance as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
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
                  'Total Revenue',
                  '\$${state.selectedIncomeStatement!.revenue.totalRevenue.toStringAsFixed(2)}',
                  const Color(0xFF10B981),
                  Icons.trending_up,
                  isSmallScreen,
                  isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildMetricCard(
                  'Total Expenses',
                  '\$${state.selectedIncomeStatement!.expenses.totalExpenses.toStringAsFixed(2)}',
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
                  'Net Income',
                  '\$${state.selectedIncomeStatement!.netIncome.netIncome.toStringAsFixed(2)}',
                  state.selectedIncomeStatement!.netIncome.isProfitable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  state.selectedIncomeStatement!.netIncome.isProfitable ? Icons.trending_up : Icons.trending_down,
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

  Widget _buildChartView(IncomeStatement incomeStatement, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
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
              'Revenue vs Expenses',
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
                              fontSize: isTablet ? 14 : 13,
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
                          reservedSize: isTablet ? 50 : 45,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: isTablet ? 50 : 45,
                          interval: _getWaterfallMaxY(incomeStatement) > 0 
                              ? _getWaterfallMaxY(incomeStatement) / 5 
                              : 1000,
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

  Widget _buildTableView(IncomeStatement incomeStatement, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
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
              'Financial Breakdown',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 19 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(height: isSmallScreen ? 18 : 22),

            _buildTableSection(
              'Revenue',
              [
                _buildTableRow('Total Revenue', incomeStatement.revenue.totalRevenue, rowSize, isTablet),
                _buildTableRow('Trading Revenue', incomeStatement.revenue.tradingRevenue, rowSize, isTablet),
                _buildTableRow('Other Income', incomeStatement.revenue.otherIncome, rowSize, isTablet),
              ],
              const Color(0xFF10B981),
              sectionTitleSize,
              isSmallScreen,
              isTablet,
            ),

            SizedBox(height: isSmallScreen ? 18 : 22),

            _buildTableSection(
              'Expenses',
              [
                _buildTableRow('Total Expenses', incomeStatement.expenses.totalExpenses, rowSize, isTablet),
                _buildTableRow('Transaction Fees', incomeStatement.expenses.transactionFees, rowSize, isTablet),
                _buildTableRow('Operational Expenses', incomeStatement.expenses.operationalExpenses, rowSize, isTablet),
                _buildTableRow('Tax Expenses', incomeStatement.expenses.taxExpenses, rowSize, isTablet),
              ],
              const Color(0xFFEF4444),
              sectionTitleSize,
              isSmallScreen,
              isTablet,
            ),

            SizedBox(height: isSmallScreen ? 18 : 22),

            _buildTableSection(
              'Profitability',
              [
                _buildTableRow('Gross Profit', incomeStatement.grossProfit.grossProfit, rowSize, isTablet),
                _buildTableRow('Gross Profit Margin', incomeStatement.grossProfit.grossProfitMargin, rowSize, isTablet, isPercentage: true),
                _buildTableRow('Net Income', incomeStatement.netIncome.netIncome, rowSize, isTablet),
                _buildTableRow('Net Profit Margin', incomeStatement.netIncome.netProfitMargin, rowSize, isTablet, isPercentage: true),
              ],
              const Color(0xFF3B82F6),
              sectionTitleSize,
              isSmallScreen,
              isTablet,
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

  Widget _buildMetadata(IncomeStatement incomeStatement, bool isSmallScreen, bool isTablet) {
    final titleSize = isTablet ? 17.0 : 16.0;
    final rowSize = isTablet ? 15.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 18),
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
          SizedBox(height: isSmallScreen ? 14 : 16),
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

  Widget _buildActionButtons(IncomeStatementState state, bool isSmallScreen, bool isTablet) {
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
            onPressed: () => _showDownloadOptions(context, state.selectedIncomeStatement!),
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

      final filePath = await PdfGenerationHelper.generateIncomeStatementPdf(incomeStatement);

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
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
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

  Future<void> _downloadExcel(BuildContext context, IncomeStatement incomeStatement) async {
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

      final filePath = await ExcelExportHelper.exportIncomeStatementToExcel(incomeStatement);

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
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
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