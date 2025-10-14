# NLP Task Creation - Flutter Integration Guide

## 📱 Implementación Flutter

Esta guía detalla la integración del servicio NLP para creación de tareas en la aplicación Flutter.

## 🏗️ Arquitectura

### Capas Implementadas

```
lib/
├── data/
│   ├── datasources/
│   │   └── nlp_remote_datasource.dart          # Comunicación con API NLP
│   └── repositories/
│       └── nlp_repository_impl.dart            # Implementación del repositorio
├── domain/
│   ├── repositories/
│   │   └── nlp_repository.dart                 # Interfaz del repositorio
│   └── usecases/
│       ├── parse_task_instruction_usecase.dart # Parse instrucciones
│       └── get_nlp_examples_usecase.dart       # Obtener ejemplos
└── features/
    └── tasks/
        └── presentation/
            └── widgets/
                └── nlp_create_task_dialog.dart # Dialog UI con IA
```

## 📦 Modelos de Datos

### NLPParsedTask

Representa el resultado del parseo de una instrucción:

```dart
class NLPParsedTask {
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final String? assignee;
  final String? category;
  final NLPAnalysis analysis;
  final String originalInstruction;
}
```

### NLPAnalysis

Contiene información de confianza sobre cada campo extraído:

```dart
class NLPAnalysis {
  final double overallConfidence;      // 0.0 - 1.0
  final NLPFieldAnalysis priority;
  final NLPFieldAnalysis dueDate;
  final NLPFieldAnalysis assignee;
  final NLPFieldAnalysis? category;
}
```

## 🔌 Data Source

### NLPRemoteDataSource

Maneja las llamadas HTTP al backend:

```dart
abstract class NLPRemoteDataSource {
  Future<NLPParsedTask> parseTaskInstruction(String instruction);
  Future<NLPExamples> getExamples();
  Future<Map<String, dynamic>> getServiceInfo();
}
```

**Endpoints utilizados:**
- `POST /api/nlp/parse-task-instruction`
- `GET /api/nlp/examples`
- `GET /api/nlp/info`

## 🎯 Use Cases

### ParseTaskInstructionUseCase

Parsea una instrucción en lenguaje natural:

```dart
final parseUseCase = getIt<ParseTaskInstructionUseCase>();

final result = await parseUseCase("Diseñar logo urgente para Juan");
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (parsed) {
    print('Título: ${parsed.title}');
    print('Prioridad: ${parsed.priority}');
    print('Confianza: ${parsed.analysis.overallConfidence}');
  },
);
```

### GetNLPExamplesUseCase

Obtiene ejemplos de instrucciones:

```dart
final examplesUseCase = getIt<GetNLPExamplesUseCase>();

final result = await examplesUseCase();
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (examples) {
    print('Ejemplos en español: ${examples.spanish.length}');
    print('Ejemplos en inglés: ${examples.english.length}');
  },
);
```

## 🎨 Widget UI

### NLPCreateTaskDialog

Dialog completo para crear tareas con IA:

```dart
// Mostrar el dialog
showDialog(
  context: context,
  builder: (context) => NLPCreateTaskDialog(
    projectId: currentProjectId,
  ),
);
```

**Características del Dialog:**

1. **Input de texto natural**
   - Campo multi-línea para instrucciones
   - Botón para ver ejemplos
   - Ejemplos clickeables para usar

2. **Procesamiento**
   - Botón "Analizar" para parsear
   - Indicador de carga mientras procesa
   - Manejo de errores con mensajes claros

3. **Preview de resultados**
   - Muestra todos los campos extraídos
   - Indicadores visuales de confianza
   - Código de colores (verde/naranja/rojo)

4. **Confirmación**
   - Botón "Crear Tarea" usa datos parseados
   - Opción de cancelar

## 🎯 Integración en Screens

### Ejemplo: All Tasks Screen

```dart
class AllTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas'),
      ),
      body: TaskList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón NLP (nuevo)
          FloatingActionButton.extended(
            heroTag: 'nlp_create',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => NLPCreateTaskDialog(
                  projectId: currentProjectId,
                ),
              );
            },
            icon: Icon(Icons.psychology_outlined),
            label: Text('IA'),
            backgroundColor: Colors.purple,
          ),
          SizedBox(height: 12),
          // Botón manual existente
          FloatingActionButton(
            heroTag: 'manual_create',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CreateTaskDialog(
                  projectId: currentProjectId,
                ),
              );
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 Configuración Requerida

### 1. Dependency Injection

Las clases están anotadas con `@injectable` y `@LazySingleton`. Regenerar el código de inyección:

```bash
cd creapolis_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

Esto actualizará `lib/injection.config.dart` con las nuevas dependencias.

### 2. API Client

Asegurarse de que el `ApiClient` esté configurado con la URL correcta del backend:

```dart
// En algún archivo de configuración
const apiBaseUrl = 'http://localhost:3001/api';
```

### 3. Autenticación

Los endpoints NLP requieren autenticación. El token debe estar incluido en las peticiones a través del `ApiClient`.

## 📊 Indicadores de Confianza

El sistema muestra indicadores visuales basados en la confianza del parseo:

| Confianza | Color  | Significado                    |
|-----------|--------|--------------------------------|
| ≥ 80%     | Verde  | Alta confianza, muy confiable  |
| 60-79%    | Naranja| Confianza media, revisar       |
| < 60%     | Rojo   | Baja confianza, verificar bien |

## 🧪 Testing

### Test del DataSource

```dart
void main() {
  group('NLPRemoteDataSource', () {
    test('should parse instruction successfully', () async {
      // Setup
      final dataSource = NLPRemoteDataSourceImpl(mockApiClient);
      
      // Execute
      final result = await dataSource.parseTaskInstruction(
        'Diseñar logo urgente para Juan'
      );
      
      // Verify
      expect(result.title, contains('logo'));
      expect(result.priority, TaskPriority.high);
    });
  });
}
```

### Test del UseCase

```dart
void main() {
  group('ParseTaskInstructionUseCase', () {
    test('should return parsed task on success', () async {
      // Setup
      final useCase = ParseTaskInstructionUseCase(mockRepository);
      
      // Execute
      final result = await useCase('Fix bug urgente');
      
      // Verify
      expect(result.isRight(), true);
    });
  });
}
```

## 🎯 Ejemplos de Uso

### Ejemplo 1: Usuario escribe en español

**Input del usuario:**
```
"Crear tarea para diseñar el logo, alta prioridad, asignar a Juan, para el viernes"
```

**Resultado parseado:**
- ✅ Título: "Crear tarea logo"
- ✅ Prioridad: HIGH (85% confianza)
- ✅ Asignado: Juan (80% confianza)
- ✅ Fecha: Próximo viernes (85% confianza)
- ✅ Categoría: DESIGN (75% confianza)

**Confianza general:** 81%

### Ejemplo 2: Usuario escribe en inglés

**Input del usuario:**
```
"Fix the login bug with high priority for tomorrow"
```

**Resultado parseado:**
- ✅ Título: "Fix the login bug"
- ✅ Prioridad: HIGH (85% confianza)
- ✅ Fecha: Mañana (95% confianza)
- ✅ Categoría: BUG (75% confianza)

**Confianza general:** 77%

## 🚀 Próximos Pasos

1. **Añadir más idiomas**: Portugués, francés, etc.
2. **Historial de instrucciones**: Guardar instrucciones previas del usuario
3. **Sugerencias en tiempo real**: Mostrar sugerencias mientras escribe
4. **Voz a texto**: Permitir dictar instrucciones
5. **Aprendizaje del usuario**: Adaptar el parseo al estilo del usuario

## 💡 Tips de UX

### Para desarrolladores

1. **Siempre mostrar confianza**: Los usuarios deben saber qué tan confiable es el parseo
2. **Permitir edición**: Antes de crear, dejar editar los campos parseados
3. **Feedback claro**: Explicar por qué algo no se pudo parsear
4. **Ejemplos visibles**: Ayudar a los usuarios a entender el formato

### Para usuarios

1. **Ser específico**: Más detalles = mejor parseo
2. **Usar palabras clave**: "urgente", "para [nombre]", "para el [fecha]"
3. **Revisar antes de crear**: Siempre verificar los campos parseados
4. **Probar ejemplos**: Usar los ejemplos como guía

## 📝 Notas de Implementación

- El dialog es **stateful** para manejar el estado del parseo
- Se usa **getIt** para inyección de dependencias
- Los errores se muestran de forma **clara y amigable**
- El UI es **responsive** y funciona en diferentes tamaños de pantalla
- La confianza se muestra de forma **visual e intuitiva**

## 🐛 Troubleshooting

### Error: "No se puede conectar al backend"

**Solución:** Verificar que el backend esté corriendo y que la URL sea correcta.

### Error: "Failed to parse instruction"

**Solución:** La instrucción puede ser muy corta o ambigua. Pedir al usuario más detalles.

### Warning: Baja confianza en campos

**Solución:** Mostrar indicadores visuales y permitir edición manual antes de crear.

## 📄 Licencia

MIT
