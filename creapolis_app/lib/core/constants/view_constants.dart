/// Constantes para configuración de vistas y UX
///
/// Este archivo define constantes utilizadas en el sistema de
/// Progressive Disclosure para mantener consistencia en toda la app.
library;

import 'package:flutter/animation.dart';

/// Tipo de densidad de vista para ProjectCard
enum ProjectViewDensity {
  /// Vista compacta - Solo información esencial
  /// Mejor para escaneo rápido de muchos proyectos
  compact,

  /// Vista cómoda - Información adicional siempre visible
  /// Mejor para trabajar con pocos proyectos activos
  comfortable,
}

/// Constantes de espaciado y dimensiones para diferentes densidades
class ViewConstants {
  ViewConstants._(); // Constructor privado para clase estática

  // ============== DENSIDAD COMPACTA ==============

  /// Altura mínima de card en vista compacta
  static const double compactCardMinHeight = 140;

  /// Padding interno en vista compacta
  static const double compactPadding = 12;

  /// Espaciado entre elementos en vista compacta
  static const double compactSpacing = 8;

  /// Altura del header de estado en vista compacta
  static const double compactHeaderHeight = 32;

  /// Tamaño de fuente del título en vista compacta
  static const double compactTitleFontSize = 15;

  // ============== DENSIDAD CÓMODA ==============

  /// Altura mínima de card en vista cómoda
  static const double comfortableCardMinHeight = 180;

  /// Padding interno en vista cómoda
  static const double comfortablePadding = 16;

  /// Espaciado entre elementos en vista cómoda
  static const double comfortableSpacing = 12;

  /// Altura del header de estado en vista cómoda
  static const double comfortableHeaderHeight = 36;

  /// Tamaño de fuente del título en vista cómoda
  static const double comfortableTitleFontSize = 16;

  // ============== ANIMACIONES ==============

  /// Duración de transición al hacer hover
  static const Duration hoverTransition = Duration(milliseconds: 200);

  /// Duración de transición al colapsar/expandir sección
  static const Duration collapseTransition = Duration(milliseconds: 300);

  /// Duración de transición al cambiar densidad de vista
  static const Duration densityTransition = Duration(milliseconds: 250);

  /// Duración de fade in/out
  static const Duration fadeTransition = Duration(milliseconds: 150);

  /// Curve suave para todas las animaciones principales
  static const Curve smoothCurve = Curves.easeInOutCubic;

  /// Curve para animaciones de colapso
  static const Curve collapseCurve = Curves.easeInOutQuart;

  /// Curve para animaciones de hover
  static const Curve hoverCurve = Curves.easeOut;

  // ============== SECCIONES COLAPSABLES ==============

  /// Altura del header de sección colapsable
  static const double sectionHeaderHeight = 48;

  /// Padding interno de sección colapsable
  static const double sectionContentPadding = 16;

  /// Espaciado entre secciones
  static const double sectionSpacing = 12;

  /// Duración de animación al rotar el icono de expandir
  static const Duration iconRotationDuration = Duration(milliseconds: 200);

  // ============== HOVER OVERLAY ==============

  /// Opacidad del overlay en hover (para tema claro)
  static const double hoverOverlayOpacity = 0.03;

  /// Opacidad del overlay en hover (para tema oscuro)
  static const double hoverOverlayOpacityDark = 0.05;

  /// Elevación de card en hover
  static const double hoverElevation = 4.0;

  /// Elevación normal de card
  static const double normalElevation = 2.0;

  // ============== TOOLTIPS ==============

  /// Delay antes de mostrar tooltip
  static const Duration tooltipWaitDuration = Duration(milliseconds: 500);

  /// Duración de visualización del tooltip
  static const Duration tooltipShowDuration = Duration(seconds: 3);

  /// Margen del tooltip
  static const double tooltipMargin = 8.0;

  // ============== RESPONSIVE ==============

  /// Breakpoint para cambiar de 2 a 3 columnas en grid
  static const double tabletBreakpoint = 600;

  /// Breakpoint para cambiar de 3 a 4 columnas en grid
  static const double desktopBreakpoint = 1200;

  /// Número de columnas en móvil
  static const int mobileCrossAxisCount = 2;

  /// Número de columnas en tablet
  static const int tabletCrossAxisCount = 3;

  /// Número de columnas en desktop
  static const int desktopCrossAxisCount = 4;

  // ============== ICONOS ==============

  /// Tamaño de iconos pequeños
  static const double smallIconSize = 14;

  /// Tamaño de iconos medianos
  static const double mediumIconSize = 18;

  /// Tamaño de iconos grandes
  static const double largeIconSize = 24;

  // ============== BORDES Y RADIOS ==============

  /// Radio de borde para cards
  static const double cardBorderRadius = 12;

  /// Radio de borde para botones pequeños
  static const double buttonBorderRadius = 8;

  /// Radio de borde para chips
  static const double chipBorderRadius = 16;

  // ============== CLAVES DE ALMACENAMIENTO ==============

  /// Key para guardar densidad de vista en SharedPreferences
  static const String prefKeyViewDensity = 'project_view_density';

  /// Prefijo para keys de estado de secciones colapsables
  static const String prefKeyCollapsedSectionPrefix = 'section_collapsed_';

  // ============== DESCRIPCIONES ==============

  /// Número máximo de líneas para descripción colapsada
  static const int descriptionCollapsedMaxLines = 3;

  /// Número de caracteres después del cual colapsar descripción por defecto
  static const int descriptionAutoCollapseThreshold = 150;
}

/// Extension para obtener valores según la densidad
extension ProjectViewDensityExtension on ProjectViewDensity {
  /// Obtiene la altura mínima del card según la densidad
  double get cardMinHeight {
    switch (this) {
      case ProjectViewDensity.compact:
        return ViewConstants.compactCardMinHeight;
      case ProjectViewDensity.comfortable:
        return ViewConstants.comfortableCardMinHeight;
    }
  }

  /// Obtiene el padding interno según la densidad
  double get padding {
    switch (this) {
      case ProjectViewDensity.compact:
        return ViewConstants.compactPadding;
      case ProjectViewDensity.comfortable:
        return ViewConstants.comfortablePadding;
    }
  }

  /// Obtiene el espaciado entre elementos según la densidad
  double get spacing {
    switch (this) {
      case ProjectViewDensity.compact:
        return ViewConstants.compactSpacing;
      case ProjectViewDensity.comfortable:
        return ViewConstants.comfortableSpacing;
    }
  }

  /// Obtiene la altura del header según la densidad
  double get headerHeight {
    switch (this) {
      case ProjectViewDensity.compact:
        return ViewConstants.compactHeaderHeight;
      case ProjectViewDensity.comfortable:
        return ViewConstants.comfortableHeaderHeight;
    }
  }

  /// Obtiene el tamaño de fuente del título según la densidad
  double get titleFontSize {
    switch (this) {
      case ProjectViewDensity.compact:
        return ViewConstants.compactTitleFontSize;
      case ProjectViewDensity.comfortable:
        return ViewConstants.comfortableTitleFontSize;
    }
  }

  /// Label para mostrar al usuario
  String get label {
    switch (this) {
      case ProjectViewDensity.compact:
        return 'Compacta';
      case ProjectViewDensity.comfortable:
        return 'Cómoda';
    }
  }

  /// Descripción para tooltips o ayuda
  String get description {
    switch (this) {
      case ProjectViewDensity.compact:
        return 'Vista minimalista para escaneo rápido';
      case ProjectViewDensity.comfortable:
        return 'Vista con más información visible';
    }
  }
}



