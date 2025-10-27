import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Register/Views/register_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<String> _words = ['Growth', 'Insights', 'Simplicity'];
  int _wordIndex = 0;
  Timer? _wordTimer;

  @override
  void initState() {
    super.initState();
    _wordTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _wordIndex = (_wordIndex + 1) % _words.length;
      });
    });
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;
    final isLargeTablet = size.width > 900;

    final lottieSize = _calculateLottieSize(size, isLandscape, isSmallScreen, isTablet, isLargeTablet);

    final horizontalPadding = _calculateHorizontalPadding(isTablet, isLargeTablet);
    final headlineFontSize = _calculateHeadlineFontSize(size, isSmallScreen, isTablet, isLargeTablet);
    final subtitleFontSize = _calculateSubtitleFontSize(isSmallScreen, isTablet, isLargeTablet);
    final buttonHeight = isSmallScreen ? 50.0 : isTablet ? 58.0 : 54.0;
    final bottomSpacing = _calculateBottomSpacing(size, isSmallScreen, isTablet);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: isLandscape
            ? _buildLandscapeLayout(
                size,
                lottieSize,
                horizontalPadding,
                headlineFontSize,
                subtitleFontSize,
                buttonHeight,
                bottomSpacing,
                isSmallScreen,
              )
            : _buildPortraitLayout(
                size,
                lottieSize,
                horizontalPadding,
                headlineFontSize,
                subtitleFontSize,
                buttonHeight,
                bottomSpacing,
                isSmallScreen,
                isTablet,
              ),
      ),
    );
  }

  double _calculateLottieSize(Size size, bool isLandscape, bool isSmallScreen, bool isTablet, bool isLargeTablet) {
    if (isLandscape) {
      return isTablet ? size.height * 0.5 : size.height * 0.45;
    }
    if (isLargeTablet) return 400.0;
    if (isTablet) return 350.0;
    if (isSmallScreen) return size.width * 0.55;
    return size.width * 0.65;
  }

  double _calculateHorizontalPadding(bool isTablet, bool isLargeTablet) {
    if (isLargeTablet) return 80.0;
    if (isTablet) return 60.0;
    return 28.0;
  }

  double _calculateHeadlineFontSize(Size size, bool isSmallScreen, bool isTablet, bool isLargeTablet) {
    if (isLargeTablet) return 48.0;
    if (isTablet) return 42.0;
    if (isSmallScreen) return size.width < 360 ? 26.0 : 30.0;
    return 34.0;
  }

  double _calculateSubtitleFontSize(bool isSmallScreen, bool isTablet, bool isLargeTablet) {
    if (isLargeTablet) return 20.0;
    if (isTablet) return 18.0;
    if (isSmallScreen) return 14.0;
    return 16.0;
  }

  double _calculateBottomSpacing(Size size, bool isSmallScreen, bool isTablet) {
    if (isTablet) return 80.0;
    if (isSmallScreen) return size.height * 0.05;
    return size.height * 0.08;
  }

  Widget _buildPortraitLayout(
    Size size,
    double lottieSize,
    double horizontalPadding,
    double headlineFontSize,
    double subtitleFontSize,
    double buttonHeight,
    double bottomSpacing,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final lottieTopPadding = isSmallScreen 
            ? availableHeight * 0.08 
            : isTablet 
                ? availableHeight * 0.12 
                : availableHeight * 0.1;

        return Stack(
          children: [
            Positioned(
              top: lottieTopPadding,
              left: 0,
              right: 0,
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/intro.json',
                  fit: BoxFit.contain,
                  width: lottieSize,
                  height: lottieSize,
                ),
              ),
            ),

            Column(
              children: [
                SizedBox(height: lottieTopPadding + lottieSize + (isSmallScreen ? 20 : 40)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: _buildContent(
                      headlineFontSize,
                      subtitleFontSize,
                      buttonHeight,
                      bottomSpacing,
                      isSmallScreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeLayout(
    Size size,
    double lottieSize,
    double horizontalPadding,
    double headlineFontSize,
    double subtitleFontSize,
    double buttonHeight,
    double bottomSpacing,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Center(
            child: Lottie.asset(
              'assets/lottie/intro.json',
              fit: BoxFit.contain,
              width: lottieSize,
              height: lottieSize,
            ),
          ),
        ),

        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: _buildContent(
              headlineFontSize,
              subtitleFontSize,
              buttonHeight,
              bottomSpacing,
              isSmallScreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    double headlineFontSize,
    double subtitleFontSize,
    double buttonHeight,
    double bottomSpacing,
    bool isSmallScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smarter Crypto Finance for',
          style: GoogleFonts.inter(
            fontSize: headlineFontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _words[_wordIndex],
                  key: ValueKey<int>(_wordIndex),
                  style: GoogleFonts.inter(
                    fontSize: headlineFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9747FF),
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: isSmallScreen ? 16 : 20),

        Text(
          'Designed to simplify accounting and accelerate crypto-native growth.',
          style: GoogleFonts.inter(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B6B6B),
            height: 1.6,
            letterSpacing: 0,
          ),
        ),

        SizedBox(height: isSmallScreen ? 32 : 40),

        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterView()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9747FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              'Get Started',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogIn()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                    letterSpacing: 0,
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Log in',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9747FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: bottomSpacing),
      ],
    );
  }
}