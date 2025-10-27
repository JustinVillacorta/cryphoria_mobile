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

class ReportsSkeleton extends StatelessWidget {
  const ReportsSkeleton({
    super.key,
    this.showChart = true,
    this.showSummaryCards = true,
    this.showDataTable = true,
    this.tableRows = 5,
    this.summaryCardsCount = 3,
    this.padding,
  });

  final bool showChart;
  final bool showSummaryCards;
  final bool showDataTable;
  final int tableRows;
  final int summaryCardsCount;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _Bone(height: 16, width: 120),
                    _Bone(height: 40, width: 100, radius: 8),
                  ],
                ),
                const SizedBox(height: 20),

                if (showSummaryCards) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summaryCardsCount,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 160,
                          margin: EdgeInsets.only(right: index < summaryCardsCount - 1 ? 16 : 0),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _Bone(height: 12, width: 80),
                              SizedBox(height: 8),
                              _Bone(height: 20, width: 100),
                              SizedBox(height: 4),
                              _Bone(height: 10, width: 60),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (showChart) ...[
                  Container(
                    width: double.infinity,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _Bone(height: 16, width: 140),
                        SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: _Bone(height: 120, width: double.infinity, radius: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (showDataTable) ...[
                  const _Bone(height: 18, width: 120),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(flex: 2, child: _Bone(height: 14, width: double.infinity)),
                            SizedBox(width: 12),
                            Expanded(child: _Bone(height: 14, width: double.infinity)),
                            SizedBox(width: 12),
                            Expanded(child: _Bone(height: 14, width: double.infinity)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(tableRows, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: const [
                                Expanded(flex: 2, child: _Bone(height: 12, width: double.infinity)),
                                SizedBox(width: 12),
                                Expanded(child: _Bone(height: 12, width: double.infinity)),
                                SizedBox(width: 12),
                                Expanded(child: _Bone(height: 12, width: double.infinity)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _Bone(height: 40, width: 100, radius: 8),
                    _Bone(height: 40, width: 100, radius: 8),
                    _Bone(height: 40, width: 100, radius: 8),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BalanceSheetSkeleton extends StatelessWidget {
  const BalanceSheetSkeleton({
    super.key,
    this.padding,
  });

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _Bone(height: 16, width: 120),
                    _Bone(height: 40, width: 100, radius: 8),
                  ],
                ),
                const SizedBox(height: 20),

                _buildSectionSkeleton('Assets', cardColor),
                const SizedBox(height: 16),

                _buildSectionSkeleton('Liabilities', cardColor),
                const SizedBox(height: 16),

                _buildSectionSkeleton('Equity', cardColor),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _Bone(height: 40, width: 100, radius: 8),
                    _Bone(height: 40, width: 100, radius: 8),
                    _Bone(height: 40, width: 100, radius: 8),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSkeleton(String title, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Bone(height: 16, width: 100),
          const SizedBox(height: 12),
          ...List.generate(4, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _Bone(height: 12, width: 150),
                  _Bone(height: 12, width: 80),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.black12,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Bone(height: 14, width: 80),
              _Bone(height: 14, width: 100),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportsLoadingOverlay extends StatelessWidget {
  const ReportsLoadingOverlay({
    super.key,
    required this.loading,
    required this.child,
    this.skeletonType = ReportsSkeletonType.general,
  });

  final bool loading;
  final Widget child;
  final ReportsSkeletonType skeletonType;

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
                child: _buildSkeleton(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkeleton() {
    switch (skeletonType) {
      case ReportsSkeletonType.balanceSheet:
        return const BalanceSheetSkeleton();
      case ReportsSkeletonType.general:
        return const ReportsSkeleton();
    }
  }
}

enum ReportsSkeletonType {
  general,
  balanceSheet,
}