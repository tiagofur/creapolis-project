# 📱 CreopolisAppBar - Guía de Uso

## 🎯 Descripción

`CreopolisAppBar` es el AppBar estandarizado de Creapolis que **siempre muestra el workspace activo** mediante el `WorkspaceSwitcher` integrado. Inspirado en Notion, Slack y Asana, donde el contexto de trabajo (workspace) está siempre visible.

## ✨ Características

- ✅ **Workspace Switcher Integrado**: Muestra y permite cambiar el workspace activo
- ✅ **3 Variantes**: Estándar, con subtítulo, y compacta
- ✅ **Modo Búsqueda**: Oculta el switcher durante búsqueda activa
- ✅ **Responsive**: Se adapta a diferentes tamaños de pantalla
- ✅ **Consistencia**: Misma UX en todas las pantallas principales

## 📦 Variantes Disponibles

### 1. `CreopolisAppBar` (Estándar)

AppBar básico con título y workspace switcher.

```dart
CreopolisAppBar(
  title: 'Proyectos',
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () => _onSearch(),
    ),
  ],
)
```

**Parámetros:**

- `title` (String): Título principal
- `titleWidget` (Widget?): Widget personalizado para título (sobrescribe `title`)
- `actions` (List<Widget>?): Botones de acción en la derecha
- `showWorkspaceSwitcher` (bool): Mostrar switcher (default: true)
- `compactWorkspaceSwitcher` (bool): Usar versión compacta (default: false)
- `showWorkspaceSubtitle` (bool): Mostrar nombre del workspace como subtítulo
- `leading` (Widget?): Widget leading personalizado
- `automaticallyImplyLeading` (bool): Auto-agregar back button (default: true)
- `backgroundColor` (Color?): Color de fondo
- `elevation` (double?): Elevación del AppBar

### 2. `CreopolisAppBarWithSubtitle` (Con Subtítulo)

AppBar con título de dos líneas, ideal para pantallas como Dashboard.

```dart
CreopolisAppBarWithSubtitle(
  title: '¡Buenos días!',
  subtitle: 'John Doe',
  actions: [
    CircleAvatar(
      child: Text('JD'),
    ),
  ],
)
```

**Parámetros:**

- `title` (String): Título principal (línea superior)
- `subtitle` (String): Subtítulo (línea inferior)
- `titleStyle` (TextStyle?): Estilo del título
- `subtitleStyle` (TextStyle?): Estilo del subtítulo
- `actions` (List<Widget>?): Botones de acción
- `showWorkspaceSwitcher` (bool): Mostrar switcher (default: true)
- `compactWorkspaceSwitcher` (bool): Usar versión compacta (default: false)
- Otros parámetros comunes...

### 3. `CompactCreopolisAppBar` (Compacta)

Versión minimalista con workspace switcher compacto (solo icono).

```dart
CompactCreopolisAppBar(
  title: 'Configuración',
  actions: [
    IconButton(
      icon: const Icon(Icons.save),
      onPressed: () => _onSave(),
    ),
  ],
)
```

**Parámetros:**

- `title` (String): Título del AppBar
- `actions` (List<Widget>?): Botones de acción
- `leading` (Widget?): Widget leading personalizado
- `automaticallyImplyLeading` (bool): Auto-agregar back button (default: true)

## 🎨 Ejemplos de Uso

### Dashboard (con saludo personalizado)

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreopolisAppBarWithSubtitle(
        title: _getGreeting(), // "¡Buenos días!"
        subtitle: userName,    // "María García"
        showWorkspaceSwitcher: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              child: Text(_getInitials(userName)),
            ),
          ),
        ],
      ),
      body: _buildDashboardContent(),
    );
  }
}
```

### Proyectos (con búsqueda)

```dart
class ProjectsScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreopolisAppBar(
        title: 'Proyectos',
        titleWidget: _showSearch
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar proyectos...',
                  border: InputBorder.none,
                ),
              )
            : null,
        showWorkspaceSwitcher: !_showSearch, // Ocultar durante búsqueda
        actions: [
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _closeSearch,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _openSearch,
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilters,
            ),
          ],
        ],
      ),
      body: _buildProjectsList(),
    );
  }
}
```

### Tareas (con filtros)

```dart
Scaffold(
  appBar: CreopolisAppBar(
    title: 'Tareas',
    showWorkspaceSwitcher: true,
    actions: [
      IconButton(
        icon: Badge(
          isLabelVisible: _hasActiveFilters,
          child: const Icon(Icons.filter_list),
        ),
        onPressed: _showFilterMenu,
      ),
      IconButton(
        icon: const Icon(Icons.sort),
        onPressed: _showSortMenu,
      ),
    ],
  ),
  body: _buildTasksList(),
)
```

### Configuración (compacto)

```dart
Scaffold(
  appBar: CompactCreopolisAppBar(
    title: 'Configuración',
    actions: [
      IconButton(
        icon: const Icon(Icons.help_outline),
        onPressed: _showHelp,
      ),
    ],
  ),
  body: _buildSettingsForm(),
)
```

## 🔄 WorkspaceSwitcher Integrado

El `WorkspaceSwitcher` está **siempre integrado** en el AppBar y proporciona:

- **Visualización del workspace activo**: Nombre + ícono del tipo (Personal/Team/Enterprise)
- **Cambio rápido**: Dropdown con lista de todos los workspaces del usuario
- **Acceso a acciones**: "Seleccionar Workspace" y "Ver Todos"
- **Feedback visual**: Checkmark en el workspace activo

### Modos del WorkspaceSwitcher

#### Modo Normal (compactWorkspaceSwitcher: false)

```
┌─────────────────────────────┐
│ 🏢 Mi Empresa ▼            │
└─────────────────────────────┘
```

Muestra: ícono + nombre del workspace + dropdown arrow

#### Modo Compacto (compactWorkspaceSwitcher: true)

```
┌────────┐
│ 🏢 ▼  │
└────────┘
```

Muestra: solo ícono + dropdown arrow

## 📋 Pantallas donde se usa

### ✅ Implementado

1. **Dashboard** → `CreopolisAppBarWithSubtitle`

   - Muestra saludo + nombre de usuario
   - Workspace switcher en modo normal
   - Avatar del usuario en actions

2. **Proyectos** → `CreopolisAppBar`

   - Título estándar con búsqueda integrada
   - Workspace switcher oculto durante búsqueda
   - Botones de búsqueda y filtros

3. **Tareas** → `CreopolisAppBar`
   - Similar a Proyectos
   - Filtros por estado y prioridad

### 📝 Pendientes de Implementar

4. **Configuración** → `CompactCreopolisAppBar`
5. **Búsqueda Global** → `CreopolisAppBar`
6. **Calendario** → `CreopolisAppBar`
7. **Miembros** → `CompactCreopolisAppBar`

## 🎯 Buenas Prácticas

### ✅ DO

```dart
// ✅ Usar CreopolisAppBar en pantallas principales
appBar: CreopolisAppBar(
  title: 'Mi Pantalla',
  showWorkspaceSwitcher: true,
)

// ✅ Ocultar switcher durante búsqueda activa
appBar: CreopolisAppBar(
  title: 'Proyectos',
  showWorkspaceSwitcher: !_showSearch,
  titleWidget: _showSearch ? TextField(...) : null,
)

// ✅ Usar variante compacta en pantallas secundarias
appBar: CompactCreopolisAppBar(
  title: 'Detalles del Proyecto',
)
```

### ❌ DON'T

```dart
// ❌ No usar AppBar estándar en pantallas principales
appBar: AppBar(
  title: Text('Proyectos'),
)

// ❌ No mostrar switcher cuando no hay workspace activo
// (El componente lo maneja automáticamente)
appBar: CreopolisAppBar(
  title: 'Mi Pantalla',
  showWorkspaceSwitcher: workspaceContext.hasActiveWorkspace, // ❌ Innecesario
)

// ❌ No duplicar lógica del workspace switcher
appBar: AppBar(
  title: Text(workspaceContext.activeWorkspace?.name ?? ''), // ❌ Usar CreopolisAppBar
)
```

## 🔧 Personalización Avanzada

### Ocultar Workspace Switcher Dinámicamente

```dart
class MyScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreopolisAppBar(
        title: 'Mi Pantalla',
        showWorkspaceSwitcher: !_isEditMode, // Ocultar en modo edición
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: _save,
              child: Text('Guardar'),
            ),
        ],
      ),
    );
  }
}
```

### AppBar con Título Personalizado

```dart
CreopolisAppBar(
  title: 'Fallback', // Se ignora si titleWidget != null
  titleWidget: Row(
    children: [
      Icon(Icons.folder),
      SizedBox(width: 8),
      Text('Proyectos Destacados'),
    ],
  ),
)
```

### Colores Personalizados

```dart
CreopolisAppBar(
  title: 'Pantalla Especial',
  backgroundColor: Colors.deepPurple,
  elevation: 0,
  actions: [...],
)
```

## 🔍 Integración con WorkspaceContext

El AppBar se actualiza **automáticamente** cuando cambia el workspace activo:

```dart
// En cualquier parte de la app:
context.read<WorkspaceContext>().switchWorkspace(newWorkspace);

// El AppBar se actualiza automáticamente porque:
// 1. WorkspaceContext notifica cambios (extends ChangeNotifier)
// 2. CreopolisAppBar usa context.watch<WorkspaceContext>()
// 3. WorkspaceSwitcher también usa context.watch<WorkspaceContext>()
```

## 📱 Responsive Behavior

El componente se adapta automáticamente:

- **Pantallas grandes (>600px)**: WorkspaceSwitcher en modo normal
- **Pantallas pequeñas (<600px)**: WorkspaceSwitcher compacto (puede forzarse)
- **Durante búsqueda**: Switcher oculto para maximizar espacio del TextField

## 🎨 Temas y Estilos

El AppBar respeta el tema de la aplicación:

```dart
// Usa colores del ColorScheme actual
- backgroundColor: theme.colorScheme.surface
- foregroundColor: theme.colorScheme.onSurface
- WorkspaceSwitcher background: theme.colorScheme.surfaceContainerHighest
```

## 🚀 Roadmap

### Versión Actual (v1.0)

- ✅ 3 variantes (estándar, subtítulo, compacta)
- ✅ WorkspaceSwitcher integrado
- ✅ Responsive design
- ✅ Implementado en Dashboard, Projects, Tasks

### Futuras Mejoras

- [ ] Animación al cambiar workspace
- [ ] Breadcrumb navigation para pantallas anidadas
- [ ] Tabs support para pantallas con múltiples vistas
- [ ] Sticky header behavior para scroll

## 📞 Soporte

Para problemas o sugerencias:

1. Verificar que `WorkspaceContext` esté configurado en `main.dart`
2. Confirmar que el usuario tiene al menos un workspace
3. Revisar documentación de `WorkspaceSwitcher` si el problema es específico del switcher

---

**Última actualización**: Octubre 2025  
**Versión**: 1.0.0  
**Autor**: Equipo Creapolis
