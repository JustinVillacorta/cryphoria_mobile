import 'package:cryphoria_mobile/dependency_injection/di.dart' as di;
import 'package:cryphoria_mobile/features/presentation/widgets/employee_widget_dart.dart';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF8E24AA),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
     home: const EmployeeWidgetTree(),
    );
  }
}
