import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: CupertinoColors.white.withOpacity(0.1), // Semi-transparent
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withValues(alpha: 1.60),
              blurRadius: 20,
              offset: const Offset(0, 0), // Elevation effect
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(CupertinoIcons.house, 0),
            _buildNavItem(CupertinoIcons.person_2, 1),
            _buildNavItem(CupertinoIcons.mail, 2), // Changed from doc_text to person_2 for employee management
            _buildNavItem(CupertinoIcons.chart_bar, 3),
            _buildNavItem(CupertinoIcons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon),
      color: currentIndex == index ? Colors.white : Colors.grey,
      onPressed: () => onTap(index),
    );
  }
}