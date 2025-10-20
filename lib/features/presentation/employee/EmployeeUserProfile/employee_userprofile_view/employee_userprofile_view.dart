import 'dart:ui';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/edit_profile/edit_profile_view/edit_profile_view.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/ChangePassword/change_password_view.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/HelpandSupport/help_and_support_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/ViewModel/logout_viewmodel.dart';

class EmployeeUserProfile extends ConsumerStatefulWidget {
  const EmployeeUserProfile({super.key});

  @override
  ConsumerState<EmployeeUserProfile> createState() => _EmployeeUserProfileState();
}

class _EmployeeUserProfileState extends ConsumerState<EmployeeUserProfile> {
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    // Load user data after the widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final user = ref.read(userProvider);
    String displayName = (() {
      final parts = <String>[];
      if ((user?.firstName ?? '').trim().isNotEmpty) parts.add(user!.firstName.trim());
      if ((user?.lastName ?? '').trim().isNotEmpty) parts.add(user!.lastName!.trim());
      return parts.isNotEmpty ? parts.join(' ') : 'User';
    })();
    final authDataSource = ref.read(authLocalDataSourceProvider);
    final authUser = await authDataSource.getAuthUser();

    if (authUser != null && mounted) {
      setState(() {
        _username = displayName;
        _email = authUser.email;
      });
    }
  }

  Future<void> _logout() async {
    final logoutViewModel = ref.read(logoutViewModelProvider);
    
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            ),
          ),
        );

        // Use simple logout
        final success = await logoutViewModel.logout();

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (success) {
          // Check if widget is still mounted before modifying providers and navigating
          if (mounted) {
            // Reset provider states
            ref.read(selectedPageProvider.notifier).state = 0;
            ref.read(selectedEmployeePageProvider.notifier).state = 0;
            
            // Navigate to login screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LogIn()),
              (route) => false,
            );
          }
        } else {
          // Show error message only if mounted
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(logoutViewModel.error ?? 'Logout failed')),
            );
          }
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.listen for side effects (navigation)
    ref.listen<LogoutViewModel>(
      logoutViewModelProvider,
      (previous, next) {
        if (!mounted) return;

        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (next.message != null) {
          // Logout successful, navigate to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              ref.read(selectedPageProvider.notifier).state = 0;
              ref.read(selectedEmployeePageProvider.notifier).state = 0;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LogIn()),
                (route) => false,
              );
            } else if (mounted) {
              // If no routes to pop, just push replacement
              ref.read(selectedPageProvider.notifier).state = 0;
              ref.read(selectedEmployeePageProvider.notifier).state = 0;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LogIn()),
              );
            }
          });
        }
      },
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingValue = screenWidth * 0.05; // 5% of screen width for padding
    final headerHeight = screenHeight * 0.22; // 22% of screen height for gradient header

    return Scaffold(
      body: Column(
        children: [
          // Gradient Header Section
          Container(
            height: headerHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8B5CF6), // Purple top
                  Color(0xFF7C3AED), // Slightly darker purple
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingValue),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Profile Card
                    _buildProfileCard(context, screenWidth, screenHeight),
                  ],
                ),
              ),
            ),
          ),

          // White Content Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.all(paddingValue),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.02), // 2% of screen height

                    SizedBox(height: screenHeight * 0.015),

                    // Privacy Settings
                    _buildMenuItem(
                      context: context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Security',
                      subtitle: 'Change your password and secure your account',
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordView(
                              provider: managerChangePasswordVmProvider,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Security Settings
                    _buildMenuItem(
                      context: context,
                      icon: Icons.security_outlined,
                      title: 'Help and Support',
                      subtitle: 'Account security settings',
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpAndSupportView(),
                          ),
                        );
                      },
                    ),

                    // Sign Out Button
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      child: TextButton(
                        onPressed: _logout,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // 4% of screen width
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Profile Image with Status Indicator
          Stack(
            children: [
              Container(
                width: screenWidth * 0.20, // 20% of screen width
                height: screenWidth * 0.20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9747FF),
                ),
                child: Center(
                  child: Text(
                    _username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Online Status Indicator
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: screenWidth * 0.04,
                  height: screenWidth * 0.04,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: screenWidth * 0.04), // 4% of screen width

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username ?? 'Loading...',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // 4.5% of screen width
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005), // 0.5% of screen height
                Text(
                  _email ?? '',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // 3.5% of screen width
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Edit Icon
          GestureDetector(
            onTap: () async {
              final authDataSource = ref.read(authLocalDataSourceProvider);
              final authUser = await authDataSource.getAuthUser();
              
              if (authUser != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(currentUser: authUser),
                  ),
                );
                
                // If profile was updated, refresh the user data
                if (result != null) {
                  _loadUserData();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User data not found. Please log in again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: screenWidth * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.1, // 10% of screen width
              height: screenWidth * 0.1,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: screenWidth * 0.05, // 5% of screen width
              ),
            ),
            SizedBox(width: screenWidth * 0.04), // 4% of screen width
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // 4% of screen width
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: screenHeight * 0.005), // 0.5% of screen height
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035, // 3.5% of screen width
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: screenWidth * 0.045, // 4.5% of screen width
            ),
          ],
        ),
      ),
    );
  }
}
