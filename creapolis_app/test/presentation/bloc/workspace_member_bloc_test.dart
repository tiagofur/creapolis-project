import 'package:bloc_test/bloc_test.dart';
import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/workspace.dart';
import 'package:creapolis_app/domain/entities/workspace_member.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_workspace_members.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_bloc.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_event.dart';
import 'package:creapolis_app/presentation/bloc/workspace_member/workspace_member_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'workspace_member_bloc_test.mocks.dart';

@GenerateMocks([GetWorkspaceMembersUseCase])
void main() {
  late WorkspaceMemberBloc bloc;
  late MockGetWorkspaceMembersUseCase mockGetWorkspaceMembersUseCase;

  setUp(() {
    mockGetWorkspaceMembersUseCase = MockGetWorkspaceMembersUseCase();
    bloc = WorkspaceMemberBloc(mockGetWorkspaceMembersUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('WorkspaceMemberBloc', () {
    const tWorkspaceId = 1;
    final tMember = WorkspaceMember(
      id: 1,
      workspaceId: tWorkspaceId,
      userId: 1,
      userName: 'John Doe',
      userEmail: 'john@test.com',
      role: WorkspaceRole.member,
      joinedAt: DateTime(2025, 1, 1),
    );

    final tMembers = <WorkspaceMember>[tMember];
    final tParams = GetWorkspaceMembersParams(workspaceId: tWorkspaceId);

    test('initial state should be WorkspaceMemberInitial', () {
      expect(bloc.state, equals(const WorkspaceMemberInitial()));
    });

    group('LoadWorkspaceMembersEvent', () {
      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMemberLoading, WorkspaceMembersLoaded] when data is gotten successfully',
        build: () {
          when(
            mockGetWorkspaceMembersUseCase.call(any),
          ).thenAnswer((_) async => Right(tMembers));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaceMembersEvent(tWorkspaceId)),
        expect: () => [
          const WorkspaceMemberLoading(),
          WorkspaceMembersLoaded(members: tMembers, workspaceId: tWorkspaceId),
        ],
        verify: (_) {
          verify(mockGetWorkspaceMembersUseCase.call(tParams));
          verifyNoMoreInteractions(mockGetWorkspaceMembersUseCase);
        },
      );

      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMemberLoading, WorkspaceMemberError] when getting data fails',
        build: () {
          when(
            mockGetWorkspaceMembersUseCase.call(any),
          ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaceMembersEvent(tWorkspaceId)),
        expect: () => [
          const WorkspaceMemberLoading(),
          const WorkspaceMemberError('Server error'),
        ],
        verify: (_) {
          verify(mockGetWorkspaceMembersUseCase.call(tParams));
          verifyNoMoreInteractions(mockGetWorkspaceMembersUseCase);
        },
      );

      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMemberLoading, WorkspaceMembersLoaded] with empty list when no members',
        build: () {
          when(
            mockGetWorkspaceMembersUseCase.call(any),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaceMembersEvent(tWorkspaceId)),
        expect: () => [
          const WorkspaceMemberLoading(),
          const WorkspaceMembersLoaded(members: [], workspaceId: tWorkspaceId),
        ],
      );

      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMemberLoading, WorkspaceMemberError] when workspace not found',
        build: () {
          when(mockGetWorkspaceMembersUseCase.call(any)).thenAnswer(
            (_) async => const Left(NotFoundFailure('Workspace not found')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaceMembersEvent(999)),
        expect: () => [
          const WorkspaceMemberLoading(),
          const WorkspaceMemberError('Workspace not found'),
        ],
      );

      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMemberLoading, WorkspaceMemberError] on network error',
        build: () {
          when(mockGetWorkspaceMembersUseCase.call(any)).thenAnswer(
            (_) async => const Left(NetworkFailure('No connection')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaceMembersEvent(tWorkspaceId)),
        expect: () => [
          const WorkspaceMemberLoading(),
          const WorkspaceMemberError('No connection'),
        ],
      );
    });

    group('RefreshWorkspaceMembersEvent', () {
      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMemberError] when refresh fails',
        build: () {
          when(mockGetWorkspaceMembersUseCase.call(any)).thenAnswer(
            (_) async => const Left(NetworkFailure('No connection')),
          );
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const RefreshWorkspaceMembersEvent(tWorkspaceId)),
        expect: () => [const WorkspaceMemberError('No connection')],
      );

      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMembersLoaded] with updated data when refresh succeeds',
        build: () {
          when(
            mockGetWorkspaceMembersUseCase.call(any),
          ).thenAnswer((_) async => Right(tMembers));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const RefreshWorkspaceMembersEvent(tWorkspaceId)),
        expect: () => [
          WorkspaceMembersLoaded(members: tMembers, workspaceId: tWorkspaceId),
        ],
      );

      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMembersLoaded] with empty list when no members after refresh',
        build: () {
          when(
            mockGetWorkspaceMembersUseCase.call(any),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const RefreshWorkspaceMembersEvent(tWorkspaceId)),
        expect: () => [
          const WorkspaceMembersLoaded(members: [], workspaceId: tWorkspaceId),
        ],
      );
    });

    group('UpdateMemberRoleEvent', () {
      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMemberLoading, WorkspaceMemberError] for not implemented feature',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const UpdateMemberRoleEvent(
            workspaceId: tWorkspaceId,
            userId: 1,
            newRole: WorkspaceRole.admin,
          ),
        ),
        expect: () => [
          const WorkspaceMemberLoading(),
          const WorkspaceMemberError('Funcionalidad no implementada'),
        ],
      );
    });

    group('RemoveMemberEvent', () {
      blocTest<WorkspaceMemberBloc, WorkspaceMemberState>(
        'should emit [WorkspaceMemberLoading, WorkspaceMemberError] for not implemented feature',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RemoveMemberEvent(workspaceId: tWorkspaceId, userId: 1),
        ),
        expect: () => [
          const WorkspaceMemberLoading(),
          const WorkspaceMemberError('Funcionalidad no implementada'),
        ],
      );
    });
  });
}
