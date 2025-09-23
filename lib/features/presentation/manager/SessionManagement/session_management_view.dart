import 'package:flutter/material.dart';
import '../../widgets/session_list_item.dart';
import 'session_management_viewmodel.dart';
import 'session_management_controller.dart';

class SessionManagementView extends StatefulWidget {
  final SessionManagementController controller;

  const SessionManagementView({
    super.key,
    required this.controller,
  });

  @override
  State<SessionManagementView> createState() => _SessionManagementViewState();
}

class _SessionManagementViewState extends State<SessionManagementView> {
  late SessionManagementViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.controller.viewModel;
    viewModel.addListener(_onViewModelChanged);
    widget.controller.loadSessions();
  }

  @override
  void dispose() {
    viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Management'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.controller.loadSessions(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'revoke_others') {
                _showRevokeOthersConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'revoke_others',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Revoke Other Sessions'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF2A0845)],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (viewModel.isLoading && viewModel.sessions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.purple,
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading sessions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.controller.loadSessions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No sessions found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    final currentSession = viewModel.sessions.where((s) => s.isCurrent).firstOrNull;
    final otherSessions = viewModel.sessions.where((s) => !s.isCurrent).toList();

    return RefreshIndicator(
      onRefresh: () => widget.controller.loadSessions(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (currentSession != null) ...[
            Text(
              'Current Session',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SessionListItem(
              session: currentSession,
              canApprove: currentSession.approved,
            ),
            const SizedBox(height: 24),
          ],
          if (otherSessions.isNotEmpty) ...[
            Text(
              'Other Sessions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...otherSessions.map((session) => SessionListItem(
              session: session,
              canApprove: currentSession?.approved ?? false,
              onApprove: !session.approved ? () => _approveSession(session.sid) : null,
              onRevoke: () => _revokeSession(session.sid),
            )),
          ],
        ],
      ),
    );
  }

  void _approveSession(String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Session'),
        content: const Text('Are you sure you want to approve this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.controller.approveSessionById(sessionId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _revokeSession(String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Session'),
        content: const Text('Are you sure you want to revoke this session? This will log out the device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.controller.revokeSessionById(sessionId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  void _showRevokeOthersConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Other Sessions'),
        content: const Text('This will log out all other devices except this one. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.controller.revokeAllOtherSessions();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke All Others'),
          ),
        ],
      ),
    );
  }
}
