import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/data/data_sources/auth_local_data_source.dart';
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


    switch (state) {
      case AppLifecycleState.resumed:
        _checkAuthenticationStatus();
        break;
      case AppLifecycleState.paused:
        _saveCurrentAuthState();
        break;
      case AppLifecycleState.detached:
        _saveCurrentAuthState();
        break;
      default:
        break;
    }
  }

  Future<void> _checkAuthenticationStatus() async {

    try {
      final authUser = await _authLocalDataSource.getAuthUser();

      if (authUser != null && authUser.token.isNotEmpty) {
        if (authUser.approved) {
          setState(() {
            _isAuthenticated = true;
            _cachedAuthUser = authUser;
            _isLoading = false;
          });
          ref.read(userProvider.notifier).state = authUser;
        } else {
          await _authLocalDataSource.clearAuthData();
          setState(() {
            _isAuthenticated = false;
            _cachedAuthUser = null;
            _isLoading = false;
          });
          ref.read(userProvider.notifier).state = null;
        }
      } else {
        setState(() {
          _isAuthenticated = false;
          _cachedAuthUser = null;
          _isLoading = false;
        });
        ref.read(userProvider.notifier).state = null;
      }
    } catch (e) {
      try {
        await _authLocalDataSource.clearAuthData();
      } catch (clearError) {
        debugPrint('⚠️ AuthWrapper: Failed to clear auth data: $clearError');
      }
      setState(() {
        _isAuthenticated = false;
        _cachedAuthUser = null;
        _isLoading = false;
      });
      ref.read(userProvider.notifier).state = null;
    }
  }

  Future<void> _saveCurrentAuthState() async {
    if (_cachedAuthUser != null) {
      try {
        await _authLocalDataSource.cacheAuthUser(_cachedAuthUser!);
      } catch (e) {
        debugPrint('⚠️ AuthWrapper: Failed to save auth state: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ManagerHomeSkeleton(),
        ),
      );
    }

    if (_isAuthenticated && _cachedAuthUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedPageProvider.notifier).state = 0;
        ref.read(selectedEmployeePageProvider.notifier).state = 0;
      });

      if (_cachedAuthUser!.role == 'Manager') {
        return const WidgetTree();
      } else {
        return const EmployeeWidgetTree();
      }
    }

    return const OnboardingScreen();
  }
}