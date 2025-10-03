import 'package:equatable/equatable.dart';

/// Tipos de dependencias entre tareas
enum DependencyType {
  finishToStart,
  startToStart;

  String get displayName {
    switch (this) {
      case DependencyType.finishToStart:
        return 'Fin a Inicio';
      case DependencyType.startToStart:
        return 'Inicio a Inicio';
    }
  }
}

/// Entidad de dominio para Dependencia entre tareas
class Dependency extends Equatable {
  final int id;
  final int predecessorId;
  final int successorId;
  final DependencyType type;

  const Dependency({
    required this.id,
    required this.predecessorId,
    required this.successorId,
    required this.type,
  });

  /// Verifica si es dependencia de tipo Fin-Inicio
  bool get isFinishToStart => type == DependencyType.finishToStart;

  /// Verifica si es dependencia de tipo Inicio-Inicio
  bool get isStartToStart => type == DependencyType.startToStart;

  @override
  List<Object?> get props => [id, predecessorId, successorId, type];
}
