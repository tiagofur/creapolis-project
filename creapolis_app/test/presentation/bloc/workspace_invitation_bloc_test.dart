import 'package:bloc_test/bloc_test.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/workspace.dart';
import 'package:creapolis_app/domain/entities/workspace_invitation.dart';
import 'package:creapolis_app/domain/usecases/workspace/accept_invitation.dart';
import 'package:creapolis_app/domain/usecases/workspace/create_invitation.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_pending_invitations.dart';
import 'package:creapolis_app/presentation/bloc/workspace_invitation/workspace_invitation_bloc.dart';
import 'package:creapolis_app/presentation/bloc/workspace_invitation/workspace_invitation_event.dart';
import 'package:creapolis_app/presentation/bloc/workspace_invitation/workspace_invitation_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'workspace_invitation_bloc_test.mocks.dart';

@GenerateMocks([
  GetPendingInvitationsUseCase,
  CreateInvitationUseCase,
  AcceptInvitationUseCase,
])
void main() {
  late WorkspaceInvitationBloc bloc;
  late MockGetPendingInvitationsUseCase mockGetPendingInvitationsUseCase;
  late MockCreateInvitationUseCase mockCreateInvitationUseCase;
  late MockAcceptInvitationUseCase mockAcceptInvitationUseCase;

  setUp(() {
    mockGetPendingInvitationsUseCase = MockGetPendingInvitationsUseCase();
    mockCreateInvitationUseCase = MockCreateInvitationUseCase();
    mockAcceptInvitationUseCase = MockAcceptInvitationUseCase();
    bloc = WorkspaceInvitationBloc(
      mockGetPendingInvitationsUseCase,
      mockCreateInvitationUseCase,
      mockAcceptInvitationUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('WorkspaceInvitationBloc', () {
    final tInvitation = WorkspaceInvitation(
      id: 1,
      workspaceId: 1,
      workspaceName: 'Test Workspace',
      workspaceType: WorkspaceType.team,
      inviterName: 'Inviter',
      inviterEmail: 'inviter@test.com',
      inviteeEmail: 'invitee@test.com',
      role: WorkspaceRole.member,
      token: 'test-token',
      status: InvitationStatus.pending,
      createdAt: DateTime(2025, 1, 1),
      expiresAt: DateTime(2025, 1, 31),
    );

    final tInvitations = <WorkspaceInvitation>[tInvitation];

    final tWorkspace = Workspace(
      id: 1,
      name: 'Test Workspace',
      description: 'Description',
      ownerId: 1,
      type: WorkspaceType.team,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      settings: const WorkspaceSettings(),
      userRole: WorkspaceRole.member,
      memberCount: 2,
    );

    test('initial state should be WorkspaceInvitationInitial', () {
      expect(bloc.state, equals(const WorkspaceInvitationInitial()));
    });

    group('LoadPendingInvitationsEvent', () {
      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, PendingInvitationsLoaded] when data is gotten successfully',
        build: () {
          when(
            mockGetPendingInvitationsUseCase.call(),
          ).thenAnswer((_) async => Right(tInvitations));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPendingInvitationsEvent()),
        expect: () => [
          const WorkspaceInvitationLoading(),
          PendingInvitationsLoaded(tInvitations),
        ],
        verify: (_) {
          verify(mockGetPendingInvitationsUseCase.call());
          verifyNoMoreInteractions(mockGetPendingInvitationsUseCase);
        },
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] when getting data fails',
        build: () {
          when(
            mockGetPendingInvitationsUseCase.call(),
          ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPendingInvitationsEvent()),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('Server error'),
        ],
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, PendingInvitationsLoaded] with empty list when no invitations',
        build: () {
          when(
            mockGetPendingInvitationsUseCase.call(),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPendingInvitationsEvent()),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const PendingInvitationsLoaded([]),
        ],
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] on auth error',
        build: () {
          when(
            mockGetPendingInvitationsUseCase.call(),
          ).thenAnswer((_) async => const Left(AuthFailure('Unauthorized')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPendingInvitationsEvent()),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('Unauthorized'),
        ],
      );
    });

    group('RefreshPendingInvitationsEvent', () {
      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationError] when refresh fails',
        build: () {
          when(mockGetPendingInvitationsUseCase.call()).thenAnswer(
            (_) async => const Left(NetworkFailure('No connection')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const RefreshPendingInvitationsEvent()),
        expect: () => [const WorkspaceInvitationError('No connection')],
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [PendingInvitationsLoaded] with updated data when refresh succeeds',
        build: () {
          when(
            mockGetPendingInvitationsUseCase.call(),
          ).thenAnswer((_) async => Right(tInvitations));
          return bloc;
        },
        act: (bloc) => bloc.add(const RefreshPendingInvitationsEvent()),
        expect: () => [PendingInvitationsLoaded(tInvitations)],
      );
    });

    group('CreateInvitationEvent', () {
      final tParams = CreateInvitationParams(
        workspaceId: 1,
        email: 'new@test.com',
        role: WorkspaceRole.member,
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, InvitationCreated, WorkspaceInvitationLoading, PendingInvitationsLoaded] when creation succeeds',
        build: () {
          when(
            mockCreateInvitationUseCase.call(any),
          ).thenAnswer((_) async => Right(tInvitation));
          when(
            mockGetPendingInvitationsUseCase.call(),
          ).thenAnswer((_) async => Right(tInvitations));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const CreateInvitationEvent(
            workspaceId: 1,
            email: 'new@test.com',
            role: WorkspaceRole.member,
          ),
        ),
        expect: () => [
          const WorkspaceInvitationLoading(),
          InvitationCreated(tInvitation),
          const WorkspaceInvitationLoading(),
          PendingInvitationsLoaded(tInvitations),
        ],
        verify: (_) {
          verify(mockCreateInvitationUseCase.call(tParams));
          verify(mockGetPendingInvitationsUseCase.call());
        },
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] when creation fails with validation error',
        build: () {
          when(mockCreateInvitationUseCase.call(any)).thenAnswer(
            (_) async => const Left(ValidationFailure('Invalid email')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const CreateInvitationEvent(
            workspaceId: 1,
            email: 'invalid-email',
            role: WorkspaceRole.member,
          ),
        ),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('Invalid email'),
        ],
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] when user already member',
        build: () {
          when(mockCreateInvitationUseCase.call(any)).thenAnswer(
            (_) async =>
                const Left(ValidationFailure('User is already a member')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const CreateInvitationEvent(
            workspaceId: 1,
            email: 'member@test.com',
            role: WorkspaceRole.member,
          ),
        ),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('User is already a member'),
        ],
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] when user lacks permissions',
        build: () {
          when(mockCreateInvitationUseCase.call(any)).thenAnswer(
            (_) async => const Left(AuthFailure('Insufficient permissions')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const CreateInvitationEvent(
            workspaceId: 1,
            email: 'new@test.com',
            role: WorkspaceRole.admin,
          ),
        ),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('Insufficient permissions'),
        ],
      );
    });

    group('AcceptInvitationEvent', () {
      const tToken = 'test-token';
      final tParams = AcceptInvitationParams(token: tToken);

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, InvitationAccepted, WorkspaceInvitationLoading, PendingInvitationsLoaded] when acceptance succeeds',
        build: () {
          when(
            mockAcceptInvitationUseCase.call(any),
          ).thenAnswer((_) async => Right(tWorkspace));
          when(
            mockGetPendingInvitationsUseCase.call(),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptInvitationEvent(tToken)),
        expect: () => [
          const WorkspaceInvitationLoading(),
          InvitationAccepted(tWorkspace),
          const WorkspaceInvitationLoading(),
          const PendingInvitationsLoaded([]),
        ],
        verify: (_) {
          verify(mockAcceptInvitationUseCase.call(tParams));
          verify(mockGetPendingInvitationsUseCase.call());
        },
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] when token is invalid',
        build: () {
          when(mockAcceptInvitationUseCase.call(any)).thenAnswer(
            (_) async =>
                const Left(NotFoundFailure('Invalid or expired token')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptInvitationEvent('invalid-token')),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('Invalid or expired token'),
        ],
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] when user already member',
        build: () {
          when(mockAcceptInvitationUseCase.call(any)).thenAnswer(
            (_) async => const Left(ValidationFailure('Already a member')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptInvitationEvent(tToken)),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('Already a member'),
        ],
      );

      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] on server error',
        build: () {
          when(
            mockAcceptInvitationUseCase.call(any),
          ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptInvitationEvent(tToken)),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('Server error'),
        ],
      );
    });

    group('DeclineInvitationEvent', () {
      blocTest<WorkspaceInvitationBloc, WorkspaceInvitationState>(
        'should emit [WorkspaceInvitationLoading, WorkspaceInvitationError] for not implemented feature',
        build: () => bloc,
        act: (bloc) => bloc.add(const DeclineInvitationEvent('test-token')),
        expect: () => [
          const WorkspaceInvitationLoading(),
          const WorkspaceInvitationError('Funcionalidad no implementada'),
        ],
      );
    });
  });
}



