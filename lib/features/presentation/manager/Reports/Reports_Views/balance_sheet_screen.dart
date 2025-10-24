import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../Reports_ViewModel/balance_sheet_view_model.dart';
import '../../../../domain/entities/balance_sheet.dart';
import '../../../widgets/reports/excel_export_helper.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/reports/download_report_bottom_sheet.dart';
import '../../../widgets/reports/report_period_selector.dart';

class BalanceSheetScreen extends ConsumerStatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  ConsumerState<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends ConsumerState<BalanceSheetScreen> {
  bool isChartView = true;
  bool isAssetsExpanded = true;
  bool isLiabilitiesExpanded = true;
  bool isEquityExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(balanceSheetViewModelProvider);
      if (state.balanceSheets == null && !state.isLoading) {
        ref.read(balanceSheetViewModelProvider.notifier).loadAllBalanceSheets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final balanceSheetState = ref.watch(balanceSheetViewModelProvider);
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
          'Balance Sheet',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        actions: [
          if (balanceSheetState.hasData)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: const Color(0xFF1A1A1A),
                size: isTablet ? 24 : 22,
              ),
              onPressed: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: _buildBody(balanceSheetState, isSmallScreen, isTablet, isDesktop, horizontalPadding),
        ),
      ),
    );
  }

  Widget _buildBody(BalanceSheetState state, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
          strokeWidth: 2.5,
        ),
      );
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
                'Error loading balance sheet',
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
                onPressed: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
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

    if (!state.hasData || state.selectedBalanceSheet == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: isTablet ? 64 : 56,
                color: const Color(0xFF6B6B6B).withOpacity(0.4),
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              Text(
                'No balance sheet available',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 19 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.3,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                'Generate a balance sheet to view data',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 15 : 14,
                  color: const Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              SizedBox(height: isSmallScreen ? 24 : 28),
              ElevatedButton(
                onPressed: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
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
          // Period Selector
          if (state.balanceSheets != null && state.balanceSheets!.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: _buildPeriodSelector(state),
            ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Header Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildHeaderCard(state, isSmallScreen, isTablet, isDesktop),
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // View Toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildViewToggle(isSmallScreen, isTablet),
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Content
          isChartView 
            ? _buildChartView(state, isSmallScreen, isTablet, isDesktop, horizontalPadding) 
            : _buildTableView(state.selectedBalanceSheet!, isSmallScreen, isTablet, isDesktop, horizontalPadding),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: _buildActionButtons(state, isSmallScreen, isTablet),
          ),
          
          SizedBox(height: isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BalanceSheetState state, bool isSmallScreen, bool isTablet, bool isDesktop) {
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
            color: Colors.black.withOpacity(0.04),
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
                  color: const Color(0xFF9747FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_outlined,
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
                      'Balance Sheet',
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
                      'Financial position as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
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
                  'Total Assets',
                  '\$${state.selectedBalanceSheet!.totals.totalAssets.toStringAsFixed(2)}',
                  const Color(0xFF10B981),
                  Icons.trending_up,
                  isSmallScreen,
                  isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: _buildMetricCard(
                  'Total Liabilities',
                  '\$${state.selectedBalanceSheet!.totals.totalLiabilities.toStringAsFixed(2)}',
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
                  'Total Equity',
                  '\$${state.selectedBalanceSheet!.totals.totalEquity.toStringAsFixed(2)}',
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
            color: Colors.black.withOpacity(0.04),
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
                      color: const Color(0xFF9747FF).withOpacity(0.3),
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
                      color: const Color(0xFF9747FF).withOpacity(0.3),
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

  Widget _buildChartView(BalanceSheetState balanceSheetState, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: RepaintBoundary(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxValue(balanceSheetState.selectedBalanceSheet!),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '\$${rod.toY.toStringAsFixed(0)}\n${_getTooltipText(group.x.toDouble(), rodIndex)}',
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
                        fontSize: isTablet ? 15 : 14,
                        height: 1.2,
                      );
                      switch (value.toInt()) {
                        case 0:
                          return Text('Assets', style: style);
                        case 1:
                          return Text('Liabilities', style: style);
                        case 2:
                          return Text('Equity', style: style);
                        default:
                          return const Text('');
                      }
                    },
                    reservedSize: isTablet ? 34 : 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: isTablet ? 50 : 45,
                    interval: _getMaxValue(balanceSheetState.selectedBalanceSheet!) > 0 
                        ? _getMaxValue(balanceSheetState.selectedBalanceSheet!) / 5 
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
              barGroups: _getBarGroups(balanceSheetState.selectedBalanceSheet!),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _getMaxValue(balanceSheetState.selectedBalanceSheet!) > 0 
                    ? _getMaxValue(balanceSheetState.selectedBalanceSheet!) / 5 
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
    );
  }

  Widget _buildTableView(BalanceSheet balanceSheet, bool isSmallScreen, bool isTablet, bool isDesktop, double horizontalPadding) {
    final sectionTitleSize = isTablet ? 17.0 : 16.0;
    final rowTitleSize = isTablet ? 15.0 : 14.0;
    final subTitleSize = isTablet ? 13.0 : 12.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Assets Section
            _buildCollapsibleSectionHeader(
              'Assets', 
              '\$${balanceSheet.totals.totalAssets.toStringAsFixed(2)}', 
              isAssetsExpanded,
              () => setState(() => isAssetsExpanded = !isAssetsExpanded),
              sectionTitleSize,
              isTablet,
            ),
            if (isAssetsExpanded) ...[
              _buildSubSection('Current Assets', '(Short-term, highly liquid)', subTitleSize, isTablet),
              _buildBalanceSheetRow('Crypto Holdings', '\$${balanceSheet.assets.currentAssets.cryptoHoldings.totalValue.toStringAsFixed(2)}', rowTitleSize, isTablet),
              
              if (balanceSheet.assets.currentAssets.cryptoHoldings.holdings.isNotEmpty)
                _buildCryptoBreakdown(balanceSheet.assets.currentAssets.cryptoHoldings, isSmallScreen, isTablet),
              
              _buildTotalRow('Total Current Assets', '\$${balanceSheet.assets.currentAssets.total.toStringAsFixed(2)}', rowTitleSize, isTablet),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              _buildSubSection('Non-Current Assets', '(Long-term investments)', subTitleSize, isTablet),
              _buildBalanceSheetRow('Long-term Investments', '\$${balanceSheet.assets.nonCurrentAssets.longTermInvestments.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildBalanceSheetRow('Equipment', '\$${balanceSheet.assets.nonCurrentAssets.equipment.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildBalanceSheetRow('Other', '\$${balanceSheet.assets.nonCurrentAssets.other.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildTotalRow('Total Non-Current Assets', '\$${balanceSheet.assets.nonCurrentAssets.total.toStringAsFixed(2)}', rowTitleSize, isTablet),
            ],

            SizedBox(height: isSmallScreen ? 20 : 24),

            // Liabilities Section
            _buildCollapsibleSectionHeader(
              'Liabilities', 
              '\$${balanceSheet.totals.totalLiabilities.toStringAsFixed(2)}', 
              isLiabilitiesExpanded,
              () => setState(() => isLiabilitiesExpanded = !isLiabilitiesExpanded),
              sectionTitleSize,
              isTablet,
            ),
            if (isLiabilitiesExpanded) ...[
              _buildSubSection('Current Liabilities', '(Due within one year)', subTitleSize, isTablet),
              _buildBalanceSheetRow('Accounts Payable', '\$${balanceSheet.liabilities.currentLiabilities.accountsPayable.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildBalanceSheetRow('Accrued Expenses', '\$${balanceSheet.liabilities.currentLiabilities.accruedExpenses.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildBalanceSheetRow('Short-term Debt', '\$${balanceSheet.liabilities.currentLiabilities.shortTermDebt.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildBalanceSheetRow('Tax Liabilities', '\$${balanceSheet.liabilities.currentLiabilities.taxLiabilities.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildTotalRow('Total Current Liabilities', '\$${balanceSheet.liabilities.currentLiabilities.total.toStringAsFixed(2)}', rowTitleSize, isTablet),
              
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              _buildSubSection('Long-term Liabilities', '(Due after one year)', subTitleSize, isTablet),
              _buildBalanceSheetRow('Long-term Debt', '\$${balanceSheet.liabilities.longTermLiabilities.longTermDebt.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildBalanceSheetRow('Deferred Tax', '\$${balanceSheet.liabilities.longTermLiabilities.deferredTax.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildBalanceSheetRow('Other', '\$${balanceSheet.liabilities.longTermLiabilities.other.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildTotalRow('Total Long-term Liabilities', '\$${balanceSheet.liabilities.longTermLiabilities.total.toStringAsFixed(2)}', rowTitleSize, isTablet),
            ],

            SizedBox(height: isSmallScreen ? 20 : 24),

            // Equity Section
            _buildCollapsibleSectionHeader(
              'Equity', 
              '\$${balanceSheet.totals.totalEquity.toStringAsFixed(2)}', 
              isEquityExpanded,
              () => setState(() => isEquityExpanded = !isEquityExpanded),
              sectionTitleSize,
              isTablet,
            ),
            if (isEquityExpanded) ...[
              _buildSubSection('Equity', '(Owner\'s equity)', subTitleSize, isTablet),
              _buildBalanceSheetRow('Retained Earnings', '\$${balanceSheet.equity.retainedEarnings.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildBalanceSheetRow('Unrealized Gains/Losses', '\$${balanceSheet.equity.unrealizedGainsLosses.toStringAsFixed(2)}', rowTitleSize, isTablet),
              _buildTotalRow('Total Equity', '\$${balanceSheet.equity.total.toStringAsFixed(2)}', rowTitleSize, isTablet),
            ],
            
            SizedBox(height: isSmallScreen ? 20 : 24),

            // Summary Section
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Total Assets', '\$${balanceSheet.totals.totalAssets.toStringAsFixed(2)}', rowTitleSize),
                  SizedBox(height: isSmallScreen ? 10 : 12),
                  _buildSummaryRow('Total Liabilities', '\$${balanceSheet.totals.totalLiabilities.toStringAsFixed(2)}', rowTitleSize),
                  SizedBox(height: isSmallScreen ? 10 : 12),
                  _buildSummaryRow('Total Equity', '\$${balanceSheet.totals.totalEquity.toStringAsFixed(2)}', rowTitleSize),
                  SizedBox(height: isSmallScreen ? 14 : 16),
                  Container(height: 1, color: const Color(0xFFE5E5E5)),
                  SizedBox(height: isSmallScreen ? 14 : 16),
                  _buildSummaryRow(
                    'Liabilities + Equity', 
                    '\$${(balanceSheet.totals.totalLiabilities + balanceSheet.totals.totalEquity).toStringAsFixed(2)}', 
                    rowTitleSize,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleSectionHeader(String title, String amount, bool isExpanded, VoidCallback onTap, double fontSize, bool isTablet) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 18),
        decoration: const BoxDecoration(
          color: Color(0xFFF9FAFB),
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
                height: 1.3,
              ),
            ),
            SizedBox(width: isTablet ? 10 : 8),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xFF6B6B6B),
                size: isTablet ? 24 : 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(String title, String subtitle, double subTitleSize, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 18,
        vertical: isTablet ? 12 : 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.1,
              height: 1.3,
            ),
          ),
          SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: subTitleSize,
              color: const Color(0xFF6B6B6B),
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSheetRow(String item, String amount, double fontSize, bool isTablet, {bool isNegative = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40 : 36,
        vertical: isTablet ? 10 : 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                color: const Color(0xFF6B6B6B),
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              color: isNegative ? Colors.red[600] : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, double fontSize, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 18),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 18,
        vertical: isTablet ? 14 : 12,
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
              color: const Color(0xFF1A1A1A),
              height: 1.3,
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
        ),
      ],
    );
  }

  Widget _buildCryptoBreakdown(CryptoHoldings cryptoHoldings, bool isSmallScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(
        left: isTablet ? 20 : 18,
        right: isTablet ? 20 : 18,
        top: isSmallScreen ? 10 : 12,
        bottom: isSmallScreen ? 10 : 12,
      ),
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crypto Breakdown',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.1,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          ...cryptoHoldings.holdings.entries.map((entry) {
            final symbol = entry.key;
            final asset = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        symbol,
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                      Text(
                        '\$${asset.currentValue.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCryptoDetail('Balance', '${asset.balance.toStringAsFixed(4)} $symbol', isTablet),
                      ),
                      Expanded(
                        child: _buildCryptoDetail('Price', '\$${asset.currentPrice.toStringAsFixed(2)}', isTablet),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCryptoDetail('Cost Basis', '\$${asset.costBasis.toStringAsFixed(2)}', isTablet),
                      ),
                      Expanded(
                        child: _buildCryptoDetail('Avg Cost', '\$${asset.averageCost.toStringAsFixed(2)}', isTablet),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCryptoDetail(
                          'Unrealized P&L', 
                          '\$${asset.unrealizedGainLoss.toStringAsFixed(2)}',
                          isTablet,
                          color: asset.unrealizedGainLoss >= 0 ? Colors.green[600] : Colors.red[600],
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCryptoDetail(String label, String value, bool isTablet, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTablet ? 11 : 10,
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTablet ? 12 : 11,
            color: color ?? const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BalanceSheetState state, bool isSmallScreen, bool isTablet) {
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
            onPressed: () => _showDownloadOptions(context, state.selectedBalanceSheet!),
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

  Widget _buildPeriodSelector(BalanceSheetState state) {
    if (state.balanceSheets == null || state.balanceSheets!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ReportPeriodSelector<BalanceSheet>(
      items: state.balanceSheets!,
      selectedItem: state.selectedBalanceSheet!,
      formatPeriod: (balanceSheet) {
        final start = balanceSheet.periodStart;
        final end = balanceSheet.periodEnd;
        return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
      },
      onPeriodChanged: (balanceSheet) {
        ref.read(balanceSheetViewModelProvider.notifier).selectBalanceSheet(balanceSheet);
      },
    );
  }

  double _getMaxValue(BalanceSheet balanceSheet) {
    final assets = balanceSheet.totals.totalAssets.abs();
    final liabilities = balanceSheet.totals.totalLiabilities.abs();
    final equity = balanceSheet.totals.totalEquity.abs();
    
    final maxValue = [assets, liabilities, equity].reduce((a, b) => a > b ? a : b) * 1.1;
    
    if (maxValue == 0) {
      return 10000;
    }
    
    return maxValue;
  }

  List<BarChartGroupData> _getBarGroups(BalanceSheet balanceSheet) {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: balanceSheet.totals.totalAssets.abs(),
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
            toY: balanceSheet.totals.totalLiabilities.abs(),
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
            toY: balanceSheet.totals.totalEquity.abs(),
            color: const Color(0xFF3B82F6),
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

  String _getTooltipText(double x, int rodIndex) {
    switch (x.toInt()) {
      case 0:
        return 'Total Assets';
      case 1:
        return 'Total Liabilities';
      case 2:
        return 'Total Equity';
      default:
        return '';
    }
  }

  Future<void> _showDownloadOptions(BuildContext context, BalanceSheet balanceSheet) async {
    showDownloadReportOptions(
      context: context,
      onPdfDownload: () => _downloadPdf(context, balanceSheet),
      onExcelDownload: () => _exportToExcel(context, balanceSheet),
    );
  }

  Future<void> _exportToExcel(BuildContext context, BalanceSheet balanceSheet) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
        ),
      );

      final filePath = await ExcelExportHelper.exportBalanceSheetToExcel(balanceSheet);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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

  Future<void> _downloadPdf(BuildContext context, BalanceSheet balanceSheet) async {
    try {
      showDialog(
        context: context,
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
          'total_assets': balanceSheet.totals.totalAssets,
          'total_liabilities': balanceSheet.totals.totalLiabilities,
          'total_equity': balanceSheet.totals.totalEquity,
        },
        'assets': {
          'current_assets': {
            'crypto_holdings': balanceSheet.assets.currentAssets.cryptoHoldings.totalValue,
            'cash_equivalents': balanceSheet.assets.currentAssets.cashEquivalents,
            'receivables': balanceSheet.assets.currentAssets.receivables.toDouble(),
            'total': balanceSheet.assets.currentAssets.total,
          },
          'non_current_assets': {
            'long_term_investments': balanceSheet.assets.nonCurrentAssets.longTermInvestments,
            'equipment': balanceSheet.assets.nonCurrentAssets.equipment,
            'other': balanceSheet.assets.nonCurrentAssets.other,
            'total': balanceSheet.assets.nonCurrentAssets.total,
          },
          'total': balanceSheet.assets.total,
        },
        'liabilities': {
          'current_liabilities': {
            'accounts_payable': balanceSheet.liabilities.currentLiabilities.accountsPayable.toDouble(),
            'accrued_expenses': balanceSheet.liabilities.currentLiabilities.accruedExpenses,
            'short_term_debt': balanceSheet.liabilities.currentLiabilities.shortTermDebt,
            'tax_liabilities': balanceSheet.liabilities.currentLiabilities.taxLiabilities,
            'total': balanceSheet.liabilities.currentLiabilities.total,
          },
          'long_term_liabilities': {
            'long_term_debt': balanceSheet.liabilities.longTermLiabilities.longTermDebt,
            'deferred_tax': balanceSheet.liabilities.longTermLiabilities.deferredTax,
            'other': balanceSheet.liabilities.longTermLiabilities.other,
            'total': balanceSheet.liabilities.longTermLiabilities.total,
          },
          'total': balanceSheet.liabilities.total,
        },
        'equity': {
          'retained_earnings': balanceSheet.equity.retainedEarnings.toDouble(),
          'unrealized_gains_losses': balanceSheet.equity.unrealizedGainsLosses,
          'total': balanceSheet.equity.total,
        },
      };

      final filePath = await PdfGenerationHelper.generateBalanceSheetPdf(reportData);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
}
