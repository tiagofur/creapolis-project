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
import 'package:creapolis_app/presentation/widgets/loading/skeleton_list.dart';
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
      return MultiProvider(
        providers: [
          BlocProvider<WorkspaceBloc>(create: (_) => workspaceBloc),
          ChangeNotifierProvider<WorkspaceContext>(
            create: (_) => workspaceContext,
          ),
        ],
        child: const MaterialApp(home: WorkspaceListScreen()),
      );
    }

    testWidgets('should load and display workspaces on screen initialization', (
      tester,
    ) async {
      // Arrange
      when(mockGetUserWorkspaces.call()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return Right(tWorkspaces);
      });

      // Act
      await tester.runAsync(() async {
        await tester.pumpWidget(createApp());
        await tester.pump(); // Trigger initState callback
        await tester.pump(
          const Duration(milliseconds: 100),
        ); // Process event and start loading

        // Wait for completion inside runAsync
        await Future.delayed(const Duration(milliseconds: 100));
      });

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
      when(mockGetUserWorkspaces.call()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return Right(tWorkspaces);
      });

      // Act
      await tester.runAsync(() async {
        await tester.pumpWidget(createApp());
        await tester.pump(); // Trigger initState callback
        await tester.pump(const Duration(milliseconds: 10)); // Process event

        // Assert - Loading state
        // WorkspaceListScreen uses SkeletonList when cache is empty
        expect(find.byType(SkeletonList), findsOneWidget);

        // Wait for completion inside runAsync to handle the delay
        await Future.delayed(const Duration(milliseconds: 600));
      });

      await tester.pump(); // Process completion
      await tester.pumpAndSettle(); // Rebuild UI

      // Assert - Loaded state
      expect(find.byType(SkeletonList), findsNothing);
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
      await tester.runAsync(() async {
        await tester.pumpWidget(createApp());
        await tester.pump(); // Trigger initState callback
        await tester.pump(const Duration(milliseconds: 100)); // Process event

        // Wait for completion
        await Future.delayed(const Duration(milliseconds: 100));
      });

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
      await tester.runAsync(() async {
        await tester.pumpWidget(createApp());
        await tester.pump(); // Trigger initState callback
        await tester.pump(const Duration(milliseconds: 100)); // Process event

        // Wait for completion
        await Future.delayed(const Duration(milliseconds: 100));
      });

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
      await tester.runAsync(() async {
        await tester.pumpWidget(createApp());
        await tester.pump(); // Trigger initState callback
        await tester.pump(const Duration(milliseconds: 100)); // Process event

        // Wait for completion
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpAndSettle(); // Rebuild UI

      // Ensure list is loaded
      expect(find.byType(ListView), findsOneWidget);

      // Act - Pull to refresh
      await tester.drag(find.byType(ListView), const Offset(0, 300));
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
      await tester.runAsync(() async {
        await tester.pumpWidget(createApp());
        await tester.pump(); // Trigger initState callback
        await tester.pump(const Duration(milliseconds: 100)); // Process event

        // Wait for completion
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpAndSettle(); // Rebuild UI

      // Find and tap "Activar" button if present
      // WorkspaceCard has an "Activar" button or similar action
      final activateButton = find.text('Activar');
      expect(activateButton, findsOneWidget); // Ensure button exists

      await tester.tap(activateButton.first);

      // Use pump instead of pumpAndSettle to avoid timeout if there's an infinite animation
      // (like CircularProgressIndicator during activation)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Assert - Active badge should appear
      // Note: If the activation is instant in the mock, we might see the result immediately.
      // If the UI shows a loading spinner, we might need to wait for it to finish.
      // Since mockSetActiveWorkspace returns Right(null), the bloc should update.

      // We check for 'Activo' text which appears in the badge
      expect(find.text('Activo'), findsWidgets);
    });

    testWidgets('should display workspace type icons correctly', (
      tester,
    ) async {
      // Arrange
      when(
        mockGetUserWorkspaces.call(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // Act
      await tester.runAsync(() async {
        await tester.pumpWidget(createApp());
        await tester.pump(); // Trigger initState callback
        await tester.pump(const Duration(milliseconds: 100)); // Process event

        // Wait for completion
        await Future.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpAndSettle(); // Rebuild UI

      // Assert - Icons present
      // WorkspaceCard uses icons based on type
      // Checking for Icons.person first to see if any icons are found
      expect(find.byIcon(Icons.person), findsWidgets); // Personal workspace
      expect(find.byIcon(Icons.group), findsWidgets); // Team workspace
    });
  });
}
