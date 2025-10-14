# 🎨 Personalización Visual de Workflows (Proyectos)

## Descripción General

Este documento describe el esquema de colores y marcadores visuales implementado para distinguir rápidamente entre diferentes tipos de relación con proyectos en la aplicación Creapolis.

## Tipos de Relación

Los proyectos pueden tener tres tipos de relación con el usuario actual:

### 1. **Personal** 🔵
- **Definición**: Proyectos donde el usuario actual es el manager y no tiene otros miembros compartidos.
- **Características visuales**:
  - Color: Color primario del tema (azul #3B82F6)
  - Marcador: Ninguno (diseño limpio)
- **Identificación**: Solo el usuario puede ver y trabajar en estos proyectos.

**Vista previa:**
```
┌─────────────────────────────────────┐
│ [Activo]                    ⚠️      │  ← Header azul (#3B82F6)
├─────────────────────────────────────┤
│                                     │
│  Mi Proyecto Personal               │  ← Solo título
│                                     │
│  Este es un proyecto que manejo     │
│  únicamente yo, sin colaboradores   │
│                                     │
│  ████████████░░░░░░░ 75%            │  ← Progreso azul
│                                     │
│  📅 01/01/2025 - 31/12/2025         │
│  👤 Juan Pérez                      │
│                                     │
└─────────────────────────────────────┘
```

### 2. **Compartido por mí** 🟣
- **Definición**: Proyectos donde el usuario actual es el manager y ha invitado a otros miembros.
- **Características visuales**:
  - Color: Color primario del tema (azul #3B82F6)
  - Marcador: Badge con icono de "compartir" (share) en color secundario (#8B5CF6)
- **Identificación**: El usuario creó el proyecto y lo comparte con otros.

**Vista previa:**
```
┌─────────────────────────────────────┐
│ [Activo] [↗️ Compartido por mí]     │  ← Badge púrpura adicional
├─────────────────────────────────────┤
│                                     │
│  Proyecto Colaborativo              │
│                                     │
│  Proyecto con varios colaboradores  │
│  que trabajan en equipo             │
│                                     │
│  ████████░░░░░░░░░░░ 45%            │
│                                     │
│  📅 15/02/2025 - 30/11/2025         │
│  👤 Juan Pérez (Tú)                 │
│                                     │
└─────────────────────────────────────┘
```

### 3. **Compartido conmigo** 🟢
- **Definición**: Proyectos donde el usuario actual NO es el manager, fue invitado por otro usuario.
- **Características visuales**:
  - Color: Color primario del tema (azul #3B82F6)
  - Marcador: Badge con icono de "grupo" (people) en color terciario (#10B981)
- **Identificación**: Otro usuario invitó al usuario actual a colaborar en el proyecto.

**Vista previa:**
```
┌─────────────────────────────────────┐
│ [Activo] [👥 Compartido conmigo]    │  ← Badge verde
├─────────────────────────────────────┤
│                                     │
│  Proyecto del Equipo                │
│                                     │
│  Me invitaron a colaborar en este   │
│  proyecto del equipo de desarrollo  │
│                                     │
│  ██████████████░░░░░ 70%            │
│                                     │
│  📅 01/03/2025 - 31/12/2025         │
│  👤 María García (Manager)          │
│                                     │
└─────────────────────────────────────┘
```

## Esquema de Colores

```dart
// Todos los proyectos
Color principal: colorScheme.primary (Color(0xFF3B82F6) - Azul)

// Marcadores visuales
Compartido por mí: colorScheme.secondary (Color(0xFF8B5CF6) - Púrpura)
Compartido conmigo: colorScheme.tertiary (Color(0xFF10B981) - Verde)
```

### Tabla Comparativa de Estilos

| Tipo de Relación      | Color Header | Marcador Visual | Icono      | Color Marcador |
|-----------------------|--------------|-----------------|------------|----------------|
| Personal              | 🔵 Azul      | Ninguno         | -          | -              |
| Compartido por mí     | 🔵 Azul      | Badge           | ↗️ Share   | 🟣 Púrpura     |
| Compartido conmigo    | 🔵 Azul      | Badge           | 👥 People  | 🟢 Verde       |

**Nota importante**: El color del header y la barra de progreso es **siempre azul** (#3B82F6) para mantener consistencia visual. Solo los marcadores usan colores distintivos.

## Componentes Implementados

### 1. `ProjectRelationType` (Enum)
**Ubicación**: `lib/domain/entities/project.dart`

Enum que define los tres tipos de relación posibles:
```dart
enum ProjectRelationType {
  personal,       // Proyecto personal
  sharedByMe,     // Compartido por mí
  sharedWithMe    // Compartido conmigo
}
```

### 2. `Project.getRelationType()` (Método)
**Ubicación**: `lib/domain/entities/project.dart`

Método que determina el tipo de relación basándose en:
- ID del usuario actual
- ID del manager del proyecto
- Si el proyecto tiene otros miembros

```dart
ProjectRelationType getRelationType(
  int currentUserId, 
  {bool hasOtherMembers = false}
)
```

### 3. `ProjectRelationMarker` (Widget)
**Ubicación**: `lib/presentation/widgets/project/project_relation_marker.dart`

Widget reutilizable que muestra el badge visual para proyectos compartidos:
- Retorna `SizedBox.shrink()` para proyectos personales
- Muestra badge con icono + texto para proyectos compartidos
- Colores y estilos configurables

**Uso:**
```dart
ProjectRelationMarker(
  relationType: ProjectRelationType.sharedByMe,
  iconSize: 12,
  fontSize: 10,
)
```

### 4. `ProjectRelationBorder` (Widget Opcional)
**Ubicación**: `lib/presentation/widgets/project/project_relation_marker.dart`

Widget alternativo para mostrar un borde de color alrededor de cards de proyectos compartidos.

**Uso:**
```dart
ProjectRelationBorder(
  relationType: relationType,
  borderWidth: 2,
  child: Card(...),
)
```

### 5. `ProjectCard` (Widget Actualizado)
**Ubicación**: `lib/presentation/widgets/project/project_card.dart`

Card de proyecto actualizado con:
- Parámetro `currentUserId` para determinar la relación
- Parámetro `hasOtherMembers` para distinguir proyectos compartidos
- Usa siempre el color primario del tema
- Muestra marcador visual en el header según el tipo de relación

**Uso:**
```dart
ProjectCard(
  project: project,
  currentUserId: authState.user.id,
  hasOtherMembers: false, // Obtener del backend
  onTap: () => navigateToDetail(project.id),
)
```

## Guía de Implementación

### Para desarrolladores

1. **Determinar el tipo de relación:**
   ```dart
   final relationType = project.getRelationType(
     currentUserId,
     hasOtherMembers: projectHasMembers,
   );
   ```

2. **Mostrar marcador visual:**
   ```dart
   if (relationType != ProjectRelationType.personal) {
     ProjectRelationMarker(relationType: relationType)
   }
   ```

3. **Usar color del tema:**
   ```dart
   // SIEMPRE usar:
   color: colorScheme.primary
   
   // NUNCA usar colores hardcoded para proyectos:
   // ❌ color: Colors.blue
   // ❌ color: _getStatusColor(project.status)
   ```

## Extensibilidad

El sistema es fácilmente extensible:

1. **Agregar nuevos tipos de relación:**
   - Añadir valor al enum `ProjectRelationType`
   - Actualizar método `getRelationType()`
   - Actualizar `ProjectRelationMarker` con nuevo icono/color

2. **Personalizar colores:**
   - Modificar `AppTheme` en `lib/core/theme/app_theme.dart`
   - Los marcadores usan `colorScheme.secondary` y `colorScheme.tertiary`

3. **Agregar más información visual:**
   - Extender `ProjectRelationMarker` con tooltips
   - Usar `ProjectRelationBorder` para énfasis adicional
   - Combinar ambos widgets si es necesario

## Testing

Para probar los tres tipos de proyectos:

1. **Proyecto Personal**: 
   - Crear proyecto donde el usuario es manager
   - No agregar otros miembros

2. **Proyecto Compartido por mí**:
   - Crear proyecto donde el usuario es manager
   - Agregar otros miembros al proyecto

3. **Proyecto Compartido conmigo**:
   - Crear proyecto con otro usuario como manager
   - Agregar al usuario actual como miembro

## Beneficios

✅ **Consistencia visual**: Todos los proyectos usan el color primario del tema
✅ **Identificación rápida**: Los marcadores permiten distinguir la relación al instante
✅ **Diseño limpio**: Los proyectos personales no tienen marcadores innecesarios
✅ **Extensible**: Fácil agregar nuevos tipos de relación o personalizar colores
✅ **Documentado**: Código y UI bien documentados para mantenimiento futuro

## Referencias

- **Entidad Project**: `lib/domain/entities/project.dart`
- **Widget ProjectCard**: `lib/presentation/widgets/project/project_card.dart`
- **Widget ProjectRelationMarker**: `lib/presentation/widgets/project/project_relation_marker.dart`
- **Tema de la app**: `lib/core/theme/app_theme.dart`
- **Uso en lista**: `lib/presentation/screens/projects/projects_list_screen.dart`
