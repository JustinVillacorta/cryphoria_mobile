import 'package:flutter/material.dart';
import '../../../domain/entities/user_session.dart';

class SessionManagementViewModel extends ChangeNotifier {
  List<UserSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<UserSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSessions(List<UserSession> sessions) {
    _sessions = sessions;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void removeSession(String sessionId) {
    _sessions.removeWhere((session) => session.sid == sessionId);
    notifyListeners();
  }

  void updateSessionApproval(String sessionId, bool approved) {
    final index = _sessions.indexWhere((session) => session.sid == sessionId);
    if (index != -1) {
      final session = _sessions[index];
      _sessions[index] = UserSession(
        sid: session.sid,
        deviceName: session.deviceName,
        deviceId: session.deviceId,
        ip: session.ip,
        userAgent: session.userAgent,
        createdAt: session.createdAt,
        lastSeen: session.lastSeen,
        approved: approved,
        approvedAt: approved ? DateTime.now() : session.approvedAt,
        revokedAt: session.revokedAt,
        isCurrent: session.isCurrent,
      );
      notifyListeners();
    }
  }
}
