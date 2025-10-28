import 'package:cryphoria_mobile/features/domain/entities/employee.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeDetailHeader extends StatelessWidget {
  final Employee employee;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onBackPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onEditPressed;

  const EmployeeDetailHeader({
    Key? key,
    required this.employee,
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.onBackPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleSize = isDesktop ? 20.0 : isTablet ? 19.0 : 18.0;
    final nameSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final positionSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    final detailSize = isDesktop ? 14.0 : isTablet ? 13.5 : 13.0;
    final avatarRadius = isDesktop ? 40.0 : isTablet ? 36.0 : 32.0;
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;

    final hasValidImage = employee.profileImage != null && 
                          employee.profileImage!.isNotEmpty &&
                          Uri.tryParse(employee.profileImage!)?.hasAbsolutePath == true;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9747FF), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isSmallScreen ? 8 : 12,
            horizontalPadding,
            isSmallScreen ? 16 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: isTablet ? 26 : 24,
                    ),
                    onPressed: onBackPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    'Employee Details',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: isTablet ? 24 : 22,
                        ),
                        onPressed: onDeletePressed,
                        tooltip: 'Remove Employee',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: isTablet ? 24 : 22,
                        ),
                        onPressed: onEditPressed,
                        tooltip: 'Edit Employee',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.white,
                      backgroundImage: hasValidImage
                          ? NetworkImage(employee.profileImage!)
                          : null,
                      child: !hasValidImage
                          ? Icon(
                              Icons.person_outline,
                              size: avatarRadius * 0.85,
                              color: const Color(0xFF9747FF),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: isTablet ? 18 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                employee.displayName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: nameSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: isTablet ? 12 : 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 12 : 10,
                                vertical: isTablet ? 6 : 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.green.shade400,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Active',
                                style: GoogleFonts.inter(
                                  color: Colors.green.shade100,
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Text(
                          employee.position ?? 'Employee',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: positionSize,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.employeeCode,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: detailSize,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 14 : 18),
              Wrap(
                spacing: isTablet ? 24 : 20,
                runSpacing: isSmallScreen ? 8 : 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: isTablet ? 18 : 16,
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Flexible(
                        child: Text(
                          employee.email,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: detailSize,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.business_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: isTablet ? 18 : 16,
                      ),
                      SizedBox(width: isTablet ? 8 : 6),
                      Text(
                        employee.department ?? 'General',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: detailSize,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}