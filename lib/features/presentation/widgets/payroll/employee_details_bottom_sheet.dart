import 'package:flutter/material.dart';

class EmployeeDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const EmployeeDetailsBottomSheet({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['employee_details']?['full_name'] ?? 'Employee Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employee Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Name', data['employee_details']?['full_name'] ?? 'N/A'),
                  _buildDetailRow('Email', data['employee_details']?['email'] ?? 'N/A'),
                  _buildDetailRow('Department', data['employee_details']?['department'] ?? 'N/A'),
                  _buildDetailRow('Employee ID', data['employee_details']?['employee_number'] ?? 'N/A'),
                  const SizedBox(height: 24),
                  const Text(
                    'Payroll Statistics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Total Entries', '${data['payroll_statistics']?['total_entries'] ?? 0}'),
                  _buildDetailRow('Completed Payments', '${data['payroll_statistics']?['completed_payments'] ?? 0}'),
                  _buildDetailRow('Scheduled Payments', '${data['payroll_statistics']?['scheduled_payments'] ?? 0}'),
                  _buildDetailRow('Failed Payments', '${data['payroll_statistics']?['failed_payments'] ?? 0}'),
                  _buildDetailRow('Total Paid (USD)', '\$${(data['payroll_statistics']?['total_paid_usd'] ?? 0).toStringAsFixed(2)}'),
                  _buildDetailRow('Total Pending (USD)', '\$${(data['payroll_statistics']?['total_pending_usd'] ?? 0).toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}