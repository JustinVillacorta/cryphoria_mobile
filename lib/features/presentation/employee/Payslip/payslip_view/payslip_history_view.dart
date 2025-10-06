import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../payslip_entry_details_view/payslip_entry_details_view.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with actual data from your state management
    final payslipHistory = [
      {
        'entryId': 'ec20ba0d-2795-4e86-aa49-098cc51b4996',
        'amount': 0.02199440463643279,
        'status': 'COMPLETED',
        'date': DateTime(2025, 10, 5),
        'cryptocurrency': 'ETH',
      },
      {
        'entryId': 'f8b2c3d4-e5f6-7890-1234-567890123456',
        'amount': 0.01567890123456789,
        'status': 'COMPLETED',
        'date': DateTime(2025, 10, 4),
        'cryptocurrency': 'ETH',
      },
      {
        'entryId': 'a1b2c3d4-e5f6-7890-1234-567890123456',
        'amount': 0.03210987654321098,
        'status': 'FAILED',
        'date': DateTime(2025, 10, 3),
        'cryptocurrency': 'ETH',
      },
    ];

    final summaryData = {
      'totalEntries': 27,
      'completed': 12,
      'scheduled': 0,
      'failed': 1,
      'totalPaid': 134230.00,
      'totalPending': 0.00,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Payroll History',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Track and manage your payment records',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mobile Layout - Stack vertically for clean mobile experience
            Column(
              children: [
                // Summary Cards
                _buildTotalEntriesCard(summaryData),
                const SizedBox(height: 12),
                _buildPaymentStatisticsCard(summaryData),
                const SizedBox(height: 12),
                _buildFinancialSummaryCard(summaryData),
                const SizedBox(height: 16),
                
                // Payslip Entries Table
                _buildPayslipEntriesCard(context, payslipHistory),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTotalEntriesCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6B46C1)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL ENTRIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${data['totalEntries']}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.show_chart,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatisticsCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Statistics',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatisticRow('Completed', data['completed'], Colors.green, Icons.check_circle),
          const SizedBox(height: 8),
          _buildStatisticRow('Scheduled', data['scheduled'], Colors.blue, Icons.schedule),
          const SizedBox(height: 8),
          _buildStatisticRow('Failed', data['failed'], Colors.red, Icons.error),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildFinancialRow('Total Paid', '\$${data['totalPaid'].toStringAsFixed(2)}', Colors.green, Icons.attach_money),
          const SizedBox(height: 8),
          _buildFinancialRow('Total Pending', '\$${data['totalPending'].toStringAsFixed(2)}', Colors.orange, Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipEntriesCard(BuildContext context, List<Map<String, dynamic>> payslipHistory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payslip Entries',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'All your payment transactions',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Card-based entries list
          ...payslipHistory.map((entry) => _buildPayslipEntryCard(context, entry)).toList(),
        ],
      ),
    );
  }

  Widget _buildPayslipEntryCard(BuildContext context, Map<String, dynamic> entry) {
    final String date = DateFormat('MMM dd, yyyy').format(entry['date']);
    final String cryptoAmount = '${entry['amount'].toStringAsFixed(4)} ${entry['cryptocurrency']}';
    final String fiatAmount = '\$${(entry['amount'] * 2000).toStringAsFixed(2)} USD'; // Sample conversion rate

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          // Navigate to payslip entry details
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PayslipEntryDetailsView(entry: entry),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left side: Date, Status, Entry ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(entry['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(entry['status']), 
                            color: _getStatusColor(entry['status']), 
                            size: 12
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry['status'].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(entry['status']),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: ${entry['entryId'].toString().substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Right side: Crypto Amount, Fiat Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cryptoAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fiatAmount,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      default:
        return Icons.help;
    }
  }
}