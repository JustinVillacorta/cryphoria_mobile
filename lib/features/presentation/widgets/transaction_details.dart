import 'package:flutter/material.dart';

// ===== Model =====
class TransactionData {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final String dateTime;
  final String category;
  final String paymentMethod;
  final String reference;
  final String notes;
  final String transactionId;
  final String accountType;
  final String taxRate;
  final double taxAmount;

  const TransactionData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.dateTime,
    required this.category,
    required this.paymentMethod,
    required this.reference,
    required this.notes,
    required this.transactionId,
    required this.accountType,
    required this.taxRate,
    required this.taxAmount,
  });
}

// ===== Widget =====
class TransactionDetailsWidget extends StatelessWidget {
  final TransactionData transaction;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onPrint;

  const TransactionDetailsWidget({
    super.key,
    required this.transaction,
    this.onDelete,
    this.onEdit,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction Details',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (onPrint != null)
            IconButton(icon: const Icon(Icons.print_outlined, color: Colors.white), onPressed: onPrint),
          if (onEdit != null)
            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white), onPressed: onEdit),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main Transaction Info
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: transaction.isIncome ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: transaction.isIncome ? Colors.green[600] : Colors.red[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(transaction.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 4),
                        Text(transaction.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: transaction.isIncome ? Colors.green[600] : Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Details Grid
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildDetailItem(label: 'Date & Time', value: transaction.dateTime)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildDetailItem(label: 'Category', value: transaction.category)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildDetailItem(label: 'Payment Method', value: transaction.paymentMethod)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildDetailItem(label: 'Reference', value: transaction.reference)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Notes
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notes',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(
                    transaction.notes,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A), height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Transaction ID + Delete
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaction ID: ${transaction.transactionId}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Accounting Summary
            Container(
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Accounting Summary',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF4338CA))),
                  const SizedBox(height: 16),
                  _buildAccountingRow('Account:', transaction.accountType),
                  const SizedBox(height: 8),
                  _buildAccountingRow('Tax Rate:', transaction.taxRate),
                  const SizedBox(height: 8),
                  _buildAccountingRow('Tax Amount:', '\$${transaction.taxAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),

            // Close
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Close',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  static Widget _buildAccountingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF4338CA))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4338CA))),
      ],
    );
  }
}
