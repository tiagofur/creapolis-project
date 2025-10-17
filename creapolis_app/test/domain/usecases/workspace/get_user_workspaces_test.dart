import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/domain/repositories/workspace_repository.dart';
import 'package:creapolis_app/domain/usecases/workspace/get_user_workspaces.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_workspaces_test.mocks.dart';

@GenerateMocks([WorkspaceRepository])
void main() {
  late GetUserWorkspacesUseCase usecase;
  late MockWorkspaceRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkspaceRepository();
    usecase = GetUserWorkspacesUseCase(mockRepository);
  });

  final tWorkspaces = [
    Workspace(
      id: 1,
      name: 'Test Workspace 1',
      description: 'Description 1',
      avatarUrl: null,
      type: WorkspaceType.team,
      ownerId: 1,
      owner: const WorkspaceOwner(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
      ),
      userRole: WorkspaceRole.owner,
      memberCount: 1,
      projectCount: 0,
      settings: WorkspaceSettings.defaults(),
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Workspace(
      id: 2,
      name: 'Test Workspace 2',
      description: 'Description 2',
      avatarUrl: null,
      type: WorkspaceType.personal,
      ownerId: 2,
      owner: const WorkspaceOwner(
        id: 2,
        name: 'Jane Doe',
        email: 'jane@example.com',
      ),
      userRole: WorkspaceRole.member,
      memberCount: 2,
      projectCount: 1,
      settings: WorkspaceSettings.defaults(),
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
  ];

  group('GetUserWorkspaces', () {
    test('should get list of workspaces from the repository', () async {
      // arrange
      when(
        mockRepository.getUserWorkspaces(),
      ).thenAnswer((_) async => Right(tWorkspaces));

      // act
      final result = await usecase();

      // assert
      expect(result, Right(tWorkspaces));
      verify(mockRepository.getUserWorkspaces());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      when(
        mockRepository.getUserWorkspaces(),
      ).thenAnswer((_) async => Left(ServerFailure('Server error')));

      // act
      final result = await usecase();

      // assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockRepository.getUserWorkspaces());
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // arrange
        when(
          mockRepository.getUserWorkspaces(),
        ).thenAnswer((_) async => Left(NetworkFailure('No internet')));

        // act
        final result = await usecase();

        // assert
        expect(result, Left(NetworkFailure('No internet')));
        verify(mockRepository.getUserWorkspaces());
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return empty list when user has no workspaces', () async {
      // arrange
      when(
        mockRepository.getUserWorkspaces(),
      ).thenAnswer((_) async => const Right(<Workspace>[]));

      // act
      final result = await usecase();

      // assert
      expect(result, const Right(<Workspace>[]));
      verify(mockRepository.getUserWorkspaces());
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
