// lib/features/presentation/manager/Payslip/Views/payslip_details_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/payslip.dart';
import 'package:intl/intl.dart';

class PayslipDetailsView extends ConsumerWidget {
  final Payslip payslip;

  const PayslipDetailsView({Key? key, required this.payslip}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
          IconButton(
            icon: Icon(Icons.payment),
            onPressed: payslip.status == PayslipStatus.generated 
                ? () => _processPayment(context)
                : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            _buildHeaderCard(context, screenWidth),
            SizedBox(height: 16),
            
            // Earnings Card
            _buildEarningsCard(context, screenWidth),
            SizedBox(height: 16),
            
            // Deductions Card
            _buildDeductionsCard(context, screenWidth),
            SizedBox(height: 16),
            
            // Net Pay Card
            _buildNetPayCard(context, screenWidth),
            SizedBox(height: 16),
            
            // Payment Status Card
            _buildPaymentStatusCard(context, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.08,
                  backgroundColor: Color(0xFF9747FF),
                  child: Text(
                    payslip.employeeName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payslip.employeeName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        payslip.position,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        payslip.department,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
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
                    Text(
                      payslip.payslipNumber,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context, double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            _buildAmountRow('Base Salary', payslip.baseSalary, screenWidth),
            if (payslip.overtimePay > 0) _buildAmountRow('Overtime Pay', payslip.overtimePay, screenWidth),
            if (payslip.bonus > 0) _buildAmountRow('Bonus', payslip.bonus, screenWidth),
            if (payslip.allowances > 0) _buildAmountRow('Allowances', payslip.allowances, screenWidth),
            Divider(),
            _buildAmountRow('Total Earnings', payslip.totalEarnings, screenWidth, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsCard(BuildContext context, double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deductions',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            if (payslip.taxDeduction > 0) _buildAmountRow('Tax Deduction', payslip.taxDeduction, screenWidth),
            if (payslip.insuranceDeduction > 0) _buildAmountRow('Insurance', payslip.insuranceDeduction, screenWidth),
            if (payslip.retirementDeduction > 0) _buildAmountRow('Retirement', payslip.retirementDeduction, screenWidth),
            if (payslip.otherDeductions > 0) _buildAmountRow('Other Deductions', payslip.otherDeductions, screenWidth),
            if (payslip.totalDeductions > 0) ...[
              Divider(),
              _buildAmountRow('Total Deductions', payslip.totalDeductions, screenWidth, isTotal: true, isDeduction: true),
            ] else ...[
              Text(
                'No deductions',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNetPayCard(BuildContext context, double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color(0xFF9747FF).withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Net Pay',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '\$${payslip.finalNetPay.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: screenWidth * 0.08,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9747FF),
              ),
            ),
            if (payslip.cryptoAmount > 0) ...[
              SizedBox(height: 8),
              Text(
                '${payslip.cryptoAmount.toStringAsFixed(6)} ${payslip.cryptocurrency}',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusCard(BuildContext context, double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Status',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getStatusIcon(payslip.status),
                  color: _getStatusColor(payslip.status),
                  size: screenWidth * 0.06,
                ),
                SizedBox(width: 12),
                Text(
                  payslip.status.displayName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(payslip.status),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Pay Date: ${DateFormat('MMM dd, yyyy').format(payslip.payDate)}',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
            if (payslip.employeeWallet != null) ...[
              SizedBox(height: 8),
              Text(
                'Wallet: ${payslip.employeeWallet}',
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, double screenWidth, {bool isTotal = false, bool isDeduction = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '${isDeduction ? '-' : ''}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isDeduction ? Colors.red[600] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.paid:
        return Icons.check_circle;
      case PayslipStatus.processing:
        return Icons.hourglass_empty;
      case PayslipStatus.failed:
        return Icons.error;
      case PayslipStatus.pending:
        return Icons.schedule;
      case PayslipStatus.generated:
        return Icons.description;
    }
  }

  Color _getStatusColor(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.paid:
        return Colors.green;
      case PayslipStatus.processing:
        return Colors.orange;
      case PayslipStatus.failed:
        return Colors.red;
      case PayslipStatus.pending:
        return Colors.blue;
      case PayslipStatus.generated:
        return Colors.grey;
    }
  }

  void _generatePdf(BuildContext context) {
    // TODO: Implement PDF generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF generation coming soon')),
    );
  }

  void _processPayment(BuildContext context) {
    // TODO: Implement payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment processing coming soon')),
    );
  }
}