import 'package:dartz/dartz.dart' hide Task;

import '../../core/errors/failures.dart';
import '../entities/time_log.dart';

/// Repositorio de time logs
abstract class TimeLogRepository {
  /// Iniciar timer para una tarea
  Future<Either<Failure, TimeLog>> startTimer(int taskId);

  /// Detener timer activo de una tarea
  Future<Either<Failure, TimeLog>> stopTimer(int taskId);

  /// Finalizar tarea y calcular horas totales
  Future<Either<Failure, void>> finishTask(int taskId);

  /// Obtener todos los time logs de una tarea
  Future<Either<Failure, List<TimeLog>>> getTimeLogsByTask(int taskId);

  /// Obtener time log activo del usuario
  Future<Either<Failure, TimeLog?>> getActiveTimeLog();

  /// Obtener time log activo de una tarea específica
  Future<Either<Failure, TimeLog?>> getActiveTimeLogByTask(int taskId);
}
