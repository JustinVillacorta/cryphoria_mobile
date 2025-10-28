import 'package:flutter/material.dart';

class TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final double Function(String) parseAmount;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.onTap,
    required this.parseAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSentTransaction = transaction['transaction_category'] == 'SENT' ||
        transaction['title'].toString().toLowerCase().contains('sent') ||
        transaction['title'].toString().toLowerCase().contains('bought') ||
        transaction['title'].toString().toLowerCase().contains('purchase') ||
        transaction['title'].toString().toLowerCase().contains('buy') ||
        transaction['type'] == 'buy';

    final bool isReceivedTransaction = transaction['transaction_category'] == 'RECEIVED' ||
        transaction['title'].toString().toLowerCase().contains('received') ||
        transaction['title'].toString().toLowerCase().contains('sell') ||
        transaction['title'].toString().toLowerCase().contains('sold') ||
        transaction['type'] == 'sell';

    final String amountText = (transaction['amount'] ?? '').toString();
    final double numericAmount = parseAmount(amountText);
    final bool isPositive = (transaction['isPositive'] as bool?) ?? (numericAmount >= 0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildIcon(isSentTransaction, isReceivedTransaction),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTransactionInfo(isSentTransaction, isReceivedTransaction),
              ),
              _buildAmountInfo(isPositive, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isSent, bool isReceived) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSent
            ? Colors.red.withValues(alpha: 0.1)
            : isReceived
                ? Colors.green.withValues(alpha: 0.1)
                : (transaction['color'] as Color?)?.withValues(alpha: 0.1) ?? Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isSent
            ? Icons.arrow_upward
            : isReceived
                ? Icons.arrow_downward
                : (transaction['icon'] as IconData?) ?? Icons.swap_horiz_rounded,
        color: isSent
            ? Colors.red
            : isReceived
                ? Colors.green
                : (transaction['color'] as Color?) ?? Colors.blue,
        size: 20,
      ),
    );
  }

  Widget _buildTransactionInfo(bool isSent, bool isReceived) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSent
                    ? Colors.red
                    : isReceived
                        ? Colors.green
                        : Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isSent
                    ? 'Sent'
                    : isReceived
                        ? 'Received'
                        : transaction['title']?.toString() ?? 'Transaction',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                transaction['subtitle']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          transaction['time']?.toString() ?? transaction['created_at']?.toString() ?? 'Today',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInfo(bool isPositive, BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            transaction['amount']?.toString() ?? '\$0.00',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isPositive ? Colors.green : Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          const SizedBox(height: 4),
          if (transaction['price'] != null || transaction['fee'] != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (transaction['price'] != null) ...[
                  Text(
                    'Price: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    transaction['price']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (transaction['fee'] != null) ...[
                  Text(
                    'Fee: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    transaction['fee']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            Text(
              'Fee: \$0.00',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}