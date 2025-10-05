// lib/features/presentation/manager/Payslip/Widgets/payslip_list_item.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/payslip.dart';
import 'package:intl/intl.dart';

class PayslipListItem extends StatelessWidget {
  final Payslip payslip;
  final VoidCallback onTap;

  const PayslipListItem({
    Key? key,
    required this.payslip,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Employee info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payslip.employeeName ?? 'Unknown Employee',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            payslip.position ?? 'No position specified',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payslip.statusEnum).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(payslip.statusEnum),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        payslip.statusEnum.displayName,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(payslip.statusEnum),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Pay period
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pay Period: ${DateFormat('MMM dd').format(payslip.payPeriodStart)} - ${DateFormat('MMM dd, yyyy').format(payslip.payPeriodEnd)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Net pay
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Pay',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '\$${payslip.finalNetPay.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9747FF),
                          ),
                        ),
                      ],
                    ),
                    
                    // Crypto amount
                    if (payslip.cryptoAmount > 0) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            payslip.cryptocurrency ?? 'Unknown',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${payslip.cryptoAmount.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Pay date
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pay Date: ${DateFormat('MMM dd, yyyy').format(payslip.payDate)}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[600],
                      ),
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

  Color _getStatusColor(PayslipStatus status) {
    switch (status) {
      case PayslipStatus.draft:
        return Colors.orange;
      case PayslipStatus.generated:
        return Colors.blue;
      case PayslipStatus.sent:
        return Colors.purple;
      case PayslipStatus.paid:
        return Colors.green;
      case PayslipStatus.cancelled:
        return Colors.red;
      case PayslipStatus.processing:
        return Colors.amber;
      case PayslipStatus.failed:
        return Colors.red;
      case PayslipStatus.pending:
        return Colors.grey;
    }
  }
}