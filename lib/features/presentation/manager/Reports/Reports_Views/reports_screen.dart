import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'balance_sheet_screen.dart';
import 'income_statement_screen.dart';
import 'cash_flow_screen.dart';
import 'payroll_summary_screen.dart';
import 'tax_reports_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 20.0;
    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Reports',
                    style: GoogleFonts.inter(
                      fontSize: isDesktop ? 28.0 : isTablet ? 26.0 : 24.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Scrollable content with all report sections
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Financial Reports Section
                          _buildSectionHeader('Financial Reports', isTablet, isDesktop),
                          SizedBox(height: isSmallScreen ? 14 : 16),
                          _buildFinancialStatementsContent(isSmallScreen, isTablet, isDesktop),
                          SizedBox(height: isSmallScreen ? 28 : 32),

                          // Payroll Reports Section
                          _buildSectionHeader('Payroll Reports', isTablet, isDesktop),
                          SizedBox(height: isSmallScreen ? 14 : 16),
                          _buildPayrollReportsContent(isSmallScreen, isTablet, isDesktop),
                          SizedBox(height: isSmallScreen ? 28 : 32),

                          // Tax Reports Section
                          _buildSectionHeader('Tax Reports', isTablet, isDesktop),
                          SizedBox(height: isSmallScreen ? 14 : 16),
                          _buildTaxReportsContent(isSmallScreen, isTablet, isDesktop),
                          SizedBox(height: isSmallScreen ? 16 : 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isTablet, bool isDesktop) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A1A),
        letterSpacing: -0.3,
        height: 1.3,
      ),
    );
  }

  Widget _buildFinancialStatementsContent(bool isSmallScreen, bool isTablet, bool isDesktop) {
    return Column(
      children: [
        // Balance Sheet Card
        _buildReportCard(
          title: 'Balance Sheet',
          subtitle: 'Last updated: Today',
          color: const Color(0xFF3B82F6),
          icon: Icons.description_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BalanceSheetScreen(),
              ),
            );
          },
          isSmallScreen: isSmallScreen,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Income Statement Card
        _buildReportCard(
          title: 'Income Statement',
          subtitle: 'Last updated: Today',
          color: const Color(0xFF8B5CF6),
          icon: Icons.bar_chart_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IncomeStatementScreen(),
              ),
            );
          },
          isSmallScreen: isSmallScreen,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Cash Flow Card
        _buildReportCard(
          title: 'Cash Flow',
          subtitle: 'Last updated: Today',
          color: const Color(0xFF8B5CF6),
          icon: Icons.trending_up_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CashFlowScreen(),
              ),
            );
          },
          isSmallScreen: isSmallScreen,
          isTablet: isTablet,
          isDesktop: isDesktop,
        ),
      ],
    );
  }

  Widget _buildPayrollReportsContent(bool isSmallScreen, bool isTablet, bool isDesktop) {
    return _buildReportCard(
      title: 'Payroll Summary',
      subtitle: 'Last updated: Today',
      color: const Color(0xFF10B981),
      icon: Icons.receipt_long_outlined,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PayrollSummaryScreen(),
          ),
        );
      },
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
    );
  }

  Widget _buildTaxReportsContent(bool isSmallScreen, bool isTablet, bool isDesktop) {
    return _buildReportCard(
      title: 'Tax Report',
      subtitle: 'Last updated: Today',
      color: const Color(0xFFF59E0B),
      icon: Icons.receipt_long_outlined,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TaxReportsScreen(),
          ),
        );
      },
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSmallScreen,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final titleSize = isDesktop ? 17.0 : isTablet ? 16.0 : 15.0;
    final subtitleSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final iconContainerSize = isDesktop ? 48.0 : isTablet ? 44.0 : 40.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPadding),
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
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: subtitleSize,
                      color: const Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF6B6B6B),
              size: isTablet ? 24 : 22,
            ),
          ],
        ),
      ),
    );
  }
}
