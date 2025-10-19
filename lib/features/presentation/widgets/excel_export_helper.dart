import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../domain/entities/balance_sheet.dart';
import '../../domain/entities/cash_flow.dart';
import '../../domain/entities/portfolio.dart';
import '../../domain/entities/payslip.dart';

class ExcelExportHelper {
  static Future<String> exportBalanceSheetToExcel(BalanceSheet balanceSheet) async {
    try {
      // Create a new Excel workbook
      var excel = Excel.createExcel();
      var sheet = excel['Balance Sheet'];
      
      // Remove default sheet
      excel.delete('Sheet1');
      
      // Set up headers and styling
      _addHeader(sheet, 'BALANCE SHEET', 'A1');
      _addSubHeader(sheet, 'As of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', 'A2');
      
      int currentRow = 4;
      
      // Assets Section
      _addSectionHeader(sheet, 'ASSETS', 'A$currentRow');
      currentRow += 2;
      
      // Current Assets
      _addSubSectionHeader(sheet, 'Current Assets', 'A$currentRow');
      currentRow += 1;
      
      // Crypto Holdings
      _addDataRow(sheet, 'Crypto Holdings', balanceSheet.assets.currentAssets.cryptoHoldings.totalValue, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Cash Equivalents
      _addDataRow(sheet, 'Cash Equivalents', balanceSheet.assets.currentAssets.cashEquivalents, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Receivables
      _addDataRow(sheet, 'Receivables', balanceSheet.assets.currentAssets.receivables.toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      _addTotalRow(sheet, 'Total Current Assets', balanceSheet.assets.currentAssets.total, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Non-Current Assets
      _addSubSectionHeader(sheet, 'Non-Current Assets', 'A$currentRow');
      currentRow += 1;
      
      // Long-term Investments
      _addDataRow(sheet, 'Long-term Investments', balanceSheet.assets.nonCurrentAssets.longTermInvestments, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Equipment
      _addDataRow(sheet, 'Equipment', balanceSheet.assets.nonCurrentAssets.equipment, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Other
      _addDataRow(sheet, 'Other', balanceSheet.assets.nonCurrentAssets.other, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      _addTotalRow(sheet, 'Total Non-Current Assets', balanceSheet.assets.nonCurrentAssets.total, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Total Assets
      _addTotalRow(sheet, 'TOTAL ASSETS', balanceSheet.totals.totalAssets, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Liabilities Section
      _addSectionHeader(sheet, 'LIABILITIES', 'A$currentRow');
      currentRow += 2;
      
      // Current Liabilities
      _addSubSectionHeader(sheet, 'Current Liabilities', 'A$currentRow');
      currentRow += 1;
      
      // Accounts Payable
      _addDataRow(sheet, 'Accounts Payable', balanceSheet.liabilities.currentLiabilities.accountsPayable.toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Accrued Expenses
      _addDataRow(sheet, 'Accrued Expenses', balanceSheet.liabilities.currentLiabilities.accruedExpenses, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Short-term Debt
      _addDataRow(sheet, 'Short-term Debt', balanceSheet.liabilities.currentLiabilities.shortTermDebt, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Tax Liabilities
      _addDataRow(sheet, 'Tax Liabilities', balanceSheet.liabilities.currentLiabilities.taxLiabilities, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      _addTotalRow(sheet, 'Total Current Liabilities', balanceSheet.liabilities.currentLiabilities.total, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Long-term Liabilities
      _addSubSectionHeader(sheet, 'Long-term Liabilities', 'A$currentRow');
      currentRow += 1;
      
      // Long-term Debt
      _addDataRow(sheet, 'Long-term Debt', balanceSheet.liabilities.longTermLiabilities.longTermDebt, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Deferred Tax
      _addDataRow(sheet, 'Deferred Tax', balanceSheet.liabilities.longTermLiabilities.deferredTax, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Other
      _addDataRow(sheet, 'Other', balanceSheet.liabilities.longTermLiabilities.other, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      _addTotalRow(sheet, 'Total Long-term Liabilities', balanceSheet.liabilities.longTermLiabilities.total, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Total Liabilities
      _addTotalRow(sheet, 'TOTAL LIABILITIES', balanceSheet.totals.totalLiabilities, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Equity Section
      _addSectionHeader(sheet, 'EQUITY', 'A$currentRow');
      currentRow += 2;
      
      // Retained Earnings
      _addDataRow(sheet, 'Retained Earnings', balanceSheet.equity.retainedEarnings.toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      // Unrealized Gains/Losses
      _addDataRow(sheet, 'Unrealized Gains/Losses', balanceSheet.equity.unrealizedGainsLosses, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      
      _addTotalRow(sheet, 'TOTAL EQUITY', balanceSheet.totals.totalEquity, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Summary
      _addTotalRow(sheet, 'LIABILITIES + EQUITY', balanceSheet.totals.totalLiabilities + balanceSheet.totals.totalEquity, 'A$currentRow', 'B$currentRow');
      
      // Auto-fit columns
      _autoFitColumns(sheet);
      
      return await _saveExcelFile(excel, 'balance_sheet');
    } catch (e) {
      throw Exception('Failed to export balance sheet to Excel: $e');
    }
  }

  static Future<String> exportCashFlowToExcel(CashFlow cashFlow) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Cash Flow'];
      
      excel.delete('Sheet1');
      
      _addHeader(sheet, 'CASH FLOW STATEMENT', 'A1');
      _addSubHeader(sheet, 'For the period ending ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', 'A2');
      
      int currentRow = 4;
      
      // Operating Activities
      _addSectionHeader(sheet, 'OPERATING ACTIVITIES', 'A$currentRow');
      currentRow += 2;
      
      for (var activity in cashFlow.operatingActivities) {
        _addDataRow(sheet, activity.description, activity.amount, 'A$currentRow', 'B$currentRow');
        currentRow += 1;
      }
      _addTotalRow(sheet, 'Net Cash from Operating Activities', cashFlow.summary.netCashFromOperations, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Investing Activities
      _addSectionHeader(sheet, 'INVESTING ACTIVITIES', 'A$currentRow');
      currentRow += 2;
      
      for (var activity in cashFlow.investingActivities) {
        _addDataRow(sheet, activity.description, activity.amount, 'A$currentRow', 'B$currentRow');
        currentRow += 1;
      }
      _addTotalRow(sheet, 'Net Cash from Investing Activities', cashFlow.summary.netCashFromInvesting, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Financing Activities
      _addSectionHeader(sheet, 'FINANCING ACTIVITIES', 'A$currentRow');
      currentRow += 2;
      
      for (var activity in cashFlow.financingActivities) {
        _addDataRow(sheet, activity.description, activity.amount, 'A$currentRow', 'B$currentRow');
        currentRow += 1;
      }
      _addTotalRow(sheet, 'Net Cash from Financing Activities', cashFlow.summary.netCashFromFinancing, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Net Change in Cash
      _addTotalRow(sheet, 'NET CHANGE IN CASH', cashFlow.summary.netChangeInCash, 'A$currentRow', 'B$currentRow');
      
      _autoFitColumns(sheet);
      
      return await _saveExcelFile(excel, 'cash_flow');
    } catch (e) {
      throw Exception('Failed to export cash flow to Excel: $e');
    }
  }

  static Future<String> exportIncomeStatementToExcel(Map<String, Map<String, Object>> incomeStatementData) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Income Statement'];
      
      excel.delete('Sheet1');
      
      _addHeader(sheet, 'INCOME STATEMENT', 'A1');
      _addSubHeader(sheet, 'For the period ending ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', 'A2');
      
      int currentRow = 4;
      
      // Revenue Section
      _addSectionHeader(sheet, 'REVENUE', 'A$currentRow');
      currentRow += 2;
      
      final summaryData = incomeStatementData['Summary'] as Map<String, Object>;
      final revenueData = incomeStatementData['Revenue Detail'] as Map<String, Object>;
      final expenseData = incomeStatementData['Expense Detail'] as Map<String, Object>;
      
      _addDataRow(sheet, 'Total Revenue', (summaryData['Total Revenue'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addDataRow(sheet, 'Trading Revenue', (revenueData['Trading Revenue'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addDataRow(sheet, 'Payroll Income', (revenueData['Payroll Income'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addDataRow(sheet, 'Other Income', (revenueData['Other Income'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Expenses Section
      _addSectionHeader(sheet, 'EXPENSES', 'A$currentRow');
      currentRow += 2;
      
      _addDataRow(sheet, 'Total Expenses', (summaryData['Total Expenses'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addDataRow(sheet, 'Transaction Fees', (expenseData['Transaction Fees'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addDataRow(sheet, 'Trading Losses', (expenseData['Trading Losses'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addDataRow(sheet, 'Operational Expenses', (expenseData['Operational Expenses'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addDataRow(sheet, 'Tax Expenses', (expenseData['Tax Expenses'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Profitability Section
      _addSectionHeader(sheet, 'PROFITABILITY', 'A$currentRow');
      currentRow += 2;
      
      _addDataRow(sheet, 'Gross Profit', (summaryData['Gross Profit'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addDataRow(sheet, 'Net Income', (summaryData['Net Income'] as num).toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow++;
      _addTextRow(sheet, 'Profitability Status', summaryData['Profitability Status'].toString(), 'A$currentRow', 'B$currentRow');
      
      _autoFitColumns(sheet);
      
      return await _saveExcelFile(excel, 'income_statement');
    } catch (e) {
      throw Exception('Failed to export income statement to Excel: $e');
    }
  }

  static Future<String> exportInvestmentPerformanceToExcel(Portfolio portfolio) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Investment Performance'];
      
      excel.delete('Sheet1');
      
      _addHeader(sheet, 'INVESTMENT PERFORMANCE', 'A1');
      _addSubHeader(sheet, 'As of ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', 'A2');
      
      int currentRow = 4;
      
      // Portfolio Summary
      _addDataRow(sheet, 'Total Portfolio Value', portfolio.totalValue.abs(), 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Total Cost Basis', portfolio.totalValue.abs(), 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Unrealized Gain/Loss', 0.0, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Cash Balance', 0.0, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Holdings Breakdown
      if (portfolio.breakdown.isNotEmpty) {
        _addSectionHeader(sheet, 'HOLDINGS BREAKDOWN', 'A$currentRow');
        currentRow += 2;
        
        for (var holding in portfolio.breakdown) {
          _addDataRow(sheet, holding.cryptocurrency, holding.value.abs(), 'A$currentRow', 'B$currentRow');
          currentRow += 1;
        }
      }
      
      _autoFitColumns(sheet);
      
      return await _saveExcelFile(excel, 'investment_performance');
    } catch (e) {
      throw Exception('Failed to export investment performance to Excel: $e');
    }
  }

  static Future<String> exportPayrollSummaryToExcel(PayslipsResponse payslipsResponse) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Payroll Summary'];
      
      excel.delete('Sheet1');
      
      _addHeader(sheet, 'PAYROLL SUMMARY', 'A1');
      _addSubHeader(sheet, 'For the period ending ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', 'A2');
      
      int currentRow = 4;
      
      // Summary Statistics
      double totalPayroll = payslipsResponse.payslips.fold(0.0, (sum, payslip) => sum + payslip.finalNetPay);
      double totalTaxes = payslipsResponse.payslips.fold(0.0, (sum, payslip) => sum + payslip.taxDeduction);
      double totalDeductions = payslipsResponse.payslips.fold(0.0, (sum, payslip) => sum + payslip.totalDeductions);
      
      _addDataRow(sheet, 'Total Employees', payslipsResponse.payslips.length.toDouble(), 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Total Payroll', totalPayroll, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Total Taxes', totalTaxes, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Total Deductions', totalDeductions, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Individual Payslips
      _addSectionHeader(sheet, 'INDIVIDUAL PAYSLIPS', 'A$currentRow');
      currentRow += 2;
      
      // Headers for payslip details
      _addDataRow(sheet, 'Employee Name', 0.0, 'A$currentRow', 'B$currentRow');
      _addDataRow(sheet, 'Net Pay', 0.0, 'C$currentRow', 'D$currentRow');
      _addDataRow(sheet, 'Tax Deduction', 0.0, 'E$currentRow', 'F$currentRow');
      currentRow += 1;
      
      for (var payslip in payslipsResponse.payslips) {
        _addDataRow(sheet, payslip.employeeName ?? 'Unknown', payslip.finalNetPay, 'A$currentRow', 'B$currentRow');
        _addDataRow(sheet, 'Net Pay', payslip.finalNetPay, 'C$currentRow', 'D$currentRow');
        _addDataRow(sheet, 'Tax Deduction', payslip.taxDeduction, 'E$currentRow', 'F$currentRow');
        currentRow += 1;
      }
      
      _autoFitColumns(sheet);
      
      return await _saveExcelFile(excel, 'payroll_summary');
    } catch (e) {
      throw Exception('Failed to export payroll summary to Excel: $e');
    }
  }

  static Future<String> exportTaxReportToExcel() async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Tax Report'];
      
      excel.delete('Sheet1');
      
      _addHeader(sheet, 'TAX REPORT', 'A1');
      _addSubHeader(sheet, 'For the tax year ${DateTime.now().year}', 'A2');
      
      int currentRow = 4;
      
      // Tax Summary
      _addDataRow(sheet, 'Total Taxable Income', 0.0, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Total Tax Withheld', 0.0, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Estimated Tax Due', 0.0, 'A$currentRow', 'B$currentRow');
      currentRow += 1;
      _addDataRow(sheet, 'Tax Refund', 0.0, 'A$currentRow', 'B$currentRow');
      
      _autoFitColumns(sheet);
      
      return await _saveExcelFile(excel, 'tax_report');
    } catch (e) {
      throw Exception('Failed to export tax report to Excel: $e');
    }
  }

  // Helper methods for formatting
  static void _addHeader(Sheet sheet, String title, String cell) {
    var cellData = sheet.cell(CellIndex.indexByString(cell));
    cellData.value = TextCellValue(title);
    cellData.cellStyle = CellStyle(
      bold: true,
      fontSize: 18,
      horizontalAlign: HorizontalAlign.Center,
    );
  }

  static void _addSubHeader(Sheet sheet, String subtitle, String cell) {
    var cellData = sheet.cell(CellIndex.indexByString(cell));
    cellData.value = TextCellValue(subtitle);
    cellData.cellStyle = CellStyle(
      fontSize: 12,
      horizontalAlign: HorizontalAlign.Center,
    );
  }

  static void _addSectionHeader(Sheet sheet, String title, String cell) {
    var cellData = sheet.cell(CellIndex.indexByString(cell));
    cellData.value = TextCellValue(title);
    cellData.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
    );
  }

  static void _addSubSectionHeader(Sheet sheet, String title, String cell) {
    var cellData = sheet.cell(CellIndex.indexByString(cell));
    cellData.value = TextCellValue(title);
    cellData.cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
    );
  }

  static void _addDataRow(Sheet sheet, String label, double amount, String labelCell, String amountCell) {
    var labelCellData = sheet.cell(CellIndex.indexByString(labelCell));
    labelCellData.value = TextCellValue(label);
    
    var amountCellData = sheet.cell(CellIndex.indexByString(amountCell));
    amountCellData.value = DoubleCellValue(amount);
    amountCellData.cellStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
    );
  }

  static void _addTotalRow(Sheet sheet, String label, double amount, String labelCell, String amountCell) {
    var labelCellData = sheet.cell(CellIndex.indexByString(labelCell));
    labelCellData.value = TextCellValue(label);
    labelCellData.cellStyle = CellStyle(
      bold: true,
    );
    
    var amountCellData = sheet.cell(CellIndex.indexByString(amountCell));
    amountCellData.value = DoubleCellValue(amount);
    amountCellData.cellStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Right,
    );
  }

  static void _addTextRow(Sheet sheet, String label, String value, String labelCell, String valueCell) {
    var labelCellData = sheet.cell(CellIndex.indexByString(labelCell));
    labelCellData.value = TextCellValue(label);
    labelCellData.cellStyle = CellStyle(
      fontSize: 11,
    );
    
    var valueCellData = sheet.cell(CellIndex.indexByString(valueCell));
    valueCellData.value = TextCellValue(value);
    valueCellData.cellStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Right,
    );
  }

  static void _autoFitColumns(Sheet sheet) {
    // Set column widths
    sheet.setColumnWidth(0, 30); // Column A
    sheet.setColumnWidth(1, 15); // Column B
  }

  static Future<String> _saveExcelFile(Excel excel, String fileName) async {
    final bytes = excel.encode();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes!);
    
    // Open the generated Excel file
    await OpenFile.open(file.path);
    
    return file.path;
  }
}
