import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_view/employee_userprofile_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/home_employee_view/home_employee_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Payslip/payslip_view/payslip_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Widget> employeePages = [
  HomeEmployeeScreen(employeeId: 'employee_id'),
  PayslipScreen(),
  EmployeeUserProfileScreen(),
];

class EmployeeWidgetTree extends StatelessWidget {
  const EmployeeWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          print('Back button pressed on employee main screen - ignoring');
        }
      },
      child: ValueListenableBuilder(
        valueListenable: selectedEmployeePageNotifer,
        builder: (context, selectedPage, child) {
          return Scaffold(
            backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
            body: Builder(
              builder: (BuildContext scaffoldContext) {
                return Stack(
                  children: [
                    employeePages[selectedPage],
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: EmployeeNavBar(
                        currentIndex: selectedPage,
                        onTap: (index) {
                          selectedEmployeePageNotifer.value = index;
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}