import 'package:equatable/equatable.dart';

import '../../../domain/entities/workspace_member.dart';

/// Estados del BLoC de miembros de workspace
abstract class WorkspaceMemberState extends Equatable {
  const WorkspaceMemberState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class WorkspaceMemberInitial extends WorkspaceMemberState {
  const WorkspaceMemberInitial();
}

/// Estado de carga
class WorkspaceMemberLoading extends WorkspaceMemberState {
  const WorkspaceMemberLoading();
}

/// Estado de miembros cargados
class WorkspaceMembersLoaded extends WorkspaceMemberState {
  final List<WorkspaceMember> members;
  final int workspaceId;

  const WorkspaceMembersLoaded({
    required this.members,
    required this.workspaceId,
  });

  @override
  List<Object?> get props => [members, workspaceId];

  /// Obtener miembros por rol
  List<WorkspaceMember> getMembersByRole(dynamic role) {
    return members.where((m) => m.role == role).toList();
  }

  /// Obtener cantidad de miembros por rol
  int getCountByRole(dynamic role) {
    return members.where((m) => m.role == role).length;
  }

  /// Copiar con nuevos valores
  WorkspaceMembersLoaded copyWith({
    List<WorkspaceMember>? members,
    int? workspaceId,
  }) {
    return WorkspaceMembersLoaded(
      members: members ?? this.members,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }
}

/// Estado de rol actualizado exitosamente
class MemberRoleUpdated extends WorkspaceMemberState {
  final WorkspaceMember member;

  const MemberRoleUpdated(this.member);

  @override
  List<Object?> get props => [member];
}

/// Estado de miembro removido exitosamente
class MemberRemoved extends WorkspaceMemberState {
  final int userId;
  final int workspaceId;

  const MemberRemoved({required this.userId, required this.workspaceId});

  @override
  List<Object?> get props => [userId, workspaceId];
}

/// Estado de error
class WorkspaceMemberError extends WorkspaceMemberState {
  final String message;

  const WorkspaceMemberError(this.message);

  @override
  List<Object?> get props => [message];
}



