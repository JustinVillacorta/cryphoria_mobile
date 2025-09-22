import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Home/home_views/homeView.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Employee_Management(manager_screens)/employee_views/employee_management_screen.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Payroll/payroll_views/payroll_Views.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Invoice/InvoiceViews/invoice_views.dart';
import 'package:cryphoria_mobile/features/presentation/pages/UserProfile/UserProfile_Views/userProfile_Views.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/navbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [HomeView(), EmployeeManagementScreen(), payrollScreen(), InvoiceScreen(), userProfile()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back button behavior
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Handle back button press - you can show a confirmation dialog or just ignore
          // For now, we'll ignore the back press to prevent accidental app closure
          print('Back button pressed on main screen - ignoring to prevent app closure');
        }
      },
      child: ValueListenableBuilder(
        valueListenable: selectedPageNotifer,
        builder: (context, selectedPage, child) {
          return Scaffold(
            backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor, // Match theme
            body: Stack(
              children: [
                // Display the selected page
                pages[selectedPage],
                // Position the custom navigation bar at the bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomNavBar(
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
      ),
    );
  }
}