// lib/features/presentation/manager/Payslip/Views/payslip_details_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/payslip.dart';
import 'package:intl/intl.dart';
import '../../../widgets/pdf_generation_helper.dart';

class PayslipDetailsView extends ConsumerWidget {
  final Payslip payslip;

  const PayslipDetailsView({Key? key, required this.payslip}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Payslip Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF9747FF),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Blue Background
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.08,
                    backgroundColor: Colors.white70,
                    child: Text(
                      (payslip.employeeName ?? 'U').substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Color(0xFF4A6CF7),
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    payslip.employeeName ?? 'Unknown Employee',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    payslip.position ?? 'No position specified',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.black54.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    payslip.department ?? 'No department specified',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.black54.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payslip Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payslip Number',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            payslip.payslipNumber ?? 'Unknown Number',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Pay Period',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Earnings Section
                  Text(
                    'Earnings',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildAmountRow('Base Salary', payslip.baseSalary, screenWidth),
                        if (payslip.overtimePay > 0) _buildAmountRow('Overtime Pay', payslip.overtimePay, screenWidth),
                        if (payslip.bonus > 0) _buildAmountRow('Bonus', payslip.bonus, screenWidth),
                        if (payslip.allowances > 0) _buildAmountRow('Allowances', payslip.allowances, screenWidth),
                        Divider(height: 24),
                        _buildAmountRow('Total Earnings', payslip.totalEarnings, screenWidth, isTotal: true),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Deductions Section
                  Text(
                    'Deductions',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: payslip.totalDeductions > 0
                        ? Column(
                      children: [
                        if (payslip.taxDeduction > 0) _buildAmountRow('Tax Deduction', payslip.taxDeduction, screenWidth),
                        if (payslip.insuranceDeduction > 0) _buildAmountRow('Insurance', payslip.insuranceDeduction, screenWidth),
                        if (payslip.retirementDeduction > 0) _buildAmountRow('Retirement', payslip.retirementDeduction, screenWidth),
                        if (payslip.otherDeductions > 0) _buildAmountRow('Other Deductions', payslip.otherDeductions, screenWidth),
                      ],
                    )
                        : Center(
                      child: Text(
                        'No deductions',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Net Pay Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Net Pay',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w100,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$${payslip.finalNetPay.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.1,
                            fontWeight: FontWeight.w200,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        if (payslip.cryptoAmount > 0) ...[
                          SizedBox(height: 8),
                          Text(
                            '${payslip.cryptoAmount.toStringAsFixed(6)} ${payslip.cryptocurrency ?? 'ETH'}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.020,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Payment Status Section
                  Text(
                    'Payment Status',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getStatusIcon(payslip.statusEnum),
                              color: _getStatusColor(payslip.statusEnum),
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: 8),
                            Text(
                              payslip.statusEnum.displayName,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(payslip.statusEnum),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Pay Date: ${DateFormat('MMMM dd, yyyy').format(payslip.payDate)}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, double screenWidth, {bool isTotal = false, bool isDeduction = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? Colors.grey[900] : Colors.grey[700],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.grey[900] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.draft:
        return Icons.edit;
      case PayslipStatus.generated:
        return Icons.check_circle;
      case PayslipStatus.sent:
        return Icons.send;
      case PayslipStatus.paid:
        return Icons.check_circle;
      case PayslipStatus.cancelled:
        return Icons.cancel;
      case PayslipStatus.processing:
        return Icons.hourglass_empty;
      case PayslipStatus.failed:
        return Icons.error;
      case PayslipStatus.pending:
        return Icons.schedule;
    }
  }

  Color _getStatusColor(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.draft:
        return Colors.orange;
      case PayslipStatus.generated:
        return Colors.green;
      case PayslipStatus.sent:
        return Colors.purple;
      case PayslipStatus.paid:
        return Colors.green;
      case PayslipStatus.cancelled:
        return Colors.red;
      case PayslipStatus.processing:
        return Colors.amber;
      case PayslipStatus.failed:
        return Colors.red;
      case PayslipStatus.pending:
        return Colors.grey;
    }
  }

  void _generatePdf(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert Payslip to Map for PDF generation
      final payslipData = payslip.toJson();
      
      // Generate PDF using the PDF generation helper
      final pdfPath = await PdfGenerationHelper.generatePayslipPdf(payslipData);
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (pdfPath.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payslip PDF generated successfully!\nSaved to: $pdfPath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate payslip PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}