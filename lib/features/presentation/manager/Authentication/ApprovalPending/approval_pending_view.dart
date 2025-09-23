import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../domain/entities/auth_user.dart';
import '../../../../../dependency_injection/di.dart';
import '../../../../domain/usecases/Session/get_sessions_usecase.dart';
import '../../../../data/services/device_approval_cache.dart';
import '../../../../data/services/device_info_service.dart';
import '../../../widgets/widget_tree.dart';

class ApprovalPendingView extends StatefulWidget {
  final AuthUser authUser;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const ApprovalPendingView({
    super.key,
    required this.authUser,
    required this.onRetry,
    required this.onLogout,
  });

  @override
  State<ApprovalPendingView> createState() => _ApprovalPendingViewState();
}

class _ApprovalPendingViewState extends State<ApprovalPendingView> {
  Timer? _pollingTimer;
  bool _isChecking = false;
  bool? _wasPreviouslyApproved;
  final GetSessions _getSessions = sl<GetSessions>();
  final DeviceApprovalCache _deviceApprovalCache = sl<DeviceApprovalCache>();
  final DeviceInfoService _deviceInfoService = sl<DeviceInfoService>();

  @override
  void initState() {
    super.initState();
    _checkIfPreviouslyApproved();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Check every 3 seconds for approval
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkApprovalStatus();
    });
  }

  Future<void> _checkIfPreviouslyApproved() async {
    try {
      final deviceId = await _deviceInfoService.getDeviceId();
      final wasApproved = await _deviceApprovalCache.isDeviceApproved(
        widget.authUser.username, 
        deviceId
      );
      
      if (mounted) {
        setState(() {
          _wasPreviouslyApproved = wasApproved;
        });
      }
      
      if (wasApproved) {
        print('ApprovalPendingView: This device was previously approved');
      }
    } catch (e) {
      print('ApprovalPendingView: Error checking previous approval: $e');
    }
  }

  Future<void> _checkApprovalStatus() async {
    if (_isChecking) return;
    
    setState(() {
      _isChecking = true;
    });

    try {
      final sessions = await _getSessions.execute();
      final currentSession = sessions.firstWhere(
        (session) => session.sid == widget.authUser.sessionId,
        orElse: () => sessions.first,
      );

      if (currentSession.approved) {
        // Session approved! Navigate to main app
        _pollingTimer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WidgetTree()),
          );
        }
      }
    } catch (e) {
      print('Error checking approval status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF2A0845)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Approval Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pending_actions,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Approval Pending',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Message
                Text(
                  _wasPreviouslyApproved == true
                    ? 'This device was previously approved but now requires re-approval for security reasons. Please approve this session from another authorized device.'
                    : 'Your device login is pending approval from another authorized device.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[300],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Device Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Session Details',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Session ID', widget.authUser.sessionId),
                      _buildInfoRow('Username', widget.authUser.username),
                      _buildInfoRow('Created', _formatDate(widget.authUser.tokenCreatedAt)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'What to do next?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Open the app on an authorized device\n'
                        '2. Go to Session Management\n'
                        '3. Approve this session\n'
                        '4. Return here and try again',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isChecking ? null : _checkApprovalStatus,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Check Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Cancel & Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
