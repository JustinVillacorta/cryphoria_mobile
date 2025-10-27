import 'package:flutter/material.dart';

class TransactionListHeaderWidget extends StatelessWidget {
  final VoidCallback onViewAllTapped;
  final bool isTablet;

  const TransactionListHeaderWidget({
    super.key,
    required this.onViewAllTapped,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: isTablet ? 20 : screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: onViewAllTapped,
          child: Row(
            children: [
              Text(
                'View All',
                style: TextStyle(
                  fontSize: isTablet ? 16 : screenWidth * 0.035,
                  color: const Color(0xFF9747FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: isTablet ? 14 : screenWidth * 0.03,
                color: const Color(0xFF9747FF),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
