import 'dart:ui';
import 'package:cryphoria_mobile/features/auth/data/notifiers/notifiers.dart';
import 'package:flutter/material.dart';

class NavBarwidget extends StatefulWidget {
  const NavBarwidget({super.key});

  @override
  State<NavBarwidget> createState() => _NavBarwidgetState();
}

class _NavBarwidgetState extends State<NavBarwidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: selectedPageNotifer, builder: (context, selectedPage, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.white.withOpacity(0.1),
                // you can tweak elevation/shadows here if you like
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedIndex: selectedPage,
                  onDestinationSelected: (int idx) {
                    selectedPageNotifer.value = idx;
                  },
                  destinations: const [
                    NavigationDestination(
                        icon: Icon(Icons.home), label: 'Home'),
                    NavigationDestination(
                        icon: Icon(Icons.payments_rounded), label: 'Payroll'),
                    NavigationDestination(
                        icon: Icon(Icons.account_balance_wallet_sharp),
                        label: 'Invoice'),
                    NavigationDestination(
                        icon: Icon(Icons.report_gmailerrorred),
                        label: 'Reports'),
                    NavigationDestination(
                        icon: Icon(Icons.account_circle_rounded),
                        label: 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
