import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Reports_ViewModel/income_statement_viewmodel.dart';
import '../../../../domain/entities/income_statement.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../widgets/excel_export_helper.dart';
import '../../../widgets/pdf_generation_helper.dart';

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
    // Load income statement data only if not already loaded
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
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Income Statement',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (incomeStatementState.hasData)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () => ref.read(incomeStatementViewModelProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(incomeStatementState),
    );
  }

  Widget _buildBody(IncomeStatementState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      );
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading income statement data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!state.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Income Statement Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Income statement data will appear here once available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(incomeStatementViewModelProvider.notifier).loadIncomeStatements();
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(state),
          const SizedBox(height: 20),
          
          // Summary Cards
          _buildSummaryCards(state.selectedIncomeStatement!),
          const SizedBox(height: 20),
          
          // View Toggle
          _buildViewToggle(),
          const SizedBox(height: 20),
          
          // Content (Charts or Table)
          if (isChartView)
            _buildChartView(state.selectedIncomeStatement!)
          else
            _buildTableView(state.selectedIncomeStatement!),
          
          const SizedBox(height: 20),
          
          // Metadata
          _buildMetadata(state.selectedIncomeStatement!),
          
          const SizedBox(height: 20),
          
          // Export Buttons
          _buildExportButtons(state.selectedIncomeStatement!),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(IncomeStatementState state) {
    if (state.incomeStatements == null || state.incomeStatements!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<IncomeStatement>(
              value: state.selectedIncomeStatement,
              isExpanded: true,
              items: state.incomeStatements!.map((statement) {
                final startDate = statement.periodStart;
                final endDate = statement.periodEnd;
                final periodText = '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
                
                return DropdownMenuItem<IncomeStatement>(
                  value: statement,
                  child: Text(periodText),
                );
              }).toList(),
              onChanged: (IncomeStatement? newValue) {
                if (newValue != null) {
                  ref.read(incomeStatementViewModelProvider.notifier).selectIncomeStatement(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(IncomeStatement incomeStatement) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Revenue',
                '\$${incomeStatement.revenue.totalRevenue.toStringAsFixed(2)}',
                const Color(0xFF4CAF50),
                Icons.trending_up,
                [
                  'Trading: \$${incomeStatement.revenue.tradingRevenue.toStringAsFixed(2)}',
                  'Payroll: \$${incomeStatement.revenue.payrollIncome.toStringAsFixed(2)}',
                  'Other: \$${incomeStatement.revenue.otherIncome.toStringAsFixed(2)}',
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Expenses',
                '\$${incomeStatement.expenses.totalExpenses.toStringAsFixed(2)}',
                const Color(0xFFF44336),
                Icons.trending_down,
                [
                  'Fees: \$${incomeStatement.expenses.transactionFees.toStringAsFixed(2)}',
                  'Losses: \$${incomeStatement.expenses.tradingLosses.toStringAsFixed(2)}',
                  'Operational: \$${incomeStatement.expenses.operationalExpenses.toStringAsFixed(2)}',
                  'Tax: \$${incomeStatement.expenses.taxExpenses.toStringAsFixed(2)}',
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Gross Profit',
                '\$${incomeStatement.grossProfit.grossProfit.toStringAsFixed(2)}',
                const Color(0xFF2196F3),
                Icons.account_balance_wallet,
                [
                  'Margin: ${incomeStatement.grossProfit.grossProfitMargin.toStringAsFixed(1)}%',
                  'COGS: \$${incomeStatement.grossProfit.costOfGoodsSold.toStringAsFixed(2)}',
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Net Income',
                '\$${incomeStatement.netIncome.netIncome.toStringAsFixed(2)}',
                incomeStatement.netIncome.isProfitable ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                incomeStatement.netIncome.isProfitable ? Icons.check_circle : Icons.warning,
                [
                  'Margin: ${incomeStatement.netIncome.netProfitMargin.toStringAsFixed(1)}%',
                  'Status: ${incomeStatement.summary.profitabilityStatus}',
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color, IconData icon, List<String> details) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                detail,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isChartView ? null : () => setState(() => isChartView = true),
                icon: const Icon(Icons.bar_chart),
                label: const Text('Charts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChartView ? const Color(0xFF8B5CF6) : Colors.grey[300],
                  foregroundColor: isChartView ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isChartView ? () => setState(() => isChartView = false) : null,
                icon: const Icon(Icons.table_chart),
                label: const Text('Table'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isChartView ? const Color(0xFF8B5CF6) : Colors.grey[300],
                  foregroundColor: !isChartView ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartView(IncomeStatement incomeStatement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [
                    incomeStatement.revenue.totalRevenue,
                    incomeStatement.expenses.totalExpenses,
                    incomeStatement.grossProfit.grossProfit,
                    incomeStatement.netIncome.netIncome,
                  ].reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const titles = ['Revenue', 'Expenses', 'Gross Profit', 'Net Income'];
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '\$${value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: incomeStatement.revenue.totalRevenue,
                          color: const Color(0xFF4CAF50),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: incomeStatement.expenses.totalExpenses,
                          color: const Color(0xFFF44336),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: incomeStatement.grossProfit.grossProfit,
                          color: const Color(0xFF2196F3),
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: incomeStatement.netIncome.netIncome,
                          color: incomeStatement.netIncome.isProfitable ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView(IncomeStatement incomeStatement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income Statement Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Revenue Section
            _buildTableSection('Revenue', [
              _buildTableRow('Total Revenue', incomeStatement.revenue.totalRevenue),
              _buildTableRow('Trading Revenue', incomeStatement.revenue.tradingRevenue),
              _buildTableRow('Payroll Income', incomeStatement.revenue.payrollIncome),
              _buildTableRow('Other Income', incomeStatement.revenue.otherIncome),
            ], const Color(0xFF4CAF50)),
            
            const SizedBox(height: 16),
            
            // Expenses Section
            _buildTableSection('Expenses', [
              _buildTableRow('Total Expenses', incomeStatement.expenses.totalExpenses),
              _buildTableRow('Transaction Fees', incomeStatement.expenses.transactionFees),
              _buildTableRow('Trading Losses', incomeStatement.expenses.tradingLosses),
              _buildTableRow('Operational Expenses', incomeStatement.expenses.operationalExpenses),
              _buildTableRow('Tax Expenses', incomeStatement.expenses.taxExpenses),
            ], const Color(0xFFF44336)),
            
            const SizedBox(height: 16),
            
            // Profitability Section
            _buildTableSection('Profitability', [
              _buildTableRow('Gross Profit', incomeStatement.grossProfit.grossProfit),
              _buildTableRow('Gross Profit Margin', incomeStatement.grossProfit.grossProfitMargin, isPercentage: true),
              _buildTableRow('Net Income', incomeStatement.netIncome.netIncome),
              _buildTableRow('Net Profit Margin', incomeStatement.netIncome.netProfitMargin, isPercentage: true),
            ], const Color(0xFF2196F3)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(String title, List<Widget> rows, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  Widget _buildTableRow(String label, double amount, {bool isPercentage = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            isPercentage ? '${amount.toStringAsFixed(1)}%' : '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(IncomeStatement incomeStatement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildMetadataRow('Period', '${incomeStatement.periodStart.day}/${incomeStatement.periodStart.month}/${incomeStatement.periodStart.year} - ${incomeStatement.periodEnd.day}/${incomeStatement.periodEnd.month}/${incomeStatement.periodEnd.year}'),
            _buildMetadataRow('Currency', incomeStatement.currency),
            _buildMetadataRow('Generated', '${incomeStatement.generatedAt.day}/${incomeStatement.generatedAt.month}/${incomeStatement.generatedAt.year}'),
            _buildMetadataRow('Transactions Processed', incomeStatement.metadata.transactionCount.toString()),
            _buildMetadataRow('Payroll Entries', incomeStatement.metadata.payrollCount.toString()),
            _buildMetadataRow('Period Length', '${incomeStatement.metadata.periodLengthDays} days'),
            _buildMetadataRow('Primary Revenue Source', incomeStatement.summary.primaryRevenueSource),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons(IncomeStatement incomeStatement) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadPdf(context, incomeStatement),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadExcel(context, incomeStatement),
            icon: const Icon(Icons.table_chart),
            label: const Text('Export Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadPdf(BuildContext context, IncomeStatement incomeStatement) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert IncomeStatement to report data format for PDF generation
      final reportData = {
        'summary': {
          'total_revenue': incomeStatement.revenue.totalRevenue,
          'total_expenses': incomeStatement.expenses.totalExpenses,
          'net_income': incomeStatement.netIncome.netIncome,
          'gross_profit': incomeStatement.grossProfit.grossProfit,
          'profitability_status': incomeStatement.summary.profitabilityStatus,
        },
        'revenue': {
          'trading_revenue': incomeStatement.revenue.tradingRevenue,
          'payroll_income': incomeStatement.revenue.payrollIncome,
          'other_income': incomeStatement.revenue.otherIncome,
        },
        'expenses': {
          'transaction_fees': incomeStatement.expenses.transactionFees,
          'trading_losses': incomeStatement.expenses.tradingLosses,
          'operational_expenses': incomeStatement.expenses.operationalExpenses,
          'tax_expenses': incomeStatement.expenses.taxExpenses,
        },
        'period': {
          'start': incomeStatement.periodStart.toIso8601String(),
          'end': incomeStatement.periodEnd.toIso8601String(),
        },
        'metadata': {
          'transaction_count': incomeStatement.metadata.transactionCount,
          'payroll_count': incomeStatement.metadata.payrollCount,
          'period_length_days': incomeStatement.metadata.periodLengthDays,
        },
      };

      // Generate PDF
      final filePath = await PdfGenerationHelper.generateIncomeStatementPdf(reportData);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _downloadExcel(BuildContext context, IncomeStatement incomeStatement) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert IncomeStatement to Excel format
      final excelData = {
        'Summary': {
          'Total Revenue': incomeStatement.revenue.totalRevenue,
          'Total Expenses': incomeStatement.expenses.totalExpenses,
          'Gross Profit': incomeStatement.grossProfit.grossProfit,
          'Net Income': incomeStatement.netIncome.netIncome,
          'Profitability Status': incomeStatement.summary.profitabilityStatus,
        },
        'Revenue Detail': {
          'Trading Revenue': incomeStatement.revenue.tradingRevenue,
          'Payroll Income': incomeStatement.revenue.payrollIncome,
          'Other Income': incomeStatement.revenue.otherIncome,
        },
        'Expense Detail': {
          'Transaction Fees': incomeStatement.expenses.transactionFees,
          'Trading Losses': incomeStatement.expenses.tradingLosses,
          'Operational Expenses': incomeStatement.expenses.operationalExpenses,
          'Tax Expenses': incomeStatement.expenses.taxExpenses,
        },
      };

      // Generate Excel
      final filePath = await ExcelExportHelper.exportIncomeStatementToExcel(excelData);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate Excel: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}