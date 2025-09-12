import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';

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
    final navBarHeight = context.responsiveValue(
      mobile: 55.0,
      tablet: 60.0,
      desktop: 65.0,
    );
    
    final navBarMargin = context.responsiveValue(
      mobile: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
      tablet: const EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
      desktop: const EdgeInsets.only(bottom: 12.0, left: 24.0, right: 24.0),
    );
    
    return Padding(
      padding: navBarMargin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: navBarHeight,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(CupertinoIcons.house, 0),
                _buildNavItem(CupertinoIcons.person_2, 1),
                _buildNavItem(CupertinoIcons.mail, 2), // Payroll
                _buildNavItem(CupertinoIcons.chart_bar, 3), // Invoices  
                _buildNavItem(CupertinoIcons.person, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return Builder(
      builder: (context) {
        final iconSize = context.responsiveValue(
          mobile: 22.0,
          tablet: 24.0,
          desktop: 26.0,
        );
        
        return IconButton(
          icon: Icon(icon, size: iconSize),
          color: currentIndex == index ? Colors.white : Colors.grey,
          onPressed: () => onTap(index),
          padding: EdgeInsets.all(context.responsiveValue(
            mobile: 8.0,
            tablet: 10.0,
            desktop: 12.0,
          )),
        );
      }
    );
  }
}