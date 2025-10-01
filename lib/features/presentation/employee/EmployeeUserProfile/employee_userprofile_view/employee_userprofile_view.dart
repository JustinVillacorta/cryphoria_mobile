import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/currency_preference/currency_preference_view/currency_preference_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/edit_profile/edit_profile_view/edit_profile_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/help/help_view/help_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/security/security_view/security_view.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/wallet/wallet_view/wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/compliance/compliance_view/compliance_view.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/ViewModel/logout_viewmodel.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Authentication/LogIn/Views/login_views.dart';


class EmployeeUserProfileScreen extends ConsumerStatefulWidget {
  const EmployeeUserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeUserProfileScreen> createState() =>
      _EmployeeUserProfileScreenState();
}

class _EmployeeUserProfileScreenState extends ConsumerState<EmployeeUserProfileScreen> {

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
    final paddingValue = screenWidth * 0.05; // 5% of screen width for padding
    final headerHeight = screenHeight * 0.22; // 25% of screen height for gradient header

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
                  mainAxisAlignment: MainAxisAlignment.end, // Changed from center to end
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

                    _buildMenuItem(
                      context: context,
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Wallet',
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WalletConnectScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.015), // 1.5% of screen height

                    _buildMenuItem(
                      context: context,
                      icon: Icons.assessment_outlined,
                      title: 'Compliance',
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplianceScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    _buildMenuItem(
                      context: context,
                      icon: Icons.attach_money_outlined,
                      title: 'Currency',
                      subtitle: 'ETH/USD',
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CurrencyScreen(),
                          ),
                        );
                      },
                    ),

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
                            builder: (context) => SecurityScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    _buildMenuItem(
                      context: context,
                      icon: Icons.help_outline,
                      title: 'Help',
                      iconColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelpScreen(),
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
                width: screenWidth * 0.20, // 15% of screen width
                height: screenWidth * 0.20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
                    ),
                    fit: BoxFit.cover,
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
                  child: Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: screenWidth * 0.025,
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
                  'John Doe',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // 4.5% of screen width
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.005), // 0.5% of screen height
                Text(
                  'Financial Manager',
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
          // Edit Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
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
