Fase 1: Backend - Modelos de Datos y Autenticación
Prompt 1: Configuración del Proyecto y Base de Datos
"Configura un nuevo proyecto con Node.js, Express y Prisma. Prepara un archivo schema.prisma para una base de datos PostgreSQL. Necesito los siguientes modelos: User, Project, Task, Dependency, y TimeLog."

Prompt 2: Definición del Modelo User
"Dentro de schema.prisma, define el modelo User. Debe tener los campos: id (autoincremental), email (único), password (string), name (string), y un campo role que pueda ser 'ADMIN', 'PROJECT_MANAGER', o 'TEAM_MEMBER'. Añade también campos para tokens de Google Calendar: googleAccessToken y googleRefreshToken (opcionales)."

Prompt 3: Definición de Modelos Project y Task
"Ahora, define los modelos Project y Task.

Un Project tiene: id, name, description, y una relación de muchos-a-muchos con User (para los miembros del proyecto).

Una Task tiene: id, title, description, status ('PLANNED', 'IN_PROGRESS', 'COMPLETED'), estimatedHours (float), actualHours (float, opcional), una relación con Project (una tarea pertenece a un proyecto), y una relación con User para el assignee (responsable)."

Prompt 4: Definición de Modelos Dependency y TimeLog
"Define los modelos Dependency y TimeLog.

Dependency representa una relación entre dos tareas. Debe tener: id, predecessorId (ID de la tarea que va primero), successorId (ID de la tarea que va después), y un type ('FINISH_TO_START', 'START_TO_START').

TimeLog registra un bloque de trabajo. Debe tener: id, startTime (DateTime), endTime (DateTime, opcional), y una relación con Task."

Prompt 5: API de Autenticación
"Crea las rutas y controladores de Express para la autenticación de usuarios. Necesito endpoints para:

POST /api/auth/register (crea un nuevo usuario).

POST /api/auth/login (autentica y devuelve un token JWT).
Usa bcrypt para hashear las contraseñas."

Fase 2: Backend - Lógica de Negocio Central
Prompt 6: API CRUD para Proyectos
"Crea una API RESTful completa para Projects. Debe incluir endpoints protegidos por JWT para:

GET /api/projects (listar proyectos del usuario autenticado).

POST /api/projects (crear un nuevo proyecto).

GET /api/projects/:id (obtener un proyecto por ID).

PUT /api/projects/:id (actualizar un proyecto).

DELETE /api/projects/:id (eliminar un proyecto)."

Prompt 7: API CRUD para Tareas
"De forma similar, crea una API RESTful completa para Tasks dentro de un proyecto. Los endpoints deben ser como /api/projects/:projectId/tasks. Incluye todas las operaciones CRUD (Crear, Leer, Actualizar, Eliminar) para las tareas de un proyecto específico."

Prompt 8: API para Time Tracking
"Crea los endpoints para controlar el tiempo de una tarea:

POST /api/tasks/:taskId/start: Crea un nuevo TimeLog con el startTime actual y cambia el estado de la tarea a 'IN_PROGRESS'.

POST /api/tasks/:taskId/stop: Encuentra el TimeLog activo para esa tarea, le asigna el endTime actual y calcula la duración.

POST /api/tasks/:taskId/finish: Marca la tarea como 'COMPLETED' y suma todos los TimeLog para calcular y guardar el actualHours."

Fase 3: Backend - El Motor de Planificación
Prompt 9: Módulo del Planificador - Cálculo Inicial
"Crea un módulo de servicio llamado SchedulerService. Dentro, crea una función calculateInitialSchedule(projectId). Esta función debe:

Obtener todas las tareas y dependencias de un proyecto.

Usar un algoritmo de ordenamiento topológico para organizar las tareas según sus dependencias.

Asumiendo una fecha de inicio, calcular las fechas de startDate y endDate para cada tarea, considerando las estimatedHours y los horarios laborales (por ahora, asume 8 horas por día, L-V)."

Prompt 10: Integración con Google Calendar
"Implementa la lógica para la integración con Google Calendar. Crea endpoints para:

/api/integrations/google/connect: Inicia el flujo OAuth 2.0 para que un usuario autorice el acceso a su calendario.

/api/integrations/google/callback: El endpoint al que Google redirige después de la autorización, donde guardas los tokens de acceso del usuario."

Prompt 11: Módulo del Planificador - Replanificación
"Ahora, en el SchedulerService, crea una función rescheduleProject(projectId, triggerTaskId). Esta función debe recalcular el cronograma a partir de la triggerTaskId (la tarea que cambió) hacia adelante, considerando los eventos del Google Calendar de los responsables como tiempo no disponible."

Fase 4: Frontend - Vistas y Componentes (React)
Prompt 12: Configuración del Frontend y Autenticación
"Configura una aplicación de React con Vite y Tailwind CSS. Crea las páginas y componentes para el registro y el login. Implementa la lógica para guardar el token JWT en el cliente y enviarlo en las cabeceras de las peticiones a la API usando Axios o Fetch."

Prompt 13: Vista de Proyectos y Tareas
"Crea una página principal que, después del login, liste los proyectos del usuario. Al hacer clic en un proyecto, debe llevar a una vista de ese proyecto que liste todas sus tareas en una tabla simple."

Prompt 14: Implementación del Diagrama de Gantt
"En la vista del proyecto, reemplaza la tabla de tareas con un componente de Diagrama de Gantt interactivo. Usa una librería como dhtmlx-gantt o frappe-gantt. El componente debe:

Obtener los datos de las tareas desde el endpoint /api/projects/:projectId/tasks.

Renderizar las tareas en una línea de tiempo.

Mostrar las dependencias entre tareas como flechas."

Prompt 15: Componente de Tarea con Time Tracking
"Crea un componente modal o un panel lateral que se abra al hacer clic en una tarea en el Gantt. Este componente debe mostrar los detalles de la tarea (title, description, assignee) y los botones de 'Play', 'Stop', y 'Finish'. Conecta estos botones a los endpoints de la API de time tracking que creamos."

Prompt 16: Vista de Carga de Trabajo (Workload)
"Crea una nueva página llamada 'Workload'. Esta página debe mostrar una tabla o una cuadrícula con los nombres de los miembros del equipo en las filas y los días de la semana en las columnas. La celda correspondiente debe mostrar las horas totales asignadas a esa persona para ese día. Colorea la celda de rojo si las horas superan las 8."
