import 'package:intl/intl.dart';

/// Utilidades para manejo de fechas
class DateTimeUtils {
  DateTimeUtils._();

  /// Formatea una fecha en formato corto (dd/MM/yyyy)
  static String formatShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formatea una fecha en formato largo (dd de MMMM de yyyy)
  static String formatLong(DateTime date) {
    return DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es').format(date);
  }

  /// Formatea una fecha con hora (dd/MM/yyyy HH:mm)
  static String formatWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formatea solo la hora (HH:mm)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Calcula la diferencia en días entre dos fechas
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Verifica si una fecha es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Verifica si una fecha es mañana
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Convierte horas decimales a formato "Xh Ymin"
  static String formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();

    if (m == 0) {
      return '${h}h';
    }

    return '${h}h ${m}min';
  }
}



