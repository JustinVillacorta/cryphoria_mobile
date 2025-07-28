import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:flutter/cupertino.dart';


class NavBarwidget extends CupertinoTabBar {
  NavBarwidget({super.key, required int currentIndex})
      : super(
          backgroundColor: CupertinoColors.systemBackground.withOpacity(0.0),
          currentIndex: currentIndex,
          onTap: (int idx) {
            selectedPageNotifer.value = idx;
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.money_dollar_circle), label: 'Payroll'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.doc_text), label: 'Invoice'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar), label: 'Reports'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person), label: 'Profile'),
          ],
        );
}