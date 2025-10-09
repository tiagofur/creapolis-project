import 'package:creapolis_app/domain/entities/workspace.dart';
import 'package:creapolis_app/domain/entities/workspace_member.dart';
import 'package:creapolis_app/presentation/widgets/workspace/member_card.dart';
import 'package:creapolis_app/presentation/widgets/workspace/role_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberCard Widget', () {
    late WorkspaceMember testMember;

    setUp(() {
      testMember = WorkspaceMember(
        id: 1,
        workspaceId: 1,
        userId: 1,
        userName: 'John Doe',
        userEmail: 'john@example.com',
        role: WorkspaceRole.member,
        joinedAt: DateTime(2024, 1, 1),
      );
    });

    Widget createWidget({
      required WorkspaceMember member,
      bool isCurrentUser = false,
      bool showActions = false,
      VoidCallback? onTap,
      VoidCallback? onChangeRole,
      VoidCallback? onRemove,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MemberCard(
            member: member,
            isCurrentUser: isCurrentUser,
            showActions: showActions,
            onTap: onTap,
            onChangeRole: onChangeRole,
            onRemove: onRemove,
          ),
        ),
      );
    }

    testWidgets('should render member name and email', (tester) async {
      await tester.pumpWidget(createWidget(member: testMember));

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('should show "Tú" badge when isCurrentUser is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(member: testMember, isCurrentUser: true),
      );

      expect(find.text('Tú'), findsOneWidget);
    });

    testWidgets('should not show "Tú" badge when isCurrentUser is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(member: testMember, isCurrentUser: false),
      );

      expect(find.text('Tú'), findsNothing);
    });

    testWidgets('should display RoleBadge widget', (tester) async {
      await tester.pumpWidget(createWidget(member: testMember));

      expect(find.byType(RoleBadge), findsOneWidget);
    });

    testWidgets('should show active indicator when member is recently active', (
      tester,
    ) async {
      final activeMember = WorkspaceMember(
        id: 1,
        workspaceId: 1,
        userId: 1,
        userName: 'Jane Doe',
        userEmail: 'jane@example.com',
        role: WorkspaceRole.admin,
        joinedAt: DateTime(2024, 1, 1),
        lastActiveAt: DateTime.now(),
      );

      await tester.pumpWidget(createWidget(member: activeMember));

      expect(find.text('Activo'), findsOneWidget);
      // Check for green circle indicator
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.green,
        ),
        findsWidgets,
      );
    });

    testWidgets(
      'should not show active indicator when member is not recently active',
      (tester) async {
        final inactiveMember = WorkspaceMember(
          id: 1,
          workspaceId: 1,
          userId: 1,
          userName: 'John Inactive',
          userEmail: 'inactive@example.com',
          role: WorkspaceRole.member,
          joinedAt: DateTime(2024, 1, 1),
          lastActiveAt: DateTime(2023, 1, 1), // Old activity
        );

        await tester.pumpWidget(createWidget(member: inactiveMember));

        expect(find.text('Activo'), findsNothing);
      },
    );

    testWidgets('should display avatar with initials when no avatar url', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(member: testMember));

      expect(find.byType(CircleAvatar), findsWidgets);
      expect(find.text('JD'), findsOneWidget); // Initials
    });

    testWidgets('should display network image when avatarUrl is provided', (
      tester,
    ) async {
      final memberWithAvatar = WorkspaceMember(
        id: 1,
        workspaceId: 1,
        userId: 1,
        userName: 'Alice',
        userEmail: 'alice@example.com',
        userAvatarUrl: 'https://example.com/avatar.png',
        role: WorkspaceRole.owner,
        joinedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidget(member: memberWithAvatar));

      final circleAvatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(circleAvatar.backgroundImage, isA<NetworkImage>());
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      var tapCalled = false;

      await tester.pumpWidget(
        createWidget(member: testMember, onTap: () => tapCalled = true),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(tapCalled, true);
    });

    testWidgets('should not show actions menu when showActions is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          member: testMember,
          showActions: false,
          onChangeRole: () {},
          onRemove: () {},
        ),
      );

      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });

    testWidgets(
      'should show actions menu when showActions is true and callbacks provided',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            member: testMember,
            showActions: true,
            onChangeRole: () {},
            onRemove: () {},
          ),
        );

        expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      },
    );

    testWidgets(
      'should show "Cambiar Rol" option in menu when onChangeRole provided',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            member: testMember,
            showActions: true,
            onChangeRole: () {},
            onRemove: () {},
          ),
        );

        // Open menu
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        expect(find.text('Cambiar Rol'), findsOneWidget);
        expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      },
    );

    testWidgets('should show "Remover" option in menu when onRemove provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          member: testMember,
          showActions: true,
          onChangeRole: () {},
          onRemove: () {},
        ),
      );

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Remover'), findsOneWidget);
      expect(find.byIcon(Icons.person_remove), findsOneWidget);
    });

    testWidgets('should call onChangeRole when menu option is selected', (
      tester,
    ) async {
      var changeRoleCalled = false;

      await tester.pumpWidget(
        createWidget(
          member: testMember,
          showActions: true,
          onChangeRole: () => changeRoleCalled = true,
        ),
      );

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap "Cambiar Rol"
      await tester.tap(find.text('Cambiar Rol'));
      await tester.pumpAndSettle();

      expect(changeRoleCalled, true);
    });

    testWidgets('should call onRemove when menu option is selected', (
      tester,
    ) async {
      var removeCalled = false;

      await tester.pumpWidget(
        createWidget(
          member: testMember,
          showActions: true,
          onRemove: () => removeCalled = true,
        ),
      );

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap "Remover"
      await tester.tap(find.text('Remover'));
      await tester.pumpAndSettle();

      expect(removeCalled, true);
    });

    testWidgets('should display different roles correctly', (tester) async {
      final roles = [
        WorkspaceRole.owner,
        WorkspaceRole.admin,
        WorkspaceRole.member,
        WorkspaceRole.guest,
      ];

      for (final role in roles) {
        final member = WorkspaceMember(
          id: 1,
          workspaceId: 1,
          userId: 1,
          userName: 'Test User',
          userEmail: 'test@example.com',
          role: role,
          joinedAt: DateTime(2024, 1, 1),
        );

        await tester.pumpWidget(createWidget(member: member));
        expect(find.byType(RoleBadge), findsOneWidget);
        await tester.pumpWidget(Container()); // Clear widget tree
      }
    });
  });
}
