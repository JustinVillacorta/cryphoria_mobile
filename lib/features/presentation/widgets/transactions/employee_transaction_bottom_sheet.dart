import 'package:flutter/material.dart';

class EmployeeTransactionDetails extends StatefulWidget {
  final String date;
  final String amount;
  final String usdAmount;
  final String status;
  final Color statusColor;
  final IconData statusIcon;

  const EmployeeTransactionDetails({
    super.key,
    required this.date,
    required this.amount,
    required this.usdAmount,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  State<EmployeeTransactionDetails> createState() => _EmployeeTransactionDetailsState();
}

class _EmployeeTransactionDetailsState extends State<EmployeeTransactionDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black,),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 8),
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.amount,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.usdAmount,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'September 2025 Salary Payment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.statusIcon,
                        size: 14,
                        color: widget.statusColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        widget.status,
                        style: TextStyle(
                          color: widget.statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow('Date', widget.date),
                _buildDetailRow('Status', widget.status, icon: widget.statusIcon, color: widget.statusColor),
                _buildDetailRow('From', '0xABC...123', isCopyable: true),
                _buildDetailRow('To', '0xDEF...456', isCopyable: true),
                _buildDetailRow('Transaction Fee', '0.001 ETH'),
                _buildDetailRow('Block Number', '1436789'),
                _buildDetailRow('Transaction Hash', '0xDEF...789', isCopyable: true),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Color(0xFF9747FF),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon, Color? color, bool isCopyable = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 16, color: color),
              SizedBox(width: icon != null ? 4 : 0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: icon != null ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              if (isCopyable)
                Icon(Icons.copy, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}