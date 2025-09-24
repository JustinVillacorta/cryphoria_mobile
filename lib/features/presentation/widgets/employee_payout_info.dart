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

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context: context,
            icon: Icons.calendar_today_outlined,
            title: 'Next Payout',
            value: nextPayoutDate,
            screenWidth: screenWidth,
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
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
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
            size: isTablet ? 24 : screenWidth * 0.05,
          ),
          SizedBox(width: screenWidth * 0.03),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : screenWidth * 0.03,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}