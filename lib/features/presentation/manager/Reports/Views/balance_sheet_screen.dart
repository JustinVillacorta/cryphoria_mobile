import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ViewModels/balance_sheet_view_model.dart';
import '../../../../domain/entities/balance_sheet.dart';
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

    return ReportScreenLayout(
      title: 'Balance Sheet',
      hasData: balanceSheetState.hasData,
      isLoading: balanceSheetState.isLoading,
      onRefresh: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
      builder: (context, responsive) => _buildBody(balanceSheetState, responsive),
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildBody(BalanceSheetState state, ResponsiveInfo responsive) {
    if (state.isLoading) {
      return const BalanceSheetSkeleton();
    }

    if (state.error != null) {
      return ReportErrorState(
        title: 'Error loading balance sheet',
        message: state.error!,
        onRetry: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    if (!state.hasData || state.selectedBalanceSheet == null) {
      return ReportEmptyState(
        title: 'No balance sheet available',
        message: 'Generate a balance sheet to view data',
        icon: Icons.account_balance_outlined,
        onAction: () => ref.read(balanceSheetViewModelProvider.notifier).refresh(),
        isSmallScreen: responsive.isSmallScreen,
        isTablet: responsive.isTablet,
        horizontalPadding: responsive.horizontalPadding,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: responsive.isSmallScreen ? 12 : 16),
      child: Column(
        children: [
          if (state.balanceSheets != null && state.balanceSheets!.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: _buildPeriodSelector(state),
            ),

          SizedBox(height: responsive.isSmallScreen ? 12 : 16),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportHeaderCard(
              title: 'Balance Sheet',
              subtitle: 'Financial position as of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              icon: Icons.account_balance_outlined,
              metrics: [
                MetricData(
                  title: 'Total Assets',
                  value: '\$${state.selectedBalanceSheet!.totals.totalAssets.toStringAsFixed(2)}',
                  color: const Color(0xFF10B981),
                  icon: Icons.trending_up,
                ),
                MetricData(
                  title: 'Total Liabilities',
                  value: '\$${state.selectedBalanceSheet!.totals.totalLiabilities.toStringAsFixed(2)}',
                  color: const Color(0xFFEF4444),
                  icon: Icons.trending_down,
                ),
                MetricData(
                  title: 'Total Equity',
                  value: '\$${state.selectedBalanceSheet!.totals.totalEquity.toStringAsFixed(2)}',
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
            ? _buildChartView(state, responsive) 
            : _buildTableView(state.selectedBalanceSheet!, responsive),

          SizedBox(height: responsive.isSmallScreen ? 20 : 24),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: ReportActionButtons(
              onClose: () => Navigator.pop(context),
              onDownload: () => _showDownloadOptions(context, state.selectedBalanceSheet!),
              isSmallScreen: responsive.isSmallScreen,
              isTablet: responsive.isTablet,
            ),
          ),

          SizedBox(height: responsive.isSmallScreen ? 24 : 32),
        ],
      ),
    );
  }


  Widget _buildChartView(BalanceSheetState balanceSheetState, ResponsiveInfo responsive) {
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
                        fontSize: responsive.isTablet ? 15 : 14,
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
                    reservedSize: responsive.isTablet ? 34 : 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: responsive.isTablet ? 50 : 45,
                    interval: _getMaxValue(balanceSheetState.selectedBalanceSheet!) > 0 
                        ? _getMaxValue(balanceSheetState.selectedBalanceSheet!) / 5 
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

  Widget _buildTableView(BalanceSheet balanceSheet, ResponsiveInfo responsive) {
    final sectionTitleSize = responsive.isTablet ? 17.0 : 16.0;
    final rowTitleSize = responsive.isTablet ? 15.0 : 14.0;
    final subTitleSize = responsive.isTablet ? 13.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: Container(
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
          children: [
            _buildCollapsibleSectionHeader(
              'Assets', 
              '\$${balanceSheet.totals.totalAssets.toStringAsFixed(2)}', 
              isAssetsExpanded,
              () => setState(() => isAssetsExpanded = !isAssetsExpanded),
              sectionTitleSize,
              responsive.isTablet,
            ),
            if (isAssetsExpanded) ...[
              _buildSubSection('Current Assets', '(Short-term, highly liquid)', subTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Crypto Holdings', '\$${balanceSheet.assets.currentAssets.cryptoHoldings.totalValue.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),

              if (balanceSheet.assets.currentAssets.cryptoHoldings.holdings.isNotEmpty)
                _buildCryptoBreakdown(balanceSheet.assets.currentAssets.cryptoHoldings, responsive.isSmallScreen, responsive.isTablet),

              _buildTotalRow('Total Current Assets', '\$${balanceSheet.assets.currentAssets.total.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),

              SizedBox(height: responsive.isSmallScreen ? 16 : 20),

              _buildSubSection('Non-Current Assets', '(Long-term investments)', subTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Long-term Investments', '\$${balanceSheet.assets.nonCurrentAssets.longTermInvestments.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Equipment', '\$${balanceSheet.assets.nonCurrentAssets.equipment.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Other', '\$${balanceSheet.assets.nonCurrentAssets.other.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildTotalRow('Total Non-Current Assets', '\$${balanceSheet.assets.nonCurrentAssets.total.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
            ],

            SizedBox(height: responsive.isSmallScreen ? 20 : 24),

            _buildCollapsibleSectionHeader(
              'Liabilities', 
              '\$${balanceSheet.totals.totalLiabilities.toStringAsFixed(2)}', 
              isLiabilitiesExpanded,
              () => setState(() => isLiabilitiesExpanded = !isLiabilitiesExpanded),
              sectionTitleSize,
              responsive.isTablet,
            ),
            if (isLiabilitiesExpanded) ...[
              _buildSubSection('Current Liabilities', '(Due within one year)', subTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Accounts Payable', '\$${balanceSheet.liabilities.currentLiabilities.accountsPayable.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Accrued Expenses', '\$${balanceSheet.liabilities.currentLiabilities.accruedExpenses.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Short-term Debt', '\$${balanceSheet.liabilities.currentLiabilities.shortTermDebt.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Tax Liabilities', '\$${balanceSheet.liabilities.currentLiabilities.taxLiabilities.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildTotalRow('Total Current Liabilities', '\$${balanceSheet.liabilities.currentLiabilities.total.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),

              SizedBox(height: responsive.isSmallScreen ? 16 : 20),

              _buildSubSection('Long-term Liabilities', '(Due after one year)', subTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Long-term Debt', '\$${balanceSheet.liabilities.longTermLiabilities.longTermDebt.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Deferred Tax', '\$${balanceSheet.liabilities.longTermLiabilities.deferredTax.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Other', '\$${balanceSheet.liabilities.longTermLiabilities.other.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildTotalRow('Total Long-term Liabilities', '\$${balanceSheet.liabilities.longTermLiabilities.total.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
            ],

            SizedBox(height: responsive.isSmallScreen ? 20 : 24),

            _buildCollapsibleSectionHeader(
              'Equity', 
              '\$${balanceSheet.totals.totalEquity.toStringAsFixed(2)}', 
              isEquityExpanded,
              () => setState(() => isEquityExpanded = !isEquityExpanded),
              sectionTitleSize,
              responsive.isTablet,
            ),
            if (isEquityExpanded) ...[
              _buildSubSection('Equity', '(Owner\'s equity)', subTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Retained Earnings', '\$${balanceSheet.equity.retainedEarnings.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildBalanceSheetRow('Unrealized Gains/Losses', '\$${balanceSheet.equity.unrealizedGainsLosses.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
              _buildTotalRow('Total Equity', '\$${balanceSheet.equity.total.toStringAsFixed(2)}', rowTitleSize, responsive.isTablet),
            ],

            SizedBox(height: responsive.isSmallScreen ? 20 : 24),

            Container(
              padding: EdgeInsets.all(responsive.isTablet ? 24 : 20),
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
                  SizedBox(height: responsive.isSmallScreen ? 10 : 12),
                  _buildSummaryRow('Total Liabilities', '\$${balanceSheet.totals.totalLiabilities.toStringAsFixed(2)}', rowTitleSize),
                  SizedBox(height: responsive.isSmallScreen ? 10 : 12),
                  _buildSummaryRow('Total Equity', '\$${balanceSheet.totals.totalEquity.toStringAsFixed(2)}', rowTitleSize),
                  SizedBox(height: responsive.isSmallScreen ? 14 : 16),
                  Container(height: 1, color: const Color(0xFFE5E5E5)),
                  SizedBox(height: responsive.isSmallScreen ? 14 : 16),
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
                          false, // isTablet
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
    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => ExcelExportHelper.exportBalanceSheetToExcel(balanceSheet),
      fileType: 'Excel',
    );
  }

  Future<void> _downloadPdf(BuildContext context, BalanceSheet balanceSheet) async {
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

    await ReportDownloadHandler.handleReportDownload(
      context: context,
      generateFile: () => PdfGenerationHelper.generateBalanceSheetPdf(reportData),
      fileType: 'PDF',
    );
  }
}