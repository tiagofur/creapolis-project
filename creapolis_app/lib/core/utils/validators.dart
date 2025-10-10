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

  /// Valida longitud mínima con mensaje personalizado
  static String? Function(String?) minLength(int min, [String? customMessage]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return AppStrings.fieldRequired;
      }
      if (value.length < min) {
        return customMessage ?? 'Debe tener al menos $min caracteres';
      }
      return null;
    };
  }

  /// Valida longitud máxima con mensaje personalizado
  static String? Function(String?) maxLength(int max, [String? customMessage]) {
    return (String? value) {
      if (value != null && value.length > max) {
        return customMessage ?? 'No debe exceder $max caracteres';
      }
      return null;
    };
  }

  /// Valida rango de longitud
  static String? Function(String?) lengthRange(
    int min,
    int max, [
    String? customMessage,
  ]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return AppStrings.fieldRequired;
      }
      if (value.length < min || value.length > max) {
        return customMessage ?? 'Debe tener entre $min y $max caracteres';
      }
      return null;
    };
  }

  /// Valida formato de URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL es opcional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'URL inválida';
    }

    return null;
  }

  /// Valida formato de teléfono (flexible)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Teléfono es opcional
    }

    // Eliminar espacios, guiones y paréntesis
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Validar que tenga entre 8 y 15 dígitos
    if (cleaned.length < 8 || cleaned.length > 15) {
      return 'Teléfono inválido';
    }

    // Validar que solo contenga dígitos y posiblemente un + al inicio
    final phoneRegex = RegExp(r'^\+?\d+$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Teléfono inválido';
    }

    return null;
  }

  /// Valida que un número esté en un rango
  static String? Function(String?) numberRange(
    double min,
    double max, [
    String? customMessage,
  ]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return AppStrings.fieldRequired;
      }

      final number = double.tryParse(value);
      if (number == null) {
        return 'Debe ser un número válido';
      }

      if (number < min || number > max) {
        return customMessage ?? 'Debe estar entre $min y $max';
      }

      return null;
    };
  }

  /// Valida formato de fecha (DD/MM/YYYY)
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    final dateRegex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
    final match = dateRegex.firstMatch(value);

    if (match == null) {
      return 'Formato inválido (DD/MM/YYYY)';
    }

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);

    if (day == null ||
        month == null ||
        year == null ||
        day < 1 ||
        day > 31 ||
        month < 1 ||
        month > 12 ||
        year < 1900) {
      return 'Fecha inválida';
    }

    return null;
  }

  /// Valida que un campo contenga solo letras
  static String? alpha(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    final alphaRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!alphaRegex.hasMatch(value)) {
      return 'Solo debe contener letras';
    }

    return null;
  }

  /// Valida que un campo contenga solo letras y números
  static String? alphanumeric(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]+$');
    if (!alphanumericRegex.hasMatch(value)) {
      return 'Solo debe contener letras y números';
    }

    return null;
  }

  /// Valida que un campo no contenga espacios
  static String? noSpaces(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    if (value.contains(' ')) {
      return 'No debe contener espacios';
    }

    return null;
  }

  /// Valida fortaleza de contraseña
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }

    if (value.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una minúscula';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Debe contener al menos un carácter especial';
    }

    return null;
  }

  /// Valida que el valor no esté en una lista de valores prohibidos
  static String? Function(String?) notIn(
    List<String> prohibitedValues, [
    String? customMessage,
  ]) {
    return (String? value) {
      if (value != null && prohibitedValues.contains(value)) {
        return customMessage ?? 'Este valor no está permitido';
      }
      return null;
    };
  }

  /// Valida con expresión regular personalizada
  static String? Function(String?) regex(
    RegExp pattern, [
    String? customMessage,
  ]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return AppStrings.fieldRequired;
      }
      if (!pattern.hasMatch(value)) {
        return customMessage ?? 'Formato inválido';
      }
      return null;
    };
  }
}
