import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ===== Model =====
class TransactionData {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final String dateTime;
  final String category;
  final String notes;
  final String transactionId;
  
  // Crypto-specific fields
  final String? transactionHash;
  final String? fromAddress;
  final String? toAddress;
  final String? gasCost;
  final String? gasPrice;
  final int? confirmations;
  final String? status;
  final String? network;
  final String? company;
  final String? description;

  const TransactionData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.dateTime,
    required this.category,
    required this.notes,
    required this.transactionId,
    this.transactionHash,
    this.fromAddress,
    this.toAddress,
    this.gasCost,
    this.gasPrice,
    this.confirmations,
    this.status,
    this.network,
    this.company,
    this.description,
  });
}

// ===== Widget =====
class TransactionDetailsWidget extends StatelessWidget {
  final TransactionData transaction;

  const TransactionDetailsWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          children: [
            // Main Transaction Info Card
            _buildMainTransactionCard(),
            const SizedBox(height: 12),
            
            // Crypto Details Card
            if (transaction.transactionHash != null) ...[
              _buildCryptoDetailsCard(),
              const SizedBox(height: 12),
            ],
            
            // Additional Info Card
            _buildAdditionalInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTransactionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: transaction.isIncome ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: transaction.isIncome ? Colors.green[600] : Colors.red[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${transaction.isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(4)} ETH',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome ? Colors.green[600] : Colors.red[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.access_time,
                  label: 'Date & Time',
                  value: transaction.dateTime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.category,
                  label: 'Category',
                  value: transaction.category,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoDetailsCard() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: const Color(0xFF9747FF), size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Blockchain Details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Transaction Hash
            if (transaction.transactionHash != null) ...[
              _buildCopyableItem(
                label: 'Transaction Hash',
                value: transaction.transactionHash!,
                icon: Icons.fingerprint,
                context: context,
              ),
              const SizedBox(height: 12),
            ],
            
            // From Address
            if (transaction.fromAddress != null) ...[
              _buildCopyableItem(
                label: 'From Address',
                value: _formatAddress(transaction.fromAddress!),
                icon: Icons.arrow_upward,
                context: context,
              ),
              const SizedBox(height: 12),
            ],
            
            // To Address
            if (transaction.toAddress != null) ...[
              _buildCopyableItem(
                label: 'To Address',
                value: _formatAddress(transaction.toAddress!),
                icon: Icons.arrow_downward,
                context: context,
              ),
              const SizedBox(height: 12),
            ],
          
            // Gas Details and Status
            Row(
              children: [
                if (transaction.gasCost != null) ...[
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.local_gas_station,
                      label: 'Gas Cost',
                      value: transaction.gasCost!,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (transaction.status != null)
                  Expanded(
                    child: _buildStatusBadge(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAdditionalInfoCard() {
    // Only show if there's relevant additional data
    final hasAdditionalData = (transaction.description != null && transaction.description!.isNotEmpty) ||
                             (transaction.company != null && transaction.company!.isNotEmpty) ||
                             (transaction.notes.isNotEmpty && transaction.notes != '—');
    
    if (!hasAdditionalData) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFF9747FF), size: 22),
              const SizedBox(width: 10),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (transaction.description != null && transaction.description!.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.description,
              label: 'Description',
              value: transaction.description!,
            ),
            const SizedBox(height: 12),
          ],
          
          if (transaction.company != null && transaction.company!.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.business,
              label: 'Company',
              value: transaction.company!,
            ),
            const SizedBox(height: 12),
          ],
          
          if (transaction.notes.isNotEmpty && transaction.notes != '—') ...[
            _buildInfoItem(
              icon: Icons.note,
              label: 'Notes',
              value: transaction.notes,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCopyableItem({
    required String label,
    required String value,
    required IconData icon,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => _copyToClipboard(value, context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.copy,
              size: 18,
              color: const Color(0xFF9747FF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText = transaction.status ?? 'Unknown';
    
    switch (statusText.toLowerCase()) {
      case 'confirmed':
      case 'success':
        statusColor = Colors.green[600]!;
        break;
      case 'pending':
        statusColor = Colors.orange[600]!;
        break;
      case 'failed':
      case 'error':
        statusColor = Colors.red[600]!;
        break;
      default:
        statusColor = Colors.grey[600]!;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 16, color: statusColor),
            const SizedBox(width: 8),
            Text(
              'Status',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            statusText.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _formatAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF9747FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
