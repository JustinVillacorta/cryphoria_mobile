import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Register/Views/register_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

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

    // Cycle through words every 3 seconds
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
    return Scaffold(
      backgroundColor: Colors.white, // white background
      body: Stack(
        children: [
          /// Adjusted Lottie Animation
          Positioned(
            top: 10, // moves it closer to the top
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 300, // adjust size here (try 250–350)
                height: 300,
                child: Lottie.asset(
                  'assets/lottie/onboarding.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ),
          ),

          /// Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Headline Texts
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Smarter Crypto Finance',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'for ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(width: 6),

                            /// Animated Word
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 700),
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                _words[_wordIndex],
                                key: ValueKey<int>(_wordIndex),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9747FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Subtext
                  Text(
                    'Designed to simplify accounting \nand accelerate crypto-native growth.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Login Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LogIn()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          children: const [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Log in',
                              style: TextStyle(
                                color: Color(0xFF9747FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
