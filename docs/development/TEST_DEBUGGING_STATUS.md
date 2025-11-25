# Estado de Depuración de Tests de Integración (Member Management)

**Fecha:** 24 de Noviembre, 2025
**Archivo:** `creapolis_app/test/integration/member_management_flow_test.dart`

## Situación Actual

Los tests de integración para el flujo de gestión de miembros están fallando. El problema principal es que el árbol de widgets (Widget Tree) en el entorno de test no se actualiza para reflejar los cambios de estado del BLoC (`Loading`, `Loaded`), a pesar de que los logs indican que el BLoC está emitiendo los estados correctamente.

### Síntomas

- **Error Común:** `Expected: exactly one matching candidate. Actual: Found 0 widgets...`
- **Logs:**
  - `WorkspaceMemberBloc: Cargando miembros del workspace 1` (El evento llega)
  - `WorkspaceMemberBloc: 3 miembros cargados` (El estado se emite)
- **Comportamiento:** El test falla en las aserciones (`expect`) porque la UI parece quedarse en el estado inicial o no reconstruirse a tiempo.

## Intentos de Solución

1.  **Inyección de Dependencias:** Se verificó que la instancia del BLoC en el test y en el widget es la misma.
2.  **Trigger de Eventos:** Se eliminaron las llamadas manuales a `bloc.add` en el test para confiar en el `initState` del widget `WorkspaceMembersScreen`, replicando el comportamiento real de la app.
3.  **Sincronización (Pumping):**
    - Se intentó usar `await tester.pump(Duration.zero);` justo después de `pumpWidget` para procesar microtareas pendientes (emisión inicial del BLoC).
    - Se añadieron bucles de `pump` con delay para esperar operaciones asíncronas.

## Hipótesis

El problema reside en la sincronización entre el `Event Loop` de Dart en el entorno de test y los `Streams` del BLoC. Es posible que el `Future.delayed` en los mocks de los UseCases esté causando que `pumpAndSettle` no espere lo suficiente o que el test verifique antes de que el frame se pinte.

## Pasos Siguientes para Retomar

1.  **Ajustar Tiempos:** Revisar si el `Future.delayed(const Duration(milliseconds: 500))` en el mock del UseCase es necesario. Si se quita, la respuesta sería inmediata. Si se mantiene, asegurar que `tester.pump(const Duration(milliseconds: 500))` se llame explícitamente.
2.  **Verificar `BlocConsumer`:** Asegurar que el `BlocConsumer` está escuchando correctamente.
3.  **Simplificar el Test:** Intentar hacer pasar un solo test (el de "loading state") antes de arreglar los demás.
    - Probar eliminando el `Future.delayed` del mock para ver si es un problema de tiempo.
4.  **Depuración Visual:** Si es posible, imprimir el árbol de widgets (`debugDumpApp()`) en el punto de fallo para ver qué está renderizando realmente.

## Comandos Útiles

Ejecutar solo el archivo de test:

```bash
flutter test test/integration/member_management_flow_test.dart
```
