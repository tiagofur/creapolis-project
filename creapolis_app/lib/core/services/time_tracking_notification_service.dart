import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/utils/app_logger.dart';

/// Servicio para notificaciones de time tracking
/// Envía recordatorios cuando el timer lleva mucho tiempo activo
class TimeTrackingNotificationService {
  static final TimeTrackingNotificationService _instance =
      TimeTrackingNotificationService._internal();
  
  factory TimeTrackingNotificationService() => _instance;
  
  TimeTrackingNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _reminderTimer;
  DateTime? _timerStartTime;
  int? _activeTaskId;

  // Configuración de intervalos
  static const Duration _firstReminder = Duration(hours: 2);
  static const Duration _secondReminder = Duration(hours: 4);
  static const Duration _breakSuggestion = Duration(hours: 3);

  Future<void> initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(initializationSettings);
      AppLogger.info('TimeTrackingNotificationService inicializado');
    } catch (e, stackTrace) {
      AppLogger.error('Error inicializando notificaciones time tracking', e, stackTrace);
    }
  }

  /// Iniciar monitoreo de timer activo
  void startTimerMonitoring(int taskId, String taskTitle) {
    _activeTaskId = taskId;
    _timerStartTime = DateTime.now();
    
    // Cancelar timer anterior si existe
    _reminderTimer?.cancel();

    // Programar recordatorios
    _scheduleReminders(taskTitle);
    
    AppLogger.info('Monitoreo de timer iniciado para tarea $taskId');
  }

  /// Detener monitoreo de timer
  void stopTimerMonitoring() {
    _reminderTimer?.cancel();
    _timerStartTime = null;
    _activeTaskId = null;
    
    AppLogger.info('Monitoreo de timer detenido');
  }

  void _scheduleReminders(String taskTitle) {
    // Revisar cada 30 minutos si se debe enviar recordatorio
    _reminderTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (_timerStartTime == null) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(_timerStartTime!);

      // Primer recordatorio a las 2 horas
      if (elapsed >= _firstReminder && elapsed < _firstReminder + const Duration(minutes: 30)) {
        _showNotification(
          id: 1,
          title: '⏰ Timer activo hace 2 horas',
          body: 'Llevas 2 horas trabajando en "$taskTitle". ¿Todo bien?',
        );
      }

      // Segundo recordatorio a las 4 horas
      if (elapsed >= _secondReminder && elapsed < _secondReminder + const Duration(minutes: 30)) {
        _showNotification(
          id: 2,
          title: '⏰ Timer activo hace 4 horas',
          body: 'Llevas 4 horas en "$taskTitle". Considera hacer una pausa.',
        );
      }

      // Sugerencia de descanso a las 3 horas
      if (elapsed >= _breakSuggestion && elapsed < _breakSuggestion + const Duration(minutes: 30)) {
        _showNotification(
          id: 3,
          title: '☕ Hora de un descanso',
          body: 'Has trabajado 3 horas seguidas. Te recomendamos un breve descanso.',
        );
      }

      // Recordatorios cada hora después de las 4 horas
      if (elapsed > _secondReminder) {
        final hoursSinceStart = elapsed.inHours;
        final minutesSinceStart = elapsed.inMinutes % 60;
        
        if (minutesSinceStart < 30) {
          _showNotification(
            id: 4,
            title: '⏱️ Timer todavía activo',
            body: 'Llevas $hoursSinceStart horas en "$taskTitle". ¿Olvidaste detenerlo?',
          );
        }
      }
    });
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'time_tracking_channel',
        'Time Tracking',
        channelDescription: 'Notificaciones de seguimiento de tiempo',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details);
      AppLogger.info('Notificación time tracking enviada: $title');
    } catch (e, stackTrace) {
      AppLogger.error('Error mostrando notificación', e, stackTrace);
    }
  }

  /// Mostrar sugerencia de productividad basada en heatmap
  Future<void> showProductivitySuggestion({
    required int peakHour,
    required String peakDay,
  }) async {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Sugerir si está cerca de su hora pico pero no trabajando
    if ((currentHour - peakHour).abs() <= 1) {
      await _showNotification(
        id: 10,
        title: '💡 Momento óptimo de productividad',
        body: 'Según tus datos, esta es una de tus horas más productivas. ¡Aprovéchala!',
      );
    }
  }

  /// Felicitar por meta alcanzada
  Future<void> showGoalAchievement({
    required String achievement,
    required String description,
  }) async {
    await _showNotification(
      id: 20,
      title: '🎉 ¡Meta alcanzada!',
      body: '$achievement: $description',
    );
  }

  /// Recordar detener timer al final del día
  void scheduleEndOfDayReminder() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM

    if (now.isBefore(endOfDay) && _timerStartTime != null) {
      final delay = endOfDay.difference(now);
      
      Timer(delay, () {
        if (_activeTaskId != null) {
          _showNotification(
            id: 30,
            title: '🌙 Fin del día laboral',
            body: 'Tienes un timer activo. ¿Quieres detenerlo?',
          );
        }
      });
    }
  }

  void dispose() {
    _reminderTimer?.cancel();
  }
}
