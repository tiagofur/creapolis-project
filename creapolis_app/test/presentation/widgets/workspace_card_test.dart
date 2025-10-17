import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/presentation/widgets/workspace/workspace_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _defaultOwner = WorkspaceOwner(
  id: 1,
  name: 'Test Owner',
  email: 'owner@test.com',
);

void main() {
  group('WorkspaceCard Widget', () {
    late Workspace testWorkspace;

    setUp(() {
      testWorkspace = Workspace(
        id: 1,
        name: 'Test Workspace',
        description: 'Test Description',
        type: WorkspaceType.team,
        ownerId: 1,
        owner: const WorkspaceOwner(
          id: 1,
          name: 'Test Owner',
          email: 'owner@test.com',
        ),
        userRole: WorkspaceRole.owner,
        memberCount: 1,
        projectCount: 0,
        settings: WorkspaceSettings.defaults(),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    });

    Widget createWidget({
      required Workspace workspace,
      bool isActive = false,
      VoidCallback? onTap,
      VoidCallback? onSetActive,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: WorkspaceCard(
            workspace: workspace,
            isActive: isActive,
            onTap: onTap,
            onSetActive: onSetActive,
          ),
        ),
      );
    }

    testWidgets('should render workspace name and description', (tester) async {
      await tester.pumpWidget(createWidget(workspace: testWorkspace));

      expect(find.text('Test Workspace'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should render workspace without description', (tester) async {
      final workspaceNoDesc = Workspace(
        id: 1,
        name: 'Test Workspace',
        type: WorkspaceType.team,
        ownerId: 1,
        owner: const WorkspaceOwner(
          id: 1,
          name: 'Test Owner',
          email: 'owner@test.com',
        ),
        userRole: WorkspaceRole.member,
        memberCount: 1,
        projectCount: 0,
        settings: WorkspaceSettings.defaults(),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidget(workspace: workspaceNoDesc));

      expect(find.text('Test Workspace'), findsOneWidget);
      expect(find.text('Test Description'), findsNothing);
    });

    testWidgets('should show "Activo" badge when isActive is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(workspace: testWorkspace, isActive: true),
      );

      expect(find.text('Activo'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should not show "Activo" badge when isActive is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(workspace: testWorkspace, isActive: false),
      );

      expect(find.text('Activo'), findsNothing);
    });

    testWidgets(
      'should show "Activar" button when not active and onSetActive provided',
      (tester) async {
        var setActiveCalled = false;

        await tester.pumpWidget(
          createWidget(
            workspace: testWorkspace,
            isActive: false,
            onSetActive: () => setActiveCalled = true,
          ),
        );

        expect(find.text('Activar'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

        await tester.tap(find.text('Activar'));
        await tester.pumpAndSettle();

        expect(setActiveCalled, true);
      },
    );

    testWidgets('should not show "Activar" button when active', (tester) async {
      await tester.pumpWidget(
        createWidget(
          workspace: testWorkspace,
          isActive: true,
          onSetActive: () {},
        ),
      );

      expect(find.text('Activar'), findsNothing);
    });

    testWidgets('should display correct type label for personal workspace', (
      tester,
    ) async {
      final personalWorkspace = Workspace(
        id: 1,
        name: 'Personal',
        type: WorkspaceType.personal,
        ownerId: 1,
        owner: _defaultOwner,
        userRole: WorkspaceRole.owner,
        memberCount: 1,
        projectCount: 0,
        settings: WorkspaceSettings.defaults(),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidget(workspace: personalWorkspace));

      // "Personal" appears in both name and type chip
      expect(find.text('Personal'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('should display correct type label for team workspace', (
      tester,
    ) async {
      final teamWorkspace = Workspace(
        id: 1,
        name: 'Team',
        type: WorkspaceType.team,
        ownerId: 1,
        owner: _defaultOwner,
        userRole: WorkspaceRole.admin,
        memberCount: 1,
        projectCount: 0,
        settings: WorkspaceSettings.defaults(),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidget(workspace: teamWorkspace));

      expect(find.text('Equipo'), findsOneWidget);
      expect(find.byIcon(Icons.group), findsWidgets);
    });

    testWidgets('should display correct type label for enterprise workspace', (
      tester,
    ) async {
      final enterpriseWorkspace = Workspace(
        id: 1,
        name: 'Enterprise',
        type: WorkspaceType.enterprise,
        ownerId: 1,
        owner: _defaultOwner,
        userRole: WorkspaceRole.member,
        memberCount: 1,
        projectCount: 0,
        settings: WorkspaceSettings.defaults(),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidget(workspace: enterpriseWorkspace));

      expect(find.text('Empresa'), findsOneWidget);
      expect(find.byIcon(Icons.business), findsWidgets);
    });

    testWidgets('should display role badge with correct role name', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(workspace: testWorkspace));

      expect(find.text('Propietario'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      var tapCalled = false;

      await tester.pumpWidget(
        createWidget(workspace: testWorkspace, onTap: () => tapCalled = true),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(tapCalled, true);
    });

    testWidgets('should display avatar when avatarUrl is provided', (
      tester,
    ) async {
      final workspaceWithAvatar = Workspace(
        id: 1,
        name: 'Test',
        type: WorkspaceType.team,
        ownerId: 1,
        owner: _defaultOwner,
        userRole: WorkspaceRole.member,
        memberCount: 1,
        projectCount: 0,
        avatarUrl: 'https://example.com/avatar.png',
        settings: WorkspaceSettings.defaults(),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidget(workspace: workspaceWithAvatar));

      expect(find.byType(CircleAvatar), findsOneWidget);
      final circleAvatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(circleAvatar.backgroundImage, isA<NetworkImage>());
    });

    testWidgets('should display icon avatar when avatarUrl is null', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(workspace: testWorkspace));

      expect(find.byType(CircleAvatar), findsOneWidget);
      final circleAvatar = tester.widget<CircleAvatar>(
        find.byType(CircleAvatar).first,
      );
      expect(circleAvatar.child, isA<Icon>());
    });

    testWidgets('should have higher elevation when active', (tester) async {
      await tester.pumpWidget(
        createWidget(workspace: testWorkspace, isActive: true),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 8);
    });

    testWidgets('should have lower elevation when not active', (tester) async {
      await tester.pumpWidget(
        createWidget(workspace: testWorkspace, isActive: false),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
    });

    testWidgets('should display different roles correctly', (tester) async {
      final roles = [
        (WorkspaceRole.owner, 'Propietario'),
        (WorkspaceRole.admin, 'Administrador'),
        (WorkspaceRole.member, 'Miembro'),
        (WorkspaceRole.guest, 'Invitado'),
      ];

      for (final (role, displayName) in roles) {
        final workspace = Workspace(
          id: 1,
          name: 'Test',
          type: WorkspaceType.team,
          ownerId: 1,
          owner: _defaultOwner,
          userRole: role,
          memberCount: 1,
          projectCount: 0,
          settings: WorkspaceSettings.defaults(),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        await tester.pumpWidget(createWidget(workspace: workspace));
        expect(find.text(displayName), findsOneWidget);
        await tester.pumpWidget(Container()); // Clear widget tree
      }
    });
  });
}
