Fase 7 – Backend: Dependencias Circulares y Consistencia

Cambios Clave
- Servicio de Tareas: Validación de ciclos al crear dependencias.
  - Archivo: `backend/src/services/task.service.js:462`
  - Construye grafo por proyecto y detecta ciclo (BFS). Rechaza con 400.
- Scheduler: Verificación proactiva de ciclos antes de ordenar/reprogramar.
  - Archivo: `backend/src/services/scheduler.service.js` (`calculateInitialSchedule`, `rescheduleProject`).
  - Usa `hasCircularDependency` y responde `BAD_REQUEST` si hay ciclos.
- GraphQL Resolvers: Rechazo de ciclos y consistencia/autoridad.
  - `addTaskDependency`: valida mismo `projectId`, no auto-dependencia, ciclo, y autorización de miembro/ADMIN.
    - Archivo: `backend/src/graphql/resolvers/task.resolvers.js:274-311` (ciclo), `:312-325` (autorización).
  - `removeTaskDependency`: verifica existencia y autorización de miembro/ADMIN antes de eliminar.
    - Archivo: `backend/src/graphql/resolvers/task.resolvers.js:313-340`.

Pruebas Añadidas
- REST (Tasks):
  - Prevención de ciclo `Task2 → Task1` tras `Task1 → Task2`.
  - Archivo: `backend/tests/task.test.js:178-189`.
- GraphQL:
  - `Dependencies` Suite:
    - Crea A→B y rechaza B→A (ciclo): `backend/tests/graphql.test.js`.
    - Rechaza dependencias entre proyectos distintos.
    - Enforce autorización en `removeTaskDependency` (usuario no miembro → FORBIDDEN).
    - Rechaza auto-dependencia (mismo id) con `BAD_REQUEST`.

Cómo Ejecutar
- Requisitos: definir `DATABASE_URL` (PostgreSQL de pruebas) en el entorno.
- Comandos:
  - Ejecutar suite completa: `npm test` en `backend`.
  - Sólo GraphQL (en BD local): `npx jest tests/graphql.test.js --runInBand`.

Notas
- El entorno de pruebas usa ESM; configurado con `node --experimental-vm-modules` y `babel-jest`.
- Las suites que dependen de BD se saltan si `DATABASE_URL` no está establecido (no fallan).
