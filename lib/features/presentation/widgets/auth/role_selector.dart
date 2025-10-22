import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef RoleSelectedCallback = void Function(String role);

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final RoleSelectedCallback onRoleSelected;

  const RoleSelector({Key? key, required this.selectedRole, required this.onRoleSelected}) : super(key: key);

  Widget _buildCard({required BuildContext context, required String role, required String assetPath}) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () => onRoleSelected(role),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFFFAF8FF) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF000000),
                width: isSelected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            // use padding instead of ClipOval to avoid cropping strokes that extend
            // to the edge of the SVG. The circular border still constrains the
            // visual area while the icon has breathing room.
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: assetPath.toLowerCase().endsWith('.svg')
                  ? SvgPicture.asset(
                      assetPath,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      color: isSelected ? const Color(0xFF8B5CF6) : null,
                    )
                  : Image.asset(
                      assetPath,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      color: isSelected ? const Color(0xFF8B5CF6) : null,
                      colorBlendMode: isSelected ? BlendMode.srcIn : null,
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            role,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.black87,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(context: context, role: 'Manager', assetPath: 'assets/icons/manager.svg'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCard(context: context, role: 'Employee', assetPath: 'assets/icons/employee.svg'),
        ),
      ],
    );
  }
}
