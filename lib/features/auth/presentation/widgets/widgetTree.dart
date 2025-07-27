import 'package:cryphoria_mobile/features/auth/data/notifiers/notifiers.dart';
import 'package:cryphoria_mobile/features/auth/presentation/pages/Home/home_views/homeView.dart';
import 'package:cryphoria_mobile/features/auth/presentation/pages/Invoice/InvoiceViews/invoice_views.dart';
import 'package:cryphoria_mobile/features/auth/presentation/pages/Payroll/payroll_views/payroll_Views.dart';
import 'package:cryphoria_mobile/features/auth/presentation/pages/Reports/Reports_Views/reports_views.dart';
import 'package:cryphoria_mobile/features/auth/presentation/pages/UserProfile/UserProfile_Views/userProfile_Views.dart';
import 'package:cryphoria_mobile/features/auth/presentation/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';


List<Widget> pages = [HomeScreen(), InvoiceScreen(), payrollScreen(), reportsScreen(), userProfile()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
        centerTitle: true,
        
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifer,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),

      bottomNavigationBar: NavBarwidget(),
    );
  }
}