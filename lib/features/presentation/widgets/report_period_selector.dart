import 'package:flutter/material.dart';

/// A reusable period selector widget that displays a dropdown with date ranges
/// for selecting different reporting periods across various report screens.
class ReportPeriodSelector<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T) formatPeriod;
  final void Function(T) onPeriodChanged;

  const ReportPeriodSelector({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.formatPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = items.indexOf(selectedItem);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 12),
          const Text(
            'Period:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<int>(
              value: currentIndex,
              isExpanded: true,
              underline: Container(),
              items: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    formatPeriod(item),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (int? newIndex) {
                if (newIndex != null && newIndex != currentIndex) {
                  onPeriodChanged(items[newIndex]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
