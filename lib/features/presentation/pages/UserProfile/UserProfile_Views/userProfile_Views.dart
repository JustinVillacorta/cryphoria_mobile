import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/dependency_injection/di.dart';
import 'package:cryphoria_mobile/features/presentation/pages/SessionManagement/profile_session_management_view.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Authentication/LogIn/Views/login_views.dart';
import 'package:cryphoria_mobile/features/data/data_sources/AuthLocalDataSource.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Logout/logout_usecase.dart';

class userProfile extends StatefulWidget {
  const userProfile({super.key});

  @override
  State<userProfile> createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authDataSource = sl<AuthLocalDataSource>();
    final authUser = await authDataSource.getAuthUser();
    
    if (authUser != null) {
      setState(() {
        _username = authUser.username;
        _email = authUser.email;
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
          ),
        ),
      );

      // ALWAYS clear local data first (most important for UX)
      final authDataSource = sl<AuthLocalDataSource>();
      await authDataSource.clearAuthData();
      print('Logout: Local authentication data cleared');

      // Then attempt API logout (best effort)
      try {
        final logoutUseCase = sl<Logout>();
        final success = await logoutUseCase.execute();
        
        if (success) {
          print('Logout: API logout successful');
        } else {
          print('Logout: API logout failed, but local data already cleared');
        }
      } catch (apiError) {
        print('Logout: API logout error: $apiError, but local data already cleared');
        // Don't rethrow - local logout is more important than API logout
      }
      
      // Close loading indicator
      if (mounted) Navigator.of(context).pop();
      
      // Always navigate to login screen (local data is cleared)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LogIn()),
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading indicator
      if (mounted) Navigator.of(context).pop();
      
      // Fallback: ensure local data is cleared even if something went wrong above
      try {
        final authDataSource = sl<AuthLocalDataSource>();
        await authDataSource.clearAuthData();
        print('Logout: Fallback local data clear completed');
      } catch (clearError) {
        print('Logout: Critical error - could not clear local data: $clearError');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout completed with issues: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LogIn()),
          (route) => false,
        );
      }
    }
  }

  void _navigateToSessionManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSessionManagementView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred radial background
          Positioned(
            top: -180,
            left: -100,
            right: -100,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Color(0xFF5B50FF),
                    Color(0xFF7142FF),
                    Color(0xFF9747FF),
                    Colors.transparent,
                  ],
                  stops: [0.2, 0.4, 0.6, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your account and security settings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // User Info Card
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF9747FF),
                              child: Text(
                                _username?.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _username ?? 'Loading...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _email ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Settings Section
                  const Text(
                    'Security & Privacy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Session Management Option
                  _buildMenuOption(
                    icon: Icons.devices,
                    title: 'Session Management',
                    subtitle: 'Manage your active devices and sessions',
                    onTap: _navigateToSessionManagement,
                  ),
                  
                  const SizedBox(height: 12),

                  // Change Password Option
                  _buildMenuOption(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () {
                      // TODO: Implement change password
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Privacy Settings Option
                  _buildMenuOption(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Settings',
                    subtitle: 'Control your privacy preferences',
                    onTap: () {
                      // TODO: Implement privacy settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feature coming soon')),
                      );
                    },
                  ),

                  const Spacer(),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        ),
                      ),
                      onPressed: _logout,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32), // Space for navbar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF9747FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF9747FF),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}