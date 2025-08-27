import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/session_list_item.dart';
import 'package:cryphoria_mobile/features/domain/entities/user_session.dart';

void main() {
  group('SessionListItem Widget Tests', () {
    late UserSession testSession;
    late UserSession currentSession;
    late UserSession legacySession;

    setUp(() {
      testSession = UserSession(
        sid: 'session_123',
        deviceName: 'iPhone 15',
        deviceId: 'device_123',
        ip: '192.168.1.100',
        userAgent: 'iOS App',
        createdAt: DateTime(2024, 8, 27, 10, 30),
        lastSeen: DateTime(2024, 8, 27, 12, 15),
        approved: false,
        approvedAt: null,
        revokedAt: null,
        isCurrent: false,
      );

      currentSession = UserSession(
        sid: 'session_current',
        deviceName: 'Android Device',
        deviceId: 'device_456',
        ip: '192.168.1.101',
        userAgent: 'Android App',
        createdAt: DateTime(2024, 8, 27, 9, 0),
        lastSeen: DateTime(2024, 8, 27, 12, 30),
        approved: true,
        approvedAt: DateTime(2024, 8, 27, 9, 1),
        revokedAt: null,
        isCurrent: true,
      );

      legacySession = UserSession(
        sid: 'legacy',
        deviceName: 'legacy',
        deviceId: '',
        ip: '',
        userAgent: '',
        createdAt: DateTime(2024, 7, 1, 0, 0),
        lastSeen: null,
        approved: true,
        approvedAt: null,
        revokedAt: null,
        isCurrent: false,
      );
    });

    Widget createWidgetUnderTest(UserSession session, {
      VoidCallback? onApprove,
      VoidCallback? onRevoke,
      bool canApprove = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SessionListItem(
            session: session,
            onApprove: onApprove,
            onRevoke: onRevoke,
            canApprove: canApprove,
          ),
        ),
      );
    }

    testWidgets('should display pending session correctly', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(testSession, canApprove: true));

      // assert
      expect(find.text('iPhone 15'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Current'), findsNothing);
      expect(find.text('Device ID: device_123'), findsOneWidget);
      expect(find.text('IP: 192.168.1.100'), findsOneWidget);
    });

    testWidgets('should display current session with indicator', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(currentSession));

      // assert
      expect(find.text('Android Device'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('should display legacy session with badge', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(legacySession));

      // assert
      expect(find.text('legacy'), findsOneWidget);
      expect(find.text('Legacy'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('should show approve button for pending sessions when canApprove is true', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(
        testSession,
        canApprove: true,
        onApprove: () {},
      ));

      // assert
      expect(find.text('Approve'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should not show approve button when canApprove is false', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(
        testSession,
        canApprove: false,
        onApprove: () {},
      ));

      // assert
      expect(find.text('Approve'), findsNothing);
    });

    testWidgets('should show revoke button for non-current sessions', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(
        testSession,
        onRevoke: () {},
      ));

      // assert
      expect(find.text('Revoke'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should not show revoke button for current session', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(currentSession));

      // assert
      expect(find.text('Revoke'), findsNothing);
    });

    testWidgets('should call onApprove when approve button is tapped', (WidgetTester tester) async {
      // arrange
      bool approveCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        testSession,
        canApprove: true,
        onApprove: () => approveCalled = true,
      ));

      // act
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      // assert
      expect(approveCalled, isTrue);
    });

    testWidgets('should call onRevoke when revoke button is tapped', (WidgetTester tester) async {
      // arrange
      bool revokeCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        testSession,
        onRevoke: () => revokeCalled = true,
      ));

      // act
      await tester.tap(find.text('Revoke'));
      await tester.pumpAndSettle();

      // assert
      expect(revokeCalled, isTrue);
    });

    testWidgets('should display correct device icon for iPhone', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(testSession));

      // assert
      expect(find.byIcon(Icons.phone_iphone), findsOneWidget);
    });

    testWidgets('should display correct device icon for Android', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(currentSession));

      // assert
      expect(find.byIcon(Icons.phone_android), findsOneWidget);
    });

    testWidgets('should display correct device icon for legacy', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(legacySession));

      // assert
      expect(find.byIcon(Icons.computer), findsOneWidget);
    });

    testWidgets('should format dates correctly', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(testSession));

      // assert
      expect(find.text('Created: 27/8/2024 10:30'), findsOneWidget);
      expect(find.text('Last seen: 27/8/2024 12:15'), findsOneWidget);
    });
  });
}
