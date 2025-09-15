import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/dependency_injection/di.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/widget_tree.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/employee_widget_dart.dart';
import 'package:cryphoria_mobile/features/data/notifiers/notifiers.dart';
import 'package:cryphoria_mobile/debug/auth_debug_helper.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  AuthUser? _cachedAuthUser;

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

  // Handle app lifecycle changes to maintain authentication
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    print('🔄 AuthWrapper: App lifecycle state changed to: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        // Re-verify authentication when app comes to foreground
        print('🔄 AuthWrapper: App resumed - re-checking authentication');
        _checkAuthenticationStatus();
        break;
      case AppLifecycleState.paused:
        // Ensure current state is saved when app goes to background
        print('🔄 AuthWrapper: App paused - saving auth state');
        _saveCurrentAuthState();
        break;
      case AppLifecycleState.detached:
        // Save state when app is being terminated
        print('🔄 AuthWrapper: App detached - final save');
        _saveCurrentAuthState();
        break;
      default:
        break;
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    print('🚀 AuthWrapper: Starting authentication check...');
    
    // Debug storage capabilities first
    await AuthDebugHelper.debugStorageCapabilities();
    await AuthDebugHelper.debugAuthStatus();
    
    try {
      final authDataSource = sl<AuthLocalDataSource>();
      final authUser = await authDataSource.getAuthUser();
      
      print('🔍 AuthWrapper: Retrieved auth user - ${authUser?.username ?? 'null'}');
      
      if (authUser != null && authUser.token.isNotEmpty) {
        print('🔍 AuthWrapper: Found valid token (length: ${authUser.token.length})');
        
        // Check if the token is approved
        if (authUser.approved) {
          // User has valid and approved authentication data
          setState(() {
            _isAuthenticated = true;
            _cachedAuthUser = authUser; // Cache the user for lifecycle management
            _isLoading = false;
          });
          print('🟢 AuthWrapper: User authenticated successfully - ${authUser.username}');
        } else {
          // User has token but it's pending approval - clear it and redirect to login
          print('🟡 AuthWrapper: Found pending approval token - clearing and redirecting');
          await authDataSource.clearAuthData();
          setState(() {
            _isAuthenticated = false;
            _cachedAuthUser = null;
            _isLoading = false;
          });
        }
      } else {
        // No valid authentication data
        setState(() {
          _isAuthenticated = false;
          _cachedAuthUser = null;
          _isLoading = false;
        });
        print('🔴 AuthWrapper: No valid auth data found');
      }
    } catch (e) {
      print('🔥 AuthWrapper: Error checking auth status: $e');
      // On error, clear any corrupted data and default to not authenticated
      try {
        final authDataSource = sl<AuthLocalDataSource>();
        await authDataSource.clearAuthData();
      } catch (clearError) {
        print('🔥 AuthWrapper: Could not clear corrupted auth data: $clearError');
      }
      setState(() {
        _isAuthenticated = false;
        _cachedAuthUser = null;
        _isLoading = false;
      });
    }
    
    print('🏁 AuthWrapper: Authentication check completed - authenticated: $_isAuthenticated');
  }

  Future<void> _saveCurrentAuthState() async {
    if (_cachedAuthUser != null) {
      try {
        final authDataSource = sl<AuthLocalDataSource>();
        await authDataSource.cacheAuthUser(_cachedAuthUser!);
        print('💾 AuthWrapper: Successfully saved auth state during app lifecycle change');
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
      // Reset page notifiers to default before navigation
      selectedPageNotifer.value = 0;
      selectedEmployeePageNotifer.value = 0;
      
      // Role-based navigation
      if (_cachedAuthUser!.role == 'Manager') {
        print('🔀 AuthWrapper: Navigating to Manager screens for user: ${_cachedAuthUser!.username}');
        return const WidgetTree();
      } else {
        print('🔀 AuthWrapper: Navigating to Employee screens for user: ${_cachedAuthUser!.username}');
        return const EmployeeWidgetTree();
      }
    }

    return const LogIn();
  }
}
