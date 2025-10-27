import 'dart:math' as math;
import 'package:flutter/material.dart';

class CryptoNewsSection extends StatelessWidget {
  const CryptoNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final double newsHeight = math.min(220, MediaQuery.of(context).size.height * 0.28).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Crypto News',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: theme.hintColor),
                const SizedBox(width: 6),
                Text(
                  'Cached · 1 minute ago',
                  style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(Icons.refresh, size: 18, color: theme.hintColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E6),
            border: Border.all(color: const Color(0xFFFFE0A3)),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFFB36B00), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Showing cached data – next update at 5:00 AM.',
                  style: textTheme.bodySmall?.copyWith(color: const Color(0xFFB36B00)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

                SizedBox(
                  height: newsHeight,
                  child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _NewsCard(
                categoryIcon: Icons.store_mall_directory_outlined,
                categoryLabel: 'Market',
                categoryColor: Color(0xFF0B7A5B),
                sourceLabel: 'CryptoDaily',
                title: 'Bitcoin Surges Past \$50,000 as\nInstitutional Interest Grows',
                summary:
                    'Bitcoin has surpassed the \$50,000 mark for the first time in months as…',
                timeAgo: '41 minutes ago',
                emphasisColor: Color(0xFFE8F7F1),
                borderColor: Color(0xFFBFE8D8),
                height: newsHeight - 24,
              ),
              _NewsCard(
                categoryIcon: Icons.memory,
                categoryLabel: 'Technology',
                categoryColor: Color(0xFF5B5BD6),
                sourceLabel: 'CryptoNews',
                title: 'Ethereum 2.0 Upgrade Scheduled\nfor Next Month',
                summary:
                    'The long‑awaited network upgrade bringing scalability improvements is finally scheduled…',
                timeAgo: '2 hours ago',
                emphasisColor: Color(0xFFF1F0FF),
                borderColor: Color(0xFFDAD8FF),
                height: newsHeight - 24,
              ),
              _NewsCard(
                categoryIcon: Icons.policy_outlined,
                categoryLabel: 'Regulation',
                categoryColor: Color(0xFF8A5A00),
                sourceLabel: 'BlockDesk',
                title: 'SEC Reviews New Spot ETF\nApplications',
                summary: 'Regulatory momentum continues as fresh applications enter the pipeline…',
                timeAgo: '3 hours ago',
                emphasisColor: Color(0xFFFFF4E8),
                borderColor: Color(0xFFFFE0B8),
                height: newsHeight - 24,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final double? height;
  final IconData categoryIcon;
  final String categoryLabel;
  final Color categoryColor;
  final String sourceLabel;
  final String title;
  final String summary;
  final String timeAgo;
  final Color emphasisColor;
  final Color borderColor;

  const _NewsCard({
    this.height,
    required this.categoryIcon,
    required this.categoryLabel,
    required this.categoryColor,
    required this.sourceLabel,
    required this.title,
    required this.summary,
    required this.timeAgo,
    required this.emphasisColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: 320,
      height: height ?? 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: emphasisColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chip(
                context,
                icon: categoryIcon,
                label: categoryLabel,
                foreground: categoryColor,
                background: Colors.white,
              ),
              const Spacer(),
              _chip(
                context,
                label: sourceLabel,
                foreground: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                background: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Divider(color: borderColor.withValues(alpha: 0.8), height: 18),
          Row(
            children: [
              Text(
                timeAgo,
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Read More',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.open_in_new, size: 14, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    IconData? icon,
    required String label,
    required Color foreground,
    required Color background,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
