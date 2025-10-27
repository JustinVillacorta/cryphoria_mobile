import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? initials;
  final VoidCallback? onEdit;
  final double height;
  final double avatarRadius;
  final double ringWidth;
  final Color? ringColor;
  final Color? gradientStart;
  final Color? gradientEnd;
  final Widget? customAvatar;

  const ProfileHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.initials,
    this.onEdit,
    this.height = 240,
    this.avatarRadius = 48,
    this.ringWidth = 3,
    this.ringColor,
    this.gradientStart,
    this.gradientEnd,
    this.customAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color effectiveRingColor = ringColor ?? theme.colorScheme.primary;
    final Color start = gradientStart ?? theme.colorScheme.primary;
    final Color end = gradientEnd ?? theme.colorScheme.primaryContainer;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Avatar(
              radius: avatarRadius,
              ringWidth: ringWidth,
              ringColor: effectiveRingColor,
              imageUrl: imageUrl,
              initials: initials ?? _initialsFrom(title),
              onEdit: onEdit,
              child: customAvatar,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _initialsFrom(String text) {
    final parts = text.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return "";
    String first = parts.first.isNotEmpty ? parts.first[0] : "";
    String last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : "";
    return (first + last).toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  final double radius;
  final double ringWidth;
  final Color ringColor;
  final String? imageUrl;
  final String? initials;
  final VoidCallback? onEdit;
  final Widget? child;

  const _Avatar({
    required this.radius,
    required this.ringWidth,
    required this.ringColor,
    this.imageUrl,
    this.initials,
    this.onEdit,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(ringWidth),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(color: ringColor, width: ringWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: child ?? CircleAvatar(
                radius: radius,
                backgroundColor: Colors.white,
                backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                    ? NetworkImage(imageUrl!)
                    : null,
                child: (imageUrl == null || imageUrl!.isEmpty)
                    ? Text(
                        (initials ?? "").isNotEmpty ? initials! : "?",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (onEdit != null)
          Positioned(
            right: -4,
            bottom: -4,
            child: Material(
              color: theme.colorScheme.secondaryContainer,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}