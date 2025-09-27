import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'package:cryphoria_mobile/features/domain/entities/auth_user.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/widget_tree.dart';

class ApprovalPendingView extends ConsumerStatefulWidget {
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
  ConsumerState<ApprovalPendingView> createState() => _ApprovalPendingViewState();
}

class _ApprovalPendingViewState extends ConsumerState<ApprovalPendingView> {
  Timer? _pollingTimer;
  bool _isChecking = false;
  bool? _wasPreviouslyApproved;

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
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkApprovalStatus();
    });
  }

  Future<void> _checkIfPreviouslyApproved() async {
    try {
      final deviceInfoService = ref.read(deviceInfoServiceProvider);
      final approvalCache = ref.read(deviceApprovalCacheProvider);
      final deviceId = await deviceInfoService.getDeviceId();
      final wasApproved = await approvalCache.isDeviceApproved(
        widget.authUser.username,
        deviceId,
      );

      if (!mounted) return;
      setState(() {
        _wasPreviouslyApproved = wasApproved;
      });

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
      final getSessions = ref.read(getSessionsUseCaseProvider);
      final sessions = await getSessions.execute();
      final currentSession = sessions.firstWhere(
        (session) => session.sid == widget.authUser.sessionId,
        orElse: () => sessions.first,
      );

      if (currentSession.approved) {
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
                Text(
                  'Approval Pending',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isChecking ? null : widget.onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isChecking
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Check Again'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onLogout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Logout'),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
