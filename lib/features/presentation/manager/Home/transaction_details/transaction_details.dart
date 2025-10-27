import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_details.dart';
class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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