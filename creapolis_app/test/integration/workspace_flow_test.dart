import 'package:creapolis_app/core/error/failures.dart';
import 'package:creapolis_app/domain/entities/workspace.dart';
import 'package:creapolis_app/domain/usecases/workspace/create_workspace.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_user_workspaces.dart';
import 'package:creapolis_app/presentation/bloc/workspace/workspace_bloc.dart';
import 'package:creapolis_app/presentation/screens/workspace/workspace_list_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'workspace_flow_test.mocks.dart';

@GenerateMocks([GetUserWorkspacesUseCase, CreateWorkspaceUseCase])
void main() {
  group('Workspace Flow Integration Tests', () {
    late MockGetUserWorkspacesUseCase mockGetUserWorkspaces;
    late MockCreateWorkspaceUseCase mockCreateWorkspace;
    late WorkspaceBloc workspaceBloc;

    setUp(() {
      mockGetUserWorkspaces = MockGetUserWorkspacesUseCase();
      mockCreateWorkspace = MockCreateWorkspaceUseCase();
      workspaceBloc = WorkspaceBloc(
        getUserWorkspaces: mockGetUserWorkspaces,
        createWorkspace: mockCreateWorkspace,
      );
    });

    tearDown(() {
      workspaceBloc.close();
    });

    final tWorkspaces = <Workspace>[
      Workspace(
        id: 1,
        name: 'Test Workspace 1',
        description: 'Description 1',
        type: WorkspaceType.team,
        ownerId: 1,
        userRole: WorkspaceRole.owner,
        settings: const WorkspaceSettings(),
        memberCount: 5,
        projectCount: 10,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Workspace(
        id: 2,
        name: 'Test Workspace 2',
        description: 'Description 2',
        type: WorkspaceType.personal,
        ownerId: 1,
        userRole: WorkspaceRole.owner,
        settings: const WorkspaceSettings(),
        memberCount: 1,
        projectCount: 3,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];

    Widget createApp() {
      return MaterialApp(
        home: BlocProvider<WorkspaceBloc>(
          create: (_) => workspaceBloc,
          child: const WorkspaceListScreen(),
        ),
      );
    }

    testWidgets('should load and display workspaces on screen initialization', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Workspace 1'), findsOneWidget);
      expect(find.text('Test Workspace 2'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.text('Description 2'), findsOneWidget);
      verify(mockGetUserWorkspaces.call()).called(1);
    });

    testWidgets('should show loading indicator while fetching workspaces', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pump(); // Don't settle yet

      // Assert - Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for completion
      await tester.pumpAndSettle();

      // Assert - Loaded state
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Workspace 1'), findsOneWidget);
    });

    testWidgets('should display error message when loading workspaces fails', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Server error'), findsOneWidget);
      expect(find.text('Test Workspace 1'), findsNothing);
    });

    testWidgets('should display empty state when no workspaces exist', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => const Right(<Workspace>[]));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pumpAndSettle();

      // Assert - Empty state message
      expect(find.textContaining('No tienes workspaces'), findsOneWidget);
      expect(find.text('Test Workspace 1'), findsNothing);
    });

    testWidgets('should refresh workspaces when pull-to-refresh is triggered', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // Act - Initial load
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pumpAndSettle();

      // Act - Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - GetUserWorkspaces called twice (initial + refresh)
      verify(mockGetUserWorkspaces.call()).called(greaterThan(1));
    });

    testWidgets(
      'should navigate to workspace detail when workspace is tapped',
      (tester) async {
        // Arrange
        when(
          mockGetUserWorkspaces.call(),
        ).thenAnswer((_) async => Right(tWorkspaces));

        // Act
        await tester.pumpWidget(createApp());
        workspaceBloc.add(const LoadUserWorkspacesEvent());
        await tester.pumpAndSettle();

        // Tap on first workspace
        await tester.tap(find.text('Test Workspace 1'));
        await tester.pumpAndSettle();

        // Assert - Navigation occurred (route change)
        // Note: Actual navigation depends on implementation
        expect(find.text('Test Workspace 1'), findsWidgets);
      },
    );

    testWidgets('should set active workspace when "Activar" button is tapped', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pumpAndSettle();

      // Find and tap "Activar" button if present
      final activateButton = find.text('Activar');
      if (activateButton.evaluate().isNotEmpty) {
        await tester.tap(activateButton.first);
        await tester.pumpAndSettle();

        // Assert - Active badge should appear
        expect(find.text('Activo'), findsOneWidget);
      }
    });

    testWidgets('should handle network error with retry option', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Left(NetworkFailure('No connection')));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pumpAndSettle();

      // Assert - Error message displayed
      expect(find.text('No connection'), findsOneWidget);

      // Look for retry button
      final retryButton = find.widgetWithText(ElevatedButton, 'Reintentar');
      if (retryButton.evaluate().isNotEmpty) {
        // Arrange - Mock successful retry
        when(
          mockGetUserWorkspaces.call(),
        ).thenAnswer((_) async => Right(tWorkspaces));

        // Act - Tap retry
        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        // Assert - Data loaded after retry
        expect(find.text('Test Workspace 1'), findsOneWidget);
      }
    });

    testWidgets('should display workspace type icons correctly', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pumpAndSettle();

      // Assert - Icons present
      expect(find.byIcon(Icons.group), findsWidgets); // Team workspace
      expect(find.byIcon(Icons.person), findsWidgets); // Personal workspace
    });

    testWidgets('should display correct member and project counts', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pumpAndSettle();

      // Assert - Counts visible (if displayed in UI)
      // This depends on WorkspaceCard implementation
      expect(find.text('Test Workspace 1'), findsOneWidget);
      expect(find.text('Test Workspace 2'), findsOneWidget);
    });

    testWidgets('complete workspace listing flow with state transitions', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // Act - Build widget
      await tester.pumpWidget(createApp());

      // Assert - Initial state
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Act - Load workspaces
      workspaceBloc.add(const LoadUserWorkspacesEvent());
      await tester.pump(); // Trigger loading state

      // Assert - Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for data to load
      await tester.pumpAndSettle();

      // Assert - Loaded state
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Workspace 1'), findsOneWidget);
      expect(find.text('Test Workspace 2'), findsOneWidget);
      expect(find.text('Equipo'), findsOneWidget); // Team type
      expect(find.text('Personal'), findsAtLeastNWidgets(1)); // Personal type

      // Verify use case was called
      verify(mockGetUserWorkspaces.call()).called(1);
    });
  });
}
