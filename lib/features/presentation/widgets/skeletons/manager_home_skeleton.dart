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
  const _Bone({this.height = 14, this.width, this.radius = 12});
  final double height;
  final double? width;
  final double radius;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class ManagerHomeSkeleton extends StatelessWidget {
  const ManagerHomeSkeleton({super.key, this.actionsCount = 4, this.listCount = 5, this.padding});

  final int actionsCount;
  final int listCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 18);
    final cardColor = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
      child: _Shimmer(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: pad,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _Bone(height: 18, width: 160),
                    SizedBox(height: 12),
                    _Bone(height: 34, width: 220),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        _Bone(height: 14, width: 100),
                        SizedBox(width: 16),
                        _Bone(height: 14, width: 100),
                        Spacer(),
                        _Bone(height: 36, width: 110, radius: 10),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 96,
                child: Row(
                  children: List.generate(actionsCount, (i) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == actionsCount - 1 ? 0 : 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _Bone(height: 52, width: 52, radius: 14),
                            SizedBox(height: 10),
                            _Bone(height: 12, width: 60),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),
              const _Bone(height: 16, width: 140),
              const SizedBox(height: 8),

              ListView.separated(
                itemCount: listCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) {
                  return Row(
                    children: const [
                      CircleAvatar(radius: 22, backgroundColor: Colors.black12),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Bone(height: 14, width: double.infinity),
                            SizedBox(height: 8),
                            _Bone(height: 12, width: 200),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      _Bone(height: 18, width: 70),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class HomeLoadingOverlay extends StatelessWidget {
  const HomeLoadingOverlay({super.key, required this.loading, required this.child});
  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Positioned.fill(
            child: AbsorbPointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.02),
                ),
                child: const ManagerHomeSkeleton(),
              ),
            ),
          ),
      ],
    );
  }
}