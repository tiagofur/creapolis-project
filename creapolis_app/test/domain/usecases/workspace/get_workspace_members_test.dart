import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/workspace.dart';
import 'package:creapolis_app/domain/entities/workspace_member.dart';
import 'package:creapolis_app/domain/repositories/workspace_repository.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_workspace_members.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_workspace_members_test.mocks.dart';

@GenerateMocks([WorkspaceRepository])
void main() {
  late GetWorkspaceMembersUseCase usecase;
  late MockWorkspaceRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkspaceRepository();
    usecase = GetWorkspaceMembersUseCase(mockRepository);
  });

  const tWorkspaceId = 1;
  final tParams = GetWorkspaceMembersParams(workspaceId: tWorkspaceId);

  final tMembers = [
    WorkspaceMember(
      id: 1,
      workspaceId: tWorkspaceId,
      userId: 1,
      userName: 'John Doe',
      userEmail: 'john@example.com',
      userAvatarUrl: null,
      role: WorkspaceRole.owner,
      joinedAt: DateTime(2024, 1, 1),
      lastActiveAt: DateTime.now(),
      isActive: true,
    ),
    WorkspaceMember(
      id: 2,
      workspaceId: tWorkspaceId,
      userId: 2,
      userName: 'Jane Smith',
      userEmail: 'jane@example.com',
      userAvatarUrl: null,
      role: WorkspaceRole.member,
      joinedAt: DateTime(2024, 1, 5),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
    ),
    WorkspaceMember(
      id: 3,
      workspaceId: tWorkspaceId,
      userId: 3,
      userName: 'Bob Johnson',
      userEmail: 'bob@example.com',
      userAvatarUrl: null,
      role: WorkspaceRole.guest,
      joinedAt: DateTime(2024, 1, 10),
      lastActiveAt: DateTime.now().subtract(const Duration(days: 2)),
      isActive: false,
    ),
  ];

  group('GetWorkspaceMembers', () {
    test('should get list of workspace members from the repository', () async {
      // arrange
      when(
        mockRepository.getWorkspaceMembers(any),
      ).thenAnswer((_) async => Right(tMembers));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tMembers));
      verify(mockRepository.getWorkspaceMembers(tWorkspaceId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when workspace has no members', () async {
      // arrange
      when(
        mockRepository.getWorkspaceMembers(any),
      ).thenAnswer((_) async => const Right(<WorkspaceMember>[]));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right(<WorkspaceMember>[]));
      verify(mockRepository.getWorkspaceMembers(tWorkspaceId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      when(
        mockRepository.getWorkspaceMembers(any),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.getWorkspaceMembers(tWorkspaceId));
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return NotFoundFailure when workspace does not exist',
      () async {
        // arrange
        when(
          mockRepository.getWorkspaceMembers(any),
        ).thenAnswer((_) async => Left(NotFoundFailure('Workspace not found')));

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, Left(NotFoundFailure('Workspace not found')));
        verify(mockRepository.getWorkspaceMembers(tWorkspaceId));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // arrange
        when(
          mockRepository.getWorkspaceMembers(any),
        ).thenAnswer((_) async => Left(NetworkFailure('No internet')));

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, Left(NetworkFailure('No internet')));
        verify(mockRepository.getWorkspaceMembers(tWorkspaceId));
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}



