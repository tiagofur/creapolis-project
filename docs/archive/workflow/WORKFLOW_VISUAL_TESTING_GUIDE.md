# 🧪 Guía de Testing - Personalización Visual de Workflows

## Descripción

Este documento proporciona una guía paso a paso para probar la personalización visual de workflows (proyectos) con los tres tipos de relación: Personal, Compartido por mí, y Compartido conmigo.

## Prerequisitos

1. Backend ejecutándose (`make start-backend`)
2. Flutter app ejecutándose (`cd creapolis_app && flutter run`)
3. Al menos 2 usuarios registrados en el sistema

## Escenarios de Testing

### Escenario 1: Proyecto Personal

**Objetivo**: Validar que un proyecto personal no muestra marcador adicional.

**Pasos**:
1. Iniciar sesión con Usuario A
2. Crear un nuevo proyecto
3. No agregar miembros adicionales al proyecto
4. Verificar que el proyecto aparece con:
   - ✅ Color primario del tema (azul) en el header
   - ✅ Badge de estado del proyecto (Planificado/Activo/etc)
   - ✅ **NO** muestra marcador adicional de compartición
   - ✅ Barra de progreso en color primario

**Resultado Esperado**:
```
┌─────────────────────────┐
│ [Activo]                │ ← Color primario (azul)
├─────────────────────────┤
│ Mi Proyecto Personal    │
│ Descripción...          │
│ ████████░░░░ 60%        │
│ 📅 01/01/2025 - 31/12/25│
└─────────────────────────┘
```

### Escenario 2: Proyecto Compartido por Mí

**Objetivo**: Validar que un proyecto compartido por el usuario muestra el marcador "Compartido por mí".

**Pasos**:
1. Iniciar sesión con Usuario A (manager)
2. Crear un nuevo proyecto
3. Agregar a Usuario B como miembro del proyecto
4. Verificar que el proyecto aparece con:
   - ✅ Color primario del tema (azul) en el header
   - ✅ Badge de estado del proyecto
   - ✅ **Marcador "Compartido por mí"** con icono de compartir (púrpura)
   - ✅ Barra de progreso en color primario

**Resultado Esperado**:
```
┌─────────────────────────────────────┐
│ [Activo] [↗ Compartido por mí]      │ ← Badge púrpura
├─────────────────────────────────────┤
│ Proyecto Colaborativo               │
│ Descripción...                      │
│ ████████░░░░ 60%                    │
│ 📅 01/01/2025 - 31/12/25            │
└─────────────────────────────────────┘
```

### Escenario 3: Proyecto Compartido Conmigo

**Objetivo**: Validar que un proyecto compartido con el usuario muestra el marcador "Compartido conmigo".

**Pasos**:
1. Iniciar sesión con Usuario A (manager)
2. Crear un nuevo proyecto
3. Agregar a Usuario B como miembro
4. Cerrar sesión y entrar con Usuario B
5. Verificar que el proyecto aparece con:
   - ✅ Color primario del tema (azul) en el header
   - ✅ Badge de estado del proyecto
   - ✅ **Marcador "Compartido conmigo"** con icono de grupo (verde)
   - ✅ Barra de progreso en color primario

**Resultado Esperado**:
```
┌─────────────────────────────────────┐
│ [Activo] [👥 Compartido conmigo]    │ ← Badge verde
├─────────────────────────────────────┤
│ Proyecto Colaborativo               │
│ Descripción...                      │
│ ████████░░░░ 60%                    │
│ 📅 01/01/2025 - 31/12/25            │
└─────────────────────────────────────┘
```

## Pruebas de Interfaz

### Test 1: Consistencia de Color

**Verificar**:
- ✅ Todos los proyectos usan el mismo color primario (azul)
- ✅ El color NO cambia según el estado del proyecto
- ✅ El color NO varía entre proyectos personales y compartidos

### Test 2: Visibilidad de Marcadores

**Verificar**:
- ✅ Los marcadores son claramente visibles
- ✅ El texto del marcador es legible
- ✅ Los iconos son reconocibles
- ✅ Los colores contrastan adecuadamente

### Test 3: Responsive Design

**Verificar en diferentes tamaños de pantalla**:
- ✅ Móvil (pequeño): Los marcadores se ajustan correctamente
- ✅ Tablet (mediano): Grid de 2-3 columnas muestra marcadores
- ✅ Desktop (grande): Los marcadores mantienen el diseño

### Test 4: Estados de Proyecto

**Verificar con diferentes estados**:
- ✅ Planificado
- ✅ Activo
- ✅ Pausado
- ✅ Completado
- ✅ Cancelado

Todos deben usar el color primario + marcador correspondiente.

## Checklist de Validación

### Funcionalidad
- [ ] Los proyectos personales no muestran marcador
- [ ] Los proyectos compartidos por el usuario muestran badge púrpura con icono de compartir
- [ ] Los proyectos compartidos con el usuario muestran badge verde con icono de grupo
- [ ] Los marcadores son correctos independientemente del estado del proyecto

### Diseño Visual
- [ ] Todos los proyectos usan el color primario del tema
- [ ] Los badges tienen bordes redondeados
- [ ] Los iconos tienen el tamaño correcto
- [ ] El texto de los badges es legible
- [ ] Los colores son accesibles (contraste adecuado)

### Experiencia de Usuario
- [ ] Es fácil distinguir entre los tres tipos de proyectos
- [ ] Los marcadores no afectan la legibilidad del contenido
- [ ] El diseño es limpio y no sobrecargado
- [ ] La información es clara sin necesidad de explicación adicional

### Código
- [ ] No hay errores de compilación
- [ ] No hay warnings en la consola
- [ ] El código está documentado
- [ ] Los widgets son reutilizables

## Problemas Conocidos

### Limitación Actual: `hasOtherMembers`

⚠️ **Importante**: Actualmente, el parámetro `hasOtherMembers` está hardcoded a `false` en `ProjectsListScreen`:

```dart
ProjectCard(
  project: project,
  currentUserId: currentUserId,
  hasOtherMembers: false, // TODO: Obtener del backend
  ...
)
```

**Impacto**: No se pueden probar completamente los escenarios 2 y 3 (proyectos compartidos) hasta que:
1. El backend devuelva la información de miembros del proyecto, o
2. Se implemente un endpoint para obtener el conteo de miembros

**Solución temporal para testing**:
1. Cambiar manualmente a `hasOtherMembers: true` en el código
2. Recargar la app con hot reload
3. Verificar que los marcadores aparecen correctamente

## Notas para Desarrollo Futuro

### Backend API Necesaria

Para soporte completo, el backend debe proporcionar:

```json
{
  "id": 1,
  "name": "Proyecto",
  "managerId": 1,
  "memberCount": 3,  // ← Necesario
  "members": [       // ← O lista de miembros
    {"userId": 1, "role": "manager"},
    {"userId": 2, "role": "member"},
    {"userId": 3, "role": "member"}
  ]
}
```

### Extensiones Posibles

1. **Tooltip**: Agregar tooltip al hover sobre el marcador con más información
2. **Animación**: Animar la aparición del marcador
3. **Filtrado**: Permitir filtrar proyectos por tipo de relación
4. **Ordenamiento**: Ordenar proyectos por tipo de relación
5. **Estadísticas**: Mostrar conteo de cada tipo de proyecto

## Recursos

- **Documentación completa**: `WORKFLOW_VISUAL_PERSONALIZATION.md`
- **Código fuente**:
  - Entity: `lib/domain/entities/project.dart`
  - Widget Marker: `lib/presentation/widgets/project/project_relation_marker.dart`
  - Widget Card: `lib/presentation/widgets/project/project_card.dart`
  - Screen: `lib/presentation/screens/projects/projects_list_screen.dart`
