import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/navigation/employee_widget_tree.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/navigation/widget_tree.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/skeletons/manager_home_skeleton.dart';

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

    try {
      final authUser = await _authLocalDataSource.getAuthUser();

      print('🔍 AuthWrapper: Retrieved auth user - '
          '${authUser?.firstName ?? 'null'}');

      if (authUser != null && authUser.token.isNotEmpty) {
        print('🔍 AuthWrapper: Found valid token (length: '
            '${authUser.token.length})');

        if (authUser.approved) {
          setState(() {
            _isAuthenticated = true;
            _cachedAuthUser = authUser;
            _isLoading = false;
          });
          // Update the global userProvider with the loaded user data
          ref.read(userProvider.notifier).state = authUser;
          print('🟢 AuthWrapper: User authenticated successfully - '
              '${authUser.firstName}');
        } else {
          print(
              '🟡 AuthWrapper: Found pending approval token - clearing and redirecting');
          await _authLocalDataSource.clearAuthData();
          setState(() {
            _isAuthenticated = false;
            _cachedAuthUser = null;
            _isLoading = false;
          });
          // Clear the global userProvider
          ref.read(userProvider.notifier).state = null;
        }
      } else {
        setState(() {
          _isAuthenticated = false;
          _cachedAuthUser = null;
          _isLoading = false;
        });
        // Clear the global userProvider
        ref.read(userProvider.notifier).state = null;
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
      // Clear the global userProvider
      ref.read(userProvider.notifier).state = null;
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
      // Show the manager skeleton while checking authentication
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ManagerHomeSkeleton(),
        ),
      );
    }

    if (_isAuthenticated && _cachedAuthUser != null) {
      // Reset navigation state when authenticating - delay to avoid build cycle modification
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedPageProvider.notifier).state = 0;
        ref.read(selectedEmployeePageProvider.notifier).state = 0;
      });

      if (_cachedAuthUser!.role == 'Manager') {
        print('🔀 AuthWrapper: Navigating to Manager screens for user: '
            '${_cachedAuthUser!.firstName}');
        return const WidgetTree();
      } else {
        print('🔀 AuthWrapper: Navigating to Employee screens for user: '
            '${_cachedAuthUser!.firstName}');
        return const EmployeeWidgetTree();
      }
    }

    return const OnboardingScreen();
  }
}
