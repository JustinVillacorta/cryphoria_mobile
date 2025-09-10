import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Home/home_viewmodel/home_viewmodel.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (viewModel.error != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const SizedBox(height: 16),
              Text('Error: ${viewModel.error}'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: viewModel.refresh,
                child: const Text('Retry'),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle click
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = viewModel.transactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction['icon'],
              color: transaction['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction['amount'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: transaction['isPositive'] ? Colors.green : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction['time'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}