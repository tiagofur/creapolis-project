import 'package:bloc_test/bloc_test.dart';
import 'package:creapolis_app/core/network/exceptions/api_exceptions.dart';
import 'package:creapolis_app/features/workspace/data/datasources/workspace_remote_datasource.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_member_model.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/features/workspace/presentation/bloc/workspace_bloc.dart';
import 'package:creapolis_app/features/workspace/presentation/bloc/workspace_event.dart';
import 'package:creapolis_app/features/workspace/presentation/bloc/workspace_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock class para WorkspaceRemoteDataSource
class MockWorkspaceRemoteDataSource extends Mock
    implements WorkspaceRemoteDataSource {}

void main() {
  late WorkspaceBloc bloc;
  late MockWorkspaceRemoteDataSource mockDataSource;

  setUpAll(() {
    // Register fallback values para mocktail
    registerFallbackValue(WorkspaceType.personal);
    registerFallbackValue(WorkspaceRole.member);
    registerFallbackValue(WorkspaceSettings.defaults());
  });

  setUp(() {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    mockDataSource = MockWorkspaceRemoteDataSource();
    bloc = WorkspaceBloc(mockDataSource);
  });

  tearDown(() {
    bloc.close();
  });

  // Test fixtures
  const tOwner = WorkspaceOwner(
    id: 1,
    name: 'John Doe',
    email: 'john@example.com',
  );

  final tSettings = WorkspaceSettings.defaults();

  final tWorkspace1 = Workspace(
    id: 1,
    name: 'Test Workspace 1',
    description: 'Test Description 1',
    type: WorkspaceType.team,
    ownerId: 1,
    owner: tOwner,
    userRole: WorkspaceRole.owner,
    memberCount: 5,
    projectCount: 3,
    settings: tSettings,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final tWorkspace2 = Workspace(
    id: 2,
    name: 'Test Workspace 2',
    description: 'Test Description 2',
    type: WorkspaceType.personal,
    ownerId: 1,
    owner: tOwner,
    userRole: WorkspaceRole.owner,
    memberCount: 1,
    projectCount: 1,
    settings: tSettings,
    createdAt: DateTime(2025, 1, 2),
    updatedAt: DateTime(2025, 1, 2),
  );

  final tWorkspaces = [tWorkspace1, tWorkspace2];

  final tInvitation = WorkspaceInvitation(
    id: 1,
    token: 'test-token-123',
    workspaceId: 3,
    workspaceName: 'Invited Workspace',
    workspaceType: WorkspaceType.team,
    inviterName: 'Jane Smith',
    inviterEmail: 'jane@example.com',
    inviteeEmail: 'test@example.com',
    role: WorkspaceRole.member,
    status: InvitationStatus.pending,
    createdAt: DateTime(2025, 1, 3),
    expiresAt: DateTime(2025, 2, 3),
  );

  group('WorkspaceBloc', () {
    test('initial state should be WorkspaceInitial', () {
      expect(bloc.state, equals(const WorkspaceInitial()));
    });

    group('LoadWorkspaces', () {
      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceLoaded] when workspaces are loaded successfully',
        build: () {
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => tWorkspaces);
          when(
            () => mockDataSource.getPendingInvitations(),
          ).thenAnswer((_) async => [tInvitation]);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaces()),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceLoaded>()
              .having((s) => s.workspaces, 'workspaces', tWorkspaces)
              .having((s) => s.isFromCache, 'isFromCache', false)
              .having((s) => s.lastSync, 'lastSync', isNotNull)
              .having((s) => s.pendingInvitations, 'pendingInvitations', [
                tInvitation,
              ]),
        ],
        verify: (_) {
          verify(() => mockDataSource.getWorkspaces()).called(1);
          verify(() => mockDataSource.getPendingInvitations()).called(1);
        },
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceLoaded] with empty invitations when getPendingInvitations fails',
        build: () {
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => tWorkspaces);
          when(
            () => mockDataSource.getPendingInvitations(),
          ).thenThrow(ServerException('Failed', statusCode: 500));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaces()),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceLoaded>()
              .having((s) => s.workspaces, 'workspaces', tWorkspaces)
              .having((s) => s.pendingInvitations, 'pendingInvitations', []),
        ],
        verify: (_) {
          verify(() => mockDataSource.getWorkspaces()).called(1);
          verify(() => mockDataSource.getPendingInvitations()).called(1);
        },
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceError] when AuthException is thrown',
        build: () {
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenThrow(UnauthorizedException('Token expired', statusCode: 401));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaces()),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            contains('No autorizado'),
          ),
        ],
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceError] when NetworkException is thrown',
        build: () {
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenThrow(NetworkException('No internet', statusCode: 0));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaces()),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            contains('Sin conexión'),
          ),
        ],
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceError] when generic exception is thrown',
        build: () {
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenThrow(Exception('Unknown error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWorkspaces()),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            contains('Error inesperado'),
          ),
        ],
      );
    });

    group('LoadWorkspaceById', () {
      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceLoaded] when workspace is found',
        build: () {
          when(
            () => mockDataSource.getWorkspaceById(1),
          ).thenAnswer((_) async => tWorkspace1);
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(const LoadWorkspaceById(1)),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceLoaded>().having(
            (s) => s.workspaces.any((w) => w.id == 1),
            'contains workspace with id 1',
            isTrue,
          ),
        ],
        verify: (_) {
          verify(() => mockDataSource.getWorkspaceById(1)).called(1);
        },
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceError] when NotFoundException is thrown',
        build: () {
          when(
            () => mockDataSource.getWorkspaceById(999),
          ).thenThrow(NotFoundException('Not found', statusCode: 404));
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(const LoadWorkspaceById(999)),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            'Not found',
          ),
        ],
      );
    });

    group('CreateWorkspace', () {
      const tCreateParams = CreateWorkspace(
        name: 'New Workspace',
        description: 'A new workspace',
        type: WorkspaceType.team,
      );

      final tCreatedWorkspace = Workspace(
        id: 3,
        name: 'New Workspace',
        description: 'A new workspace',
        type: WorkspaceType.team,
        ownerId: 1,
        owner: tOwner,
        userRole: WorkspaceRole.owner,
        memberCount: 1,
        projectCount: 0,
        settings: tSettings,
        createdAt: DateTime(2025, 1, 3),
        updatedAt: DateTime(2025, 1, 3),
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceOperationInProgress, WorkspaceOperationSuccess] when workspace is created',
        build: () {
          when(
            () => mockDataSource.createWorkspace(
              name: any(named: 'name'),
              description: any(named: 'description'),
              type: any(named: 'type'),
              avatarUrl: any(named: 'avatarUrl'),
              settings: any(named: 'settings'),
            ),
          ).thenAnswer((_) async => tCreatedWorkspace);
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(tCreateParams),
        expect: () => [
          isA<WorkspaceOperationInProgress>().having(
            (s) => s.operation,
            'operation',
            'creating',
          ),
          isA<WorkspaceOperationSuccess>()
              .having((s) => s.message, 'message', contains('creado'))
              .having(
                (s) => s.updatedWorkspace,
                'updatedWorkspace',
                tCreatedWorkspace,
              ),
        ],
        verify: (_) {
          verify(
            () => mockDataSource.createWorkspace(
              name: 'New Workspace',
              description: 'A new workspace',
              type: WorkspaceType.team,
              avatarUrl: null,
              settings: null,
            ),
          ).called(1);
        },
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceOperationInProgress, WorkspaceError] when ValidationException is thrown',
        build: () {
          when(
            () => mockDataSource.createWorkspace(
              name: any(named: 'name'),
              description: any(named: 'description'),
              type: any(named: 'type'),
              avatarUrl: any(named: 'avatarUrl'),
              settings: any(named: 'settings'),
            ),
          ).thenThrow(ValidationException('Name required', statusCode: 400));
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(tCreateParams),
        expect: () => [
          isA<WorkspaceOperationInProgress>().having(
            (s) => s.operation,
            'operation',
            'creating',
          ),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            'Name required',
          ),
        ],
      );
    });

    group('UpdateWorkspace', () {
      final tUpdateParams = UpdateWorkspace(
        workspaceId: 1,
        name: 'Updated Name',
        description: 'Updated Description',
      );

      final tUpdatedWorkspace = Workspace(
        id: 1,
        name: 'Updated Name',
        description: 'Updated Description',
        type: WorkspaceType.team,
        ownerId: 1,
        owner: tOwner,
        userRole: WorkspaceRole.owner,
        memberCount: 5,
        projectCount: 3,
        settings: tSettings,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 4),
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceOperationInProgress, WorkspaceOperationSuccess] when workspace is updated',
        build: () {
          when(
            () => mockDataSource.updateWorkspace(
              id: any(named: 'id'),
              name: any(named: 'name'),
              description: any(named: 'description'),
              avatarUrl: any(named: 'avatarUrl'),
              type: any(named: 'type'),
              settings: any(named: 'settings'),
            ),
          ).thenAnswer((_) async => tUpdatedWorkspace);
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(tUpdateParams),
        expect: () => [
          isA<WorkspaceOperationInProgress>().having(
            (s) => s.operation,
            'operation',
            'updating',
          ),
          isA<WorkspaceOperationSuccess>()
              .having((s) => s.message, 'message', contains('actualizado'))
              .having(
                (s) => s.updatedWorkspace,
                'updatedWorkspace',
                tUpdatedWorkspace,
              ),
        ],
        verify: (_) {
          verify(
            () => mockDataSource.updateWorkspace(
              id: 1,
              name: 'Updated Name',
              description: 'Updated Description',
              avatarUrl: null,
              type: null,
              settings: null,
            ),
          ).called(1);
        },
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceOperationInProgress, WorkspaceError] when NotFoundException is thrown',
        build: () {
          when(
            () => mockDataSource.updateWorkspace(
              id: any(named: 'id'),
              name: any(named: 'name'),
              description: any(named: 'description'),
              avatarUrl: any(named: 'avatarUrl'),
              type: any(named: 'type'),
              settings: any(named: 'settings'),
            ),
          ).thenThrow(NotFoundException('Not found', statusCode: 404));
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(tUpdateParams),
        expect: () => [
          isA<WorkspaceOperationInProgress>().having(
            (s) => s.operation,
            'operation',
            'updating',
          ),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            'Not found',
          ),
        ],
      );
    });

    group('DeleteWorkspace', () {
      const tDeleteParams = DeleteWorkspace(1);

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceOperationInProgress, WorkspaceOperationSuccess] when workspace is deleted',
        build: () {
          when(
            () => mockDataSource.deleteWorkspace(any()),
          ).thenAnswer((_) async => Future.value());
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(tDeleteParams),
        expect: () => [
          isA<WorkspaceOperationInProgress>().having(
            (s) => s.operation,
            'operation',
            'deleting',
          ),
          isA<WorkspaceOperationSuccess>().having(
            (s) => s.message,
            'message',
            contains('eliminado'),
          ),
        ],
        verify: (_) {
          verify(() => mockDataSource.deleteWorkspace(1)).called(1);
        },
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceOperationInProgress, WorkspaceError] when ForbiddenException is thrown',
        build: () {
          when(
            () => mockDataSource.deleteWorkspace(any()),
          ).thenThrow(ForbiddenException('Not allowed', statusCode: 403));
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(tDeleteParams),
        expect: () => [
          isA<WorkspaceOperationInProgress>().having(
            (s) => s.operation,
            'operation',
            'deleting',
          ),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            contains('Sin permisos'),
          ),
        ],
      );
    });

    group('SelectWorkspace', () {
      const tSelectParams = SelectWorkspace(1);

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits WorkspaceLoaded with selected workspace when it exists',
        build: () {
          // Necesitamos mockear getWorkspaces para que LoadWorkspaces funcione
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => tWorkspaces);
          when(
            () => mockDataSource.getPendingInvitations(),
          ).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) async {
          // Primero cargamos workspaces para poblar _workspaces interno
          bloc.add(const LoadWorkspaces());
          // Esperamos a que se cargue
          await Future.delayed(const Duration(milliseconds: 100));
          // Luego seleccionamos
          bloc.add(tSelectParams);
        },
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceLoaded>(), // Resultado de LoadWorkspaces
          isA<WorkspaceLoaded>() // Resultado de SelectWorkspace
              .having((s) => s.activeWorkspace, 'activeWorkspace', tWorkspace1)
              .having(
                (s) => s.workspaces.length,
                'workspaces length',
                tWorkspaces.length,
              ),
        ],
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits WorkspaceError when workspace is not found',
        build: () {
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => tWorkspaces);
          when(
            () => mockDataSource.getPendingInvitations(),
          ).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) async {
          // Primero cargamos workspaces
          bloc.add(const LoadWorkspaces());
          await Future.delayed(const Duration(milliseconds: 100));
          // Luego intentamos seleccionar uno que no existe
          bloc.add(const SelectWorkspace(999));
        },
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceLoaded>(), // Resultado de LoadWorkspaces
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            contains('Error seleccionando workspace'),
          ),
        ],
      );
    });

    group('AcceptInvitation', () {
      const tAcceptParams = AcceptInvitation('test-token-123');

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, InvitationHandled] when invitation accepted',
        build: () {
          when(
            () => mockDataSource.acceptInvitation(any()),
          ).thenAnswer((_) async => {'workspaceName': 'Test Workspace 1'});
          // Mock LoadWorkspaces que se llama automáticamente después
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => tWorkspaces);
          when(
            () => mockDataSource.getPendingInvitations(),
          ).thenAnswer((_) async => []);
          return bloc;
        },
        seed: () => WorkspaceLoaded(
          workspaces: tWorkspaces,
          pendingInvitations: [tInvitation],
        ),
        act: (bloc) => bloc.add(tAcceptParams),
        expect: () => [
          const WorkspaceLoading(),
          isA<InvitationHandled>()
              .having((s) => s.accepted, 'accepted', true)
              .having(
                (s) => s.message,
                'message',
                contains('Test Workspace 1'),
              ),
          const WorkspaceLoading(), // LoadWorkspaces llamado automáticamente
          isA<WorkspaceLoaded>(), // Resultado de LoadWorkspaces
        ],
        verify: (_) {
          verify(
            () => mockDataSource.acceptInvitation('test-token-123'),
          ).called(1);
        },
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceError] when NotFoundException thrown',
        build: () {
          when(
            () => mockDataSource.acceptInvitation(any()),
          ).thenThrow(NotFoundException('Not found', statusCode: 404));
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(tAcceptParams),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            'Not found',
          ),
        ],
      );
    });

    group('DeclineInvitation', () {
      const tDeclineParams = DeclineInvitation('test-token-123');

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, InvitationHandled] when invitation declined',
        build: () {
          when(
            () => mockDataSource.declineInvitation(any()),
          ).thenAnswer((_) async => Future.value());
          return bloc;
        },
        seed: () => WorkspaceLoaded(
          workspaces: tWorkspaces,
          pendingInvitations: [tInvitation],
        ),
        act: (bloc) => bloc.add(tDeclineParams),
        expect: () => [
          const WorkspaceLoading(),
          isA<InvitationHandled>()
              .having((s) => s.accepted, 'accepted', false)
              .having((s) => s.message, 'message', 'Invitación rechazada'),
        ],
        verify: (_) {
          verify(
            () => mockDataSource.declineInvitation('test-token-123'),
          ).called(1);
        },
      );

      blocTest<WorkspaceBloc, WorkspaceState>(
        'emits [WorkspaceLoading, WorkspaceError] when ServerException thrown',
        build: () {
          when(
            () => mockDataSource.declineInvitation(any()),
          ).thenThrow(ServerException('Server error', statusCode: 500));
          return bloc;
        },
        seed: () => WorkspaceLoaded(workspaces: tWorkspaces),
        act: (bloc) => bloc.add(tDeclineParams),
        expect: () => [
          const WorkspaceLoading(),
          isA<WorkspaceError>().having(
            (s) => s.message,
            'message',
            'Server error',
          ),
        ],
      );
    });
  });
}
