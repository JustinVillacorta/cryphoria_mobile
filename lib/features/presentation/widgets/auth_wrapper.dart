import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_widget_tree.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/widget_tree.dart';
import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:cryphoria_mobile/debug/auth_debug_helper.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  AuthUser? _cachedAuthUser;

  AuthLocalDataSource get _authLocalDataSource =>
      ref.read(authLocalDataSourceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthenticationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print('🔄 AuthWrapper: App lifecycle state changed to: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        print('🔄 AuthWrapper: App resumed - re-checking authentication');
        _checkAuthenticationStatus();
        break;
      case AppLifecycleState.paused:
        print('🔄 AuthWrapper: App paused - saving auth state');
        _saveCurrentAuthState();
        break;
      case AppLifecycleState.detached:
        print('🔄 AuthWrapper: App detached - final save');
        _saveCurrentAuthState();
        break;
      default:
        break;
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    print('🚀 AuthWrapper: Starting authentication check...');

    await AuthDebugHelper.debugStorageCapabilities();
    await AuthDebugHelper.debugAuthStatus(_authLocalDataSource);

    try {
      final authUser = await _authLocalDataSource.getAuthUser();

      print('🔍 AuthWrapper: Retrieved auth user - '
          '${authUser?.username ?? 'null'}');

      if (authUser != null && authUser.token.isNotEmpty) {
        print('🔍 AuthWrapper: Found valid token (length: '
            '${authUser.token.length})');

        if (authUser.approved) {
          setState(() {
            _isAuthenticated = true;
            _cachedAuthUser = authUser;
            _isLoading = false;
          });
          print('🟢 AuthWrapper: User authenticated successfully - '
              '${authUser.username}');
        } else {
          print(
              '🟡 AuthWrapper: Found pending approval token - clearing and redirecting');
          await _authLocalDataSource.clearAuthData();
          setState(() {
            _isAuthenticated = false;
            _cachedAuthUser = null;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isAuthenticated = false;
          _cachedAuthUser = null;
          _isLoading = false;
        });
        print('🔴 AuthWrapper: No valid auth data found');
      }
    } catch (e) {
      print('🔥 AuthWrapper: Error checking auth status: $e');
      try {
        await _authLocalDataSource.clearAuthData();
      } catch (clearError) {
        print('🔥 AuthWrapper: Could not clear corrupted auth data: '
            '$clearError');
      }
      setState(() {
        _isAuthenticated = false;
        _cachedAuthUser = null;
        _isLoading = false;
      });
    }

    print('🏁 AuthWrapper: Authentication check completed - '
        'authenticated: $_isAuthenticated');
  }

  Future<void> _saveCurrentAuthState() async {
    if (_cachedAuthUser != null) {
      try {
        await _authLocalDataSource.cacheAuthUser(_cachedAuthUser!);
        print(
            '💾 AuthWrapper: Successfully saved auth state during app lifecycle change');
      } catch (e) {
        print('🔥 AuthWrapper: Failed to save auth state: $e');
      }
    } else {
      print('ℹ️ AuthWrapper: No cached auth user to save');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.purple),
              SizedBox(height: 16),
              Text(
                'Checking authentication...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Verifying stored credentials',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (_isAuthenticated && _cachedAuthUser != null) {
      selectedPageNotifer.value = 0;
      selectedEmployeePageNotifer.value = 0;

      if (_cachedAuthUser!.role == 'Manager') {
        print('🔀 AuthWrapper: Navigating to Manager screens for user: '
            '${_cachedAuthUser!.username}');
        return const WidgetTree();
      } else {
        print('🔀 AuthWrapper: Navigating to Employee screens for user: '
            '${_cachedAuthUser!.username}');
        return const EmployeeWidgetTree();
      }
    }

    return const LogIn();
  }
}
