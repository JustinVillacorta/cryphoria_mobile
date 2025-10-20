import 'package:flutter/material.dart';
import 'balance_sheet_screen.dart';
import 'income_statement_screen.dart';
import 'cash_flow_screen.dart';
import 'investment_performance_screen.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Reports',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Scrollable content with all report sections
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Financial Reports Section
                      _buildSectionHeader('Financial Reports'),
                      const SizedBox(height: 16),
                      _buildFinancialStatementsContent(),
                      const SizedBox(height: 32),

                      // Payroll Reports Section
                      _buildSectionHeader('Payroll Reports'),
                      const SizedBox(height: 16),
                      _buildPayrollReportsContent(),
                      const SizedBox(height: 32),

                      // Tax Reports Section
                      _buildSectionHeader('Tax Reports'),
                      const SizedBox(height: 16),
                      _buildTaxReportsContent(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (title == 'Balance Sheet') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BalanceSheetScreen(),
            ),
          );
        } else if (title == 'Income Statement') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncomeStatementScreen(),
            ),
          );
        } else if (title == 'Cash Flow') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CashFlowScreen(),
            ),
          );
        } else if (title == 'Investment Performance') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvestmentPerformanceScreen(),
            ),
          );
        } else if (title == 'Payroll Summary') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PayrollSummaryScreen(),
            ),
          );
        } else if (title == 'Tax Report') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaxReportsScreen(),
            ),
          );
        }
      },
      child: Container(
        height: 140, // Increased height to fix overflow
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFinancialStatementsContent() {
    return Column(
      children: [
        // First Row
        Row(
          children: [
            Expanded(
              child: _buildReportCard(
                'Balance Sheet',
                'Last updated: Today',
                const Color(0xFF3B82F6),
                Icons.description,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildReportCard(
                'Income Statement',
                'Last updated: Today',
                const Color(0xFF8B5CF6),
                Icons.bar_chart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Second Row
        Row(
          children: [
            Expanded(
              child: _buildReportCard(
                'Cash Flow',
                'Last updated: Today',
                const Color(0xFF8B5CF6),
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildReportCard(
                'Investment Performance',
                'Last updated: Today',
                const Color(0xFFF97316),
                Icons.show_chart,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayrollReportsContent() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PayrollSummaryScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payroll Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Last updated: Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxReportsContent() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TaxReportsScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Last updated: Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
