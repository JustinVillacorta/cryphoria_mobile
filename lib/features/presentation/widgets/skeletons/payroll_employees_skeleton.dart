import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});
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
    final base = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final highlight = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25);
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
  const _Bone({this.height = 14, this.width});
  final double height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class PayrollEmployeesSkeleton extends StatelessWidget {
  const PayrollEmployeesSkeleton({super.key, this.employeeCount = 4});

  final int employeeCount;

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Bone(height: 16, width: 160),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _Bone(height: 14, width: 100),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const _Bone(height: 13, width: 80),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 400,
              child: ListView.builder(
                itemCount: employeeCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEmployeeCardSkeleton(cardColor),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCardSkeleton(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cardColor),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: cardColor),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Bone(height: 16, width: 180),
                const SizedBox(height: 4),

                const _Bone(height: 14, width: 140),
                const SizedBox(height: 4),

                const _Bone(height: 12, width: 200),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const _Bone(height: 14, width: 60),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: cardColor),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: _Bone(height: 14, width: 80),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}