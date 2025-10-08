import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transaction_details.dart';
/// Screen that supplies FAKE DATA to the widget.
/// Push this screen with Navigator when you want to preview.
class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ---- Fake transaction data ----
    const transaction = TransactionData(
      title: 'Client Payment',
      subtitle: 'Johnson & Co.',
      amount: 1250.00,
      isIncome: true,
      dateTime: 'Today, 10:24 AM',
      category: 'Income',
      paymentMethod: 'Bank Transfer',
      reference: 'INV-2025-001',
      notes: 'Payment for website development services.',
      transactionId: 'TX-000001',
      accountType: 'Revenue',
      taxRate: '10%',
      taxAmount: 125.00,
    );

    return TransactionDetailsWidget(
      transaction: transaction,
      onDelete: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text('Are you sure you want to delete this transaction?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Transaction deleted')));
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onEdit: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit transaction'))),
      onPrint: () =>
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Printing transaction...'))),
    );
  }
}
