import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:flutter/cupertino.dart';

class NavBarwidget extends StatelessWidget {
  final int currentIndex;
  const NavBarwidget({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: (int idx) {
        selectedPageNotifer.value = idx;
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.money_dollar),
          label: 'Payroll',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.briefcase),
          label: 'Invoice',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chart_bar),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
