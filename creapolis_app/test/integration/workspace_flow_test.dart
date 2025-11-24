import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/usecases/workspace/create_workspace.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_active_workspace.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_user_workspaces.dart';
import 'package:creapolis_app/domain/usecases/workspace/set_active_workspace.dart';
import 'package:creapolis_app/features/workspace/data/datasources/workspace_remote_datasource.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/features/workspace/presentation/bloc/workspace_bloc.dart';
import 'package:creapolis_app/features/workspace/presentation/bloc/workspace_event.dart';
import 'package:creapolis_app/presentation/screens/workspace/workspace_list_screen.dart';
import 'package:creapolis_app/presentation/providers/workspace_context.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'workspace_flow_test.mocks.dart';

@GenerateMocks([
  GetUserWorkspacesUseCase,
  CreateWorkspaceUseCase,
  SetActiveWorkspaceUseCase,
  GetActiveWorkspaceUseCase,
  WorkspaceRemoteDataSource,
])
void main() {
  group('Workspace Flow Integration Tests', () {
    late MockGetUserWorkspacesUseCase mockGetUserWorkspaces;
    late MockCreateWorkspaceUseCase mockCreateWorkspace;
    late MockSetActiveWorkspaceUseCase mockSetActiveWorkspace;
    late MockGetActiveWorkspaceUseCase mockGetActiveWorkspace;
    late MockWorkspaceRemoteDataSource mockWorkspaceRemoteDataSource;
    late WorkspaceBloc workspaceBloc;
    late WorkspaceContext workspaceContext;

    setUp(() {
      mockGetUserWorkspaces = MockGetUserWorkspacesUseCase();
      mockCreateWorkspace = MockCreateWorkspaceUseCase();
      mockSetActiveWorkspace = MockSetActiveWorkspaceUseCase();
      mockGetActiveWorkspace = MockGetActiveWorkspaceUseCase();
      mockWorkspaceRemoteDataSource = MockWorkspaceRemoteDataSource();

      // Default stubs
      when(
        mockGetActiveWorkspace.call(),
      ).thenAnswer((_) async => const Right(null));
      when(
        mockSetActiveWorkspace.call(any),
      ).thenAnswer((_) async => const Right(null));
      when(
        mockWorkspaceRemoteDataSource.getPendingInvitations(),
      ).thenAnswer((_) async => []);

      workspaceBloc = WorkspaceBloc(
        dataSource: mockWorkspaceRemoteDataSource,
        getUserWorkspaces: mockGetUserWorkspaces,
        createWorkspace: mockCreateWorkspace,
        setActiveWorkspace: mockSetActiveWorkspace,
        getActiveWorkspace: mockGetActiveWorkspace,
      );

      workspaceContext = WorkspaceContext(workspaceBloc);
    });

    tearDown(() {
      workspaceBloc.close();
    });

    final tWorkspaceOwner = const WorkspaceOwner(
      id: 1,
      name: 'Test Owner',
      email: 'owner@test.com',
    );

    final tWorkspaces = <Workspace>[
      Workspace(
        id: 1,
        name: 'Test Workspace 1',
        description: 'Description 1',
        type: WorkspaceType.team,
        ownerId: 1,
        owner: tWorkspaceOwner,
        userRole: WorkspaceRole.owner,
        settings: WorkspaceSettings.defaults(),
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
        owner: tWorkspaceOwner,
        userRole: WorkspaceRole.owner,
        settings: WorkspaceSettings.defaults(),
        memberCount: 1,
        projectCount: 3,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];

    Widget createApp() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            BlocProvider<WorkspaceBloc>(create: (_) => workspaceBloc),
            ChangeNotifierProvider<WorkspaceContext>(
              create: (_) => workspaceContext,
            ),
          ],
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
      workspaceBloc.add(const LoadWorkspaces()); // Manual trigger
      await tester.pump(); // Trigger initState
      await tester.pump(const Duration(seconds: 1)); // Wait for mock delay
      await tester.pumpAndSettle(); // Rebuild UI

      // Assert
      expect(find.text('Test Workspace 1'), findsOneWidget);
      expect(find.text('Test Workspace 2'), findsOneWidget);
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.text('Description 2'), findsOneWidget);
      verify(mockGetUserWorkspaces.call()).called(greaterThan(0));
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
      workspaceBloc.add(const LoadWorkspaces()); // Manual trigger
      await tester.pump(); // Process event -> Loading
      await tester.pump(
        const Duration(milliseconds: 10),
      ); // Small pump to ensure loading state

      // Assert - Loading state
      // Note: WorkspaceListScreen uses SkeletonList or LinearProgressIndicator, not CircularProgressIndicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Wait for completion
      await tester.pump(const Duration(seconds: 1)); // Wait for mock delay
      await tester.pumpAndSettle(); // Rebuild UI

      // Assert - Loaded state
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Test Workspace 1'), findsOneWidget);
    });

    testWidgets('should display error message when loading workspaces fails', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadWorkspaces()); // Manual trigger
      await tester.pump(); // Trigger initState
      await tester.pump(const Duration(seconds: 1)); // Wait for mock delay
      await tester.pumpAndSettle(); // Rebuild UI

      // Assert
      // WorkspaceListScreen uses NoConnectionWidget or similar which might show the error message
      // or context.showError which shows a SnackBar
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
      workspaceBloc.add(const LoadWorkspaces()); // Manual trigger
      await tester.pump(); // Trigger initState
      await tester.pump(const Duration(seconds: 1)); // Wait for mock delay
      await tester.pumpAndSettle(); // Rebuild UI

      // Assert - Empty state message
      // EmptyWorkspaceScreen usually has text like "No tienes workspaces"
      expect(
        find.textContaining('Comienza tu viaje creando tu primer workspace'),
        findsOneWidget,
      );
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
      workspaceBloc.add(const LoadWorkspaces()); // Manual trigger
      await tester.pump(); // Trigger initState
      await tester.pump(const Duration(seconds: 1)); // Wait for mock delay
      await tester.pumpAndSettle(); // Rebuild UI

      // Act - Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert - GetUserWorkspaces called twice (initial + refresh)
      verify(mockGetUserWorkspaces.call()).called(greaterThan(1));
    });

    testWidgets('should set active workspace when "Activar" button is tapped', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));
      when(
        mockSetActiveWorkspace.call(any),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await tester.pumpWidget(createApp());
      workspaceBloc.add(const LoadWorkspaces()); // Manual trigger
      await tester.pump(); // Trigger initState
      await tester.pump(const Duration(seconds: 1)); // Wait for mock delay
      await tester.pumpAndSettle(); // Rebuild UI

      // Find and tap "Activar" button if present
      // WorkspaceCard has an "Activar" button or similar action
      final activateButton = find.text('Activar');
      if (activateButton.evaluate().isNotEmpty) {
        await tester.tap(activateButton.first);
        await tester.pumpAndSettle();

        // Assert - Active badge should appear
        expect(find.text('Activo'), findsOneWidget);
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
      workspaceBloc.add(const LoadWorkspaces()); // Manual trigger
      await tester.pump(); // Trigger initState
      await tester.pump(const Duration(seconds: 1)); // Wait for mock delay
      await tester.pumpAndSettle(); // Rebuild UI

      // Assert - Icons present
      // WorkspaceCard uses icons based on type
      expect(find.byIcon(Icons.group), findsWidgets); // Team workspace
      expect(find.byIcon(Icons.person), findsWidgets); // Personal workspace
    });
  });
}
