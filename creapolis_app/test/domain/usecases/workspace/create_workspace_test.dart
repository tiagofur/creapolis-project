import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/domain/repositories/workspace_repository.dart';
import 'package:creapolis_app/domain/usecases/workspace/create_workspace.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_workspace_test.mocks.dart';

@GenerateMocks([WorkspaceRepository])
void main() {
  late CreateWorkspaceUseCase usecase;
  late MockWorkspaceRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkspaceRepository();
    usecase = CreateWorkspaceUseCase(mockRepository);
  });

  final tParams = CreateWorkspaceParams(
    name: 'New Workspace',
    description: 'A new workspace for testing',
    type: WorkspaceType.team,
  );

  final tWorkspace = Workspace(
    id: 1,
    name: 'New Workspace',
    description: 'A new workspace for testing',
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
  );

  group('CreateWorkspace', () {
    test('should create a new workspace through the repository', () async {
      // arrange
      when(
        mockRepository.createWorkspace(
          name: anyNamed('name'),
          description: anyNamed('description'),
          avatarUrl: anyNamed('avatarUrl'),
          type: anyNamed('type'),
          settings: anyNamed('settings'),
        ),
      ).thenAnswer((_) async => Right(tWorkspace));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tWorkspace));
      verify(
        mockRepository.createWorkspace(
          name: tParams.name,
          description: tParams.description,
          avatarUrl: tParams.avatarUrl,
          type: tParams.type,
          settings: tParams.settings,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      when(
        mockRepository.createWorkspace(
          name: anyNamed('name'),
          description: anyNamed('description'),
          avatarUrl: anyNamed('avatarUrl'),
          type: anyNamed('type'),
          settings: anyNamed('settings'),
        ),
      ).thenAnswer(
        (_) async => Left(ServerFailure('Failed to create workspace')),
      );

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Left(ServerFailure('Failed to create workspace')));
      verify(
        mockRepository.createWorkspace(
          name: tParams.name,
          description: tParams.description,
          avatarUrl: tParams.avatarUrl,
          type: tParams.type,
          settings: tParams.settings,
        ),
      );
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return ValidationFailure when workspace name is invalid',
      () async {
        // arrange
        when(
          mockRepository.createWorkspace(
            name: anyNamed('name'),
            description: anyNamed('description'),
            avatarUrl: anyNamed('avatarUrl'),
            type: anyNamed('type'),
            settings: anyNamed('settings'),
          ),
        ).thenAnswer(
          (_) async => Left(ValidationFailure('Workspace name is required')),
        );

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, Left(ValidationFailure('Workspace name is required')));
      },
    );

    test(
      'should return NetworkFailure when there is no internet connection',
      () async {
        // arrange
        when(
          mockRepository.createWorkspace(
            name: anyNamed('name'),
            description: anyNamed('description'),
            avatarUrl: anyNamed('avatarUrl'),
            type: anyNamed('type'),
            settings: anyNamed('settings'),
          ),
        ).thenAnswer(
          (_) async => Left(NetworkFailure('No internet connection')),
        );

        // act
        final result = await usecase(tParams);

        // assert
        expect(result, Left(NetworkFailure('No internet connection')));
      },
    );
  });
}
