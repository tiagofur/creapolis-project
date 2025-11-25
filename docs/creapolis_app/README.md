# 📱 Creapolis Flutter App - Documentación

> Documentación técnica para la aplicación Flutter de Creapolis

## 📚 Índice

### 🏗️ Arquitectura

| Documento                                            | Descripción                    |
| ---------------------------------------------------- | ------------------------------ |
| [ARCHITECTURE.md](./ARCHITECTURE.md)                 | Arquitectura general de la app |
| [ARCHITECTURE_DIAGRAM.md](./ARCHITECTURE_DIAGRAM.md) | Diagramas visuales             |
| [FLOW_DIAGRAMS.md](./FLOW_DIAGRAMS.md)               | Flujos de usuario              |
| [COMPONENTS.md](./COMPONENTS.md)                     | Catálogo de componentes        |

### 🎨 Design System

| Documento                                                        | Descripción                |
| ---------------------------------------------------------------- | -------------------------- |
| [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md)                           | Sistema de diseño completo |
| [DESIGN_SYSTEM_EXAMPLES.md](./DESIGN_SYSTEM_EXAMPLES.md)         | Ejemplos de uso            |
| [DESIGN_SYSTEM_VISUAL_GUIDE.md](./DESIGN_SYSTEM_VISUAL_GUIDE.md) | Guía visual                |
| [ANIMACIONES_GUIA.md](./ANIMACIONES_GUIA.md)                     | Guía de animaciones        |

### ✨ Features

| Documento                                                                | Descripción              |
| ------------------------------------------------------------------------ | ------------------------ |
| [DASHBOARD_UI_GUIDE.md](./DASHBOARD_UI_GUIDE.md)                         | Dashboard personalizable |
| [WIDGETS_UI_GUIDE.md](./WIDGETS_UI_GUIDE.md)                             | Widgets del dashboard    |
| [GANTT_QUICK_GUIDE.md](./GANTT_QUICK_GUIDE.md)                           | Diagrama Gantt           |
| [BURNDOWN_BURNUP_VISUAL_DIAGRAM.md](./BURNDOWN_BURNUP_VISUAL_DIAGRAM.md) | Gráficos burndown        |
| [NLP_FLUTTER_INTEGRATION.md](./NLP_FLUTTER_INTEGRATION.md)               | Integración IA/NLP       |
| [TASK_UX_REDESIGN.md](./TASK_UX_REDESIGN.md)                             | UX de tareas             |

### 📴 Offline & Sync

| Documento                                                            | Descripción                  |
| -------------------------------------------------------------------- | ---------------------------- |
| [OFFLINE_FIRST_IMPLEMENTATION.md](./OFFLINE_FIRST_IMPLEMENTATION.md) | Implementación offline-first |
| [BACKGROUND_SYNC_ARCHITECTURE.md](./BACKGROUND_SYNC_ARCHITECTURE.md) | Arquitectura de sync         |
| [BACKGROUND_SYNC_QUICK_GUIDE.md](./BACKGROUND_SYNC_QUICK_GUIDE.md)   | Guía rápida de sync          |

### 🔄 Real-Time

| Documento                                                              | Descripción            |
| ---------------------------------------------------------------------- | ---------------------- |
| [REAL_TIME_VISUAL_ARCHITECTURE.md](./REAL_TIME_VISUAL_ARCHITECTURE.md) | Arquitectura WebSocket |
| [REAL_TIME_QUICK_START.md](./REAL_TIME_QUICK_START.md)                 | Guía rápida real-time  |

### 📖 Guías de Desarrollo

| Documento                                                    | Descripción               |
| ------------------------------------------------------------ | ------------------------- |
| [GETTING_STARTED.md](./GETTING_STARTED.md)                   | Inicio rápido para devs   |
| [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)               | Integración con backend   |
| [LOGGING_GUIDELINES.md](./LOGGING_GUIDELINES.md)             | Estándares de logging     |
| [LAZY_LOADING_PAGINATION.md](./LAZY_LOADING_PAGINATION.md)   | Paginación y lazy loading |
| [FLUTTER_STANDARDS_UPDATE.md](./FLUTTER_STANDARDS_UPDATE.md) | Estándares de código      |

### 🧪 Testing

| Documento                                            | Descripción            |
| ---------------------------------------------------- | ---------------------- |
| [MANUAL_TESTING_GUIDE.md](./MANUAL_TESTING_GUIDE.md) | Guía de testing manual |

### 🔧 Tutoriales

| Documento                                                            | Descripción                |
| -------------------------------------------------------------------- | -------------------------- |
| [TUTORIAL_ADD_WIDGET.md](./TUTORIAL_ADD_WIDGET.md)                   | Cómo agregar widgets       |
| [CUSTOMIZATION_METRICS_README.md](./CUSTOMIZATION_METRICS_README.md) | Métricas personalizables   |
| [PREFERENCES_EXPORT_IMPORT.md](./PREFERENCES_EXPORT_IMPORT.md)       | Export/Import preferencias |

---

## 🚀 Quick Start

```bash
cd creapolis_app
flutter pub get
flutter run -d chrome   # Web
flutter run             # Mobile/Desktop
```

## 📁 Estructura del Proyecto

```
lib/
├── core/           # Servicios core, sync, network, theme
├── data/           # Datasources, models, repositories impl
├── domain/         # Entities, repository contracts, usecases
├── features/       # Feature modules (calendar, chat, tasks...)
├── presentation/   # BLoCs, pages, widgets globales
└── routes/         # GoRouter configuration
```

## 🔗 Referencias

- [MASTER_STATUS.md](../MASTER_STATUS.md) - Estado general del proyecto
- [Backend Docs](../backend/) - Documentación del backend
- [API Reference](../api-reference/) - Documentación de APIs
