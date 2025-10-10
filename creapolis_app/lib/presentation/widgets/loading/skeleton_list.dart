import 'package:flutter/material.dart';

import 'skeleton_card.dart';

/// Widget que muestra una lista de skeleton cards
///
/// Útil para mostrar mientras se cargan listas de contenido
class SkeletonList extends StatelessWidget {
  /// Número de items a mostrar
  final int itemCount;

  /// Tipo de skeleton a usar
  final SkeletonType type;

  /// Padding entre items
  final EdgeInsets? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    required this.type,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _buildSkeletonCard(type);
      },
    );
  }

  Widget _buildSkeletonCard(SkeletonType type) {
    switch (type) {
      case SkeletonType.workspace:
        return const WorkspaceSkeletonCard();
      case SkeletonType.project:
        return const ProjectSkeletonCard();
      case SkeletonType.task:
        return const TaskSkeletonCard();
      case SkeletonType.member:
        return const MemberSkeletonCard();
    }
  }
}

/// Widget que muestra un grid de skeleton cards
///
/// Útil para mostrar mientras se cargan grids de contenido (ej: proyectos)
class SkeletonGrid extends StatelessWidget {
  /// Número de items a mostrar
  final int itemCount;

  /// Tipo de skeleton a usar
  final SkeletonType type;

  /// Número de columnas en el grid
  final int crossAxisCount;

  /// Aspect ratio de los cards
  final double childAspectRatio;

  /// Padding del grid
  final EdgeInsets? padding;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    required this.type,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _buildSkeletonCard(type);
      },
    );
  }

  Widget _buildSkeletonCard(SkeletonType type) {
    switch (type) {
      case SkeletonType.workspace:
        return const WorkspaceSkeletonCard();
      case SkeletonType.project:
        return const ProjectSkeletonCard();
      case SkeletonType.task:
        return const TaskSkeletonCard();
      case SkeletonType.member:
        return const MemberSkeletonCard();
    }
  }
}

/// Tipos de skeleton disponibles
enum SkeletonType { workspace, project, task, member }
