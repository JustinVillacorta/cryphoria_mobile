// lib/features/presentation/widgets/invoice_header_widget.dart
import 'package:flutter/material.dart';
import '../../domain/entities/invoice.dart';

class InvoiceHeaderWidget extends StatelessWidget {
  final Invoice invoice;

  const InvoiceHeaderWidget({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Issued on  ${_formatDate(invoice.issueDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(invoice.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'paid':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        icon = Icons.check_circle;
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        icon = Icons.schedule;
        break;
      case 'overdue':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        icon = Icons.error;
        break;
      default:
        bgColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF6B7280);
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }
}