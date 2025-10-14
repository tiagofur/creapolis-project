# 🎨 Workflows Visuales - Creapolis

> **Última actualización**: Octubre 11, 2025

Documentación completa sobre el sistema de workflows visuales, personalización y diseño del proyecto Creapolis.

---

## 📚 Documentos Disponibles

### 📖 [WORKFLOW_VISUAL_DESIGN_GUIDE.md](./WORKFLOW_VISUAL_DESIGN_GUIDE.md)
**Guía completa de diseño visual**

Documentación detallada sobre el sistema de diseño visual del proyecto, incluyendo:
- Paleta de colores y teoría del color
- Tipografía y jerarquía visual
- Sistema de componentes
- Guías de estilo y consistencia
- Patrones de diseño UI/UX

**Cuándo usarlo**: Para entender las decisiones de diseño y mantener consistencia visual.

---

### ⚡ [WORKFLOW_VISUAL_QUICK_REFERENCE.md](./WORKFLOW_VISUAL_QUICK_REFERENCE.md)
**Referencia rápida**

Guía condensada con información esencial para consultas rápidas:
- Códigos de color principales
- Componentes clave
- Estilos comunes
- Shortcuts y tips
- Ejemplos de uso

**Cuándo usarlo**: Para consultas rápidas durante el desarrollo.

---

### 🎨 [WORKFLOW_VISUAL_PERSONALIZATION.md](./WORKFLOW_VISUAL_PERSONALIZATION.md)
**Guía de personalización**

Instrucciones para personalizar el sistema visual:
- Temas (claro/oscuro)
- Personalización de colores
- Ajustes de componentes
- Preferencias de usuario
- Configuración avanzada

**Cuándo usarlo**: Para implementar opciones de personalización y temas.

---

### 🧪 [WORKFLOW_VISUAL_TESTING_GUIDE.md](./WORKFLOW_VISUAL_TESTING_GUIDE.md)
**Guía de testing visual**

Estrategias y prácticas para testing del sistema visual:
- Tests de componentes visuales
- Tests de accesibilidad (a11y)
- Tests de responsive design
- Tests de cross-browser
- Herramientas recomendadas

**Cuándo usarlo**: Para implementar y ejecutar tests visuales.

---

### 📋 [WORKFLOW_VISUAL_IMPLEMENTATION_SUMMARY.md](./WORKFLOW_VISUAL_IMPLEMENTATION_SUMMARY.md)
**Resumen de implementación**

Resumen ejecutivo de la implementación del sistema visual:
- Estado actual
- Componentes implementados
- Pendientes y roadmap
- Métricas de cobertura
- Próximos pasos

**Cuándo usarlo**: Para overview del estado del sistema visual.

---

### 📄 [WORKFLOW_VISUAL_DOCS_README.md](./WORKFLOW_VISUAL_DOCS_README.md)
**README de documentación visual**

Índice y estructura de toda la documentación visual:
- Organización de archivos
- Convenciones
- Cómo contribuir
- Referencias cruzadas

**Cuándo usarlo**: Para navegar la documentación completa.

---

## 🚀 Inicio Rápido

### Para Nuevos Desarrolladores

1. **Entender el diseño**: Empieza con [WORKFLOW_VISUAL_DESIGN_GUIDE.md](./WORKFLOW_VISUAL_DESIGN_GUIDE.md)
2. **Consulta rápida**: Ten a mano [WORKFLOW_VISUAL_QUICK_REFERENCE.md](./WORKFLOW_VISUAL_QUICK_REFERENCE.md)
3. **Personalización**: Si necesitas temas, ve [WORKFLOW_VISUAL_PERSONALIZATION.md](./WORKFLOW_VISUAL_PERSONALIZATION.md)
4. **Testing**: Para validar cambios, consulta [WORKFLOW_VISUAL_TESTING_GUIDE.md](./WORKFLOW_VISUAL_TESTING_GUIDE.md)

### Para Diseñadores

1. **Sistema de diseño**: [WORKFLOW_VISUAL_DESIGN_GUIDE.md](./WORKFLOW_VISUAL_DESIGN_GUIDE.md)
2. **Estado actual**: [WORKFLOW_VISUAL_IMPLEMENTATION_SUMMARY.md](./WORKFLOW_VISUAL_IMPLEMENTATION_SUMMARY.md)
3. **Personalización**: [WORKFLOW_VISUAL_PERSONALIZATION.md](./WORKFLOW_VISUAL_PERSONALIZATION.md)

---

## 🎯 Stack Tecnológico Visual

### Frontend (Flutter)
- **Material Design 3** - Sistema de diseño base
- **Custom Theme** - Tema personalizado de Creapolis
- **Color System** - Paleta de colores dinámica
- **Typography** - Sistema tipográfico escalable
- **Components** - Biblioteca de componentes reutilizables

### Testing
- **Flutter Test** - Tests de widgets
- **Golden Tests** - Tests de snapshots visuales
- **Integration Tests** - Tests E2E con UI
- **Accessibility** - Tests de a11y

---

## 📋 Convenciones de Diseño

### Nombres de Colores
```dart
// Colores primarios
primaryColor
primaryColorLight
primaryColorDark

// Colores secundarios
secondaryColor
accentColor

// Colores semánticos
successColor
warningColor
errorColor
infoColor

// Colores neutrales
backgroundColor
surfaceColor
textColor
```

### Espaciado
```dart
// Sistema de espaciado (múltiplos de 8)
spacing_xs: 4.0
spacing_sm: 8.0
spacing_md: 16.0
spacing_lg: 24.0
spacing_xl: 32.0
spacing_xxl: 48.0
```

### Tipografía
```dart
// Estilos de texto
displayLarge  // Títulos grandes
displayMedium // Títulos medianos
displaySmall  // Títulos pequeños
headlineLarge // Encabezados
bodyLarge     // Cuerpo principal
bodyMedium    // Cuerpo secundario
labelLarge    // Labels y botones
```

---

## 🛠️ Herramientas Recomendadas

### Diseño
- **Figma** - Diseño UI/UX
- **Adobe Color** - Paletas de colores
- **Google Fonts** - Tipografías

### Desarrollo
- **VS Code** - Editor principal
- **Flutter DevTools** - Inspector de widgets
- **Flutter Widget Inspector** - Debugging visual

### Testing
- **Flutter Test** - Framework de testing
- **flutter_test** - Testing de widgets
- **golden_toolkit** - Golden tests

---

## 📊 Estado del Sistema Visual

| Componente | Estado | Cobertura | Testing |
|------------|--------|-----------|---------|
| Theme System | ✅ Completo | 100% | ✅ |
| Color Palette | ✅ Completo | 100% | ✅ |
| Typography | ✅ Completo | 100% | ✅ |
| Components | 🟡 90% | 90% | 🟡 |
| Dark Mode | ✅ Completo | 100% | ✅ |
| Responsive | ✅ Completo | 95% | ✅ |
| Accessibility | 🟡 En progreso | 80% | 🟡 |

**Leyenda**: ✅ Completo | 🟡 En progreso | ❌ Pendiente

---

## 🤝 Contribuir

### Para Agregar Nuevos Componentes

1. Diseñar en Figma siguiendo el sistema
2. Implementar en Flutter con tests
3. Documentar en WORKFLOW_VISUAL_DESIGN_GUIDE.md
4. Agregar a WORKFLOW_VISUAL_QUICK_REFERENCE.md
5. Actualizar WORKFLOW_VISUAL_IMPLEMENTATION_SUMMARY.md

### Para Modificar Diseño Existente

1. Validar con equipo de diseño
2. Actualizar componente y tests
3. Actualizar documentación
4. Ejecutar tests visuales
5. Crear PR con screenshots

---

## 📞 Recursos Adicionales

### Documentación Externa
- [Material Design 3](https://m3.material.io/)
- [Flutter Themes](https://docs.flutter.dev/cookbook/design/themes)
- [Accessibility Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

### Documentación Interna
- [Setup del Proyecto](../setup/ENVIRONMENT_SETUP.md)
- [Fixes Comunes](../fixes/COMMON_FIXES.md)
- [README Principal](../README.md)

---

## 📅 Última Actualización

**Fecha**: Octubre 11, 2025  
**Versión**: 1.0  
**Mantenedor**: Equipo de Diseño Creapolis  
**Próxima revisión**: Diciembre 2025

---

## 📝 Notas

- Todos los valores de color deben usar el sistema de temas
- Componentes nuevos requieren tests visuales
- Mantener consistencia con Material Design 3
- Documentar todos los cambios significativos
- Validar accesibilidad antes de merge

---

_Sistema de Workflows Visuales - Creapolis Project_ 🎨
