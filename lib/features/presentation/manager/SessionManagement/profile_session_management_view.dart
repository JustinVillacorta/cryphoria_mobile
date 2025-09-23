import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/dependency_injection/di.dart';
import 'package:cryphoria_mobile/features/domain/entities/user_session.dart';
import 'package:cryphoria_mobile/features/data/services/device_info_service.dart';
import 'session_management_controller.dart';
import 'session_management_viewmodel.dart';

class ProfileSessionManagementView extends StatefulWidget {
  const ProfileSessionManagementView({super.key});

  @override
  State<ProfileSessionManagementView> createState() => _ProfileSessionManagementViewState();
}

class _ProfileSessionManagementViewState extends State<ProfileSessionManagementView> {
  late SessionManagementController _controller;
  late SessionManagementViewModel _viewModel;
  String _currentDeviceId = '';

  @override
  void initState() {
    super.initState();
    _controller = sl<SessionManagementController>();
    _viewModel = _controller.viewModel;
    _viewModel.addListener(_onViewModelChanged);
    _loadCurrentDeviceId();
    _controller.loadSessions();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  Future<void> _loadCurrentDeviceId() async {
    final deviceInfoService = sl<DeviceInfoService>();
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
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9747FF),
              foregroundColor: Colors.white,
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
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _controller.revokeAllOtherSessions();
            },
            child: const Text('Sign Out All'),
          ),
        ],
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Session Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => _controller.loadSessions(),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _viewModel.error ?? 'Unknown error',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9747FF),
                  foregroundColor: Colors.white,
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
    final currentSessions = sessions.where((s) => s.deviceId == _currentDeviceId).toList();
    final otherSessions = sessions.where((s) => s.deviceId != _currentDeviceId).toList();
    final pendingSessions = otherSessions.where((s) => !s.approved).toList();
    final activeSessions = otherSessions.where((s) => s.approved).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Device Section
          if (currentSessions.isNotEmpty) ...[
            const Text(
              'This Device',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...currentSessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSessionCard(session, isCurrentDevice: true),
            )),
            const SizedBox(height: 24),
          ],

          // Pending Approvals Section
          if (pendingSessions.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  'Pending Approvals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pendingSessions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...pendingSessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSessionCard(session, isPending: true),
            )),
            const SizedBox(height: 24),
          ],

          // Other Devices Section
          if (activeSessions.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  'Other Devices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showRevokeAllDialog,
                  child: const Text(
                    'Sign Out All',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeSessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSessionCard(session),
            )),
          ],

          // Empty state
          if (sessions.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    const Icon(
                      Icons.devices,
                      color: Colors.white54,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Other Sessions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re only signed in on this device.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionCard(UserSession session, {bool isCurrentDevice = false, bool isPending = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending 
            ? Colors.orange.withOpacity(0.3)
            : isCurrentDevice 
              ? const Color(0xFF9747FF).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPending
                    ? Colors.orange.withOpacity(0.2)
                    : isCurrentDevice
                      ? const Color(0xFF9747FF).withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDeviceIcon(session.deviceName),
                  color: isPending
                    ? Colors.orange
                    : isCurrentDevice
                      ? const Color(0xFF9747FF)
                      : Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.deviceName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isCurrentDevice)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9747FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Current',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isPending)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last active: ${_formatDateTime(session.lastSeen ?? session.createdAt)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (isPending || !isCurrentDevice) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (isPending)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9747FF),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _showApprovalDialog(session),
                      child: const Text('Approve'),
                    ),
                  ),
                if (isPending) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () => _showRevokeDialog(session),
                    child: Text(isPending ? 'Deny' : 'Revoke'),
                  ),
                ),
              ],
            ),
          ],
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
