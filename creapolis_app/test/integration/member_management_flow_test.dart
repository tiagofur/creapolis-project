import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:creapolis_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:creapolis_app/presentation/bloc/auth/auth_event.dart';
import 'package:creapolis_app/presentation/bloc/auth/auth_state.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_state.dart';
import 'package:creapolis_app/presentation/bloc/workspace_invitation/workspace_invitation_state.dart';
import 'package:creapolis_app/domain/entities/user.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/domain/entities/workspace_invitation.dart';
import 'package:creapolis_app/domain/entities/workspace_member.dart';
import 'package:creapolis_app/domain/usecases/workspace/accept_invitation.dart';
import 'package:creapolis_app/domain/usecases/workspace/create_invitation.dart';
import 'package:creapolis_app/domain/usecases/workspace/decline_invitation.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_pending_invitations.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_workspace_members.dart';
import 'package:creapolis_app/presentation/bloc/workspace_invitation/workspace_invitation_bloc.dart';
import 'package:creapolis_app/presentation/bloc/workspace_invitation/workspace_invitation_event.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_bloc.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_event.dart';
import 'package:creapolis_app/presentation/screens/workspace/workspace_invitations_screen.dart';
import 'package:creapolis_app/presentation/screens/workspace/workspace_members_screen.dart';
import 'package:creapolis_app/presentation/widgets/loading/skeleton_list.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'member_management_flow_test.mocks.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

@GenerateMocks([
  GetWorkspaceMembersUseCase,
  GetPendingInvitationsUseCase,
  CreateInvitationUseCase,
  AcceptInvitationUseCase,
  DeclineInvitationUseCase,
])
void main() {
  // Helper to wait for BLoC state
  Future<void> waitForState<B extends StateStreamable<S>, S>(
    WidgetTester tester,
    B bloc,
    bool Function(S) condition,
  ) async {
    if (condition(bloc.state)) return;

    await tester.runAsync(() async {
      int retries = 0;
      while (retries < 50) {
        if (condition(bloc.state)) return;
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
    });

    await tester.pump();

    if (!condition(bloc.state)) {
      print('Timed out waiting for state. Current state: ${bloc.state}');
    }
  }

  group('Member Management Flow Integration Tests', () {
    late MockGetWorkspaceMembersUseCase mockGetWorkspaceMembers;
    late MockGetPendingInvitationsUseCase mockGetPendingInvitations;
    late MockCreateInvitationUseCase mockCreateInvitation;
    late MockAcceptInvitationUseCase mockAcceptInvitation;
    late MockDeclineInvitationUseCase mockDeclineInvitation;
    late MockAuthBloc mockAuthBloc;
    late WorkspaceMemberBloc memberBloc;
    late WorkspaceInvitationBloc invitationBloc;

    setUp(() {
      mockGetWorkspaceMembers = MockGetWorkspaceMembersUseCase();
      mockGetPendingInvitations = MockGetPendingInvitationsUseCase();
      mockCreateInvitation = MockCreateInvitationUseCase();
      mockAcceptInvitation = MockAcceptInvitationUseCase();
      mockDeclineInvitation = MockDeclineInvitationUseCase();
      mockAuthBloc = MockAuthBloc();

      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthAuthenticated(
            User(
              id: 1,
              email: 'owner@test.com',
              name: 'Test Owner',
              role: UserRole.teamMember,
            ),
          ),
        ]),
        initialState: const AuthAuthenticated(
          User(
            id: 1,
            email: 'owner@test.com',
            name: 'Test Owner',
            role: UserRole.teamMember,
          ),
        ),
      );

      memberBloc = WorkspaceMemberBloc(mockGetWorkspaceMembers);

      invitationBloc = WorkspaceInvitationBloc(
        mockGetPendingInvitations,
        mockCreateInvitation,
        mockAcceptInvitation,
        mockDeclineInvitation,
      );

      when(
        mockDeclineInvitation.call(any),
      ).thenAnswer((_) => Future.value(const Right(null)));
    });

    tearDown(() {
      memberBloc.close();
      invitationBloc.close();
      mockAuthBloc.close();
    });

    final tWorkspace = Workspace(
      id: 1,
      name: 'Test Workspace',
      description: 'Test workspace description',
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final tMembers = <WorkspaceMember>[
      WorkspaceMember(
        id: 1,
        workspaceId: 1,
        userId: 1,
        userName: 'John Doe',
        userEmail: 'john@example.com',
        role: WorkspaceRole.owner,
        joinedAt: DateTime(2024, 1, 1),
        lastActiveAt: DateTime.now(),
      ),
      WorkspaceMember(
        id: 2,
        workspaceId: 1,
        userId: 2,
        userName: 'Jane Smith',
        userEmail: 'jane@example.com',
        role: WorkspaceRole.admin,
        joinedAt: DateTime(2024, 1, 5),
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      WorkspaceMember(
        id: 3,
        workspaceId: 1,
        userId: 3,
        userName: 'Bob Johnson',
        userEmail: 'bob@example.com',
        role: WorkspaceRole.member,
        joinedAt: DateTime(2024, 1, 10),
      ),
    ];

    final tInvitations = <WorkspaceInvitation>[
      WorkspaceInvitation(
        id: 1,
        workspaceId: 1,
        workspaceName: 'Test Workspace',
        workspaceType: WorkspaceType.team,
        inviterName: 'John Doe',
        inviterEmail: 'john@example.com',
        inviteeEmail: 'alice@example.com',
        role: WorkspaceRole.member,
        status: InvitationStatus.pending,
        token: 'token-123',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      WorkspaceInvitation(
        id: 2,
        workspaceId: 1,
        workspaceName: 'Test Workspace',
        workspaceType: WorkspaceType.team,
        inviterName: 'John Doe',
        inviterEmail: 'john@example.com',
        inviteeEmail: 'charlie@example.com',
        role: WorkspaceRole.admin,
        status: InvitationStatus.pending,
        token: 'token-456',
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    Widget createMembersApp() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<WorkspaceMemberBloc>.value(value: memberBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: MaterialApp(home: WorkspaceMembersScreen(workspace: tWorkspace)),
      );
    }

    Widget createInvitationsApp() {
      return BlocProvider<WorkspaceInvitationBloc>.value(
        value: invitationBloc,
        child: MaterialApp(home: const WorkspaceInvitationsScreen()),
      );
    }

    group('Members Management', () {
      testWidgets('should show loading state while fetching members', (
        tester,
      ) async {
        // Arrange
        when(mockGetWorkspaceMembers.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          return Right(tMembers);
        });

        await tester.runAsync(() async {
          await tester.pumpWidget(createMembersApp());
          // Allow BLoC to process event and emit Loading
          await Future.delayed(Duration.zero);
        });

        // Rebuild widget with new state
        await tester.pump();

        // Assert
        expect(find.byType(SkeletonList), findsOneWidget);
        expect(find.text('Miembros del Workspace'), findsOneWidget);

        // Finish the test - wait for the real timer in the mock to complete
        await tester.runAsync(() async {
          await Future.delayed(const Duration(milliseconds: 600));
        });

        await tester.pumpAndSettle();
      });

      testWidgets('should load and display workspace members', (tester) async {
        // Arrange
        when(mockGetWorkspaceMembers.call(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Right(tMembers);
        });

        await tester.pumpWidget(createMembersApp());

        // Wait for Loaded state
        await waitForState<WorkspaceMemberBloc, WorkspaceMemberState>(
          tester,
          memberBloc,
          (state) => state is WorkspaceMembersLoaded,
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Owners'), findsOneWidget); // Fallback text
        expect(find.text('Admins'), findsOneWidget); // Fallback text
        expect(find.text('Miembros'), findsOneWidget); // Fallback text
        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('should show active indicator for recently active members', (
        tester,
      ) async {
        // Arrange
        when(
          mockGetWorkspaceMembers.call(any),
        ).thenAnswer((_) => Future.value(Right(tMembers)));

        // Act
        await tester.pumpWidget(createMembersApp());

        // Wait for Loaded state
        await waitForState<WorkspaceMemberBloc, WorkspaceMemberState>(
          tester,
          memberBloc,
          (state) => state is WorkspaceMembersLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Active indicators present
        expect(find.text('Activo'), findsWidgets);
      });

      testWidgets('should handle empty members list', (tester) async {
        // Arrange
        when(
          mockGetWorkspaceMembers.call(any),
        ).thenAnswer((_) => Future.value(const Right(<WorkspaceMember>[])));

        // Act
        await tester.pumpWidget(createMembersApp());

        // Wait for Loaded state
        await waitForState<WorkspaceMemberBloc, WorkspaceMemberState>(
          tester,
          memberBloc,
          (state) => state is WorkspaceMembersLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Empty state
        expect(find.textContaining('No hay miembros'), findsOneWidget);
      });

      testWidgets('should refresh members when pull-to-refresh is triggered', (
        tester,
      ) async {
        // Arrange
        when(
          mockGetWorkspaceMembers.call(any),
        ).thenAnswer((_) => Future.value(Right(tMembers)));

        // Act - Initial load
        await tester.pumpWidget(createMembersApp());

        // Wait for Loaded state
        await waitForState<WorkspaceMemberBloc, WorkspaceMemberState>(
          tester,
          memberBloc,
          (state) => state is WorkspaceMembersLoaded,
        );

        await tester.pumpAndSettle();

        // Act - Pull to refresh
        // Ensure list is present before dragging
        expect(find.byType(ListView), findsOneWidget);

        // Drag the list view instead of finding RefreshIndicator directly if it's tricky
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pumpAndSettle();

        // Assert - Called multiple times
        verify(
          mockGetWorkspaceMembers.call(
            GetWorkspaceMembersParams(workspaceId: 1),
          ),
        ).called(greaterThan(1));
      });

      testWidgets('should display member avatars and initials', (tester) async {
        // Arrange
        when(
          mockGetWorkspaceMembers.call(any),
        ).thenAnswer((_) => Future.value(Right(tMembers)));

        // Act
        await tester.pumpWidget(createMembersApp());

        // Wait for Loaded state
        await waitForState<WorkspaceMemberBloc, WorkspaceMemberState>(
          tester,
          memberBloc,
          (state) => state is WorkspaceMembersLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Avatars present
        expect(find.byType(CircleAvatar), findsWidgets);
        expect(find.text('JD'), findsOneWidget); // John Doe initials
        expect(find.text('JS'), findsOneWidget); // Jane Smith initials
        expect(find.text('BJ'), findsOneWidget); // Bob Johnson initials
      });
    });

    group('Invitations Management', () {
      testWidgets('should load and display pending invitations', (
        tester,
      ) async {
        // Arrange
        when(mockGetPendingInvitations.call()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Right(tInvitations);
        });

        // Act
        await tester.pumpWidget(createInvitationsApp());

        // Wait for Loaded state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is PendingInvitationsLoaded,
        );

        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Workspace'), findsWidgets);
        expect(find.text('John Doe'), findsWidgets); // Inviter name
        verify(mockGetPendingInvitations.call()).called(1);
      });

      testWidgets('should show loading state while fetching invitations', (
        tester,
      ) async {
        // Arrange
        when(mockGetPendingInvitations.call()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          return Right(tInvitations);
        });

        // Act
        await tester.runAsync(() async {
          await tester.pumpWidget(createInvitationsApp());
          // Allow BLoC to process event and emit Loading
          await Future.delayed(Duration.zero);
        });

        await tester.pump();

        // Assert - Loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for completion
        await tester.runAsync(() async {
          await Future.delayed(const Duration(milliseconds: 600));
        });
        await tester.pumpAndSettle();

        // Assert - Loaded
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Test Workspace'), findsWidgets);
      });

      testWidgets('should display invitation status badges', (tester) async {
        // Arrange
        when(
          mockGetPendingInvitations.call(),
        ).thenAnswer((_) => Future.value(Right(tInvitations)));

        // Act
        await tester.pumpWidget(createInvitationsApp());

        // Wait for Loaded state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is PendingInvitationsLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Status badges
        expect(find.text('Pendiente'), findsWidgets);
      });

      testWidgets(
        'should show accept and decline buttons for pending invitations',
        (tester) async {
          // Arrange
          when(
            mockGetPendingInvitations.call(),
          ).thenAnswer((_) => Future.value(Right(tInvitations)));

          // Act
          await tester.pumpWidget(createInvitationsApp());

          // Wait for Loaded state
          await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
            tester,
            invitationBloc,
            (state) => state is PendingInvitationsLoaded,
          );

          await tester.pumpAndSettle();

          // Assert - Action buttons present
          expect(find.byIcon(Icons.check), findsWidgets);
          expect(find.byIcon(Icons.close), findsWidgets);
        },
      );

      testWidgets('should accept invitation when accept button is pressed', (
        tester,
      ) async {
        // Arrange
        when(
          mockGetPendingInvitations.call(),
        ).thenAnswer((_) => Future.value(Right(tInvitations)));
        when(
          mockAcceptInvitation.call(any),
        ).thenAnswer((_) => Future.value(Right(tWorkspace)));
        when(
          mockDeclineInvitation.call(any),
        ).thenAnswer((_) => Future.value(const Right(null)));

        // Act
        await tester.pumpWidget(createInvitationsApp());

        // Wait for Loaded state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is PendingInvitationsLoaded,
        );

        await tester.pumpAndSettle();

        // Tap accept button
        final acceptButton = find.byIcon(Icons.check).first;
        await tester.tap(acceptButton);
        await tester.pumpAndSettle();

        // Confirm dialog
        await tester.tap(find.widgetWithText(ElevatedButton, 'Aceptar'));
        await tester.pump();

        // Assert - Accept use case was called
        verify(mockAcceptInvitation.call(any)).called(1);
      });

      testWidgets('should display invitation role badges', (tester) async {
        // Arrange
        when(
          mockGetPendingInvitations.call(),
        ).thenAnswer((_) => Future.value(Right(tInvitations)));

        // Act
        await tester.pumpWidget(createInvitationsApp());

        // Wait for Loaded state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is PendingInvitationsLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Role badges (Chips)
        expect(find.byType(Chip), findsWidgets);
      });

      testWidgets('should handle empty invitations list', (tester) async {
        // Arrange
        when(
          mockGetPendingInvitations.call(),
        ).thenAnswer((_) => Future.value(const Right(<WorkspaceInvitation>[])));

        // Act
        await tester.pumpWidget(createInvitationsApp());

        // Wait for Loaded state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is PendingInvitationsLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Empty state
        expect(find.textContaining('No tienes invitaciones'), findsOneWidget);
      });

      testWidgets('should display days until expiration', (tester) async {
        // Arrange
        when(
          mockGetPendingInvitations.call(),
        ).thenAnswer((_) => Future.value(Right(tInvitations)));

        // Act
        await tester.pumpWidget(createInvitationsApp());

        // Wait for Loaded state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is PendingInvitationsLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Expiration info displayed
        expect(
          find.textContaining(RegExp(r'días|days|Expira|Expires')),
          findsWidgets,
        );
      });

      testWidgets('should show error when accepting invitation fails', (
        tester,
      ) async {
        // Arrange
        when(mockGetPendingInvitations.call()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Right(tInvitations);
        });
        when(
          mockAcceptInvitation.call(any),
        ).thenAnswer((_) async => Left(ServerFailure('Server error')));

        // Act
        await tester.pumpWidget(createInvitationsApp());

        // Wait for Loaded state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is PendingInvitationsLoaded,
        );

        await tester.pumpAndSettle();

        // Tap accept button
        final acceptButton = find.byIcon(Icons.check).first;
        await tester.tap(acceptButton);
        await tester.pumpAndSettle();

        // Confirm dialog
        await tester.tap(find.widgetWithText(ElevatedButton, 'Aceptar'));
        await tester.pump();

        // Wait for error state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is WorkspaceInvitationError,
        );
        await tester.pumpAndSettle();

        // Assert - Error message displayed
        expect(find.text('Server error'), findsOneWidget);
      });
    });

    group('Complete Member Management Flow', () {
      testWidgets('complete flow: load members → refresh → check states', (
        tester,
      ) async {
        // Arrange
        when(
          mockGetWorkspaceMembers.call(any),
        ).thenAnswer((_) => Future.value(Right(tMembers)));

        // Act - Build widget
        await tester.pumpWidget(createMembersApp());

        // Step 1: Load members

        // Wait for Loaded state
        await waitForState<WorkspaceMemberBloc, WorkspaceMemberState>(
          tester,
          memberBloc,
          (state) => state is WorkspaceMembersLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Loaded state
        expect(find.byType(SkeletonList), findsNothing);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Bob Johnson'), findsOneWidget);

        // Step 2: Refresh
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pumpAndSettle();

        // Assert - Still showing members after refresh
        expect(find.text('John Doe'), findsOneWidget);
        verify(
          mockGetWorkspaceMembers.call(
            GetWorkspaceMembersParams(workspaceId: 1),
          ),
        ).called(greaterThan(1));
      });

      testWidgets('complete flow: load invitations → accept → verify update', (
        tester,
      ) async {
        // Arrange
        when(mockGetPendingInvitations.call()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Right(tInvitations);
        });
        when(
          mockAcceptInvitation.call(any),
        ).thenAnswer((_) => Future.value(Right(tWorkspace)));

        // Act - Build widget
        await tester.pumpWidget(createInvitationsApp());

        // Step 1: Load invitations

        // Wait for Loaded state
        await waitForState<WorkspaceInvitationBloc, WorkspaceInvitationState>(
          tester,
          invitationBloc,
          (state) => state is PendingInvitationsLoaded,
        );

        await tester.pumpAndSettle();

        // Assert - Invitations loaded
        expect(find.text('John Doe'), findsWidgets);
        expect(find.byIcon(Icons.check), findsWidgets);

        // Step 2: Accept invitation
        final acceptButton = find.byIcon(Icons.check).first;
        await tester.tap(acceptButton);
        await tester.pumpAndSettle();

        // Confirm dialog
        await tester.tap(find.widgetWithText(ElevatedButton, 'Aceptar'));
        await tester.pump();

        // Assert - Accept was called
        verify(mockAcceptInvitation.call(any)).called(1);
      });
    });
  });
}
