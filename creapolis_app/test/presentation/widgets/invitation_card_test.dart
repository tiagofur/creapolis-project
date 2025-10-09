import 'package:creapolis_app/domain/entities/workspace.dart';
import 'package:creapolis_app/domain/entities/workspace_invitation.dart';
import 'package:creapolis_app/presentation/widgets/workspace/invitation_card.dart';
import 'package:creapolis_app/presentation/widgets/workspace/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InvitationCard Widget', () {
    late WorkspaceInvitation testInvitation;

    setUp(() {
      testInvitation = WorkspaceInvitation(
        id: 1,
        workspaceId: 1,
        workspaceName: 'Test Workspace',
        workspaceType: WorkspaceType.team,
        inviterName: 'John Inviter',
        inviterEmail: 'inviter@example.com',
        inviteeEmail: 'invitee@example.com',
        role: WorkspaceRole.member,
        status: InvitationStatus.pending,
        token: 'test-token',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
    });

    Widget createWidget({
      required WorkspaceInvitation invitation,
      VoidCallback? onAccept,
      VoidCallback? onDecline,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: InvitationCard(
            invitation: invitation,
            onAccept: onAccept,
            onDecline: onDecline,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('should render workspace name', (tester) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      expect(find.text('Test Workspace'), findsOneWidget);
    });

    testWidgets('should render inviter name', (tester) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      expect(find.text('John Inviter'), findsOneWidget);
      expect(find.text('Invitado por'), findsOneWidget);
    });

    testWidgets('should display RoleBadge widget', (tester) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      expect(find.byType(RoleBadge), findsOneWidget);
    });

    testWidgets('should display workspace type chip', (tester) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      expect(find.text('Equipo'), findsOneWidget);
    });

    testWidgets('should show pending status badge', (tester) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets('should show days until expiration when not expired', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      expect(find.textContaining('días restantes'), findsOneWidget);
    });

    testWidgets('should show "Expirada" when invitation is expired', (
      tester,
    ) async {
      final expiredInvitation = WorkspaceInvitation(
        id: 1,
        workspaceId: 1,
        workspaceName: 'Test',
        workspaceType: WorkspaceType.team,
        inviterName: 'John',
        inviterEmail: 'inviter@example.com',
        inviteeEmail: 'invitee@example.com',
        role: WorkspaceRole.member,
        status: InvitationStatus.expired,
        token: 'test-token',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      );

      await tester.pumpWidget(createWidget(invitation: expiredInvitation));

      // Should show "Expirada" text in red color (expiration status)
      expect(find.text('Expirada'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'should show accept and decline buttons when pending and not expired',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            invitation: testInvitation,
            onAccept: () {},
            onDecline: () {},
          ),
        );

        expect(find.text('Aceptar'), findsOneWidget);
        expect(find.text('Rechazar'), findsOneWidget);
      },
    );

    testWidgets('should not show action buttons when expired', (tester) async {
      final expiredInvitation = WorkspaceInvitation(
        id: 1,
        workspaceId: 1,
        workspaceName: 'Test',
        workspaceType: WorkspaceType.team,
        inviterName: 'John',
        inviterEmail: 'inviter@example.com',
        inviteeEmail: 'invitee@example.com',
        role: WorkspaceRole.member,
        status: InvitationStatus.expired,
        token: 'test-token',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      );

      await tester.pumpWidget(
        createWidget(
          invitation: expiredInvitation,
          onAccept: () {},
          onDecline: () {},
        ),
      );

      expect(find.text('Aceptar'), findsNothing);
      expect(find.text('Rechazar'), findsNothing);
      expect(find.text('Esta invitación ha expirado'), findsOneWidget);
    });

    testWidgets('should not show action buttons when status is accepted', (
      tester,
    ) async {
      final acceptedInvitation = WorkspaceInvitation(
        id: 1,
        workspaceId: 1,
        workspaceName: 'Test',
        workspaceType: WorkspaceType.team,
        inviterName: 'John',
        inviterEmail: 'inviter@example.com',
        inviteeEmail: 'invitee@example.com',
        role: WorkspaceRole.member,
        status: InvitationStatus.accepted,
        token: 'test-token',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        createWidget(
          invitation: acceptedInvitation,
          onAccept: () {},
          onDecline: () {},
        ),
      );

      expect(find.text('Aceptar'), findsNothing);
      expect(find.text('Rechazar'), findsNothing);
    });

    testWidgets('should call onAccept when accept button is pressed', (
      tester,
    ) async {
      var acceptCalled = false;

      await tester.pumpWidget(
        createWidget(
          invitation: testInvitation,
          onAccept: () => acceptCalled = true,
          onDecline: () {},
        ),
      );

      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      expect(acceptCalled, true);
    });

    testWidgets('should call onDecline when decline button is pressed', (
      tester,
    ) async {
      var declineCalled = false;

      await tester.pumpWidget(
        createWidget(
          invitation: testInvitation,
          onAccept: () {},
          onDecline: () => declineCalled = true,
        ),
      );

      await tester.tap(find.text('Rechazar'));
      await tester.pumpAndSettle();

      expect(declineCalled, true);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      var tapCalled = false;

      await tester.pumpWidget(
        createWidget(invitation: testInvitation, onTap: () => tapCalled = true),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(tapCalled, true);
    });

    testWidgets('should display inviter avatar when provided', (tester) async {
      final invitationWithAvatar = WorkspaceInvitation(
        id: 1,
        workspaceId: 1,
        workspaceName: 'Test',
        workspaceType: WorkspaceType.team,
        inviterName: 'John',
        inviterEmail: 'inviter@example.com',
        inviterAvatarUrl: 'https://example.com/avatar.png',
        inviteeEmail: 'invitee@example.com',
        role: WorkspaceRole.member,
        status: InvitationStatus.pending,
        token: 'test-token',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(createWidget(invitation: invitationWithAvatar));

      final circleAvatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(circleAvatar.backgroundImage, isA<NetworkImage>());
    });

    testWidgets('should display inviter initials when no avatar', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      expect(find.text('JI'), findsOneWidget); // John Inviter initials
    });

    testWidgets('should display correct icon for personal workspace type', (
      tester,
    ) async {
      final personalInvitation = WorkspaceInvitation(
        id: 1,
        workspaceId: 1,
        workspaceName: 'Personal Workspace',
        workspaceType: WorkspaceType.personal,
        inviterName: 'John',
        inviterEmail: 'inviter@example.com',
        inviteeEmail: 'invitee@example.com',
        role: WorkspaceRole.member,
        status: InvitationStatus.pending,
        token: 'test-token',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(createWidget(invitation: personalInvitation));

      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('should display correct icon for team workspace type', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      expect(find.byIcon(Icons.groups), findsOneWidget);
    });

    testWidgets('should display correct icon for enterprise workspace type', (
      tester,
    ) async {
      final enterpriseInvitation = WorkspaceInvitation(
        id: 1,
        workspaceId: 1,
        workspaceName: 'Enterprise Workspace',
        workspaceType: WorkspaceType.enterprise,
        inviterName: 'John',
        inviterEmail: 'inviter@example.com',
        inviteeEmail: 'invitee@example.com',
        role: WorkspaceRole.member,
        status: InvitationStatus.pending,
        token: 'test-token',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(createWidget(invitation: enterpriseInvitation));

      expect(find.byIcon(Icons.business), findsOneWidget);
    });

    testWidgets('should format creation date correctly', (tester) async {
      await tester.pumpWidget(createWidget(invitation: testInvitation));

      // Should show "hace X horas"
      expect(find.textContaining('hace'), findsOneWidget);
    });
  });
}
