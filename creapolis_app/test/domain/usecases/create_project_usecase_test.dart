import 'package:creapolis_app/core/errors/failures.dart';
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:creapolis_app/domain/repositories/project_repository.dart';
import 'package:creapolis_app/domain/usecases/create_project_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late CreateProjectUseCase usecase;
  late MockProjectRepository mockRepository;

  setUp(() {
    registerFallbackValue(ProjectStatus.planned);
    mockRepository = MockProjectRepository();
    usecase = CreateProjectUseCase(mockRepository);
  });

  final tStartDate = DateTime(2025, 1, 1);
  final tEndDate = DateTime(2025, 12, 31);

  final tParams = CreateProjectParams(
    name: 'New Project',
    description: 'Project Description',
    startDate: tStartDate,
    endDate: tEndDate,
    status: ProjectStatus.planned,
    managerId: 1,
    workspaceId: 1,
  );

  final tProject = Project(
    id: 1,
    name: 'New Project',
    description: 'Project Description',
    startDate: tStartDate,
    endDate: tEndDate,
    status: ProjectStatus.planned,
    managerId: 1,
    managerName: 'Manager',
    workspaceId: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CreateProjectUseCase', () {
    test('should create a project when inputs are valid', () async {
      // arrange
      when(
        () => mockRepository.createProject(
          name: any(named: 'name'),
          description: any(named: 'description'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          status: any(named: 'status'),
          managerId: any(named: 'managerId'),
          workspaceId: any(named: 'workspaceId'),
        ),
      ).thenAnswer((_) async => Right(tProject));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tProject));
      verify(
        () => mockRepository.createProject(
          name: tParams.name,
          description: tParams.description,
          startDate: tParams.startDate,
          endDate: tParams.endDate,
          status: tParams.status,
          managerId: tParams.managerId,
          workspaceId: tParams.workspaceId,
        ),
      ).called(1);
    });

    test('should return ValidationFailure when name is empty', () async {
      // arrange
      final invalidParams = CreateProjectParams(
        name: '',
        description: 'Description',
        startDate: tStartDate,
        endDate: tEndDate,
        status: ProjectStatus.planned,
        workspaceId: 1,
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(
        result,
        const Left(ValidationFailure('El nombre del proyecto es requerido')),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when name is too short', () async {
      // arrange
      final invalidParams = CreateProjectParams(
        name: 'AB',
        description: 'Description',
        startDate: tStartDate,
        endDate: tEndDate,
        status: ProjectStatus.planned,
        workspaceId: 1,
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(
        result,
        const Left(
          ValidationFailure('El nombre debe tener al menos 3 caracteres'),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test('should return ValidationFailure when description is empty', () async {
      // arrange
      final invalidParams = CreateProjectParams(
        name: 'Project Name',
        description: '',
        startDate: tStartDate,
        endDate: tEndDate,
        status: ProjectStatus.planned,
        workspaceId: 1,
      );

      // act
      final result = await usecase(invalidParams);

      // assert
      expect(
        result,
        const Left(
          ValidationFailure('La descripción del proyecto es requerida'),
        ),
      );
      verifyZeroInteractions(mockRepository);
    });

    test(
      'should return ValidationFailure when end date is before start date',
      () async {
        // arrange
        final invalidParams = CreateProjectParams(
          name: 'Project Name',
          description: 'Description',
          startDate: tEndDate,
          endDate: tStartDate, // End date before start date
          status: ProjectStatus.planned,
          workspaceId: 1,
        );

        // act
        final result = await usecase(invalidParams);

        // assert
        expect(
          result,
          const Left(
            ValidationFailure(
              'La fecha de fin debe ser posterior a la fecha de inicio',
            ),
          ),
        );
        verifyZeroInteractions(mockRepository);
      },
    );
  });
}
