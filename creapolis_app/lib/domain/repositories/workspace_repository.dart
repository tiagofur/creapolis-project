import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/workspace.dart';
import '../entities/workspace_invitation.dart';
import '../entities/workspace_member.dart';

/// Repository para gestión de workspaces
abstract class WorkspaceRepository {
  /// Obtener todos los workspaces del usuario
  Future<Either<Failure, List<Workspace>>> getUserWorkspaces();

  /// Obtener un workspace específico
  Future<Either<Failure, Workspace>> getWorkspace(int workspaceId);

  /// Crear un nuevo workspace
  Future<Either<Failure, Workspace>> createWorkspace({
    required String name,
    String? description,
    String? avatarUrl,
    required WorkspaceType type,
    WorkspaceSettings? settings,
  });

  /// Actualizar workspace
  Future<Either<Failure, Workspace>> updateWorkspace({
    required int workspaceId,
    String? name,
    String? description,
    String? avatarUrl,
    WorkspaceType? type,
    WorkspaceSettings? settings,
  });

  /// Eliminar workspace
  Future<Either<Failure, void>> deleteWorkspace(int workspaceId);

  /// Obtener miembros del workspace
  Future<Either<Failure, List<WorkspaceMember>>> getWorkspaceMembers(
    int workspaceId,
  );

  /// Actualizar rol de miembro
  Future<Either<Failure, WorkspaceMember>> updateMemberRole({
    required int workspaceId,
    required int userId,
    required WorkspaceRole role,
  });

  /// Remover miembro del workspace
  Future<Either<Failure, void>> removeMember({
    required int workspaceId,
    required int userId,
  });

  /// Crear invitación
  Future<Either<Failure, WorkspaceInvitation>> createInvitation({
    required int workspaceId,
    required String email,
    required WorkspaceRole role,
  });

  /// Obtener invitaciones pendientes del usuario
  Future<Either<Failure, List<WorkspaceInvitation>>> getPendingInvitations();

  /// Aceptar invitación
  Future<Either<Failure, Workspace>> acceptInvitation(String token);

  /// Rechazar invitación
  Future<Either<Failure, void>> declineInvitation(String token);

  /// Guardar workspace activo en local storage
  Future<Either<Failure, void>> saveActiveWorkspace(int workspaceId);

  /// Obtener workspace activo desde local storage
  Future<Either<Failure, int?>> getActiveWorkspaceId();
}
