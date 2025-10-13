import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

/// Lightweight shimmer effect without extra dependencies.
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child, Key? key}) : super(key: key);
  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6);
    final highlight = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.25);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final width = rect.width;
            final gradientWidth = width * 0.30;
            final dx = (width + gradientWidth) * _controller.value - gradientWidth;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.1, 0.5, 0.9],
              transform: _GradientTranslation(Offset(dx, 0)),
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _GradientTranslation extends GradientTransform {
  const _GradientTranslation(this.offset);
  final Offset offset;
  @override
  vm.Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return vm.Matrix4.translationValues(offset.dx, offset.dy, 0.0);
  }
}

class _Bone extends StatelessWidget {
  const _Bone({this.height = 14, this.width, this.radius = 12, Key? key}) : super(key: key);
  final double height;
  final double? width;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Invoice screen skeleton approximating:
/// - Header with title and description
/// - Search bar
/// - Filter tabs
/// - Invoice cards list
class InvoiceScreenSkeleton extends StatelessWidget {
  const InvoiceScreenSkeleton({Key? key, this.invoiceCount = 5}) : super(key: key);

  final int invoiceCount;

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);

    return Container(
      color: const Color(0xFFF8F9FA),
      child: _Shimmer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const _Bone(height: 28, width: 120),
                const SizedBox(height: 8),
                const _Bone(height: 14, width: double.infinity),
                const SizedBox(height: 4),
                const _Bone(height: 14, width: 300),
                const SizedBox(height: 24),

                // Search Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),

                // Filter Tabs
                Row(
                  children: [
                    _buildFilterTabSkeleton(cardColor),
                    const SizedBox(width: 12),
                    _buildFilterTabSkeleton(cardColor),
                    const SizedBox(width: 12),
                    _buildFilterTabSkeleton(cardColor),
                  ],
                ),
                const SizedBox(height: 20),

                // Invoice Cards
                Expanded(
                  child: ListView.builder(
                    itemCount: invoiceCount,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildInvoiceCardSkeleton(cardColor),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabSkeleton(Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const _Bone(height: 16, width: 60),
    );
  }

  Widget _buildInvoiceCardSkeleton(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with invoice number and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _Bone(height: 18, width: 140),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const _Bone(height: 14, width: 60),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Client name
          const _Bone(height: 16, width: 180),
          const SizedBox(height: 4),
          
          // Amount and date row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _Bone(height: 14, width: 100),
              const _Bone(height: 14, width: 80),
            ],
          ),
          const SizedBox(height: 8),
          
          // Description line
          const _Bone(height: 12, width: 200),
        ],
      ),
    );
  }
}
