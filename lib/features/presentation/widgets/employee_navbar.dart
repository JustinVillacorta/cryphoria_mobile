import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmployeeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmployeeNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12), // Darker with higher opacity
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // Slightly more visible border
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(CupertinoIcons.house, 0),
                _buildNavItem(CupertinoIcons.doc_text, 1), // Payslip icon
                _buildNavItem(CupertinoIcons.person, 2), // User Profile
              ],
            ),
          ),
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