import '../../../domain/usecases/Session/get_sessions_usecase.dart';
import '../../../domain/usecases/Session/approve_session_usecase.dart';
import '../../../domain/usecases/Session/revoke_session_usecase.dart';
import '../../../domain/usecases/Session/revoke_other_sessions_usecase.dart';
import 'session_management_viewmodel.dart';

class SessionManagementController {
  final GetSessions getSessions;
  final ApproveSession approveSession;
  final RevokeSession revokeSession;
  final RevokeOtherSessions revokeOtherSessions;
  final SessionManagementViewModel viewModel;

  SessionManagementController({
    required this.getSessions,
    required this.approveSession,
    required this.revokeSession,
    required this.revokeOtherSessions,
    required this.viewModel,
  });

  // Legacy methods for backward compatibility with existing views
  Future<void> loadSessions() async {
    try {
      viewModel.setLoading(true);
      final sessions = await getSessions.execute();
      viewModel.setSessions(sessions);
    } catch (e) {
      viewModel.setError('Failed to load sessions: ${e.toString()}');
    } finally {
      viewModel.setLoading(false);
    }
  }

  Future<void> approveSessionById(String sessionId) async {
    try {
      final success = await approveSession.execute(sessionId);
      if (success) {
        viewModel.updateSessionApproval(sessionId, true);
        _showMessage('Session approved successfully');
      } else {
        _showMessage('Failed to approve session');
      }
    } catch (e) {
      _showMessage('Failed to approve session: ${e.toString()}');
    }
  }

  Future<void> revokeSessionById(String sessionId) async {
    try {
      final success = await revokeSession.execute(sessionId);
      if (success) {
        viewModel.removeSession(sessionId);
        _showMessage('Session revoked successfully');
      } else {
        _showMessage('Failed to revoke session');
      }
    } catch (e) {
      _showMessage('Failed to revoke session: ${e.toString()}');
    }
  }

  Future<void> revokeAllOtherSessions() async {
    try {
      final success = await revokeOtherSessions.execute();
      if (success) {
        await loadSessions(); // Reload to get updated list
        _showMessage('Other sessions revoked successfully');
      } else {
        _showMessage('Failed to revoke other sessions');
      }
    } catch (e) {
      _showMessage('Failed to revoke other sessions: ${e.toString()}');
    }
  }

  // New backend-aligned methods (delegate to legacy for now)
  Future<void> loadTransferableSessions() async {
    await loadSessions();
  }

  Future<void> transferMainDeviceToSession(String sessionId) async {
    await approveSessionById(sessionId);
  }

  Future<bool> confirmUserPassword(String password) async {
    _showMessage('Password confirmation not implemented');
    return false;
  }

  Future<Map<String, dynamic>> checkLogoutStatus() async {
    _showMessage('Logout status check not implemented');
    return {'success': false, 'message': 'Not implemented'};
  }

  Future<void> forceLogout() async {
    _showMessage('Force logout not implemented');
  }

  void _showMessage(String message) {
    // This would typically be handled by the view
    print(message);
  }
}
