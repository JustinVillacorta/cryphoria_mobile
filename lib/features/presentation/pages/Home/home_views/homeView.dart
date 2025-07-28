import 'dart:ui';
import 'package:cryphoria_mobile/features/presentation/widgets/notification_icon.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/refresh_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widgets/navbar_widget.dart';

import '../../../widgets/cardwallet.dart';


void main() {
  runApp(const HomeView());
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark base background
      body: Stack(
        children: [
          // Blurred gradient background
          Positioned(
            top: -180,
            left: -100,
            right: -100,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Color(0xFF5B50FF),
                    Color(0xFF7142FF),
                    Color(0xFF9747FF),
                    Colors.transparent,
                  ],
                  stops: [0.2, 0.4, 0.6, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Greeting and notification
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Greeting section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hi, Anna!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'How are you today?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: const [
                    GlassNotificationIcon(),
                    SizedBox(width: 12), // Adjust spacing here
                    GlassRefreshIcon(),
                  ],
                ),// Cupertino glass notification icon


              ],
            ),
          ),
          Positioned(
            top: 130,
            left: 20,
            right: 20,
            child: GlassCard(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP RIGHT: Current Wallet + ETH
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Current Wallet",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.currency_bitcoin,
                                    color: Colors.lightBlueAccent, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  "0.48 ETH",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white70, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // BOTTOM: Converted to + value + currency
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Converted to",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "₱ 82,400.00",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Text(
                              "PHP",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.white70, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 326,
            left: 25,
            child: Text(
              "Quick Actions",
              style: TextStyle(
                color: Color(0xFFfcfcfc),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Positioned(
            top: 360,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassCard(
                  height: 100,
                  width: 100,
                  child: const Center(
                    child: Icon(CupertinoIcons.arrow_up_arrow_down, color: Colors.white),
                  ),
                ),
                GlassCard(
                  height: 100,
                  width: 100,
                  child: const Center(
                    child: Icon(CupertinoIcons.qrcode_viewfinder, color: Colors.white),
                  ),
                ),
                GlassCard(
                  height: 100,
                  width: 100,
                  child: const Center(
                    child: Icon(CupertinoIcons.arrow_right_arrow_left, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomNavBar(
              currentIndex: 0,
              onTap: (index) {
                // Handle tab navigation (optional for now)
              },
            ),
          ),

        ],
      ),
    );
  }
}
