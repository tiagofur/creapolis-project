# 🧩 Biblioteca de Componentes Creapolis

Documentación completa de todos los componentes reutilizables del Design System de Creapolis.

---

## 📋 Tabla de Contenidos

- [Botones](#-botones)
- [Cards](#-cards)
- [Inputs y Formularios](#-inputs-y-formularios)
- [Feedback y Estados](#-feedback-y-estados)
- [Status y Badges](#-status-y-badges)
- [Guías de Uso](#-guías-de-uso)

---

## 🔵 Botones

### PrimaryButton

Botón principal para acciones primarias e importantes.

#### Propiedades

```dart
PrimaryButton({
  required String text,           // Texto del botón
  VoidCallback? onPressed,        // Callback al presionar
  bool isLoading = false,         // Muestra loading spinner
  bool isFullWidth = false,       // Ocupa ancho completo
  IconData? icon,                 // Icono opcional (izquierda)
})
```

#### Ejemplos de Uso

```dart
// Botón simple
PrimaryButton(
  text: 'Guardar',
  onPressed: () => _saveData(),
)

// Botón con icono
PrimaryButton(
  text: 'Iniciar Sesión',
  icon: Icons.login,
  onPressed: () => _login(),
)

// Botón con loading
PrimaryButton(
  text: 'Guardando...',
  isLoading: true,
  onPressed: null,  // Deshabilitado durante loading
)

// Botón de ancho completo
PrimaryButton(
  text: 'Continuar',
  isFullWidth: true,
  onPressed: () => _continue(),
)
```

#### Cuándo Usar

✅ **DO**:
- Acción principal de la pantalla (Guardar, Enviar, Continuar)
- Una sola acción primaria por pantalla/sección
- Cuando la acción es destructiva pero confirmada (Eliminar después de confirmación)

❌ **DON'T**:
- Múltiples botones primarios juntos
- Acciones secundarias o de menor importancia
- Cancelar o cerrar

#### Estados

| Estado | Descripción | Visual |
|--------|-------------|--------|
| Default | Botón activo | Fondo azul primario |
| Hover | Ratón encima | Fondo azul más oscuro |
| Pressed | Siendo presionado | Fondo azul más oscuro + elevación |
| Disabled | No disponible | Gris, sin interacción |
| Loading | Procesando | Spinner blanco, botón deshabilitado |

---

### SecondaryButton

Botón secundario para acciones alternativas.

#### Propiedades

```dart
SecondaryButton({
  required String text,           // Texto del botón
  VoidCallback? onPressed,        // Callback al presionar
  bool isFullWidth = false,       // Ocupa ancho completo
  IconData? icon,                 // Icono opcional (izquierda)
})
```

#### Ejemplos de Uso

```dart
// Botón simple
SecondaryButton(
  text: 'Cancelar',
  onPressed: () => Navigator.pop(context),
)

// Botón con icono
SecondaryButton(
  text: 'Exportar',
  icon: Icons.download,
  onPressed: () => _export(),
)

// Combinado con botón primario
Row(
  children: [
    SecondaryButton(
      text: 'Cancelar',
      onPressed: () => Navigator.pop(context),
    ),
    SizedBox(width: 12),
    PrimaryButton(
      text: 'Guardar',
      onPressed: () => _save(),
    ),
  ],
)
```

#### Cuándo Usar

✅ **DO**:
- Acciones secundarias (Cancelar, Volver, Descartar)
- Alternativas a la acción principal
- Acciones no destructivas de menor prioridad

❌ **DON'T**:
- Acción principal de la pantalla
- Más de 2-3 botones secundarios visibles al mismo tiempo

---

### TextButton

Botón de texto para acciones terciarias (incluido en Flutter).

#### Ejemplo de Uso

```dart
TextButton(
  onPressed: () => _showHelp(),
  child: Text('¿Necesitas ayuda?'),
)

TextButton.icon(
  onPressed: () => _viewMore(),
  icon: Icon(Icons.arrow_forward),
  label: Text('Ver más'),
)
```

#### Cuándo Usar

✅ **DO**:
- Enlaces dentro de texto
- Acciones menos importantes
- Navegación secundaria
- "Ver más", "Aprender más", etc.

---

### OutlinedButton

Botón con borde para acciones alternativas (incluido en Flutter).

#### Ejemplo de Uso

```dart
OutlinedButton(
  onPressed: () => _selectOption(),
  child: Text('Seleccionar'),
)

OutlinedButton.icon(
  onPressed: () => _addItem(),
  icon: Icon(Icons.add),
  label: Text('Agregar'),
)
```

#### Cuándo Usar

✅ **DO**:
- Opciones de selección múltiple
- Acciones de igual importancia
- Toggles y filtros

---

## 📄 Cards

### CustomCard

Card personalizable para contener contenido agrupado.

#### Propiedades

```dart
CustomCard({
  required Widget child,               // Contenido del card
  EdgeInsetsGeometry? padding,         // Padding interno (default: 16px)
  VoidCallback? onTap,                 // Hace el card clickeable
  Color? color,                        // Color de fondo personalizado
})
```

#### Ejemplos de Uso

```dart
// Card simple
CustomCard(
  child: Column(
    children: [
      Text('Título', style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('Contenido del card'),
    ],
  ),
)

// Card clickeable
CustomCard(
  onTap: () => _navigateToDetail(),
  child: ListTile(
    leading: Icon(Icons.folder),
    title: Text('Proyecto Alpha'),
    subtitle: Text('3 tareas pendientes'),
    trailing: Icon(Icons.arrow_forward_ios),
  ),
)

// Card con padding personalizado
CustomCard(
  padding: EdgeInsets.all(24),
  child: Text('Contenido con más espacio'),
)

// Card con color personalizado
CustomCard(
  color: Colors.blue.shade50,
  child: Text('Card destacado'),
)
```

#### Variantes Comunes

```dart
// Card de información
CustomCard(
  child: Row(
    children: [
      Icon(Icons.info_outline, color: AppColors.info),
      SizedBox(width: 12),
      Expanded(
        child: Text('Información importante'),
      ),
    ],
  ),
)

// Card de estadística
CustomCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Tareas Completadas', style: Theme.of(context).textTheme.bodySmall),
      SizedBox(height: 4),
      Text('42', style: Theme.of(context).textTheme.headlineMedium),
    ],
  ),
)
```

#### Cuándo Usar

✅ **DO**:
- Agrupar información relacionada
- Listas de elementos (proyectos, tareas)
- Dashboards y estadísticas
- Contenedores de formularios

❌ **DON'T**:
- Anidar cards dentro de cards (evitar profundidad excesiva)
- Usar para elementos muy simples (usar Container)

---

## 📝 Inputs y Formularios

### ValidatedTextField

Input de texto con validación automática y feedback visual.

#### Propiedades

```dart
ValidatedTextField({
  TextEditingController? controller,      // Controlador del texto
  String? label,                          // Etiqueta del campo
  String? hint,                           // Placeholder
  String? helperText,                     // Texto de ayuda
  IconData? prefixIcon,                   // Icono inicial
  Widget? suffixIcon,                     // Widget final
  bool obscureText = false,               // Para contraseñas
  TextInputType? keyboardType,            // Tipo de teclado
  List<TextInputFormatter>? inputFormatters,  // Formateadores
  String? Function(String?)? validator,   // Función de validación
  ValueChanged<String>? onChanged,        // Callback de cambio
  VoidCallback? onEditingComplete,        // Callback al completar
  bool enabled = true,                    // Estado habilitado
  int? maxLines = 1,                      // Número de líneas
  int? maxLength,                         // Longitud máxima
  bool validateOnType = true,             // Validar al escribir
  Duration debounceTime = 500ms,          // Tiempo de debounce
})
```

#### Ejemplos de Uso

```dart
// Email con validación
ValidatedTextField(
  label: 'Email',
  hint: 'correo@ejemplo.com',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: Validators.email,
)

// Contraseña
ValidatedTextField(
  label: 'Contraseña',
  hint: 'Mínimo 8 caracteres',
  prefixIcon: Icons.lock,
  obscureText: true,
  validator: Validators.password,
)

// Campo de texto con ayuda
ValidatedTextField(
  label: 'Nombre del proyecto',
  helperText: 'Usa un nombre descriptivo y único',
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length < 3) {
      return 'Mínimo 3 caracteres';
    }
    return null;
  },
)

// Área de texto (multilinea)
ValidatedTextField(
  label: 'Descripción',
  maxLines: 4,
  maxLength: 500,
  hint: 'Describe el proyecto...',
)
```

#### Features

- ✅ Validación en tiempo real con debounce
- ✅ Iconos de estado (✓ válido, ✗ inválido)
- ✅ Borde verde cuando válido
- ✅ Mensajes de error contextuales
- ✅ Feedback visual inmediato

---

### ValidatedDropdown

Selector dropdown con validación.

#### Propiedades

```dart
ValidatedDropdown<T>({
  required T? value,                          // Valor seleccionado
  required List<DropdownMenuItem<T>> items,   // Opciones
  required ValueChanged<T?> onChanged,        // Callback de cambio
  String? label,                              // Etiqueta
  String? hint,                               // Texto de placeholder
  String? helperText,                         // Texto de ayuda
  IconData? prefixIcon,                       // Icono inicial
  String? Function(T?)? validator,            // Validación
  bool enabled = true,                        // Estado habilitado
})
```

#### Ejemplo de Uso

```dart
ValidatedDropdown<TaskStatus>(
  label: 'Estado',
  value: _selectedStatus,
  items: TaskStatus.values.map((status) {
    return DropdownMenuItem(
      value: status,
      child: Text(status.displayName),
    );
  }).toList(),
  onChanged: (value) => setState(() => _selectedStatus = value),
  validator: (value) {
    if (value == null) return 'Selecciona un estado';
    return null;
  },
)
```

---

### ValidatedCheckbox

Checkbox con etiqueta y validación.

#### Propiedades

```dart
ValidatedCheckbox({
  required bool value,                    // Valor actual
  required ValueChanged<bool> onChanged,  // Callback de cambio
  required String label,                  // Texto de la etiqueta
  String? Function(bool?)? validator,     // Validación
  bool enabled = true,                    // Estado habilitado
})
```

#### Ejemplo de Uso

```dart
ValidatedCheckbox(
  value: _acceptedTerms,
  label: 'Acepto los términos y condiciones',
  onChanged: (value) => setState(() => _acceptedTerms = value),
  validator: (value) {
    if (value != true) return 'Debes aceptar los términos';
    return null;
  },
)
```

---

## 💬 Feedback y Estados

### LoadingWidget

Indicador de carga para estados de procesamiento.

#### Propiedades

```dart
LoadingWidget({
  String? message,  // Mensaje opcional
})
```

#### Ejemplos de Uso

```dart
// Loading simple
LoadingWidget()

// Loading con mensaje
LoadingWidget(
  message: 'Cargando proyectos...',
)

// En condicional
if (state is ProjectsLoading) {
  return LoadingWidget(message: 'Cargando...');
}
```

#### Cuándo Usar

✅ **DO**:
- Carga de datos inicial
- Operaciones que toman >500ms
- Transiciones entre pantallas

❌ **DON'T**:
- Para operaciones instantáneas (<500ms)
- Cuando hay contenido parcial disponible (usar Shimmer)

---

### ErrorWidget

Pantalla de error con opción de reintentar.

#### Propiedades

```dart
ErrorWidget({
  required String message,   // Mensaje de error
  VoidCallback? onRetry,     // Callback para reintentar
})
```

#### Ejemplos de Uso

```dart
// Error simple
ErrorWidget(
  message: 'No se pudo cargar los datos',
)

// Error con retry
ErrorWidget(
  message: 'Error de conexión',
  onRetry: () => _reload(),
)

// En BLoC
if (state is ProjectsError) {
  return ErrorWidget(
    message: state.message,
    onRetry: () => context.read<ProjectBloc>().add(LoadProjects()),
  );
}
```

#### Tipos de Errores

```dart
// Error de red
ErrorWidget(
  message: 'No se pudo conectar al servidor. Verifica tu conexión.',
  onRetry: () => _retry(),
)

// Error de validación
ErrorWidget(
  message: 'Los datos ingresados no son válidos.',
)

// Error general
ErrorWidget(
  message: 'Algo salió mal. Por favor, intenta nuevamente.',
  onRetry: () => _retry(),
)
```

---

### EmptyWidget

Estado vacío cuando no hay datos para mostrar.

#### Propiedades

```dart
EmptyWidget({
  String? message,    // Mensaje personalizado
  IconData? icon,     // Icono personalizado
})
```

#### Ejemplos de Uso

```dart
// Empty simple
EmptyWidget()

// Empty personalizado
EmptyWidget(
  message: 'No tienes proyectos aún',
  icon: Icons.folder_open,
)

// Empty con acción
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    EmptyWidget(
      message: 'No hay tareas para hoy',
      icon: Icons.check_circle_outline,
    ),
    SizedBox(height: 24),
    PrimaryButton(
      text: 'Crear nueva tarea',
      icon: Icons.add,
      onPressed: () => _createTask(),
    ),
  ],
)
```

#### Cuándo Usar

✅ **DO**:
- Listas vacías
- Búsquedas sin resultados
- Estados iniciales sin datos
- Filtros que no devuelven resultados

❌ **DON'T**:
- Durante la carga inicial (usar LoadingWidget)
- Para errores (usar ErrorWidget)

---

## 🏷️ Status y Badges

### StatusBadgeWidget

Badge interactivo que muestra y permite cambiar el estado de una tarea.

#### Propiedades

```dart
StatusBadgeWidget({
  required Task task,       // Tarea con el estado
  bool showIcon = true,     // Mostrar icono del estado
  double? fontSize,         // Tamaño de fuente personalizado
})
```

#### Ejemplo de Uso

```dart
StatusBadgeWidget(
  task: task,
  showIcon: true,
)
```

#### Features

- ✅ Click para cambiar estado
- ✅ Menú contextual con opciones
- ✅ Colores por estado (Planned, In Progress, Completed, etc.)
- ✅ Iconos descriptivos
- ✅ Feedback inmediato

#### Estados Disponibles

| Estado | Color | Icono |
|--------|-------|-------|
| Planned | Gris | `radio_button_unchecked` |
| In Progress | Azul | `play_circle_outline` |
| Completed | Verde | `check_circle_outline` |
| Blocked | Rojo | `block` |
| Cancelled | Gris claro | `cancel_outlined` |

---

### PriorityBadgeWidget

Badge que muestra la prioridad de una tarea.

#### Propiedades

```dart
PriorityBadgeWidget({
  required Task task,       // Tarea con la prioridad
  bool showIcon = true,     // Mostrar icono de prioridad
  double? fontSize,         // Tamaño de fuente personalizado
  VoidCallback? onTap,      // Callback opcional al hacer click
})
```

#### Ejemplo de Uso

```dart
PriorityBadgeWidget(
  task: task,
  showIcon: true,
)
```

#### Prioridades Disponibles

| Prioridad | Color | Icono |
|-----------|-------|-------|
| Low | Verde | `arrow_downward` |
| Medium | Naranja | `remove` |
| High | Naranja oscuro | `arrow_upward` |
| Critical | Rojo | `priority_high` |

---

## 📐 Guías de Uso

### Composición de Componentes

#### Formulario Completo

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      ValidatedTextField(
        label: 'Nombre del proyecto',
        validator: Validators.required,
      ),
      SizedBox(height: AppSpacing.md),
      
      ValidatedTextField(
        label: 'Descripción',
        maxLines: 3,
      ),
      SizedBox(height: AppSpacing.md),
      
      ValidatedDropdown<ProjectStatus>(
        label: 'Estado',
        value: _status,
        items: _statusItems,
        onChanged: (value) => setState(() => _status = value),
      ),
      SizedBox(height: AppSpacing.lg),
      
      Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: 'Cancelar',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: PrimaryButton(
              text: 'Guardar',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ),
        ],
      ),
    ],
  ),
)
```

#### Card de Proyecto

```dart
CustomCard(
  onTap: () => _openProject(project),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header con título y estado
      Row(
        children: [
          Expanded(
            child: Text(
              project.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          StatusBadgeWidget(task: project.mainTask),
        ],
      ),
      SizedBox(height: AppSpacing.sm),
      
      // Descripción
      Text(
        project.description,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: AppSpacing.md),
      
      // Footer con metadata
      Row(
        children: [
          Icon(Icons.person, size: 16),
          SizedBox(width: 4),
          Text('${project.members.length} miembros'),
          Spacer(),
          Icon(Icons.calendar_today, size: 16),
          SizedBox(width: 4),
          Text(DateFormat.yMd().format(project.dueDate)),
        ],
      ),
    ],
  ),
)
```

#### Estados de la Pantalla

```dart
Widget build(BuildContext context) {
  return BlocBuilder<ProjectBloc, ProjectState>(
    builder: (context, state) {
      if (state is ProjectsLoading) {
        return LoadingWidget(message: 'Cargando proyectos...');
      }
      
      if (state is ProjectsError) {
        return ErrorWidget(
          message: state.message,
          onRetry: () => _loadProjects(),
        );
      }
      
      if (state is ProjectsLoaded) {
        if (state.projects.isEmpty) {
          return EmptyWidget(
            message: 'No tienes proyectos aún',
            icon: Icons.folder_open,
          );
        }
        
        return _buildProjectList(state.projects);
      }
      
      return SizedBox.shrink();
    },
  );
}
```

---

## ✅ Checklist de Uso

Al usar componentes, asegúrate de:

- [ ] Usar el componente apropiado para cada caso
- [ ] Proporcionar todos los parámetros requeridos
- [ ] Seguir las guías de espaciado (AppSpacing)
- [ ] Mantener consistencia visual con otros componentes
- [ ] Proporcionar feedback al usuario (loading, errores)
- [ ] Validar inputs de formularios
- [ ] Usar colores del theme, no hardcoded
- [ ] Considerar accesibilidad (tamaños mínimos, contraste)
- [ ] Manejar estados de carga y error apropiadamente
- [ ] Probar en diferentes tamaños de pantalla

---

## 🔗 Referencias

- [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) - Sistema de diseño completo
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Arquitectura de la aplicación
- [Material Design Components](https://m3.material.io/components)

---

**Última actualización**: Octubre 2025  
**Versión**: 1.0.0  
**Mantenido por**: Equipo Creapolis
