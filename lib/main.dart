import 'package:cryphoria_mobile/dependency_injection/di.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/SignUp/Views/signupview.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/widget_tree.dart';

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
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const LogIn(),
    );
  }
}
