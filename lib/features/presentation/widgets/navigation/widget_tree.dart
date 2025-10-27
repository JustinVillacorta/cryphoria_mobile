import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Home/home_views/home_view.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Employee_Management(manager_screens)/employee_views/employee_management_screen.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Invoice/InvoiceViews/invoice_views.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Reports/Reports_Views/reports_screen.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/UserProfile_Views/user_profile_views.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/navigation/navbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [HomeView(), EmployeeManagementScreen(), ReportsScreen(), InvoiceScreen(), UserProfile()];

class WidgetTree extends ConsumerWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPage = ref.watch(selectedPageProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          } else {
            debugPrint('Back button pressed on main screen - preventing app closure');
          }
        }
      },
      child: Scaffold(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            pages[selectedPage],
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