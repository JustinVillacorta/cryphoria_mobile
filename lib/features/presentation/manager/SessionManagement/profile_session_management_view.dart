import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/domain/entities/user_session.dart';
import 'package:cryphoria_mobile/features/data/services/device_info_service.dart';
import 'session_management_controller.dart';
import 'session_management_viewmodel.dart';

class ProfileSessionManagementView extends ConsumerStatefulWidget {
  const ProfileSessionManagementView({super.key});

  @override
  ConsumerState<ProfileSessionManagementView> createState() =>
      _ProfileSessionManagementViewState();
}

class _ProfileSessionManagementViewState extends ConsumerState<ProfileSessionManagementView> {
  late SessionManagementController _controller;
  late SessionManagementViewModel _viewModel;
  String _currentDeviceId = '';

  @override
  void initState() {
    super.initState();
    _controller = ref.read(sessionManagementControllerProvider);
    _viewModel = _controller.viewModel;
    _viewModel.addListener(_onViewModelChanged);
    _loadCurrentDeviceId();
    Future.microtask(() => _controller.loadSessions());
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  Future<void> _loadCurrentDeviceId() async {
    final deviceInfoService = ref.read(deviceInfoServiceProvider);
    final deviceId = await deviceInfoService.getDeviceId();
    setState(() {
      _currentDeviceId = deviceId;
    });
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showApprovalDialog(UserSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Approve Device?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to approve this device?',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            _buildSessionInfoCard(session, compact: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Deny', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9747FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _controller.approveSessionById(session.sid);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRevokeDialog(UserSession session) {
    final isCurrentDevice = session.deviceId == _currentDeviceId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isCurrentDevice ? 'Sign Out?' : 'Revoke Access?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCurrentDevice
                  ? 'This will sign you out of this device.'
                  : 'This will revoke access for this device.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            _buildSessionInfoCard(session, compact: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _controller.revokeSessionById(session.sid);
            },
            child: Text(isCurrentDevice ? 'Sign Out' : 'Revoke'),
          ),
        ],
      ),
    );
  }

  void _showRevokeAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out All Other Devices?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will sign out all other devices except this one.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _controller.revokeAllOtherSessions();
            },
            child: const Text('Sign Out From All Devices'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Security and Privacy',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
        ),
      );
    }

    if (_viewModel.error != null && _viewModel.error!.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading sessions',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _viewModel.error ?? 'Unknown error',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => _controller.loadSessions(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final sessions = _viewModel.sessions;

// Always show current device (main device)
    final currentSessions = sessions
        .where((s) => s.deviceId == _currentDeviceId)
        .toList();

// Pending approvals → only other devices that are not approved
    final pendingSessions = sessions
        .where((s) => s.deviceId != _currentDeviceId && !s.approved)
        .toList();

// Active devices → only other devices that are approved
    final activeSessions = sessions
        .where((s) => s.deviceId != _currentDeviceId && s.approved)
        .toList();


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Settings Header

          // Password Settings
          _buildPasswordSection(),
          const SizedBox(height: 20),

          // Recent Login Activity Section
          _buildSectionHeader('Device Management'),
          const SizedBox(height: 16),

          // Current Device
          if (currentSessions.isNotEmpty) ...[
            ...currentSessions.map((session) => _buildLoginActivityItem(
              session: session,
              isCurrentDevice: true,
            )),
          ],

          // Other Active Sessions
          if (activeSessions.isNotEmpty) ...[
            ...activeSessions.map((session) => _buildLoginActivityItem(
              session: session,
              showRevokeButton: true,
            )),
          ],

          if (activeSessions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _showRevokeAllDialog(),
                child: const Text(
                  'View Full Login History',
                  style: TextStyle(
                    color: Color(0xFF9747FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],

          // Pending Approval Section
          if (pendingSessions.isNotEmpty) ...[
            const SizedBox(height: 30),
            _buildSectionHeader('Pending Approval'),
            const SizedBox(height: 16),
            ...pendingSessions.map((session) => _buildPendingApprovalItem(session)),
          ],



          // Empty state
          if (sessions.isEmpty) ...[
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.devices,
                    color: Colors.black26,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Other Sessions',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You\'re only signed in on this device.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF9747FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.security,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400, // border color
          width: 1,                    // border width
        ),
        borderRadius: BorderRadius.circular(12), // rounded corners
      ),
      child: Row(
        children: [
          const Icon(
            Icons.key,
            color: Colors.black54,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Password',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle password change
            },
            child: const Text(
              'Change Password',
              style: TextStyle(
                color: Color(0xFF9747FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLoginActivityItem({
    required UserSession session,
    bool isCurrentDevice = false,
    bool showRevokeButton = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getDeviceIcon(session.deviceName),
            color: Colors.black54,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.deviceName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Last Active: ${_formatDateTime(session.lastSeen ?? session.createdAt)}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentDevice)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (showRevokeButton)
            InkWell(
              onTap: () => _showRevokeDialog(session),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Revoke',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalItem(UserSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getDeviceIcon(session.deviceName),
                color: Colors.black54,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.deviceName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last Active: ${_formatDateTime(session.lastSeen ?? session.createdAt)}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black54,
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    _controller.revokeSessionById(session.sid);
                  },
                  child: const Text('Deny'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9747FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    _controller.approveSessionById(session.sid);
                  },
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoCard(UserSession session, {bool compact = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getDeviceIcon(session.deviceName),
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.deviceName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Last active: ${_formatDateTime(session.lastSeen ?? session.createdAt)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('iphone') || name.contains('ipad') || name.contains('ios')) {
      return Icons.phone_iphone;
    } else if (name.contains('android')) {
      return Icons.phone_android;
    } else if (name.contains('mac')) {
      return Icons.laptop_mac;
    } else if (name.contains('windows')) {
      return Icons.laptop_windows;
    } else if (name.contains('linux')) {
      return Icons.laptop;
    } else {
      return Icons.devices;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
