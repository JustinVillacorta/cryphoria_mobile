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
      title: 'ETH Received',
      subtitle: '0x1234...5678',
      amount: 0.5,
      isIncome: true,
      dateTime: 'Today, 10:24 AM',
      category: 'Income',
      notes: 'Payment for website development services.',
      transactionId: 'TX-000001',
      transactionHash: '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890',
      fromAddress: '0x1234567890abcdef1234567890abcdef12345678',
      toAddress: '0x9876543210fedcba9876543210fedcba98765432',
      gasCost: '0.001 ETH',
      gasPrice: '20 Gwei',
      confirmations: 12,
      status: 'confirmed',
      network: 'Ethereum',
      company: 'Johnson & Co.',
      description: 'Payment for website development services.',
    );

    return TransactionDetailsWidget(
      transaction: transaction,
    );
  }
}
