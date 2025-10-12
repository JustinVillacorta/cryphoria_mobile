// lib/features/presentation/widgets/pdf_generation_helper.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

class PdfGenerationHelper {
  static Future<String> generateTaxReportPdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();
    
    // Add Tax Report content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Tax Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Report Summary
              pw.Text(
                'Report Summary',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              // Summary data
              if (reportData['summary'] != null) ...[
                pw.Text('Total Income: \$${reportData['summary']['total_income']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Total Deductions: \$${reportData['summary']['total_deductions']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Taxable Income: \$${reportData['summary']['taxable_income']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Total Tax Owed: \$${reportData['summary']['total_tax_owed']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.SizedBox(height: 20),
              ],
              
              // Categories
              if (reportData['categories'] != null) ...[
                pw.Text(
                  'Tax Categories',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...(reportData['categories'] as List<dynamic>).map((category) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(category['name'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(category['amount'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'tax_report');
  }
  
  static Future<String> generateBalanceSheetPdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Balance Sheet',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              if (reportData['summary'] != null) ...[
                pw.Text(
                  'Financial Summary',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Total Assets: \$${reportData['summary']['total_assets']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Total Liabilities: \$${reportData['summary']['total_liabilities']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Total Equity: \$${reportData['summary']['total_equity']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.SizedBox(height: 20),
              ],
              
              // Assets
              if (reportData['assets'] != null) ...[
                pw.Text(
                  'Assets',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Asset', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...(reportData['assets'] as List<dynamic>).map((asset) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(asset['name'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(asset['amount'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'balance_sheet');
  }
  
  static Future<String> generateCashFlowPdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Cash Flow Statement',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              if (reportData['summary'] != null) ...[
                pw.Text(
                  'Cash Flow Summary',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Net Cash from Operations: \$${reportData['summary']['net_cash_from_operations']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Net Cash from Investing: \$${reportData['summary']['net_cash_from_investing']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Net Cash from Financing: \$${reportData['summary']['net_cash_from_financing']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Net Change in Cash: \$${reportData['summary']['net_change_in_cash']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.SizedBox(height: 20),
              ],
              
              // Operating Activities
              if (reportData['operating_activities'] != null) ...[
                pw.Text(
                  'Operating Activities',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Activity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...(reportData['operating_activities'] as List<dynamic>).map((activity) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(activity['description'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(activity['amount'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'cash_flow');
  }
  
  static Future<String> generatePayslipPdf(Map<String, dynamic> payslipData) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PAYSLIP',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Pay Period: ${_formatDate(payslipData['pay_period_start'])} - ${_formatDate(payslipData['pay_period_end'])}',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      'Pay Date: ${_formatDate(payslipData['pay_date'])}',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Employee Information
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Employee Information',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('Name: ${payslipData['employee_name'] ?? 'N/A'}'),
                        pw.Text('Employee ID: ${payslipData['employee_id'] ?? 'N/A'}'),
                        pw.Text('Email: ${payslipData['employee_email'] ?? 'N/A'}'),
                        pw.Text('Department: ${payslipData['department'] ?? 'N/A'}'),
                        pw.Text('Position: ${payslipData['position'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Payslip Details',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text('Payslip #: ${payslipData['payslip_number'] ?? 'N/A'}'),
                        pw.Text('Status: ${payslipData['status'] ?? 'N/A'}'),
                        pw.Text('Currency: ${payslipData['salary_currency'] ?? 'USD'}'),
                        pw.Text('Cryptocurrency: ${payslipData['cryptocurrency'] ?? 'ETH'}'),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Earnings Section
              pw.Text(
                'Earnings',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Base Salary'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('\$${(payslipData['base_salary'] ?? 0).toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  if ((payslipData['overtime_pay'] ?? 0) > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Overtime Pay'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslipData['overtime_pay'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  if ((payslipData['bonus'] ?? 0) > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Bonus'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslipData['bonus'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  if ((payslipData['allowances'] ?? 0) > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Allowances'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslipData['allowances'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Total Earnings', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('\$${(payslipData['total_earnings'] ?? 0).toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Deductions Section
              pw.Text(
                'Deductions',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  if ((payslipData['tax_deduction'] ?? 0) > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Tax Deduction'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslipData['tax_deduction'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  if ((payslipData['insurance_deduction'] ?? 0) > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Insurance Deduction'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslipData['insurance_deduction'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  if ((payslipData['retirement_deduction'] ?? 0) > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Retirement Deduction'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslipData['retirement_deduction'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  if ((payslipData['other_deductions'] ?? 0) > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Other Deductions'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslipData['other_deductions'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Total Deductions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('\$${(payslipData['total_deductions'] ?? 0).toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Net Pay Section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Net Pay',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '\$${(payslipData['final_net_pay'] ?? 0).toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Cryptocurrency Payment Details
              if (payslipData['crypto_amount'] != null && payslipData['crypto_amount'] > 0) ...[
                pw.Text(
                  'Cryptocurrency Payment',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Amount: ${(payslipData['crypto_amount'] ?? 0).toStringAsFixed(6)} ${payslipData['cryptocurrency'] ?? 'ETH'}'),
                      pw.Text('USD Equivalent: \$${(payslipData['usd_equivalent'] ?? 0).toStringAsFixed(2)}'),
                      if (payslipData['transaction_hash'] != null)
                        pw.Text('Transaction Hash: ${payslipData['transaction_hash']}'),
                    ],
                  ),
                ),
              ],
              
              pw.SizedBox(height: 30),
              
              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Generated on ${_formatDate(DateTime.now().toIso8601String())}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    if (payslipData['notes'] != null && payslipData['notes'].isNotEmpty)
                      pw.Text(
                        'Notes: ${payslipData['notes']}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'payslip');
  }
  
  static String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
  
  static Future<String> generateIncomeStatementPdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Income Statement',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              if (reportData['summary'] != null) ...[
                pw.Text(
                  'Financial Summary',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Total Revenue: \$${reportData['summary']['total_revenue']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Total Expenses: \$${reportData['summary']['total_expenses']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Net Income: \$${reportData['summary']['net_income']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.SizedBox(height: 20),
              ],
              
              // Revenue
              if (reportData['revenue'] != null) ...[
                pw.Text(
                  'Revenue',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Revenue Source', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...(reportData['revenue'] as List<dynamic>).map((item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(item['name'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(item['amount'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'income_statement');
  }
  
  static Future<String> generateInvestmentPerformancePdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Investment Performance Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              if (reportData['summary'] != null) ...[
                pw.Text(
                  'Portfolio Summary',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Total Value: \$${reportData['summary']['total_value']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Currency: ${reportData['summary']['currency'] ?? 'USD'}'),
                pw.Text('Success: ${reportData['summary']['success'] ?? false}'),
                pw.SizedBox(height: 20),
              ],
              
              // Holdings
              if (reportData['holdings'] != null) ...[
                pw.Text(
                  'Portfolio Holdings',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Crypto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...(reportData['holdings'] as List<dynamic>).map((holding) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(holding['cryptocurrency'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text((holding['amount'] ?? 0).abs().toStringAsFixed(6)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(holding['current_price'] ?? 0).abs().toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(holding['value'] ?? 0).abs().toStringAsFixed(2)}'),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'investment_performance');
  }
  
  static Future<String> generatePayrollSummaryPdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Payroll Summary Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Summary
              if (reportData['summary'] != null) ...[
                pw.Text(
                  'Payroll Summary',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Total Employees: ${reportData['summary']['total_employees'] ?? 0}'),
                pw.Text('Total Amount: \$${reportData['summary']['total_amount']?.toStringAsFixed(2) ?? '0.00'}'),
                pw.Text('Currency: ${reportData['summary']['currency'] ?? 'USD'}'),
                pw.SizedBox(height: 20),
              ],
              
              // Payslips
              if (reportData['payslips'] != null) ...[
                pw.Text(
                  'Employee Payslips',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Employee', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Net Pay', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Tax', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...(reportData['payslips'] as List<dynamic>).map((payslip) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(payslip['employee_name'] ?? 'Unknown'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslip['final_net_pay'] ?? 0).toStringAsFixed(2)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('\$${(payslip['tax_deduction'] ?? 0).toStringAsFixed(2)}'),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'payroll_summary');
  }
  
  static Future<String> generateAuditReportPdf(dynamic auditReport) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'SMART AUDIT REPORT',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Contract: ${auditReport.contractName}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'File: ${auditReport.fileName}',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      'Generated: ${_formatDate(auditReport.timestamp.toIso8601String())}',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      'Overall Score: ${auditReport.overallScore.toStringAsFixed(1)}/100',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Security Analysis Section
              pw.Text(
                'Security Analysis',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Security Score: ${auditReport.securityAnalysis.securityScore.toStringAsFixed(1)}/100'),
                    pw.Text('Critical Issues: ${auditReport.securityAnalysis.criticalIssues}'),
                    pw.Text('High Risk Issues: ${auditReport.securityAnalysis.highRiskIssues}'),
                    pw.Text('Medium Risk Issues: ${auditReport.securityAnalysis.mediumRiskIssues}'),
                    pw.Text('Low Risk Issues: ${auditReport.securityAnalysis.lowRiskIssues}'),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Vulnerabilities Section
              if (auditReport.vulnerabilities.isNotEmpty) ...[
                pw.Text(
                  'Vulnerabilities (${auditReport.vulnerabilities.length})',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(3),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Title', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Severity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...auditReport.vulnerabilities.map((vuln) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(vuln.title),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(vuln.severity.toString().split('.').last.toUpperCase()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(vuln.category),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(vuln.description),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
              
              // Gas Optimization Section
              pw.Text(
                'Gas Optimization',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Optimization Score: ${auditReport.gasOptimization.optimizationScore.toStringAsFixed(1)}/100'),
                    pw.SizedBox(height: 10),
                    if (auditReport.gasOptimization.suggestions.isNotEmpty) ...[
                      pw.Text('Suggestions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...auditReport.gasOptimization.suggestions.map((suggestion) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Text('• ${suggestion.function}: ${suggestion.suggestion} (${suggestion.priority.toString().split('.').last.toUpperCase()})'),
                      )).toList(),
                    ],
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Code Quality Section
              pw.Text(
                'Code Quality',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Quality Score: ${auditReport.codeQuality.qualityScore.toStringAsFixed(1)}/100'),
                    pw.Text('Lines of Code: ${auditReport.codeQuality.linesOfCode}'),
                    pw.Text('Complexity Score: ${auditReport.codeQuality.complexityScore}'),
                    if (auditReport.codeQuality.issues.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      pw.Text('Issues:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      ...auditReport.codeQuality.issues.map((issue) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Text('• Line ${issue.lineNumber}: ${issue.type} - ${issue.description} (${issue.severity.toString().split('.').last.toUpperCase()})'),
                      )).toList(),
                    ],
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Recommendations Section
              if (auditReport.recommendations.isNotEmpty) ...[
                pw.Text(
                  'Recommendations (${auditReport.recommendations.length})',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(3),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Title', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Priority', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...auditReport.recommendations.map((rec) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(rec.title),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(rec.priority.toString().split('.').last.toUpperCase()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(rec.category),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(rec.description),
                        ),
                      ],
                    )).toList(),
                  ],
                ),
              ],
              
              pw.SizedBox(height: 30),
              
              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Generated on ${_formatDate(DateTime.now().toIso8601String())}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Smart Audit System - Comprehensive Security Analysis',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'audit_report');
  }
  
  static Future<String> generateInvoicePdf(dynamic invoice) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Invoice #: ${invoice.invoiceNumber}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Date: ${_formatDate(invoice.issueDate)}',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      'Status: ${invoice.status.toUpperCase()}',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Parties Section
              pw.Text(
                'Parties',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Cryphoria Mobile'),
                        pw.Text('Business Address'),
                        pw.Text('City, State, ZIP'),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(invoice.clientName ?? 'Client'),
                        pw.Text('Client Address'),
                        pw.Text('City, State, ZIP'),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Items Section
              pw.Text(
                'Invoice Items',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...invoice.items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(item.description),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(item.quantity.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('\$${item.unitPrice.toStringAsFixed(2)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Totals Section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Subtotal:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('\$${invoice.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Tax:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('\$${invoice.taxAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text('\$${invoice.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        invoice.currency,
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Generated on ${_formatDate(DateTime.now().toIso8601String())}',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Cryphoria Mobile - Invoice Management System',
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    
    return await _savePdf(pdf, 'invoice');
  }
  
  static Future<String> _savePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    
    // Open the generated PDF file
    await OpenFile.open(file.path);
    
    return file.path;
  }
}
