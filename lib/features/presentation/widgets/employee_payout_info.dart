import 'package:flutter/material.dart';

class PayoutInfoWidget extends StatelessWidget {
  final String nextPayoutDate;
  final String frequency;
  final bool isTablet;

  const PayoutInfoWidget({
    Key? key,
    required this.nextPayoutDate,
    required this.frequency,
    this.isTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              context: context,
              icon: Icons.calendar_today_outlined,
              title: 'Next Payout',
              value: nextPayoutDate,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: _buildInfoCard(
              context: context,
              icon: Icons.wallet,
              title: 'Frequency',
              value: frequency,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required double screenWidth,
    required double screenHeight,
  }) {
    // Calculate responsive dimensions
    final double cardHeight = screenHeight * 0.08; // 8% of screen height
    final double iconSize = cardHeight * 0.4; // 40% of card height
    final double titleFontSize = cardHeight * 0.2; // 20% of card height
    final double valueFontSize = cardHeight * 0.25; // 25% of card height
    
    return Container(
      height: cardHeight,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: cardHeight * 0.15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF9747FF),
            size: isTablet ? 24 : iconSize,
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : titleFontSize,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : valueFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}