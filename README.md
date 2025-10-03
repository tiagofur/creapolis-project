Descripción del Proyecto: ChronosFlow

1. Visión General (Elevator Pitch)
   ChronosFlow es un sistema de gestión de proyectos colaborativo e inteligente que crea cronogramas de trabajo dinámicos. A diferencia de las herramientas estáticas, ChronosFlow ajusta automáticamente las fechas y plazos del proyecto en tiempo real basándose en la disponibilidad real del equipo (sincronizada con Google Calendar) y el tiempo de ejecución real de las tareas, eliminando la necesidad de replanificar manualmente ante cada imprevisto.

2. Problema a Solucionar
   Los planes de proyecto tradicionales fallan al enfrentarse a la realidad: reuniones inesperadas, tareas que toman más o menos tiempo de lo estimado y cambios de prioridades. Esto obliga a los Jefes de Proyecto a perder horas replanificando manualmente, genera fechas de entrega poco realistas y crea una desconexión entre el plan y la ejecución diaria del equipo.

3. Módulos y Características Clave
   Módulo 1: Gestión de Proyectos y Tareas (El Núcleo)
   Proyectos: Creación de proyectos con nombre, descripción y equipo asignado.

Tareas: Creación de tareas con título, descripción, tiempo estimado en horas y responsable asignado.

Dependencias Avanzadas: Sistema para vincular tareas (Final a Inicio, Inicio a Inicio, Final a Final) para crear flujos de trabajo lógicos.

Tareas Ancladas: Opción para fijar tareas a fechas inamovibles que el motor de replanificación no puede desplazar.

Módulo 2: Motor de Planificación Adaptativa (La Inteligencia)
Cálculo Inicial de Cronograma: Al definir las tareas, dependencias y la fecha de inicio de la primera tarea, el motor genera el cronograma completo del proyecto.

Sincronización con Calendarios: Conexión vía OAuth 2.0 a Google Calendar de cada miembro del equipo para leer sus eventos y considerarlos como "tiempo no disponible".

Disparadores de Replanificación Automática: El motor se activa y recalcula el cronograma si:

Un evento se añade/modifica en el Google Calendar de un miembro.

Una tarea se completa fuera de su tiempo estimado (usando datos del time tracker).

Se modifica manualmente una dependencia o la fecha de una tarea anclada.

Lógica de Horarios Laborales: Permite configurar un horario laboral (ej. L-V de 9:00 a 18:00) para que las tareas solo se programen en tiempo de trabajo real.

Módulo 3: Colaboración y Gestión de Recursos
Roles de Usuario:

Administrador: Control total sobre usuarios y proyectos.

Jefe de Proyecto: Crea proyectos y asigna tareas a su equipo.

Miembro de Equipo: Trabaja en las tareas asignadas.

Invitado: Rol de solo lectura para stakeholders.

Asignación de Tareas: Asignación clara de cada tarea a un único miembro del equipo.

Vista de Carga de Trabajo (Workload): Un panel visual que muestra la cantidad de horas asignadas a cada miembro por día/semana, con alertas visuales de sobreasignación.

Módulo 4: Time Tracking y Analíticas
Control de Tiempo: Botones de "Play", "Stop" y "Finish" en cada tarea para registrar el tiempo de ejecución real.

Dashboard de Métricas:

Comparativa: Tiempo Estimado vs. Tiempo Real (por tarea, por usuario, por proyecto).

Reporte de Desviación: Identificación de las tareas que más se desvían de las estimaciones.

Avance del Proyecto: Porcentaje de completado general.

Módulo 5: Visualización
Diagrama de Gantt Interactivo: Vista principal del proyecto que muestra las tareas como barras en una línea de tiempo, con sus dependencias y el progreso indicado visualmente.

Panel Personal "Mis Tareas": Vista simplificada para que cada miembro del equipo vea solo las tareas que tiene asignadas para el día/semana.

4. Flujo de Usuario de Alto Nivel
   Un Jefe de Proyecto crea un proyecto e invita a su equipo.

El equipo conecta su Google Calendar.

El JP desglosa el proyecto en tareas, las estima en horas, establece dependencias y las asigna.

ChronosFlow genera el cronograma inicial y lo puebla en los calendarios.

Un Miembro de Equipo inicia su día, va a su panel "Mis Tareas", le da "Play" a su primera tarea.

Durante el día, surge una reunión. Se añade al Google Calendar.

ChronosFlow detecta el conflicto, replanifica automáticamente y notifica al JP del ajuste en la fecha final.

Al terminar una tarea, el miembro le da a "Finish". El sistema compara el tiempo real con el estimado y ajusta el resto del cronograma si es necesario.

El JP revisa el Dashboard para monitorear el progreso y la precisión de las estimaciones.
