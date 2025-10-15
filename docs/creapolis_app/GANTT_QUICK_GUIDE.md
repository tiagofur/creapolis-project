# 🚀 Guía Rápida: Diagramas de Gantt Dinámicos

## 📊 Cómo Usar el Gantt Chart

### Acceso
```
Dashboard → Seleccionar Proyecto → Tab "Gantt" 
```

### Características Principales

#### 1. 🔍 Zoom y Navegación
- **Zoom In**: Botón `🔍+` o pellizcar hacia afuera
- **Zoom Out**: Botón `🔍-` o pellizcar hacia adentro  
- **Scroll Horizontal**: Arrastra el chart izquierda/derecha
- **Scroll Vertical**: Arrastra arriba/abajo para ver más tareas

#### 2. 🎯 Interacción con Tareas
- **Tap simple**: Selecciona y muestra detalles
- **Long press**: Menú de opciones (Editar, Replanificar)
- **Arrastre horizontal**: Cambia fechas de la tarea*

*Requiere confirmación

#### 3. 👥 Vista de Recursos
- **Toggle**: Botón `👥` en AppBar
- **Ver**: Carga de trabajo por persona
- **Expandir**: Click en card para ver tareas asignadas
- **Regresar a Gantt**: Botón `📊`

#### 4. 📥 Exportación
- **Abrir menú**: Botón `📥` en AppBar
- **Opciones**:
  - 🖼️ Exportar como Imagen → Guarda PNG
  - 📄 Exportar como PDF → Comparte documento
  - 📤 Compartir → Share nativo del sistema

#### 5. 🧮 Planificación Automática
- **Calcular Cronograma**: Botón `🧮` en AppBar
- **Función**: Calcula fechas óptimas basadas en:
  - Dependencias entre tareas
  - Duración estimada
  - Disponibilidad de recursos
- **Efecto**: Actualiza todas las fechas automáticamente

#### 6. 🔄 Replanificación
- **Desde Gantt**: Long press → Replanificar
- **Desde Detalle**: Botón "Replanificar" en diálogo
- **Función**: Recalcula fechas desde una tarea específica
- **Útil para**: Ajustar cronograma tras retrasos

---

## 🎨 Código de Colores

### Estados de Tareas
| Color | Estado | Significado |
|-------|--------|-------------|
| 🟢 Verde | Completada | Tarea finalizada |
| 🔵 Azul | En Progreso | Actualmente trabajando |
| ⚫ Gris Oscuro | Planificada | Pendiente de iniciar |
| 🔴 Rojo | Bloqueada | No puede avanzar |
| ⚪ Gris Claro | Cancelada | Ya no se realizará |

### Prioridades (Indicador circular)
| Color | Prioridad |
|-------|-----------|
| 🔴 Rojo | Crítica |
| 🟠 Naranja | Alta |
| - | Media (sin indicador) |
| - | Baja (sin indicador) |

### Dependencias
| Símbolo | Significado |
|---------|-------------|
| → | Flecha de dependencia |
| Línea gris | Conexión entre tareas |

---

## 📋 Panel de Recursos

### Información Mostrada
```
👤 Nombre del Asignado
├─ X tareas · Y.Zh (total de horas)
├─ Barra de progreso: [████████░░░░] Completadas | En Progreso | Planificadas
└─ Lista de tareas asignadas
   ├─ • Tarea 1  DD/MM - DD/MM  XXh
   ├─ • Tarea 2  DD/MM - DD/MM  XXh
   └─ • Tarea 3  DD/MM - DD/MM  XXh
```

### Barra de Progreso
- **Verde**: Tareas completadas
- **Azul**: Tareas en progreso
- **Gris**: Tareas planificadas

### Expansión de Cards
- Click en card → Expande/colapsa lista de tareas
- Click en tarea → Muestra detalle completo

---

## 🖱️ Drag & Drop de Fechas

### Cómo Funcionar
1. **Ubica la tarea** que deseas mover
2. **Click y mantén** sobre la barra de la tarea
3. **Arrastra horizontalmente** izquierda (adelantar) o derecha (retrasar)
4. **Suelta** cuando esté en la posición deseada
5. **Confirma** el cambio en el diálogo

### Visual Feedback
- Barra se torna **semi-transparente** (70% opacidad)
- **Sombra más pronunciada** alrededor de la barra
- Cursor cambia para indicar arrastre activo

### Restricciones
- Solo se puede mover **horizontalmente** (fechas)
- **No se puede mover verticalmente** (orden de tareas)
- Las **dependencias se mantienen** (ajustar manualmente si es necesario)

### Después del Cambio
- Se actualiza en **base de datos**
- Se recarga la **vista completa**
- **No afecta** automáticamente tareas dependientes (usar Replanificar)

---

## 📤 Exportación Detallada

### Exportar como Imagen
**Formato**: PNG  
**Resolución**: Alta (3x pixel ratio)  
**Ubicación**: Documentos de la app  
**Nombre**: `gantt_NombreProyecto_timestamp.png`

**Uso**:
```
1. Click en 📥
2. Seleccionar "Exportar como Imagen"
3. Esperar captura (loading)
4. Ver confirmación con path del archivo
```

### Exportar como PDF
**Formato**: Actualmente PNG (PDF real pendiente)  
**Acción**: Abre share sheet del sistema

**Uso**:
```
1. Click en 📥
2. Seleccionar "Exportar como PDF"
3. Esperar captura
4. Elegir app destino (Drive, Email, etc.)
```

### Compartir
**Formato**: PNG  
**Destino**: Cualquier app compatible

**Uso**:
```
1. Click en 📥
2. Seleccionar "Compartir"
3. Esperar captura
4. Elegir destinatario/plataforma
```

**Nota**: El archivo se guarda temporalmente y se elimina automáticamente.

---

## 🔧 Configuración y Preferencias

### Nivel de Zoom Inicial
Definido en: `initialDayWidth: 40.0` (GanttChartWidget)

Valores recomendados:
- **20**: Muy alejado (ver todo el proyecto)
- **40**: Normal (balance visualización/detalle)
- **60**: Acercado (ver pocos días con detalle)
- **100**: Muy cercano (máximo detalle por día)

### Altura de Tareas
Definido en: `taskHeight: 40.0`

No modificable desde UI actualmente.

---

## ⚡ Atajos de Teclado (Futuro)

Planificado para implementación futura:
- `+` / `-`: Zoom in/out
- `Space`: Pan mode
- `Ctrl+S`: Exportar
- `Ctrl+R`: Recargar
- `Ctrl+C`: Calcular cronograma

---

## 🐛 Solución de Problemas

### "No hay tareas para mostrar"
**Causa**: No hay tareas creadas en el proyecto  
**Solución**: Crear tareas desde el tab "Tareas"

### "Error al exportar"
**Causa**: Permisos de almacenamiento no otorgados  
**Solución**: Verificar permisos en Settings → Apps → Creapolis

### Drag & Drop no funciona
**Causa**: Gesto de zoom detectado en su lugar  
**Solución**: Asegúrate de hacer click/hold con un solo dedo

### Dependencias no se muestran
**Causa**: Tareas sin dependencias definidas  
**Solución**: Agregar dependencias desde editor de tareas

---

## 💡 Tips y Trucos

### 1. Mejor Visualización
- Usa **zoom 100%** para ver detalles diarios
- Usa **zoom 50%** para overview del proyecto completo

### 2. Gestión Eficiente
- Usa **Vista de Recursos** para detectar sobrecargas
- Usa **Calcular Cronograma** tras crear múltiples tareas
- Usa **Replanificar** cuando una tarea se retrasa

### 3. Colaboración
- **Exporta como Imagen** para presentaciones
- **Comparte** para revisión rápida con equipo
- **Captura pantallas específicas** con zoom personalizado

### 4. Productividad
- **Long press** es más rápido que abrir detalles
- **Drag & Drop** es más rápido que editar fechas manualmente
- **Toggle Gantt/Recursos** frecuentemente para balance

---

## 📖 Recursos Adicionales

### Documentación Técnica
- [FASE_2_GANTT_COMPLETADA.md](./FASE_2_GANTT_COMPLETADA.md) - Documentación completa de implementación

### Roadmap
- [FLUTTER_ROADMAP.md](./FLUTTER_ROADMAP.md#gantt-chart) - Funcionalidades futuras

### Reportar Problemas
- GitHub Issues: [github.com/tiagofur/creapolis-project/issues](https://github.com/tiagofur/creapolis-project/issues)

---

## 🎯 Checklist de Funcionalidades

### Básicas
- [x] Ver diagrama de Gantt
- [x] Zoom in/out
- [x] Scroll horizontal/vertical
- [x] Ver detalles de tarea
- [x] Ver dependencias

### Avanzadas
- [x] Drag & drop de fechas
- [x] Vista de recursos
- [x] Exportar como imagen
- [x] Compartir diagrama
- [x] Calcular cronograma
- [x] Replanificar proyecto

### Futuras
- [ ] PDF real con múltiples páginas
- [ ] Edición in-line de fechas
- [ ] Ruta crítica visual
- [ ] Conflictos de recursos
- [ ] Undo/Redo
- [ ] Múltiples proyectos en un Gantt

---

**Última actualización**: Octubre 2025  
**Versión del documento**: 1.0  
**Autor**: Equipo Creapolis
