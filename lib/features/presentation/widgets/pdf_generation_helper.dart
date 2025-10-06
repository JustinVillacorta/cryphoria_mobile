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
