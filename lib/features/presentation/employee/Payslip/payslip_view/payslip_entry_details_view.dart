import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/payroll_entry.dart';
import '../providers/payroll_history_providers.dart';
import '../../../../presentation/widgets/pdf_generation_helper.dart';

class PayslipEntryDetailsView extends ConsumerWidget {
  final String entryId;

  const PayslipEntryDetailsView({
    Key? key,
    required this.entryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryDetailsAsync = ref.watch(payrollEntryDetailsProvider(entryId));

    // Debug logging
    print('PayslipEntryDetailsView - entryId: $entryId');
    print('PayslipEntryDetailsView - async state: ${entryDetailsAsync.runtimeType}');
    entryDetailsAsync.when(
      data: (entry) => print('PayslipEntryDetailsView - data state: ${entry.entryId}'),
      loading: () => print('PayslipEntryDetailsView - loading state'),
      error: (error, stackTrace) => print('PayslipEntryDetailsView - error state: $error'),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: entryDetailsAsync.when(
        data: (entry) => _buildContent(context, entry),
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PayrollEntry entry) {
    return Column(
      children: [
        // Header Section
        _buildHeader(context),
        
        // Content Section
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entry Information Section
                _buildEntryInformationSection(entry),
                
                const SizedBox(height: 20),
                
                // Transaction Details Section
                _buildTransactionDetailsSection(entry),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                _buildActionButtons(context, entry),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading entry details...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load entry details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(payrollEntryDetailsProvider(entryId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payroll Entry Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete transaction information',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryInformationSection(PayrollEntry entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Entry Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(entry.status ?? 'PENDING'),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(entry.status ?? 'PENDING'),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (entry.status ?? 'PENDING').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Entry Information Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.tag,
                  label: 'Entry ID',
                  value: entry.entryId ?? 'Unknown',
                  iconColor: Colors.grey[600]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.calendar_today,
                  label: 'Payment Date',
                  value: DateFormat('MMMM d, yyyy').format(entry.paymentDate),
                  iconColor: Colors.grey[600]!,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Processing time information
          _buildInfoCard(
            icon: Icons.access_time,
            label: 'Processed At',
            value: entry.processedAt != null 
                ? DateFormat('MMMM d, yyyy \'at\' hh:mm a').format(entry.processedAt!)
                : 'Not processed yet',
            iconColor: Colors.orange[600]!,
            isFullWidth: true,
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.attach_money,
                  label: 'Amount',
                  value: '${entry.amount.toStringAsFixed(6)} ${entry.cryptocurrency ?? 'ETH'}',
                  iconColor: Colors.blue[600]!,
                  backgroundColor: Colors.blue[50]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.attach_money,
                  label: 'USD Equivalent',
                  value: '\$${entry.usdEquivalent.toStringAsFixed(2)}',
                  iconColor: Colors.green[600]!,
                  backgroundColor: Colors.green[50]!,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.credit_card,
            label: 'Payment Method',
            value: 'MetaMask',
            iconColor: Colors.grey[600]!,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailsSection(PayrollEntry entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Transaction Hash (Full Width)
          _buildInfoCard(
            icon: Icons.tag,
            label: 'Transaction Hash',
            value: entry.transactionHash ?? 'Not available',
            iconColor: Colors.grey[600]!,
            isFullWidth: true,
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.local_gas_station,
                  label: 'Gas Fee',
                  value: entry.gasFee != null ? '${entry.gasFee!.toStringAsFixed(6)} ${entry.cryptocurrency ?? 'ETH'}' : 'Not available',
                  iconColor: Colors.grey[600]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: _getStatusIcon(entry.status ?? 'PENDING'),
                  label: 'Status',
                  value: (entry.status ?? 'PENDING').toUpperCase(),
                  iconColor: _getStatusColor(entry.status ?? 'PENDING'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? backgroundColor,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PayrollEntry entry) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _downloadPayslipPdf(context, entry),
            icon: const Icon(Icons.download, size: 20),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'SCHEDULED':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'PROCESSING':
        return Colors.orange;
      case 'PENDING':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'SCHEDULED':
        return Icons.schedule;
      case 'FAILED':
        return Icons.error;
      case 'PROCESSING':
        return Icons.hourglass_empty;
      case 'PENDING':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  Future<void> _downloadPayslipPdf(BuildContext context, PayrollEntry entry) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert PayrollEntry to payslip data format for PDF generation
      final payslipData = {
        'payslip_number': 'PS-${entry.entryId?.substring(0, 8) ?? 'UNKNOWN'}',
        'employee_name': entry.employeeName ?? 'Unknown Employee',
        'employee_id': entry.userId ?? 'Unknown ID',
        'employee_email': 'N/A', // Not available in PayrollEntry
        'department': 'N/A', // Not available in PayrollEntry
        'position': 'N/A', // Not available in PayrollEntry
        'pay_period_start': entry.startDate.toIso8601String(),
        'pay_period_end': entry.paymentDate.toIso8601String(),
        'pay_date': entry.paymentDate.toIso8601String(),
        'base_salary': entry.salaryAmount,
        'salary_currency': entry.salaryCurrency ?? 'USD',
        'overtime_pay': 0.0,
        'bonus': 0.0,
        'allowances': 0.0,
        'total_earnings': entry.salaryAmount,
        'tax_deduction': 0.0,
        'insurance_deduction': 0.0,
        'retirement_deduction': 0.0,
        'other_deductions': 0.0,
        'total_deductions': 0.0,
        'final_net_pay': entry.usdEquivalent,
        'cryptocurrency': entry.cryptocurrency ?? 'ETH',
        'crypto_amount': entry.amount,
        'usd_equivalent': entry.usdEquivalent,
        'transaction_hash': entry.transactionHash,
        'status': entry.status ?? 'UNKNOWN',
        'notes': entry.notes ?? 'Generated from payroll entry',
      };

      // Generate PDF
      final filePath = await PdfGenerationHelper.generatePayslipPdf(payslipData);

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
}
