import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:creapolis_app/features/workspace/data/datasources/workspace_remote_datasource.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_model.dart';
import 'package:creapolis_app/features/workspace/data/models/workspace_member_model.dart';
import 'package:creapolis_app/features/workspace/presentation/bloc/workspace_bloc.dart';
import 'package:creapolis_app/features/workspace/presentation/bloc/workspace_event.dart';
import 'package:creapolis_app/features/workspace/presentation/bloc/workspace_state.dart';

/// Mock del WorkspaceRemoteDataSource
class MockWorkspaceRemoteDataSource extends Mock
    implements WorkspaceRemoteDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Workspace Integration Tests', () {
    late WorkspaceBloc bloc;
    late MockWorkspaceRemoteDataSource mockDataSource;

    // Datos de prueba
    final tOwner = WorkspaceOwner(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      avatarUrl: null,
    );

    final tSettings = WorkspaceSettings.defaults();

    final tWorkspace1 = Workspace(
      id: 1,
      name: 'Test Workspace',
      description: 'Test Description',
      avatarUrl: null,
      type: WorkspaceType.team,
      ownerId: 1,
      owner: tOwner,
      userRole: WorkspaceRole.owner,
      memberCount: 1,
      projectCount: 0,
      settings: tSettings,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    final tWorkspace1Updated = Workspace(
      id: 1,
      name: 'Updated Workspace',
      description: 'Updated Description',
      avatarUrl: null,
      type: WorkspaceType.team,
      ownerId: 1,
      owner: tOwner,
      userRole: WorkspaceRole.owner,
      memberCount: 1,
      projectCount: 0,
      settings: tSettings,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 2),
    );

    final tInvitation = WorkspaceInvitation(
      id: 1,
      workspaceId: 2,
      workspaceName: 'Invited Workspace',
      workspaceAvatarUrl: null,
      workspaceType: WorkspaceType.team,
      inviterName: 'Jane Doe',
      inviterEmail: 'jane@example.com',
      inviterAvatarUrl: null,
      inviteeEmail: 'john@example.com',
      role: WorkspaceRole.member,
      token: 'test-token-abc',
      status: InvitationStatus.pending,
      createdAt: DateTime(2025, 1, 10),
      expiresAt: DateTime(2025, 2, 10),
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockDataSource = MockWorkspaceRemoteDataSource();
      bloc = WorkspaceBloc(mockDataSource);

      // Register fallback values for mocktail
      registerFallbackValue(WorkspaceType.personal);
      registerFallbackValue(WorkspaceRole.member);
      registerFallbackValue(tSettings);
    });

    tearDown(() {
      bloc.close();
    });

    group('Flujo: Crear → Editar → Eliminar Workspace', () {
      test(
        'debe crear, actualizar y eliminar un workspace exitosamente con persistencia',
        () async {
          // Arrange - Mock de todas las operaciones
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => []);
          when(
            () => mockDataSource.getPendingInvitations(),
          ).thenAnswer((_) async => []);
          when(
            () => mockDataSource.createWorkspace(
              name: any(named: 'name'),
              description: any(named: 'description'),
              type: any(named: 'type'),
              avatarUrl: any(named: 'avatarUrl'),
              settings: any(named: 'settings'),
            ),
          ).thenAnswer((_) async => tWorkspace1);
          when(
            () => mockDataSource.updateWorkspace(
              id: any(named: 'id'),
              name: any(named: 'name'),
              description: any(named: 'description'),
              avatarUrl: any(named: 'avatarUrl'),
              type: any(named: 'type'),
              settings: any(named: 'settings'),
            ),
          ).thenAnswer((_) async => tWorkspace1Updated);
          when(
            () => mockDataSource.deleteWorkspace(any()),
          ).thenAnswer((_) async => Future.value());

          // Act & Assert - Paso 1: Cargar workspaces iniciales (vacío)
          bloc.add(const LoadWorkspaces());
          await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<WorkspaceLoading>(),
              isA<WorkspaceLoaded>().having(
                (s) => s.workspaces.isEmpty,
                'workspaces vacío',
                true,
              ),
            ]),
          );

          // Act & Assert - Paso 2: Crear workspace
          bloc.add(
            const CreateWorkspace(
              name: 'Test Workspace',
              description: 'Test Description',
              type: WorkspaceType.team,
            ),
          );
          await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<WorkspaceOperationInProgress>().having(
                (s) => s.operation,
                'operation',
                'creating',
              ),
              isA<WorkspaceOperationSuccess>()
                  .having((s) => s.message, 'message', contains('creado'))
                  .having((s) => s.updatedWorkspace?.id, 'workspace creado', 1),
            ]),
          );

          // Verificar que el workspace está en la lista interna del BLoC
          expect(bloc.workspaces.length, 1);
          expect(bloc.workspaces.first.name, 'Test Workspace');

          // Act & Assert - Paso 3: Actualizar workspace
          bloc.add(
            const UpdateWorkspace(
              workspaceId: 1,
              name: 'Updated Workspace',
              description: 'Updated Description',
            ),
          );
          await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<WorkspaceOperationInProgress>().having(
                (s) => s.operation,
                'operation',
                'updating',
              ),
              isA<WorkspaceOperationSuccess>()
                  .having((s) => s.message, 'message', contains('actualizado'))
                  .having(
                    (s) => s.updatedWorkspace?.name,
                    'workspace actualizado',
                    'Updated Workspace',
                  ),
            ]),
          );

          // Verificar que el workspace se actualizó en la lista
          expect(bloc.workspaces.length, 1);
          expect(bloc.workspaces.first.name, 'Updated Workspace');
          expect(bloc.workspaces.first.description, 'Updated Description');

          // Act & Assert - Paso 4: Eliminar workspace
          bloc.add(const DeleteWorkspace(1));
          await expectLater(
            bloc.stream,
            emitsInOrder([
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
            ]),
          );

          // Verificar que el workspace fue eliminado
          expect(bloc.workspaces.isEmpty, true);
          expect(bloc.activeWorkspace, null);

          // Verify - Verificar todas las llamadas
          verify(() => mockDataSource.getWorkspaces()).called(1);
          verify(
            () => mockDataSource.createWorkspace(
              name: 'Test Workspace',
              description: 'Test Description',
              type: WorkspaceType.team,
              avatarUrl: null,
              settings: null,
            ),
          ).called(1);
          verify(
            () => mockDataSource.updateWorkspace(
              id: 1,
              name: 'Updated Workspace',
              description: 'Updated Description',
              avatarUrl: null,
              type: null,
              settings: null,
            ),
          ).called(1);
          verify(() => mockDataSource.deleteWorkspace(1)).called(1);
        },
      );
    });

    group('Flujo: Aceptar Invitación', () {
      test(
        'debe cargar invitaciones, aceptar una y recargar workspaces',
        () async {
          // Arrange
          final tWorkspace2 = Workspace(
            id: 2,
            name: 'Invited Workspace',
            description: 'Workspace from invitation',
            avatarUrl: null,
            type: WorkspaceType.team,
            ownerId: 2,
            owner: WorkspaceOwner(
              id: 2,
              name: 'Jane Doe',
              email: 'jane@example.com',
              avatarUrl: null,
            ),
            userRole: WorkspaceRole.member,
            memberCount: 2,
            projectCount: 1,
            settings: tSettings,
            createdAt: DateTime(2025, 1, 10),
            updatedAt: DateTime(2025, 1, 10),
          );

          // Arrange - Configurar secuencia de respuestas
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => [tWorkspace1]);
          when(
            () => mockDataSource.getPendingInvitations(),
          ).thenAnswer((_) async => [tInvitation]);
          when(
            () => mockDataSource.acceptInvitation(any()),
          ).thenAnswer((_) async => {'workspaceName': 'Invited Workspace'});

          // Act & Assert - Paso 1: Cargar workspaces con invitaciones
          bloc.add(const LoadWorkspaces());
          await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<WorkspaceLoading>(),
              isA<WorkspaceLoaded>()
                  .having((s) => s.workspaces.length, 'workspaces', 1)
                  .having(
                    (s) => s.pendingInvitations?.length,
                    'invitaciones',
                    1,
                  ),
            ]),
          );

          // Preparar el mock para la segunda llamada después de aceptar
          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => [tWorkspace1, tWorkspace2]);

          // Act & Assert - Paso 2: Aceptar invitación
          bloc.add(const AcceptInvitation('test-token-abc'));
          await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<WorkspaceLoading>(),
              isA<InvitationHandled>()
                  .having((s) => s.accepted, 'accepted', true)
                  .having(
                    (s) => s.message,
                    'message',
                    contains('Invited Workspace'),
                  ),
              // El BLoC llama automáticamente a LoadWorkspaces
              isA<WorkspaceLoading>(),
              isA<WorkspaceLoaded>().having(
                (s) => s.workspaces.length,
                'workspaces después de aceptar',
                2,
              ),
            ]),
          );

          // Verificar que ahora hay 2 workspaces
          expect(bloc.workspaces.length, 2);
          expect(
            bloc.workspaces.any((w) => w.name == 'Invited Workspace'),
            true,
          );

          // Verify
          verify(
            () => mockDataSource.acceptInvitation('test-token-abc'),
          ).called(1);
          verify(() => mockDataSource.getWorkspaces()).called(greaterThan(1));
        },
      );
    });

    group('Flujo: Cambiar Workspace Activo con Persistencia', () {
      test(
        'debe cambiar workspace activo y persistir en SharedPreferences',
        () async {
          // Arrange
          final tWorkspace2 = Workspace(
            id: 2,
            name: 'Second Workspace',
            description: 'Another workspace',
            avatarUrl: null,
            type: WorkspaceType.personal,
            ownerId: 1,
            owner: tOwner,
            userRole: WorkspaceRole.owner,
            memberCount: 1,
            projectCount: 0,
            settings: tSettings,
            createdAt: DateTime(2025, 1, 5),
            updatedAt: DateTime(2025, 1, 5),
          );

          when(
            () => mockDataSource.getWorkspaces(),
          ).thenAnswer((_) async => [tWorkspace1, tWorkspace2]);
          when(
            () => mockDataSource.getPendingInvitations(),
          ).thenAnswer((_) async => []);

          // Act & Assert - Paso 1: Cargar workspaces
          bloc.add(const LoadWorkspaces());
          await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<WorkspaceLoading>(),
              isA<WorkspaceLoaded>()
                  .having((s) => s.workspaces.length, 'workspaces', 2)
                  .having(
                    (s) => s.activeWorkspace?.id,
                    'active workspace (primero por defecto)',
                    1,
                  ),
            ]),
          );

          // Verificar que el workspace activo fue persistido
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getInt('active_workspace_id'), 1);

          // Act & Assert - Paso 2: Cambiar a segundo workspace
          bloc.add(const SelectWorkspace(2));
          await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<WorkspaceLoaded>()
                  .having((s) => s.activeWorkspace?.id, 'nuevo activo', 2)
                  .having(
                    (s) => s.activeWorkspace?.name,
                    'nombre',
                    'Second Workspace',
                  ),
            ]),
          );

          // Verificar que el nuevo workspace activo fue persistido
          expect(prefs.getInt('active_workspace_id'), 2);
          expect(bloc.activeWorkspace?.id, 2);

          // Act & Assert - Paso 3: Volver al primer workspace
          bloc.add(const SelectWorkspace(1));
          await expectLater(
            bloc.stream,
            emitsInOrder([
              isA<WorkspaceLoaded>()
                  .having((s) => s.activeWorkspace?.id, 'volver al primero', 1)
                  .having(
                    (s) => s.activeWorkspace?.name,
                    'nombre',
                    'Test Workspace',
                  ),
            ]),
          );

          // Verificar persistencia final
          expect(prefs.getInt('active_workspace_id'), 1);
          expect(bloc.activeWorkspace?.id, 1);
        },
      );
    });

    group('Flujo: Workspace Activo se Elimina', () {
      test('debe limpiar workspace activo cuando se elimina', () async {
        // Arrange
        final tWorkspace2 = Workspace(
          id: 2,
          name: 'Second Workspace',
          description: 'Another workspace',
          avatarUrl: null,
          type: WorkspaceType.personal,
          ownerId: 1,
          owner: tOwner,
          userRole: WorkspaceRole.owner,
          memberCount: 1,
          projectCount: 0,
          settings: tSettings,
          createdAt: DateTime(2025, 1, 5),
          updatedAt: DateTime(2025, 1, 5),
        );

        when(
          () => mockDataSource.getWorkspaces(),
        ).thenAnswer((_) async => [tWorkspace1, tWorkspace2]);
        when(
          () => mockDataSource.getPendingInvitations(),
        ).thenAnswer((_) async => []);
        when(
          () => mockDataSource.deleteWorkspace(1),
        ).thenAnswer((_) async => Future.value());

        // Act & Assert - Paso 1: Cargar workspaces y seleccionar el primero
        bloc.add(const LoadWorkspaces());
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<WorkspaceLoading>(),
            isA<WorkspaceLoaded>().having(
              (s) => s.activeWorkspace?.id,
              'activo',
              1,
            ),
          ]),
        );

        bloc.add(const SelectWorkspace(1));
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<WorkspaceLoaded>().having(
              (s) => s.activeWorkspace?.id,
              'confirmado activo',
              1,
            ),
          ]),
        );

        // Act & Assert - Paso 2: Eliminar workspace activo
        bloc.add(const DeleteWorkspace(1));
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<WorkspaceOperationInProgress>(),
            isA<WorkspaceOperationSuccess>(),
          ]),
        );

        // Verificar que el workspace activo fue limpiado
        expect(bloc.activeWorkspace, null);
        expect(bloc.workspaces.length, 1);
        expect(bloc.workspaces.first.id, 2);

        // Verificar que SharedPreferences fue limpiado
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('active_workspace_id'), null);
      });
    });
  });
}
