import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Home/home_views/homeView.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Employee_Management(manager_screens)/employee_views/employee_management_screen.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Invoice/InvoiceViews/invoice_views.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Reports/Reports_Views/reports_screen.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/UserProfile_Views/userProfile_Views.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/navbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [HomeView(), EmployeeManagementScreen(), ReportsScreen(), InvoiceScreen(), userProfile()];

class WidgetTree extends ConsumerWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);
    
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
            print('Back button pressed on main screen - preventing app closure');
          }
        }
      },
      child: Scaffold(
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
                  ref.read(selectedPageProvider.notifier).state = index;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}