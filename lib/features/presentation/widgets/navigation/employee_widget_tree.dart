import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/employee/UserProfile/employee_userprofile_view/employee_userprofile_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Home/home_employee_view/home_employee_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Payslip/payslip_view/payslip_history_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/navigation/employee_navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmployeeWidgetTree extends ConsumerWidget {
  const EmployeeWidgetTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedEmployeePageProvider);
    final user = ref.watch(userProvider);

    final employeeId = user?.userId ?? 'unknown';

    final employeePages = [
      HomeEmployeeScreen(employeeId: employeeId),
      PayslipScreen(),
      EmployeeUserProfile(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          } else {
          }
        }
      },
      child: Scaffold(
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
                      ref.read(selectedEmployeePageProvider.notifier).state = index;
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}