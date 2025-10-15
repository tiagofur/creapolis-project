import 'package:flutter/material.dart';

import 'shimmer_widget.dart';

/// Skeleton card para workspace
class WorkspaceSkeletonCard extends StatelessWidget {
  const WorkspaceSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  const ShimmerCircle(size: 48),
                  const SizedBox(width: 12),
                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 16,
                        ),
                        const SizedBox(height: 8),
                        ShimmerLine(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Chips
              Row(
                children: [
                  ShimmerBox(width: 80, height: 24, borderRadius: 12),
                  const SizedBox(width: 8),
                  ShimmerBox(width: 60, height: 24, borderRadius: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton card para proyecto
class ProjectSkeletonCard extends StatelessWidget {
  const ProjectSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.grey[400],
              child: Row(
                children: [
                  ShimmerBox(width: 60, height: 20, borderRadius: 8),
                  const SizedBox(width: 8),
                  ShimmerBox(width: 80, height: 20, borderRadius: 8),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    ShimmerLine(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    // Descripción
                    const ShimmerLine(height: 12),
                    const SizedBox(height: 4),
                    ShimmerLine(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 12,
                    ),
                    const Spacer(),
                    // Progress bar
                    const ShimmerBox(
                      width: double.infinity,
                      height: 6,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 8),
                    // Porcentaje
                    ShimmerLine(width: 80, height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton card para tarea
class TaskSkeletonCard extends StatelessWidget {
  const TaskSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con badges
              Row(
                children: [
                  ShimmerBox(width: 80, height: 24, borderRadius: 12),
                  const SizedBox(width: 8),
                  ShimmerBox(width: 60, height: 24, borderRadius: 12),
                ],
              ),
              const SizedBox(height: 12),
              // Título
              ShimmerLine(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 16,
              ),
              const SizedBox(height: 8),
              // Descripción
              const ShimmerLine(height: 12),
              const SizedBox(height: 4),
              ShimmerLine(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 12,
              ),
              const SizedBox(height: 12),
              // Progress bar
              const ShimmerBox(
                width: double.infinity,
                height: 6,
                borderRadius: 4,
              ),
              const SizedBox(height: 8),
              // Footer
              Row(
                children: [
                  ShimmerLine(width: 60, height: 12),
                  const Spacer(),
                  ShimmerLine(width: 80, height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton card para miembro
class MemberSkeletonCard extends StatelessWidget {
  const MemberSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const ShimmerCircle(size: 40),
          title: ShimmerLine(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 14,
          ),
          subtitle: ShimmerLine(
            width: MediaQuery.of(context).size.width * 0.2,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
          ),
          trailing: ShimmerBox(width: 60, height: 24, borderRadius: 12),
        ),
      ),
    );
  }
}



