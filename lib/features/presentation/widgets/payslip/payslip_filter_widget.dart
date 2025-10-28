
import 'package:flutter/material.dart';
import '../../../domain/entities/create_payslip_request.dart';
import '../../../domain/entities/payslip.dart';

class PayslipFilterWidget extends StatelessWidget {
  final PayslipFilter currentFilter;
  final Function(PayslipFilter) onFilterChanged;

  const PayslipFilterWidget({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Status',
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatusChip(
                context,
                'All',
                null,
                currentFilter.status == null,
              ),
              SizedBox(width: 8),
              ...PayslipStatus.values.map((status) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: _buildStatusChip(
                  context,
                  status.displayName,
                  status,
                  currentFilter.status == status,
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    PayslipStatus? status,
    bool isSelected,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: screenWidth * 0.03,
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        final newFilter = currentFilter.copyWith(status: status);
        onFilterChanged(newFilter);
      },
      selectedColor: Color(0xFF9747FF),
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}