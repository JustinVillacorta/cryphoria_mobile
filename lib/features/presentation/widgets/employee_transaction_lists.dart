import 'package:cryphoria_mobile/features/presentation/widgets/employee_transaction_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/domain/entities/employee_transaction_status.dart';

class TransactionItemWidget extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap; // Make onTap nullable since we'll handle it internally
  final bool isTablet;

  const TransactionItemWidget({
    Key? key,
    required this.transaction,
    this.onTap,
    this.isTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        print('Card tapped!'); // Debug print
        onTap?.call();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => EmployeeTransactionDetails(
            date: _formatDate(transaction.date),
            amount: '${transaction.amount} ${transaction.currency}',
            usdAmount: '\$${transaction.usdAmount.toStringAsFixed(2)} USD',
            status: _getStatusText(transaction.status),
            statusColor: _getStatusColor(transaction.status),
            statusIcon: _getStatusIcon(transaction.status),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.01),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(transaction.date),
                    style: TextStyle(
                      fontSize: isTablet ? 18 : screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    _formatWalletAddress(transaction.id),
                    style: TextStyle(
                      fontSize: isTablet ? 14 : screenWidth * 0.03,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(transaction.status),
                          size: isTablet ? 14 : screenWidth * 0.03,
                          color: _getStatusColor(transaction.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(transaction.status),
                          style: TextStyle(
                            fontSize: isTablet ? 14 : screenWidth * 0.03,
                            color: _getStatusColor(transaction.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.amount} ${transaction.currency}',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005),
                Text(
                  '\$${transaction.usdAmount.toStringAsFixed(2)} USD',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : screenWidth * 0.03,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatWalletAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.paid:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.paid:
        return Icons.check_circle;
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.paid:
        return 'Paid';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }
}