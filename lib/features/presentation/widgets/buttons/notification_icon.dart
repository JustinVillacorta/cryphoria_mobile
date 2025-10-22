import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlassNotificationIcon extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final VoidCallback? onTap;

  const GlassNotificationIcon({
    super.key,
    this.width = 32,
    this.height = 32,
    this.icon = CupertinoIcons.bell,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07), // glass effect
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
