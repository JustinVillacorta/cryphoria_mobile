import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionData {
  final String title;
  final String subtitle;
  final double amount;
  final bool isIncome;
  final String dateTime;
  final String category;
  final String notes;
  final String transactionId;

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

class TransactionDetailsWidget extends StatelessWidget {
  final TransactionData transaction;

  const TransactionDetailsWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;
    final appBarTitleSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction Details',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: appBarTitleSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 900 : isTablet ? 700 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainTransactionCard(context, size, isSmallScreen, isTablet, isDesktop, cardPadding, titleFontSize),
                SizedBox(height: isSmallScreen ? 12 : 16),

                if (transaction.transactionHash != null) ...[
                  _buildCryptoDetailsCard(context, size, isSmallScreen, isTablet, isDesktop, cardPadding, titleFontSize),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                ],

                _buildAdditionalInfoCard(context, size, isSmallScreen, isTablet, isDesktop, cardPadding, titleFontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainTransactionCard(BuildContext context, Size size, bool isSmallScreen, bool isTablet, bool isDesktop, double cardPadding, double titleFontSize) {
    final iconSize = isDesktop ? 28.0 : isTablet ? 26.0 : 24.0;
    final amountFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 14),
                decoration: BoxDecoration(
                  color: transaction.isIncome 
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: transaction.isIncome ? Colors.green[600] : Colors.red[600],
                  size: iconSize,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.title,
                      style: GoogleFonts.inter(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    Text(
                      transaction.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: isTablet ? 15 : 14,
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${transaction.isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(4)}',
                    style: GoogleFonts.inter(
                      fontSize: amountFontSize,
                      fontWeight: FontWeight.w700,
                      color: transaction.isIncome ? Colors.green[600] : Colors.red[600],
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'ETH',
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w500,
                      color: transaction.isIncome ? Colors.green[600] : Colors.red[600],
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.access_time,
                  label: 'Date & Time',
                  value: transaction.dateTime,
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 24 : 20),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.category,
                  label: 'Category',
                  value: transaction.category,
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoDetailsCard(BuildContext context, Size size, bool isSmallScreen, bool isTablet, bool isDesktop, double cardPadding, double titleFontSize) {
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: const Color(0xFF9747FF),
                size: isTablet ? 24 : 22,
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Text(
                'Blockchain Details',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 18 : 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          if (transaction.transactionHash != null) ...[
            _buildCopyableItem(
              label: 'Transaction Hash',
              value: transaction.transactionHash!,
              icon: Icons.fingerprint,
              context: context,
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
            ),
            SizedBox(height: isSmallScreen ? 12 : 14),
          ],

          if (transaction.fromAddress != null) ...[
            _buildCopyableItem(
              label: 'From Address',
              value: _formatAddress(transaction.fromAddress!),
              icon: Icons.arrow_upward,
              context: context,
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
            ),
            SizedBox(height: isSmallScreen ? 12 : 14),
          ],

          if (transaction.toAddress != null) ...[
            _buildCopyableItem(
              label: 'To Address',
              value: _formatAddress(transaction.toAddress!),
              icon: Icons.arrow_downward,
              context: context,
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
            ),
            SizedBox(height: isSmallScreen ? 12 : 14),
          ],

        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(BuildContext context, Size size, bool isSmallScreen, bool isTablet, bool isDesktop, double cardPadding, double titleFontSize) {
    final hasAdditionalData = (transaction.description != null && transaction.description!.isNotEmpty) ||
                             (transaction.company != null && transaction.company!.isNotEmpty) ||
                             (transaction.notes.isNotEmpty && transaction.notes != '—');

    if (!hasAdditionalData) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF9747FF),
                size: isTablet ? 24 : 22,
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Text(
                'Additional Information',
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 18 : 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 20 : 16),

          if (transaction.description != null && transaction.description!.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.description,
              label: 'Description',
              value: transaction.description!,
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
            ),
            if ((transaction.company != null && transaction.company!.isNotEmpty) || 
                (transaction.notes.isNotEmpty && transaction.notes != '—'))
              SizedBox(height: isSmallScreen ? 16 : 18),
          ],

          if (transaction.company != null && transaction.company!.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.business,
              label: 'Company',
              value: transaction.company!,
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
            ),
            if (transaction.notes.isNotEmpty && transaction.notes != '—')
              SizedBox(height: isSmallScreen ? 16 : 18),
          ],

          if (transaction.notes.isNotEmpty && transaction.notes != '—') ...[
            _buildInfoItem(
              icon: Icons.note,
              label: 'Notes',
              value: transaction.notes,
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
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
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: isTablet ? 18 : 16, color: const Color(0xFF6B6B6B)),
            SizedBox(width: isTablet ? 10 : 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: isTablet ? 14 : 13,
                  color: const Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTablet ? 16 : 15,
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          maxLines: 3,
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
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: () => _copyToClipboard(value, context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: isTablet ? 20 : 18, color: const Color(0xFF6B6B6B)),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 14 : 13,
                      color: const Color(0xFF6B6B6B),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: isTablet ? 15 : 14,
                      color: const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Icon(
              Icons.copy,
              size: isTablet ? 20 : 18,
              color: const Color(0xFF9747FF),
            ),
          ],
        ),
      ),
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
        content: Text(
          'Copied to clipboard',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF9747FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}