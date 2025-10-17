import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/edit_profile/edit_profile_view/edit_profile_view.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/ChangePassword/change_password_view.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/HelpandSupport/help_and_support_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/ViewModel/logout_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/shared/widgets/profile_header.dart';


class EmployeeUserProfileScreen extends ConsumerStatefulWidget {
  const EmployeeUserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeUserProfileScreen> createState() =>
      _EmployeeUserProfileScreenState();
}

class _EmployeeUserProfileScreenState extends ConsumerState<EmployeeUserProfileScreen> {

  String _username = 'User';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadAuthUser();
  }

  Future<void> _loadAuthUser() async {
    try {
      final authDataSource = ref.read(authLocalDataSourceProvider);
      final authUser = await authDataSource.getAuthUser();
      final user = ref.read(userProvider);
      final displayName = _buildDisplayName(user?.firstName, user?.lastName);
      if (mounted) {
        setState(() {
          _username = displayName;
          _email = authUser?.email ?? '';
        });
      }
    } catch (_) {
      // ignore load errors silently for header
    }
  }

  Future<void> _logout() async {
    final logoutViewModel = ref.read(logoutViewModelProvider);
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Logout', style: TextStyle(color: Colors.black87)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey),
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logout failed: ${logoutViewModel.error ?? "Unknown error"}'),
                backgroundColor: Colors.red,
              ),
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
    final paddingValue = screenWidth * 0.05;

    final user = ref.watch(userProvider);
    final displayName = _buildDisplayName(user?.firstName, user?.lastName);

    return Scaffold(
      body: Column(
        children: [
          // Unified Profile Header (matches manager style)
          ProfileHeader(
            
            title: displayName,
            subtitle: _email.isNotEmpty ? _email : null,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(),
                ),
              );
            },
            gradientStart: const Color(0xFF8B5CF6),
            gradientEnd: const Color(0xFF7C3AED),
            ringColor: const Color(0xFF8B5CF6),
            height: screenHeight * 0.26,
            avatarRadius: 44,
          ),

          // Content Section
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
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(height: screenHeight * 0.015),

                    _buildMenuItem(
                      context: context,
                      icon: Icons.security_outlined,
                      title: 'Security',
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordView(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    _buildMenuItem(
                      context: context,
                      icon: Icons.help_outline,
                      title: 'Help and Support',
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelpAndSupportView(),
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
                            fontSize: screenWidth * 0.04,
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

  String _buildDisplayName(String? first, String? last) {
    final parts = <String>[];
    if ((first ?? '').trim().isNotEmpty) parts.add(first!.trim());
    if ((last ?? '').trim().isNotEmpty) parts.add(last!.trim());
    return parts.isNotEmpty ? parts.join(' ') : 'User';
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback onTap, // Added onTap parameter
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap, // Made the entire container tappable
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
