import '../constants/app_strings.dart';

/// Utilidades para validación de formularios
class Validators {
  Validators._();

  /// Valida que un campo no esté vacío
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return AppStrings.invalidEmail;
    }

    return null;
  }

  /// Valida longitud mínima de contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }

    return null;
  }

  /// Valida que dos contraseñas coincidan
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    if (value != originalPassword) {
      return AppStrings.passwordsDontMatch;
    }

    return null;
  }

  /// Valida que un número sea positivo
  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'Debe ser un número positivo';
    }

    return null;
  }

  /// Combina múltiples validadores
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
