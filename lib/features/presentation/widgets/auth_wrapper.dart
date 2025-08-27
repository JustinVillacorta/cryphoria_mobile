import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/dependency_injection/di.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/widget_tree.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final authDataSource = sl<AuthLocalDataSource>();
      final authUser = await authDataSource.getAuthUser();
      
      if (authUser != null && authUser.token.isNotEmpty) {
        // User has valid authentication data
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
        print('AuthWrapper: Found cached auth user - ${authUser.username}');
      } else {
        // No valid authentication data
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
        print('AuthWrapper: No cached auth user found');
      }
    } catch (e) {
      print('AuthWrapper: Error checking auth status: $e');
      // On error, default to not authenticated
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.purple,
          ),
        ),
      );
    }

    return _isAuthenticated ? const WidgetTree() : const LogIn();
  }
}
