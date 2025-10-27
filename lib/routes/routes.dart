import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/Register/Views/register_view.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/navigation/widget_tree.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String widgetTree = '/';

  static Map<String, WidgetBuilder> routes = {
    widgetTree: (context) => const WidgetTree(),
    login: (context) => const LogIn(),
    register: (context) => const RegisterView(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LogIn());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case widgetTree:
        return MaterialPageRoute(builder: (_) => const WidgetTree());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}