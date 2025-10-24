import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Transactions/all_transactions_screen.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/transactions/transaction_details.dart';

class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    
    // Responsive sizing
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;
    final seeAllFontSize = isSmallScreen ? 13.0 : 14.0;
    
    final state = ref.watch(walletNotifierProvider);
    final notifier = ref.read(walletNotifierProvider.notifier);

    if (state.isLoading) {
      return SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFF9747FF),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (state.error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: GoogleFonts.inter(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 14 : 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: ${state.error}',
                    style: GoogleFonts.inter(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: notifier.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9747FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
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
            Text(
              'Recent Transactions',
              style: GoogleFonts.inter(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9747FF),
                        fontSize: seeAllFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: const Color(0xFF9747FF),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        SizedBox(height: isSmallScreen ? 14 : 16),

        ...(() {
          final limitedTransactions = state.transactions.take(5).toList();

          if (state.transactions.isEmpty) {
            return [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isSmallScreen ? 32 : 48,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: isTablet ? 56 : 48,
                        color: const Color(0xFF6B6B6B).withOpacity(0.5),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        'No recent transactions',
                        style: GoogleFonts.inter(
                          fontSize: isTablet ? 17 : 16,
                          color: const Color(0xFF6B6B6B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          } else {
            return [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: limitedTransactions.length,
                separatorBuilder: (context, index) => SizedBox(height: isSmallScreen ? 10 : 12),
                itemBuilder: (context, index) {
                  final transaction = limitedTransactions[index];
                  return _buildTransactionItem(context, transaction, size, isSmallScreen, isTablet);
                },
              )
            ];
          }
        })(),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Map<String, dynamic> transaction,
    Size size,
    bool isSmallScreen,
    bool isTablet,
  ) {
    final Color color = (transaction['color'] as Color?) ?? const Color(0xFF9747FF);
    final IconData iconData = transaction['icon'] is IconData
        ? transaction['icon'] as IconData
        : Icons.swap_horiz_rounded;

    final String amountText = (transaction['amount'] ?? '').toString();
    final double numericAmount = _parseAmount(amountText);
    final bool isPositive = (transaction['isPositive'] as bool?) ?? (numericAmount >= 0);

    final iconSize = isTablet ? 22.0 : 20.0;
    final containerSize = isTablet ? 44.0 : 40.0;
    final titleFontSize = isTablet ? 15.0 : 14.0;
    final subtitleFontSize = isSmallScreen ? 11.5 : 12.0;
    final amountFontSize = isTablet ? 15.0 : 14.0;
    final timeFontSize = isSmallScreen ? 11.5 : 12.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final tx = TransactionData(
            title: (transaction['title'] ?? 'Transaction').toString(),
            subtitle: (transaction['subtitle'] ?? '').toString(),
            amount: numericAmount.abs(),
            isIncome: isPositive,
            dateTime: (transaction['time'] ?? 'Today').toString(),
            category: (transaction['category'] ?? (isPositive ? 'Income' : 'Expense')).toString(),
            notes: (transaction['notes'] ?? '—').toString(),
            transactionId: (transaction['id'] ?? transaction['transactionId'] ??
                    'TX-${DateTime.now().millisecondsSinceEpoch}')
                .toString(),
            transactionHash: transaction['transaction_hash']?.toString(),
            fromAddress: transaction['from_address']?.toString(),
            toAddress: transaction['to_address']?.toString(),
            gasCost: transaction['gas_cost']?.toString(),
            gasPrice: transaction['gas_price']?.toString(),
            confirmations: transaction['confirmations'] is int
                ? transaction['confirmations'] as int
                : null,
            status: transaction['status']?.toString(),
            network: transaction['network']?.toString() ?? 'Ethereum',
            company: transaction['company']?.toString(),
            description: transaction['description']?.toString(),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailsWidget(transaction: tx),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(isTablet ? 18 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: color,
                  size: iconSize,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'],
                      style: GoogleFonts.inter(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transaction['subtitle'],
                      style: GoogleFonts.inter(
                        fontSize: subtitleFontSize,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width * 0.28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transaction['amount'],
                      style: GoogleFonts.inter(
                        fontSize: amountFontSize,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : const Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transaction['time'],
                      style: GoogleFonts.inter(
                        fontSize: timeFontSize,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _parseAmount(String raw) {
    if (raw.isEmpty) return 0.0;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
