import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../domain/entities/task.dart';

/// Painter personalizado para el diagrama de Gantt
class GanttChartPainter extends CustomPainter {
  final List<Task> tasks;
  final DateTime startDate;
  final DateTime endDate;
  final double dayWidth;
  final double taskHeight;
  final double taskSpacing;
  final Map<int, List<int>> dependencies;
  final int? selectedTaskId;

  GanttChartPainter({
    required this.tasks,
    required this.startDate,
    required this.endDate,
    required this.dayWidth,
    this.taskHeight = 40.0,
    this.taskSpacing = 10.0,
    required this.dependencies,
    this.selectedTaskId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar líneas de dependencia primero (detrás de las barras)
    _drawDependencies(canvas);

    // Dibujar barras de tareas
    _drawTaskBars(canvas);
  }

  /// Dibuja las barras de tareas
  void _drawTaskBars(Canvas canvas) {
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final y = i * (taskHeight + taskSpacing);

      // Calcular posición X y ancho basado en fechas
      final taskStartDays = task.startDate.difference(startDate).inDays;
      final taskDurationDays = task.endDate.difference(task.startDate).inDays;

      final x = taskStartDays * dayWidth;
      final width = math.max(taskDurationDays * dayWidth, dayWidth * 0.5);

      // Color basado en el estado
      final color = _getColorForStatus(task.status);
      final isSelected = task.id == selectedTaskId;

      // Dibujar sombra si está seleccionada
      if (isSelected) {
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 2, y + 2, width, taskHeight),
            const Radius.circular(8),
          ),
          shadowPaint,
        );
      }

      // Dibujar barra principal
      final barPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, width, taskHeight),
          const Radius.circular(8),
        ),
        barPaint,
      );

      // Dibujar borde si está seleccionada
      if (isSelected) {
        final borderPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, width, taskHeight),
            const Radius.circular(8),
          ),
          borderPaint,
        );
      }

      // Dibujar barra de progreso
      if (task.progress > 0) {
        final progressPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, width * task.progress, taskHeight),
            const Radius.circular(8),
          ),
          progressPaint,
        );
      }

      // Dibujar título de la tarea
      final textSpan = TextSpan(
        text: task.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      );

      textPainter.layout(maxWidth: width - 16);
      textPainter.paint(
        canvas,
        Offset(x + 8, y + (taskHeight - textPainter.height) / 2),
      );

      // Dibujar indicador de prioridad
      if (task.priority == TaskPriority.critical ||
          task.priority == TaskPriority.high) {
        final priorityPaint = Paint()
          ..color = task.priority == TaskPriority.critical
              ? Colors.red
              : Colors.orange
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x + width - 8, y + 8), 4, priorityPaint);
      }
    }
  }

  /// Dibuja las líneas de dependencia
  void _drawDependencies(Canvas canvas) {
    final linePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arrowPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final deps = dependencies[task.id] ?? [];

      for (final predId in deps) {
        // Encontrar la tarea predecesora
        final predIndex = tasks.indexWhere((t) => t.id == predId);
        if (predIndex == -1) continue;

        final predTask = tasks[predIndex];

        // Calcular posiciones
        final predY = predIndex * (taskHeight + taskSpacing) + taskHeight / 2;
        final taskY = i * (taskHeight + taskSpacing) + taskHeight / 2;

        final predEndDays = predTask.endDate.difference(startDate).inDays;
        final taskStartDays = task.startDate.difference(startDate).inDays;

        final predX = predEndDays * dayWidth;
        final taskX = taskStartDays * dayWidth;

        // Dibujar línea con curva
        final path = Path();
        path.moveTo(predX, predY);

        // Línea horizontal desde el final de la tarea predecesora
        final midX = (predX + taskX) / 2;
        path.lineTo(midX, predY);

        // Línea vertical
        path.lineTo(midX, taskY);

        // Línea horizontal hasta el inicio de la tarea sucesora
        path.lineTo(taskX, taskY);

        canvas.drawPath(path, linePaint);

        // Dibujar flecha al final
        _drawArrow(canvas, taskX, taskY, arrowPaint);
      }
    }
  }

  /// Dibuja una flecha
  void _drawArrow(Canvas canvas, double x, double y, Paint paint) {
    final path = Path();
    path.moveTo(x, y);
    path.lineTo(x - 8, y - 4);
    path.lineTo(x - 8, y + 4);
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Obtiene el color según el estado de la tarea
  Color _getColorForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.planned:
        return Colors.grey.shade600;
      case TaskStatus.inProgress:
        return Colors.blue.shade600;
      case TaskStatus.completed:
        return Colors.green.shade600;
      case TaskStatus.blocked:
        return Colors.red.shade600;
      case TaskStatus.cancelled:
        return Colors.grey.shade400;
    }
  }

  @override
  bool shouldRepaint(GanttChartPainter oldDelegate) {
    return oldDelegate.tasks != tasks ||
        oldDelegate.dayWidth != dayWidth ||
        oldDelegate.selectedTaskId != selectedTaskId;
  }
}
