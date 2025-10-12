import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_view/employee_userprofile_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/HomeEmployee/home_employee_view/home_employee_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/Payslip/payslip_view/payslip_history_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmployeeWidgetTree extends ConsumerWidget {
  const EmployeeWidgetTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedEmployeePageProvider);
    final user = ref.watch(userProvider);
    
    // Get the actual user ID from the logged-in user
    final employeeId = user?.userId ?? 'unknown';
    
    // Create employee pages with the actual user ID
    final employeePages = [
      HomeEmployeeScreen(employeeId: employeeId),
      PayslipScreen(),
      EmployeeUserProfileScreen(),
    ];
    
    return PopScope(
      canPop: false, // Intercept all back button presses
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Check if we're on a detail screen (pushed route)
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            // We're on a detail screen, allow back navigation
            navigator.pop();
          } else {
            // We're on main tab, prevent app closure
            print('Back button pressed on employee main screen - preventing app closure');
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