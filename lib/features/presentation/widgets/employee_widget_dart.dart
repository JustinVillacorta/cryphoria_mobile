import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_view/employee_userprofile_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/home_employee_view/home_employee_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Payslip/payslip_view/payslip_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_navbar.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Employee pages list
List<Widget> employeePages = [
  HomeEmployeeScreen(),
  PayslipScreen(), // You'll need to create this
  EmployeeUserProfileScreen()
];

class EmployeeWidgetTree extends StatelessWidget {
  const EmployeeWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifer, // You can reuse the same notifier or create a separate one
      builder: (context, selectedPage, child) {
        return Scaffold(
          backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor, // Match theme
          body: Stack(
            children: [
              // Display the selected page
              employeePages[selectedPage],
              // Position the employee navigation bar at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: EmployeeNavBar(
                  currentIndex: selectedPage,
                  onTap: (index) {
                    selectedPageNotifer.value = index;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}