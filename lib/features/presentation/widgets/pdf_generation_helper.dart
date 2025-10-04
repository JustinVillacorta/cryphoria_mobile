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
