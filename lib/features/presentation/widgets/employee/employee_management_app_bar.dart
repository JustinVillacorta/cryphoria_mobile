import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeManagementAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double appBarHeight;
  final double titleFontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final bool isTablet;
  final VoidCallback onAddPressed;

  const EmployeeManagementAppBar({
    Key? key,
    required this.appBarHeight,
    required this.titleFontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.isTablet,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF9FAFB),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Employee Management',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1A1A1A),
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF9747FF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9747FF).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isTablet ? 24 : 22,
                  ),
                  onPressed: onAddPressed,
                  tooltip: 'Add Employee',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}