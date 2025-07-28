import 'dart:ui';
import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavBarwidget extends StatelessWidget {
  final int currentIndex;
  const NavBarwidget({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: CupertinoColors.systemBackground.withOpacity(0.1),
            child: CupertinoTabBar(
              backgroundColor:
                  CupertinoColors.systemBackground.withOpacity(0.0),
              currentIndex: currentIndex,
              onTap: (int idx) {
                selectedPageNotifer.value = idx;
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.payments_rounded), label: 'Payroll'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_sharp),
                    label: 'Invoice'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.report_gmailerrorred),
                    label: 'Reports'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle_rounded),
                    label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
