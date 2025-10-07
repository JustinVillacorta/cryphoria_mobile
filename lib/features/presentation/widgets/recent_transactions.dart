import 'package:cryphoria_mobile/features/presentation/manager/Home/transaction_details/transaction_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Transactions/all_transactions_screen.dart';

// ⬇️ Add this import (update the path if different)
import 'package:cryphoria_mobile/features/presentation/widgets/transaction_details.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletNotifierProvider);
    final notifier = ref.read(walletNotifierProvider.notifier);

    if (state.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text('Error: ${state.error}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: notifier.refresh,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllTransactionsScreen(),
                  ),
                );
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

        // ✅ Limit to 5 transactions
        ...(() {
          final limitedTransactions = state.transactions.take(5).toList();

          if (state.transactions.isEmpty) {
            return [
              const Text(
                'No recent transactions.',
                style: TextStyle(color: Colors.grey),
              )
            ];
          } else {
            return [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: limitedTransactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = limitedTransactions[index];
                  // ⬇️ pass context so we can navigate
                  return _buildTransactionItem(context, transaction);
                },
              )
            ];
          }
        })(),
      ],
    );
  }

  // ⬇️ Accept BuildContext so we can call Navigator.push
  Widget _buildTransactionItem(BuildContext context, Map<String, dynamic> transaction) {
    final Color color = (transaction['color'] as Color?) ?? Colors.blue;
    final IconData iconData = transaction['icon'] is IconData ? transaction['icon'] as IconData : Icons.swap_horiz_rounded;

    // amount may be a string (e.g., "+\$12.30") or a number
    final String amountText = (transaction['amount'] ?? '').toString();
    final double numericAmount = _parseAmount(amountText);
    final bool isPositive = (transaction['isPositive'] as bool?) ?? (numericAmount >= 0);

    // ⬇️ Build the tile with InkWell to support onTap
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Minimal: construct TransactionData from the map with safe fallbacks
          final tx = TransactionData(
            title: (transaction['title'] ?? 'Transaction').toString(),
            subtitle: (transaction['subtitle'] ?? '').toString(),
            amount: numericAmount.abs(),
            isIncome: isPositive,
            dateTime: (transaction['time'] ?? 'Today').toString(),
            category: (transaction['category'] ?? (isPositive ? 'Income' : 'Expense')).toString(),
            paymentMethod: (transaction['paymentMethod'] ?? 'Wallet').toString(),
            reference: (transaction['reference'] ?? '—').toString(),
            notes: (transaction['notes'] ?? '—').toString(),
            transactionId: (transaction['id'] ?? transaction['transactionId'] ?? 'TX-${DateTime.now().millisecondsSinceEpoch}').toString(),
            accountType: (transaction['accountType'] ?? (isPositive ? 'Revenue' : 'Expense')).toString(),
            taxRate: (transaction['taxRate'] ?? '0%').toString(),
            taxAmount: _deriveTaxFromRate(
              numericAmount.abs(),
              (transaction['taxRate'] ?? '0%').toString(),
              fallback: (transaction['taxAmount'] is num) ? (transaction['taxAmount'] as num).toDouble() : null,
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailsScreen(),
            ),
          );
        },
        child: Container(
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: color,
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
                      color: isPositive ? Colors.green : Colors.black,
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
        ),
      ),
    );
  }

  // ---- helpers (just for parsing & tax fallback; doesn't change your UI) ----
  double _parseAmount(String raw) {
    if (raw.isEmpty) return 0.0;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  double _deriveTaxFromRate(double base, String rateLike, {double? fallback}) {
    if (fallback != null) return fallback;
    final s = rateLike.trim();
    if (s.endsWith('%')) {
      final pct = double.tryParse(s.substring(0, s.length - 1)) ?? 0.0;
      return base * (pct / 100.0);
    }
    final rate = double.tryParse(s) ?? 0.0;
    return base * rate;
  }
}
