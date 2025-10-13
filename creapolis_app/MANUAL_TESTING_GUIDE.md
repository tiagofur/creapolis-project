# Guía de Testing Manual - Personalización por Rol

## 🧪 Pre-requisitos

- Flutter SDK instalado
- Proyecto compilando sin errores
- Emulador o dispositivo físico conectado

---

## 📋 Tests Automatizados

### Ejecutar Tests Unitarios

```bash
cd creapolis_app
flutter test test/core/services/role_based_preferences_service_test.dart -r expanded
```

**Output Esperado:**
```
✓ debe inicializar correctamente
✓ debe cargar preferencias por defecto para admin sin datos guardados
✓ debe cargar preferencias por defecto para projectManager sin datos guardados
✓ debe cargar preferencias por defecto para teamMember sin datos guardados
✓ debe establecer override de tema correctamente
✓ debe limpiar override de tema correctamente
...
All tests passed!
```

### Ver Cobertura

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🎯 Escenarios de Testing Manual

### Escenario 1: Usuario Admin - Primera Vez

**Objetivo**: Verificar configuración por defecto para administrador

**Pasos**:
1. Login como usuario con rol `admin`
2. Ir al Dashboard
3. Verificar widgets visibles
4. Ir a More > Preferencias por Rol

**Resultados Esperados**:
- ✅ Dashboard muestra 6 widgets:
  1. Workspace Info
  2. Quick Stats
  3. Quick Actions
  4. My Projects
  5. My Tasks
  6. Recent Activity
- ✅ Tema sigue preferencia del sistema
- ✅ En Preferencias por Rol se muestra "Administrador"
- ✅ No hay indicadores "Personalizado"
- ✅ Tema muestra "Usando el default de tu rol"
- ✅ Dashboard muestra "Usando el dashboard por defecto de tu rol"

**Captura Recomendada**: Dashboard completo con 6 widgets

---

### Escenario 2: Usuario Team Member - Primera Vez

**Objetivo**: Verificar configuración por defecto para miembro del equipo

**Pasos**:
1. Cerrar sesión del admin
2. Login como usuario con rol `teamMember`
3. Ir al Dashboard
4. Verificar widgets visibles
5. Ir a More > Preferencias por Rol

**Resultados Esperados**:
- ✅ Dashboard muestra 4 widgets:
  1. Workspace Info
  2. My Tasks (priorizado)
  3. Quick Stats
  4. My Projects
- ✅ Tema es Light por defecto
- ✅ En Preferencias por Rol se muestra "Miembro del Equipo"
- ✅ Descripción: "Colaboras en proyectos y completas tareas..."
- ✅ No hay indicadores "Personalizado"

**Captura Recomendada**: Dashboard con 4 widgets, enfoque en "My Tasks"

---

### Escenario 3: Personalización de Tema

**Objetivo**: Verificar que los overrides funcionan correctamente

**Pasos**:
1. Como `teamMember` (tema Light por defecto)
2. Ir a Preferencias por Rol
3. Click en botón "Editar" junto a Tema
4. Observar cambios en la UI
5. Verificar indicador "Personalizado"
6. Cerrar app completamente
7. Volver a abrir y hacer login

**Resultados Esperados**:
- ✅ Al hacer click en editar, tema cambia a Dark
- ✅ Aparece chip verde "Personalizado" junto a Tema
- ✅ Texto cambia a "Estás usando tu personalización (default: Claro)"
- ✅ Icono del botón cambia de "edit" a "clear"
- ✅ Después de reiniciar, tema Dark persiste
- ✅ Indicador "Personalizado" sigue presente

**Captura Recomendada**: Card de Tema con indicador "Personalizado"

---

### Escenario 4: Personalización de Dashboard

**Objetivo**: Verificar override de widgets

**Pasos**:
1. Como `projectManager` (5 widgets por defecto)
2. Ir a Dashboard
3. Click en "Personalizar" (botón en AppBar)
4. Eliminar widget "Recent Activity"
5. Click en "Guardar"
6. Ir a Preferencias por Rol
7. Observar el indicador

**Resultados Esperados**:
- ✅ Dashboard queda con 4 widgets
- ✅ En Preferencias por Rol aparece chip "Personalizado" en Dashboard
- ✅ Texto muestra "Estás usando tu personalización"
- ✅ Muestra "4 widgets configurados"
- ✅ Lista de chips muestra los 4 widgets activos

**Captura Recomendada**: Card de Dashboard con indicador "Personalizado"

---

### Escenario 5: Limpiar Override Individual

**Objetivo**: Verificar volver a default del rol en un elemento

**Pasos**:
1. Con overrides activos (Escenarios 3 y 4)
2. Ir a Preferencias por Rol
3. Click en "X" (clear) junto a Tema
4. Observar cambios

**Resultados Esperados**:
- ✅ Tema vuelve al default del rol (Light para teamMember)
- ✅ Chip "Personalizado" desaparece de Tema
- ✅ Texto vuelve a "Usando el default de tu rol"
- ✅ Icono vuelve a "edit"
- ✅ Dashboard override sigue activo

**Captura Recomendada**: Card de Tema sin indicador después de clear

---

### Escenario 6: Resetear Todo

**Objetivo**: Verificar reseteo completo a defaults del rol

**Pasos**:
1. Con múltiples overrides activos
2. Ir a Preferencias por Rol
3. Click en botón "Resetear" en AppBar
4. Leer diálogo de confirmación
5. Click en "Resetear"
6. Observar cambios

**Resultados Esperados**:
- ✅ Aparece AlertDialog con:
  - Título: "Resetear Configuración"
  - Mensaje explicativo
  - Botones "Cancelar" y "Resetear"
- ✅ Al confirmar, muestra SnackBar "Configuración reseteada correctamente"
- ✅ Todos los chips "Personalizado" desaparecen
- ✅ Tema vuelve al default del rol
- ✅ Dashboard vuelve al default del rol
- ✅ Todos los textos muestran "Usando el default de tu rol"

**Captura Recomendada**: AlertDialog de confirmación

---

### Escenario 7: Cambio de Rol

**Objetivo**: Verificar que overrides no afectan al cambiar de rol

**Pasos**:
1. Como `admin` con overrides activos
2. Guardar configuración
3. Cerrar sesión
4. Login como `teamMember`
5. Ir a Dashboard y Preferencias por Rol

**Resultados Esperados**:
- ✅ Dashboard muestra configuración de teamMember (4 widgets)
- ✅ No hay indicadores "Personalizado" del admin
- ✅ Tema es Light (default de teamMember)
- ✅ En Preferencias por Rol se muestra "Miembro del Equipo"

**Captura Recomendada**: Dashboard de teamMember sin overrides del admin

---

### Escenario 8: Persistencia entre Sesiones

**Objetivo**: Verificar que las preferencias persisten

**Pasos**:
1. Como `admin`
2. Establecer tema Dark
3. Personalizar dashboard (eliminar un widget)
4. Verificar indicadores "Personalizado"
5. Cerrar app completamente
6. Volver a abrir y login como mismo usuario

**Resultados Esperados**:
- ✅ Tema Dark se mantiene
- ✅ Dashboard personalizado se mantiene
- ✅ Indicadores "Personalizado" presentes
- ✅ Al ir a Preferencias por Rol, todo está igual que antes

**Captura Recomendada**: Preferencias por Rol después de reiniciar app

---

## 🎨 Capturas de Pantalla Recomendadas

Para documentación completa, capturar:

1. **Dashboard de Admin** (6 widgets)
2. **Dashboard de Team Member** (4 widgets)
3. **Dashboard de Project Manager** (5 widgets)
4. **Preferencias por Rol - Sin Overrides** (estado inicial)
5. **Preferencias por Rol - Con Overrides** (indicadores "Personalizado")
6. **Card de Tema Personalizado** (con chip verde)
7. **Card de Dashboard Personalizado** (lista de widgets)
8. **AlertDialog de Resetear** (confirmación)
9. **Card de Ayuda** (explicación del sistema)

---

## 📊 Matriz de Verificación

### Comportamiento por Rol

| Característica | Admin | Project Manager | Team Member | ✓ |
|----------------|-------|-----------------|-------------|---|
| Widgets por defecto | 6 | 5 | 4 | |
| Tema por defecto | System | System | Light | |
| Widget #1 | Workspace Info | Workspace Info | Workspace Info | |
| Widget #2 | Quick Stats | My Projects | My Tasks | |
| Widget #3 | Quick Actions | Quick Stats | Quick Stats | |
| Widget #4 | My Projects | My Tasks | My Projects | |
| Widget #5 | My Tasks | Recent Activity | - | |
| Widget #6 | Recent Activity | - | - | |

### Funcionalidades del Sistema

| Funcionalidad | Estado | ✓ |
|---------------|--------|---|
| Cargar defaults por rol | | |
| Establecer override de tema | | |
| Establecer override de dashboard | | |
| Limpiar override de tema | | |
| Limpiar override de dashboard | | |
| Resetear todo | | |
| Persistencia entre sesiones | | |
| Manejo de cambio de rol | | |
| Indicadores visuales | | |
| UI responsiva | | |

---

## 🐛 Problemas Conocidos

### Si los Tests Fallan

1. **Error de compilación**: Asegurarse de que todas las dependencias estén instaladas
   ```bash
   flutter pub get
   ```

2. **Tests fallan**: Limpiar y regenerar
   ```bash
   flutter clean
   flutter pub get
   flutter test
   ```

3. **SharedPreferences mock error**: Verificar que `shared_preferences` esté en `pubspec.yaml`

### Si la UI No Responde

1. **Preferencias no cargan**: Verificar que el servicio se inicializa en `main.dart`
2. **Overrides no persisten**: Verificar permisos de escritura en el dispositivo
3. **Rol no cambia**: Verificar que `loadUserPreferences` se llama al cambiar usuario

---

## 📝 Checklist de Testing Completo

- [ ] Ejecutar tests unitarios (24 tests pasan)
- [ ] Escenario 1: Admin primera vez
- [ ] Escenario 2: Team Member primera vez
- [ ] Escenario 3: Personalización de tema
- [ ] Escenario 4: Personalización de dashboard
- [ ] Escenario 5: Limpiar override individual
- [ ] Escenario 6: Resetear todo
- [ ] Escenario 7: Cambio de rol
- [ ] Escenario 8: Persistencia entre sesiones
- [ ] Capturar 9 pantallas recomendadas
- [ ] Completar matriz de verificación
- [ ] Documentar problemas encontrados

---

## 📞 Reportar Problemas

Si encuentras algún problema:
1. Anotar pasos exactos para reproducir
2. Capturar pantalla del error
3. Revisar logs de la app
4. Comparar con comportamiento esperado en esta guía

---

**Fecha**: 13 de Octubre, 2025  
**Versión de Prueba**: 1.0  
**Autor**: Sistema de Personalización por Rol
