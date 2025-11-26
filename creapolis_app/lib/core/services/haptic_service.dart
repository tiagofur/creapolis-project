import 'package:flutter/services.dart';

/// Servicio centralizado para feedback háptico.
///
/// Proporciona diferentes niveles de intensidad de vibración
/// para mejorar la experiencia de usuario en acciones importantes.
///
/// Ejemplo de uso:
/// ```dart
/// HapticService.lightImpact();     // Taps suaves
/// HapticService.mediumImpact();    // Confirmaciones
/// HapticService.heavyImpact();     // Acciones importantes
/// HapticService.selectionClick();  // Selecciones en listas
/// HapticService.success();         // Operaciones exitosas
/// HapticService.warning();         // Alertas
/// HapticService.error();           // Errores
/// ```
class HapticService {
  static bool _enabled = true;

  /// Habilitar o deshabilitar haptic feedback globalmente
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Verificar si haptic feedback está habilitado
  static bool get isEnabled => _enabled;

  /// Impacto ligero - para taps y selecciones menores
  static Future<void> lightImpact() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Impacto medio - para confirmaciones y acciones moderadas
  static Future<void> mediumImpact() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Impacto fuerte - para acciones importantes como eliminar
  static Future<void> heavyImpact() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Click de selección - para cambios de selección en listas
  static Future<void> selectionClick() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Vibración - vibración genérica del sistema
  static Future<void> vibrate() async {
    if (!_enabled) return;
    await HapticFeedback.vibrate();
  }

  /// Feedback de éxito - doble impacto ligero
  static Future<void> success() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Feedback de advertencia - impacto medio
  static Future<void> warning() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Feedback de error - impacto fuerte
  static Future<void> error() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Feedback para toggle/switch
  static Future<void> toggle() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Feedback para long press
  static Future<void> longPress() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Feedback para pull-to-refresh
  static Future<void> pullToRefresh() async {
    if (!_enabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Feedback para drag and drop
  static Future<void> dragStart() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Feedback para soltar en drag and drop
  static Future<void> dragEnd() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Feedback para navegación
  static Future<void> navigate() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Feedback para acción destructiva (eliminar, etc)
  static Future<void> destructive() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }
}
