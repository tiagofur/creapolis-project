# Creapolis App - Flutter

Sistema de gestión de proyectos con planificación automática e integración con Google Calendar.

## 🏗️ Arquitectura del Proyecto

El proyecto sigue **Clean Architecture** con una estructura modular y escalable:

```
lib/
├── core/                          # Núcleo compartido de la aplicación
│   ├── constants/                 # Constantes (API, Storage, Strings)
│   ├── theme/                     # Tema y estilos
│   ├── utils/                     # Utilidades compartidas
│   ├── errors/                    # Manejo de errores
│   └── network/                   # Configuración de red
├── domain/                        # Capa de dominio (entidades y casos de uso)
│   ├── entities/                  # Entidades de negocio
│   ├── repositories/              # Interfaces de repositorios
│   └── usecases/                  # Casos de uso
├── data/                          # Capa de datos
│   ├── models/                    # Modelos de datos (DTOs)
│   ├── repositories/              # Implementación de repositorios
│   └── datasources/               # Fuentes de datos (remote/local)
├── presentation/                  # Capa de presentación
│   ├── shared/widgets/            # Widgets reutilizables
│   ├── screens/                   # Pantallas organizadas por feature
│   └── blocs/                     # State Management (BLoC/Cubit)
└── routes/                        # Configuración de navegación
```

## 📋 Principios de Organización

### 1. **Código Limpio**

- Funciones pequeñas y específicas
- Nombres descriptivos
- Un widget por archivo

### 2. **DRY (Don't Repeat Yourself)**

- Widgets reutilizables en `presentation/shared/widgets/`
- Utilidades comunes en `core/utils/`
- Constantes centralizadas en `core/constants/`

### 3. **Separación de Responsabilidades**

- **Domain**: Lógica de negocio pura
- **Data**: Manejo de datos y APIs
- **Presentation**: UI y gestión de estado

## 🚀 Ejecutar la Aplicación

```bash
cd creapolis_app
flutter pub get
flutter run
```

## 📱 Plataformas Soportadas

✅ Android | iOS | Web | Windows | macOS | Linux
