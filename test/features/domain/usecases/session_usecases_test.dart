import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/get_sessions_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/approve_session_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/revoke_session_usecase.dart';
import 'package:cryphoria_mobile/features/domain/usecases/Session/revoke_other_sessions_usecase.dart';

@GenerateMocks([
  GetSessions,
  ApproveSession,
  RevokeSession,
  RevokeOtherSessions,
])
void main() {
  // This file is used to generate mocks for session usecases
  // The actual tests are in other files
  test('mock generation file', () {
    expect(true, true);
  });
}
