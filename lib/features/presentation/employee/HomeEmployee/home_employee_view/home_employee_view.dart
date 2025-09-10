import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_transaction_bottom_sheet.dart';
class HomeEmployeeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% of screen width
              vertical: screenHeight * 0.025, // 2.5% of screen height
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting and notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, Anna',
                            style: TextStyle(
                              fontSize: isTablet ? 28 : screenWidth * 0.06,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            'How are you today?',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : screenWidth * 0.04,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: Colors.grey[700],
                        size: isTablet ? 24 : screenWidth * 0.05,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // Wallet Card
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 500 : double.infinity,
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B5FBF),
                        Color(0xFF6B46C1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Wallet',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isTablet ? 16 : screenWidth * 0.035,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$ ETH',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 18 : screenWidth * 0.04,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white,
                                  size: isTablet ? 18 : screenWidth * 0.04,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Connect Wallet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 14 : screenWidth * 0.03,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      Text(
                        '67,980 ETH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 36 : screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      Text(
                        'Converted to',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isTablet ? 14 : screenWidth * 0.03,
                        ),
                      ),
                      Text(
                        '12,230 PHP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : screenWidth * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // Payout and Frequency Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF9747FF),
                              size: isTablet ? 24 : screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Next Payout',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : screenWidth * 0.03,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'June 30, 2023',
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
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.02),

                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wallet,
                              color: Color(0xFF9747FF),
                              size: isTablet ? 24 : screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Frequency',
                                    style: TextStyle(
                                      fontSize: isTablet ? 14 : screenWidth * 0.03,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Monthly',
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
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // Recent Transactions Header
                Row(
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
                    Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : screenWidth * 0.035,
                            color: Color(0xFF9747FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: isTablet ? 14 : screenWidth * 0.03,
                          color: Color(0xFF9747FF),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.016),

                // Transaction List
                Column(
                  children: [
                    _buildTransactionItem(
                      context: context,
                      date: 'May 31, 2023',
                      amount: '0.45 ETH',
                      usdAmount: '\$820.90 USD',
                      status: 'Paid',
                      statusColor: Colors.green,
                      statusIcon: Icons.check_circle,
                    ),
                    _buildTransactionItem(
                      context: context,
                      date: 'April 30, 2023',
                      amount: '0.45 ETH',
                      usdAmount: '\$820.90 USD',
                      status: 'Paid',
                      statusColor: Colors.green,
                      statusIcon: Icons.check_circle,
                    ),
                    _buildTransactionItem(
                      context: context,
                      date: 'June 30, 2023',
                      amount: '0.45 ETH',
                      usdAmount: '\$820.90 USD',
                      status: 'Pending',
                      statusColor: Colors.orange,
                      statusIcon: Icons.schedule,
                    ),
                    _buildTransactionItem(
                      context: context,
                      date: 'June 30, 2023',
                      amount: '0.45 ETH',
                      usdAmount: '\$820.90 USD',
                      status: 'Pending',
                      statusColor: Colors.orange,
                      statusIcon: Icons.schedule,
                    ),
                    _buildTransactionItem(
                      context: context,
                      date: 'June 30, 2023',
                      amount: '0.45 ETH',
                      usdAmount: '\$820.90 USD',
                      status: 'Pending',
                      statusColor: Colors.orange,
                      statusIcon: Icons.schedule,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required String date,
    required String amount,
    required String usdAmount,
    required String status,
    required Color statusColor,
    required IconData statusIcon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          builder: (context) => EmployeeTransactionDetails(
            date: date,
            amount: amount,
            usdAmount: usdAmount,
            status: status,
            statusColor: statusColor,
            statusIcon: statusIcon,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.01),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    usdAmount,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : screenWidth * 0.03,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: isTablet ? 14 : screenWidth * 0.03,
                          color: statusColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : screenWidth * 0.03,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                // Removed "View" text since the whole card is tappable
              ],
            ),
          ],
        ),
      ),
    );
  }
}