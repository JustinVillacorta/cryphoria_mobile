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
      
      double currentAssetsTotal = 0.0;
      for (var asset in balanceSheet.assets.where((a) => a.isCurrent)) {
        _addDataRow(sheet, asset.name, asset.amount, 'A$currentRow', 'B$currentRow');
        currentAssetsTotal += asset.amount;
        currentRow += 1;
      }
      _addTotalRow(sheet, 'Total Current Assets', currentAssetsTotal, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Non-Current Assets
      _addSubSectionHeader(sheet, 'Non-Current Assets', 'A$currentRow');
      currentRow += 1;
      
      double nonCurrentAssetsTotal = 0.0;
      for (var asset in balanceSheet.assets.where((a) => !a.isCurrent)) {
        _addDataRow(sheet, asset.name, asset.amount, 'A$currentRow', 'B$currentRow');
        nonCurrentAssetsTotal += asset.amount;
        currentRow += 1;
      }
      _addTotalRow(sheet, 'Total Non-Current Assets', nonCurrentAssetsTotal, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Total Assets
      _addTotalRow(sheet, 'TOTAL ASSETS', balanceSheet.summary.totalAssets, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Liabilities Section
      _addSectionHeader(sheet, 'LIABILITIES', 'A$currentRow');
      currentRow += 2;
      
      // Current Liabilities
      _addSubSectionHeader(sheet, 'Current Liabilities', 'A$currentRow');
      currentRow += 1;
      
      double currentLiabilitiesTotal = 0.0;
      for (var liability in balanceSheet.liabilities.where((l) => l.isCurrent)) {
        _addDataRow(sheet, liability.name, liability.amount, 'A$currentRow', 'B$currentRow');
        currentLiabilitiesTotal += liability.amount;
        currentRow += 1;
      }
      _addTotalRow(sheet, 'Total Current Liabilities', currentLiabilitiesTotal, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Long-term Liabilities
      _addSubSectionHeader(sheet, 'Long-term Liabilities', 'A$currentRow');
      currentRow += 1;
      
      double longTermLiabilitiesTotal = 0.0;
      for (var liability in balanceSheet.liabilities.where((l) => !l.isCurrent)) {
        _addDataRow(sheet, liability.name, liability.amount, 'A$currentRow', 'B$currentRow');
        longTermLiabilitiesTotal += liability.amount;
        currentRow += 1;
      }
      _addTotalRow(sheet, 'Total Long-term Liabilities', longTermLiabilitiesTotal, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Total Liabilities
      _addTotalRow(sheet, 'TOTAL LIABILITIES', balanceSheet.summary.totalLiabilities, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Equity Section
      _addSectionHeader(sheet, 'EQUITY', 'A$currentRow');
      currentRow += 2;
      
      for (var equity in balanceSheet.equity) {
        _addDataRow(sheet, equity.name, equity.amount, 'A$currentRow', 'B$currentRow');
        currentRow += 1;
      }
      _addTotalRow(sheet, 'TOTAL EQUITY', balanceSheet.summary.totalEquity, 'A$currentRow', 'B$currentRow');
      currentRow += 2;
      
      // Summary
      _addTotalRow(sheet, 'LIABILITIES + EQUITY', balanceSheet.summary.totalLiabilities + balanceSheet.summary.totalEquity, 'A$currentRow', 'B$currentRow');
      
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

  static Future<String> exportIncomeStatementToExcel(Portfolio portfolio) async {
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
      _addDataRow(sheet, 'Total Revenue', portfolio.totalValue.abs(), 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Expenses Section
      _addSectionHeader(sheet, 'EXPENSES', 'A$currentRow');
      currentRow += 2;
      _addDataRow(sheet, 'Total Expenses', 0.0, 'A$currentRow', 'B$currentRow');
      currentRow += 3;
      
      // Net Income
      _addTotalRow(sheet, 'NET INCOME', portfolio.totalValue.abs(), 'A$currentRow', 'B$currentRow');
      
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
