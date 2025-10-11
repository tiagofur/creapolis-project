# 🚀 Quick Reference: Workflow Visual Personalization

**Para desarrolladores que necesitan usar o extender la funcionalidad de marcadores visuales.**

## 📦 Imports Necesarios

```dart
import 'package:creapolis_app/domain/entities/project.dart';
import 'package:creapolis_app/presentation/widgets/project/project_relation_marker.dart';
```

## 🎯 Uso Básico

### 1. Determinar el tipo de relación

```dart
final relationType = project.getRelationType(
  currentUserId,
  hasOtherMembers: true, // Si el proyecto tiene más miembros
);
```

### 2. Mostrar un ProjectCard con marcador

```dart
ProjectCard(
  project: project,
  currentUserId: authState.user.id,      // ID del usuario actual
  hasOtherMembers: project.memberCount > 1, // Del backend
  onTap: () => navigateToDetail(project.id),
)
```

### 3. Usar marcador standalone

```dart
ProjectRelationMarker(
  relationType: ProjectRelationType.sharedByMe,
  iconSize: 14,
  fontSize: 11,
)
```

## 🎨 Tipos de Relación

```dart
enum ProjectRelationType {
  personal,      // Sin marcador
  sharedByMe,    // Badge púrpura + icono share
  sharedWithMe   // Badge verde + icono people
}
```

## 🎭 Ejemplos Completos

### Ejemplo 1: Card Simple

```dart
Widget buildProjectCard(Project project, int currentUserId) {
  return ProjectCard(
    project: project,
    currentUserId: currentUserId,
    hasOtherMembers: false,
    onTap: () => print('Tap on ${project.name}'),
  );
}
```

### Ejemplo 2: Lista de Proyectos

```dart
ListView.builder(
  itemCount: projects.length,
  itemBuilder: (context, index) {
    final project = projects[index];
    final currentUserId = context.read<AuthBloc>().state.user.id;
    
    return ProjectCard(
      project: project,
      currentUserId: currentUserId,
      hasOtherMembers: project.memberCount > 1,
      onTap: () => context.push('/projects/${project.id}'),
    );
  },
)
```

### Ejemplo 3: Marcador Custom

```dart
Widget buildCustomMarker(ProjectRelationType type) {
  if (type == ProjectRelationType.personal) {
    return const SizedBox.shrink();
  }
  
  return ProjectRelationMarker(
    relationType: type,
    iconSize: 16,
    fontSize: 12,
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  );
}
```

### Ejemplo 4: Con Borde (Opcional)

```dart
ProjectRelationBorder(
  relationType: relationType,
  borderWidth: 2,
  child: ProjectCard(
    project: project,
    currentUserId: currentUserId,
  ),
)
```

## 🔍 Verificación de Tipo

```dart
// Verificar si es personal
if (relationType == ProjectRelationType.personal) {
  // No mostrar marcador
}

// Verificar si es compartido
if (relationType != ProjectRelationType.personal) {
  // Mostrar marcador
}

// Switch completo
switch (relationType) {
  case ProjectRelationType.personal:
    // Solo para el usuario
    break;
  case ProjectRelationType.sharedByMe:
    // Usuario es el owner
    break;
  case ProjectRelationType.sharedWithMe:
    // Usuario es colaborador
    break;
}
```

## 🎨 Personalizar Colores

Los colores se obtienen del tema:

```dart
// En el widget
final colorScheme = Theme.of(context).colorScheme;

// Colores disponibles
colorScheme.primary     // Azul - Para todos los proyectos
colorScheme.secondary   // Púrpura - Para "compartido por mí"
colorScheme.tertiary    // Verde - Para "compartido conmigo"
```

Para cambiar colores, editar `lib/core/theme/app_theme.dart`:

```dart
colorScheme: const ColorScheme.light(
  primary: Color(0xFF3B82F6),    // Cambiar este
  secondary: Color(0xFF8B5CF6),  // O este
  tertiary: Color(0xFF10B981),   // O este
),
```

## 🧩 Extender Funcionalidad

### Agregar Nuevo Tipo de Relación

1. **Actualizar enum** (`lib/domain/entities/project.dart`):
```dart
enum ProjectRelationType {
  personal,
  sharedByMe,
  sharedWithMe,
  collaborator,  // ← Nuevo tipo
}
```

2. **Actualizar label**:
```dart
String get label {
  // ... casos existentes
  case ProjectRelationType.collaborator:
    return 'Colaborador';
}
```

3. **Actualizar widget** (`project_relation_marker.dart`):
```dart
Color _getMarkerColor(ProjectRelationType type, ColorScheme colorScheme) {
  // ... casos existentes
  case ProjectRelationType.collaborator:
    return Colors.amber;
}

IconData _getMarkerIcon(ProjectRelationType type) {
  // ... casos existentes
  case ProjectRelationType.collaborator:
    return Icons.handshake;
}
```

4. **Actualizar lógica** en `getRelationType()`:
```dart
ProjectRelationType getRelationType(int currentUserId, {bool hasOtherMembers = false}) {
  // ... lógica existente
  // Agregar condiciones para el nuevo tipo
}
```

## 🐛 Debugging

### Verificar tipo de relación

```dart
print('Project: ${project.name}');
print('Manager ID: ${project.managerId}');
print('Current User ID: $currentUserId');
print('Relation Type: ${project.getRelationType(currentUserId)}');
```

### Verificar marcador

```dart
final relationType = project.getRelationType(currentUserId);
print('Should show marker: ${relationType != ProjectRelationType.personal}');
print('Marker color: ${_getMarkerColor(relationType, colorScheme)}');
```

## 📱 Testing en Demo Screen

Para probar rápidamente:

```dart
// Navegar a demo
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ProjectVisualsDemo(),
  ),
);
```

## ⚠️ Limitaciones Actuales

1. **hasOtherMembers** está hardcoded en `ProjectsListScreen`
   - Cambiar manualmente para testing
   - Esperar endpoint de backend con información de miembros

2. **Membresía** no se obtiene automáticamente
   - Backend debe incluir `memberCount` o `members[]`

## 📚 Más Información

- **Documentación completa**: `WORKFLOW_VISUAL_PERSONALIZATION.md`
- **Guía de testing**: `WORKFLOW_VISUAL_TESTING_GUIDE.md`
- **Resumen**: `WORKFLOW_VISUAL_IMPLEMENTATION_SUMMARY.md`
- **Demo**: `lib/presentation/screens/demo/project_visuals_demo.dart`

## 🔗 Links Rápidos

| Componente | Ubicación |
|------------|-----------|
| Enum | `lib/domain/entities/project.dart` |
| Marcador Widget | `lib/presentation/widgets/project/project_relation_marker.dart` |
| ProjectCard | `lib/presentation/widgets/project/project_card.dart` |
| Demo | `lib/presentation/screens/demo/project_visuals_demo.dart` |
| Tema | `lib/core/theme/app_theme.dart` |

---

**Última actualización**: 2025-10-10  
**Versión**: 1.0.0  
**Mantenedor**: GitHub Copilot
