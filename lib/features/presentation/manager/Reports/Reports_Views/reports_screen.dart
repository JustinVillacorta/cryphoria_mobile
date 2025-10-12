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
  int selectedTabIndex = 0;
  int selectedPeriodIndex = 0;

  final List<String> tabs = ['Financial', 'Payroll ', 'Tax '];
  final List<String> periods = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

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

              // Tab Buttons (remain fixed)
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTabIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0x1A9747FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: isSelected ? Color(0xff9747FF) : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Make periods part of the scrollable area by moving them into the SingleChildScrollView below.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Period Buttons (now scroll with content)
                      Row(
                        children: List.generate(periods.length, (index) {
                          final isSelected = selectedPeriodIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPeriodIndex = index;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: index < periods.length - 1 ? 8 : 0),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0x1A9747FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(50), // smoother radius
                                  border: Border.all(
                                    color: isSelected ? const Color(0x1A9747FF) : Colors.grey[300]!,
                                    width: 1.2, // subtle border
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    periods[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: isSelected ? const Color(0xff9747FF) : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // The existing report content
                      _buildSelectedTabContent(),
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

  Widget _buildRiskAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Risk Assessment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '3 alerts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.purple[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // High Risk Alert
        _buildRiskAlert(
          title: 'Decreasing Cash Flow',
          subtitle: 'Cash flow has decreased by 18% compared to last quarter.',
          recommendation: 'Review accounts receivable processes and consider implementing stricter collection policies.',
          level: 'high',
          color: Colors.white!,
          iconColor: Colors.red,
          levelColor: Colors.red,
        ),
        const SizedBox(height: 12),

        // Medium Risk Alert
        _buildRiskAlert(
          title: 'Increasing Operational Expenses',
          subtitle: 'Operational expenses have increased by 12% while revenue remained flat.',
          recommendation: 'Conduct expense audit and identify areas for potential cost reduction.',
          level: 'medium',
          color: Colors.white!,
          iconColor: Colors.orange,
          levelColor: Colors.orange,
        ),
        const SizedBox(height: 12),

        // Low Risk Alert
        _buildRiskAlert(
          title: 'Debt-to-Equity Ratio Rising',
          subtitle: 'Your debt-to-equity ratio is approaching industry warning levels (currently 1.8).',
          recommendation: 'Consider equity financing options instead of taking on additional debt.',
          level: 'low',
          color: Colors.white!,
          iconColor: Colors.blue,
          levelColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildRiskAlert({
    required String title,
    required String subtitle,
    required String recommendation,
    required String level,
    required Color color,
    required Color? iconColor,
    required Color? levelColor,
  }) {
    IconData getIcon() {
      switch (level) {
        case 'high':
          return Icons.warning;
        case 'medium':
          return Icons.error_outline;
        case 'low':
          return Icons.info_outline;
        default:
          return Icons.info_outline;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor!.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                getIcon(),
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: levelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendation:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildFinancialStatementsContent();
      case 1:
        return _buildPayrollReportsContent();
      case 2:
        return _buildTaxReportsContent();
      default:
        return _buildFinancialStatementsContent();
    }
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
        const SizedBox(height: 30),

        // Risk Assessment Section
        _buildRiskAssessmentSection(),
      ],
    );
  }

  Widget _buildPayrollReportsContent() {
    return Column(
      children: [
        // Payroll Summary Card
        GestureDetector(
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
        ),
        const SizedBox(height: 30),

        // Risk Assessment Section for Payroll
        _buildPayrollRiskAssessmentSection(),
      ],
    );
  }

  Widget _buildTaxReportsContent() {
    return Column(
      children: [
        // VAT Report Card
        GestureDetector(
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
                            'VAT Report',
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
        ),

        const SizedBox(height: 20),

        // Risk Assessment Section
        _buildTaxRiskAssessmentSection(),
      ],
    );
  }

  Widget _buildTaxRiskAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Risk Assessment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '3 alerts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.purple[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // High Risk - VAT Underpayment (styled like financial/payroll)
        _buildRiskAlert(
          title: 'Potential VAT Underpayment',
          subtitle: 'System detected a 3% discrepancy between calculated VAT and reported amounts.',
          recommendation: 'Conduct internal audit of VAT calculations before next filing period.',
          level: 'high',
          color: Colors.white,
          iconColor: const Color(0xFFDC2626),
          levelColor: const Color(0xFFDC2626),
        ),
        const SizedBox(height: 12),

        // Medium Risk - Late Filing (styled like financial/payroll)
        _buildRiskAlert(
          title: 'Late Filing Risk',
          subtitle: 'Two recent tax filings were submitted within 48 hours of deadline.',
          recommendation: 'Implement earlier preparation schedules with 10-day buffer before deadlines.',
          level: 'medium',
          color: Colors.white,
          iconColor: const Color(0xFFF59E0B),
          levelColor: const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 12),

        // Low Risk - Missing Documentation (styled like financial/payroll)
        _buildRiskAlert(
          title: 'Missing Documentation',
          subtitle: 'Some expense receipts lack proper categorization for tax deduction purposes.',
          recommendation: 'Implement standardized receipt management system with required categorization.',
          level: 'low',
          color: Colors.white,
          iconColor: const Color(0xFF3B82F6),
          levelColor: const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildPayrollRiskAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Risk Assessment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '3 alerts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.purple[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Use the same visual style as the financial Risk Assessment items
        _buildRiskAlert(
          title: 'Overtime Costs Exceeding Budget',
          subtitle: 'Overtime expenses are 23% above projected budget for this period.',
          recommendation: 'Analyze staffing levels and workload distribution to reduce overtime requirements.',
          level: 'high',
          color: Colors.white,
          iconColor: Colors.red[600],
          levelColor: Colors.red[600],
        ),
        const SizedBox(height: 12),

        _buildRiskAlert(
          title: 'Inconsistent Deduction Patterns',
          subtitle: 'Unusual patterns detected in employee benefit deductions for 3 employees.',
          recommendation: 'Verify deduction calculations and ensure compliance with current regulations.',
          level: 'medium',
          color: Colors.white,
          iconColor: Colors.orange[600],
          levelColor: Colors.orange[600],
        ),
        const SizedBox(height: 12),

        _buildRiskAlert(
          title: 'Payroll Processing Delays',
          subtitle: 'Average processing time has increased from 2 to 3 days.',
          recommendation: 'Review payroll workflow and consider automation improvements.',
          level: 'low',
          color: Colors.white,
          iconColor: Colors.blue[600],
          levelColor: Colors.blue[600],
        ),
      ],
    );
  }
}
