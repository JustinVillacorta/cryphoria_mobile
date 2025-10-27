import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponsiveInfo {
  final bool isSmallScreen;
  final bool isTablet;
  final bool isDesktop;
  final double horizontalPadding;
  final double maxContentWidth;

  const ResponsiveInfo({
    required this.isSmallScreen,
    required this.isTablet,
    required this.isDesktop,
    required this.horizontalPadding,
    required this.maxContentWidth,
  });
}

class ReportScreenLayout extends StatelessWidget {
  final String title;
  final bool hasData;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Widget child;
  final Widget Function(BuildContext context, ResponsiveInfo responsive)? builder;

  const ReportScreenLayout({
    super.key,
    required this.title,
    required this.hasData,
    required this.isLoading,
    required this.onRefresh,
    required this.child,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;

    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    final responsiveInfo = ResponsiveInfo(
      isSmallScreen: isSmallScreen,
      isTablet: isTablet,
      isDesktop: isDesktop,
      horizontalPadding: horizontalPadding,
      maxContentWidth: maxContentWidth,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF1A1A1A),
            size: isTablet ? 26 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        actions: [
          if (hasData)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: const Color(0xFF1A1A1A),
                size: isTablet ? 24 : 22,
              ),
              onPressed: onRefresh,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: builder != null
              ? builder!(context, responsiveInfo)
              : child,
        ),
      ),
    );
  }
}

