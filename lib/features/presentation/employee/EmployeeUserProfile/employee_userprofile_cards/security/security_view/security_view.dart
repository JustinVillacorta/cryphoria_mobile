import 'package:cryphoria_mobile/features/presentation/employee/EmployeeUserProfile/employee_userprofile_cards/security/security_view/change_password_view.dart';
import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool twoFactorEnabled = false;

  final List<LoginActivity> loginActivities = [
    LoginActivity(
      location: "New York, USA",
      device: "Chrome on Windows",
      time: "Today, 10:30 AM",
      isCurrent: true,
    ),
    LoginActivity(
      location: "Chicago, USA",
      device: "Safari on iPhone",
      time: "2 days ago",
      isCurrent: false,
    ),
    LoginActivity(
      location: "New York, USA",
      device: "Firefox on Mac",
      time: "1 week ago",
      isCurrent: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Security',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Settings Section
            _buildSectionHeader(
              icon: Icons.security,
              title: 'Security Settings',
            ),

            const SizedBox(height: 16),

            // Password Setting - Updated to navigate to ChangePasswordScreen
            _buildSecurityItem(
              icon: Icons.lock_outline,
              title: 'Password',
              onTap: () => _navigateToChangePassword(),
              trailing: TextButton(
                onPressed: () => _navigateToChangePassword(),
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    color: Color(0xFF9747FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Two-Factor Authentication
            _buildSecurityItem(
              icon: Icons.phone_android,
              title: 'Two-Factor Authentication',
              subtitle: 'Enable two-factor authentication for an additional layer of security.',
              trailing: Switch(
                value: twoFactorEnabled,
                onChanged: (value) {
                  setState(() {
                    twoFactorEnabled = value;
                  });
                  _show2FADialog(value);
                },

                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
                activeColor: Color(0xFF9747FF),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent), // Removes the outline
              ),
            ),

            const SizedBox(height: 32),

            // Recent Login Activity Section
            _buildSectionTitle('Recent Login Activity'),

            const SizedBox(height: 16),

            // Login Activity List
            ...loginActivities.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLoginActivityItem(activity),
            )).toList(),

            const SizedBox(height: 16),

            // View Full Login History Button
            Center(
              child: TextButton(
                onPressed: () => _viewFullHistory(),
                child: Text(
                  'View Full Login History',
                  style: TextStyle(
                    color:Color(0xFF9747FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Device Management Section
            _buildSectionTitle('Device Management'),

            const SizedBox(height: 8),

            Text(
              'Manage devices that are currently logged in to your account.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Sign Out From All Devices Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _signOutFromAllDevices(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[600],
                  side: BorderSide(color: Colors.red[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign Out From All Devices',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color(0xFF9747FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Color(0xFF9747FF),
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginActivityItem(LoginActivity activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.grey[500],
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.location,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.device,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (activity.isCurrent) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Updated method to navigate to ChangePasswordScreen instead of showing dialog
  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(), // Use the correct class name
      ),
    );
  }

  void _show2FADialog(bool enabled) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(enabled ? 'Enable 2FA' : 'Disable 2FA'),
          content: Text(
            enabled
                ? 'Two-factor authentication has been enabled for your account. You\'ll need to use your authenticator app for future logins.'
                : 'Two-factor authentication has been disabled for your account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _viewFullHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login History'),
          content: const Text('This would show the complete login history for your account.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _signOutFromAllDevices() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out From All Devices'),
          content: const Text(
            'Are you sure you want to sign out from all devices? You will need to log in again on all your devices.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signed out from all devices successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

class LoginActivity {
  final String location;
  final String device;
  final String time;
  final bool isCurrent;

  LoginActivity({
    required this.location,
    required this.device,
    required this.time,
    required this.isCurrent,
  });
}