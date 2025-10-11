import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Register/Views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/auth_wrapper.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  String? _errorMessage;
  // Words to cycle through with fade animation
  final List<String> _words = ['Growth', 'Insights', 'Simplicity'];
  int _wordIndex = 0;
  Timer? _wordTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    // Start cycling headline words
    _wordTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _wordIndex = (_wordIndex + 1) % _words.length;
      });
    });
  }

  void _initializeVideo() {
    // Load video from assets
    _videoController = VideoPlayerController.asset('assets/video/intro.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController.play();
          _videoController.setLooping(true);
          _videoController.setVolume(0.5); // Set volume to 50%
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error loading video: $error';
          });
        }
        print('Error initializing video: $error');
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _wordTimer?.cancel();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen video background
          Positioned.fill(
            child: _isVideoInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
                : Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF8E24AA),
              ),
            ),
          ),

          // Dark gradient overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),

          // Content overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            color: Colors.white,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 8,
                                color: Colors.black45,
                              ),
                            ],
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
                                color: Colors.white,
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 8,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Animated word
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 700),
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              layoutBuilder: (currentChild, previousChildren) {
                                // Overlap children so fade is smooth
                                return Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: Align(alignment: Alignment.centerLeft, child: child),
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _words[_wordIndex],
                                  key: ValueKey<int>(_wordIndex),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF9747FF),
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 8,
                                        color: Colors.black45,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtext
                  Text(
                    'Designed to simplify accounting \nand accelerate crypto-native growth.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                      height: 1.5,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Get Started Button at the bottom
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
                        shadowColor: const Color(0xFF9747FF).withOpacity(0.5),
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

                  // Already have an account text
                  Center(
                    child: GestureDetector(
                      onTap: _navigateToLogin,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
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
                  const SizedBox(height: 60)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}