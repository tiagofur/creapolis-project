# 🎬 Guía de Implementación de Animaciones

**Fecha:** 9 de octubre de 2025  
**Objetivo:** Aplicar Hero animations y Page transitions a la aplicación

---

## ✅ Paso 1: Hero Animations en WorkspaceCard

### Archivo: `lib/presentation/widgets/workspace/workspace_card.dart`

#### 1.1 Agregar import

```dart
import '../../../core/animations/hero_tags.dart';
```

#### 1.2 Envolver el Card principal con Hero

**Antes:**

```dart
@override
Widget build(BuildContext context) {
  return Card(
    elevation: isActive ? 8 : 2,
    // ...
```

**Después:**

```dart
@override
Widget build(BuildContext context) {
  return Hero(
    tag: HeroTags.workspace(workspace.id),
    child: Card(
      elevation: isActive ? 8 : 2,
      // ...
```

**Y cerrar el Hero al final del build method (antes del último `);`)**

#### 1.3 Envolver el Avatar con Hero

**Antes:**

```dart
// Avatar o icono
_buildAvatar(context),
```

**Después:**

```dart
// Avatar o icono con Hero
Hero(
  tag: HeroTags.workspaceIcon(workspace.id),
  child: _buildAvatar(context),
),
```

#### 1.4 Envolver el Título con Hero y Material

**Antes:**

```dart
Expanded(
  child: Text(
    workspace.name,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.bold),
  ),
),
```

**Después:**

```dart
Expanded(
  child: Hero(
    tag: HeroTags.workspaceTitle(workspace.id),
    child: Material(
      color: Colors.transparent,
      child: Text(
        workspace.name,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    ),
  ),
),
```

---

## ✅ Paso 2: Hero Animations en ProjectCard

### Archivo: `lib/presentation/widgets/project/project_card.dart`

#### 2.1 Agregar import

```dart
import '../../../core/animations/hero_tags.dart';
```

#### 2.2 Aplicar Hero al Card

```dart
@override
Widget build(BuildContext context) {
  return Hero(
    tag: HeroTags.project(project.id),
    child: Card(
      // ... resto del código
    ),
  );
}
```

#### 2.3 Hero en Icono de Estado

```dart
Hero(
  tag: HeroTags.projectIcon(project.id),
  child: Icon(
    _getStatusIcon(),
    color: _getStatusColor(status, colorScheme),
    size: 24,
  ),
),
```

#### 2.4 Hero en Título

```dart
Hero(
  tag: HeroTags.projectTitle(project.id),
  child: Material(
    color: Colors.transparent,
    child: Text(
      project.name,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
```

---

## ✅ Paso 3: Hero Animations en TaskCard

### Archivo: `lib/presentation/widgets/task/task_card.dart`

#### 3.1 Agregar import

```dart
import '../../../core/animations/hero_tags.dart';
```

#### 3.2 Aplicar Hero al Card

```dart
@override
Widget build(BuildContext context) {
  return Hero(
    tag: HeroTags.task(task.id),
    child: Card(
      // ... resto del código
    ),
  );
}
```

#### 3.3 Hero en Status Icon

```dart
Hero(
  tag: HeroTags.taskIcon(task.id),
  child: Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: _getStatusColor(task.status),
      shape: BoxShape.circle,
    ),
  ),
),
```

#### 3.4 Hero en Título

```dart
Hero(
  tag: HeroTags.taskTitle(task.id),
  child: Material(
    color: Colors.transparent,
    child: Text(
      task.title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
  ),
),
```

---

## ✅ Paso 4: Page Transitions en WorkspaceListScreen

### Archivo: `lib/presentation/screens/workspace/workspace_list_screen.dart`

#### 4.1 Agregar imports

```dart
import '../../../core/animations/page_transitions.dart';
```

#### 4.2 Reemplazar Navigator.push

**Antes:**

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WorkspaceDetailScreen(workspace: workspace),
  ),
);
```

**Después:**

```dart
context.pushWithTransition(
  WorkspaceDetailScreen(workspace: workspace),
  type: PageTransitionType.slideFromRight,
  duration: const Duration(milliseconds: 300),
);
```

**O usando CustomPageRoute directamente:**

```dart
Navigator.push(
  context,
  CustomPageRoute(
    page: WorkspaceDetailScreen(workspace: workspace),
    transitionType: PageTransitionType.scale,
  ),
);
```

---

## ✅ Paso 5: Staggered Animations en WorkspaceListScreen

### Archivo: `lib/presentation/screens/workspace/workspace_list_screen.dart`

#### 5.1 Agregar import

```dart
import '../../../core/animations/list_animations.dart';
```

#### 5.2 Modificar ListView.builder

**Antes:**

```dart
ListView.builder(
  itemCount: workspaces.length,
  itemBuilder: (context, index) {
    final workspace = workspaces[index];
    return WorkspaceCard(
      workspace: workspace,
      isActive: workspace.id == activeWorkspaceId,
      onTap: () => _navigateToDetail(context, workspace),
      onSetActive: () => _setActiveWorkspace(context, workspace.id),
    );
  },
)
```

**Después:**

```dart
ListView.builder(
  itemCount: workspaces.length,
  itemBuilder: (context, index) {
    final workspace = workspaces[index];
    return StaggeredListAnimation(
      index: index,
      delay: const Duration(milliseconds: 50),
      duration: const Duration(milliseconds: 400),
      child: WorkspaceCard(
        workspace: workspace,
        isActive: workspace.id == activeWorkspaceId,
        onTap: () => _navigateToDetail(context, workspace),
        onSetActive: () => _setActiveWorkspace(context, workspace.id),
      ),
    );
  },
)
```

---

## ✅ Paso 6: Staggered Animations en WorkspaceMembersScreen

### Archivo: `lib/presentation/screens/workspace/workspace_members_screen.dart`

#### 6.1 Agregar import

```dart
import '../../../core/animations/list_animations.dart';
```

#### 6.2 Envolver ListTile con StaggeredListAnimation

```dart
ListView.builder(
  itemCount: members.length,
  itemBuilder: (context, index) {
    final member = members[index];
    return StaggeredListAnimation(
      index: index,
      child: ListTile(
        // ... resto del código
      ),
    );
  },
)
```

---

## ✅ Paso 7: Page Transitions en Toda la App

### Archivos a actualizar:

1. **ProjectListScreen** → ProjectDetailScreen
2. **TaskListScreen** → TaskDetailScreen
3. **SettingsScreen** → SubScreens
4. **Cualquier Navigator.push en la app**

### Estrategia:

Buscar todos los `Navigator.push` y reemplazarlos con:

```dart
// Opción 1: Extension method (más simple)
context.pushWithTransition(
  DestinationScreen(),
  type: PageTransitionType.slideFromRight,
);

// Opción 2: CustomPageRoute (más control)
Navigator.push(
  context,
  CustomPageRoute(
    page: DestinationScreen(),
    transitionType: PageTransitionType.scale,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeInOutCubic,
  ),
);
```

---

## 📊 Checklist de Implementación

### Hero Animations:

- [ ] WorkspaceCard (Card, Icon, Title)
- [ ] ProjectCard (Card, Icon, Title)
- [ ] TaskCard (Card, Icon, Title)
- [ ] MemberCard (Avatar, Name) - si existe

### Page Transitions:

- [ ] WorkspaceListScreen → WorkspaceDetailScreen
- [ ] ProjectListScreen → ProjectDetailScreen
- [ ] TaskListScreen → TaskDetailScreen
- [ ] WorkspaceMembersScreen → MemberDetailScreen (si existe)
- [ ] Todos los demás Navigator.push

### List Animations:

- [ ] WorkspaceListScreen
- [ ] WorkspaceMembersScreen
- [ ] ProjectListScreen
- [ ] TaskListScreen

---

## 🎨 Recomendaciones de Estilo

### Transiciones por Tipo de Pantalla:

| Tipo de Navegación   | Transición Recomendada | Duración |
| -------------------- | ---------------------- | -------- |
| Detail screens       | `slideFromRight`       | 300ms    |
| Modal screens        | `slideFromBottom`      | 250ms    |
| Dialogs              | `scale`                | 200ms    |
| Settings subsections | `fade`                 | 200ms    |
| Back navigation      | Automático             | 300ms    |

### Stagger Delay por Cantidad:

| Items       | Delay | Duración |
| ----------- | ----- | -------- |
| < 10 items  | 50ms  | 400ms    |
| 10-20 items | 30ms  | 350ms    |
| > 20 items  | 20ms  | 300ms    |

---

## 🐛 Troubleshooting

### Error: "There are multiple heroes that share the same tag"

**Solución:** Asegúrate de que cada Hero tag sea único. Usa IDs en los tags.

```dart
// ❌ MAL
Hero(tag: 'workspace', ...)

// ✅ BIEN
Hero(tag: HeroTags.workspace(workspace.id), ...)
```

### Error: "Hero animation is jumpy"

**Solución:** Envuelve Text widgets con Material:

```dart
Hero(
  tag: HeroTags.workspaceTitle(id),
  child: Material(  // ← Importante
    color: Colors.transparent,
    child: Text(...),
  ),
)
```

### Animación no se ve suave

**Solución:** Ajusta la curva de animación:

```dart
CustomPageRoute(
  page: Screen(),
  curve: Curves.easeInOutCubic,  // ← Más suave
)
```

---

## ✨ Resultado Esperado

Después de implementar todos los pasos:

- ✅ **Hero animations** suaves en cards → detail
- ✅ **Page transitions** consistentes en toda la app
- ✅ **Staggered animations** en todas las listas
- ✅ **60 FPS** de rendimiento
- ✅ **Sensación premium** en la UX

---

**Tiempo estimado total:** 2-3 horas  
**Dificultad:** Media  
**Impacto:** Alto ⭐⭐⭐⭐⭐
