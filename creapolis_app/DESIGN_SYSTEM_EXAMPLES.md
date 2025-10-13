# 💡 Design System - Code Examples Showcase

Colección rápida de ejemplos prácticos del Design System de Creapolis para copy-paste.

---

## 🎨 Colores

### Usar colores del tema

```dart
import 'package:creapolis_app/core/theme/app_theme.dart';

// ✅ CORRECTO - Usar AppColors
Container(
  color: AppColors.primary,
  child: Text(
    'Texto',
    style: TextStyle(color: AppColors.white),
  ),
)

// ❌ INCORRECTO - No hardcodear colores
Container(
  color: Color(0xFF3B82F6),  // ❌ No hacer esto
  child: Text('Texto'),
)
```

### Colores semánticos en contexto

```dart
// Success message
Container(
  color: AppColors.success.withOpacity(0.1),
  padding: EdgeInsets.all(AppSpacing.md),
  child: Row(
    children: [
      Icon(Icons.check_circle, color: AppColors.success),
      SizedBox(width: AppSpacing.sm),
      Text('Operación exitosa', style: TextStyle(color: AppColors.success)),
    ],
  ),
)

// Error message
Container(
  color: AppColors.error.withOpacity(0.1),
  padding: EdgeInsets.all(AppSpacing.md),
  child: Row(
    children: [
      Icon(Icons.error, color: AppColors.error),
      SizedBox(width: AppSpacing.sm),
      Text('Error al guardar', style: TextStyle(color: AppColors.error)),
    ],
  ),
)

// Warning
Container(
  color: AppColors.warning.withOpacity(0.1),
  padding: EdgeInsets.all(AppSpacing.md),
  child: Row(
    children: [
      Icon(Icons.warning, color: AppColors.warning),
      SizedBox(width: AppSpacing.sm),
      Text('Atención requerida', style: TextStyle(color: AppColors.warning)),
    ],
  ),
)
```

---

## 📝 Tipografía

### Jerarquía de títulos

```dart
import 'package:creapolis_app/core/theme/app_dimensions.dart';

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // H1 - Título principal de pantalla
    Text(
      'Dashboard',
      style: TextStyle(
        fontSize: AppFontSizes.xxxl,  // 32px
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: AppSpacing.lg),
    
    // H2 - Título de sección
    Text(
      'Proyectos Activos',
      style: TextStyle(
        fontSize: AppFontSizes.xxl,  // 24px
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: AppSpacing.md),
    
    // H3 - Subtítulo
    Text(
      'Recientes',
      style: TextStyle(
        fontSize: AppFontSizes.xl,  // 20px
        fontWeight: FontWeight.w600,
      ),
    ),
    SizedBox(height: AppSpacing.sm),
    
    // Body - Texto normal
    Text(
      'Lista de proyectos en los que estás trabajando actualmente.',
      style: TextStyle(
        fontSize: AppFontSizes.md,  // 16px
        fontWeight: FontWeight.normal,
      ),
    ),
  ],
)
```

### Texto con Theme

```dart
// ✅ CORRECTO - Usar Theme.of(context)
Text(
  'Título',
  style: Theme.of(context).textTheme.headlineMedium,
)

Text(
  'Cuerpo',
  style: Theme.of(context).textTheme.bodyMedium,
)

Text(
  'Caption',
  style: Theme.of(context).textTheme.bodySmall?.copyWith(
    color: AppColors.grey500,
  ),
)
```

---

## 📏 Espaciado

### Padding y margins consistentes

```dart
import 'package:creapolis_app/core/theme/app_dimensions.dart';

// Card con padding estándar
CustomCard(
  padding: EdgeInsets.all(AppSpacing.md),  // 16px
  child: Column(
    children: [
      Text('Item 1'),
      SizedBox(height: AppSpacing.sm),  // 8px entre items
      Text('Item 2'),
      SizedBox(height: AppSpacing.sm),
      Text('Item 3'),
    ],
  ),
)

// Pantalla con márgenes
Scaffold(
  body: Padding(
    padding: EdgeInsets.all(AppSpacing.lg),  // 24px
    child: Column(
      children: [
        Text('Título'),
        SizedBox(height: AppSpacing.xl),  // 32px separación grande
        Text('Contenido'),
      ],
    ),
  ),
)
```

### Espaciado responsive

```dart
// Espaciado que se adapta
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.lg,
  ),
  child: YourWidget(),
)

// Espaciado entre secciones
Column(
  children: [
    Section1(),
    SizedBox(height: AppSpacing.xxl),  // 48px entre secciones
    Section2(),
  ],
)
```

---

## 🔵 Botones

### Combinaciones comunes

```dart
import 'package:creapolis_app/presentation/shared/widgets/primary_button.dart';
import 'package:creapolis_app/presentation/shared/widgets/secondary_button.dart';

// Diálogo con botones
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    SecondaryButton(
      text: 'Cancelar',
      onPressed: () => Navigator.pop(context),
    ),
    SizedBox(width: AppSpacing.md),
    PrimaryButton(
      text: 'Guardar',
      onPressed: () => _save(),
      isLoading: _isSaving,
    ),
  ],
)

// Botones apilados (móvil)
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    PrimaryButton(
      text: 'Acción Principal',
      onPressed: () => _primaryAction(),
      isFullWidth: true,
    ),
    SizedBox(height: AppSpacing.md),
    SecondaryButton(
      text: 'Acción Secundaria',
      onPressed: () => _secondaryAction(),
      isFullWidth: true,
    ),
  ],
)
```

### Botón con estado de carga

```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    
    try {
      await _doSave();
      Navigator.pop(context);
    } catch (e) {
      // Manejar error
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: _isSaving ? 'Guardando...' : 'Guardar',
      isLoading: _isSaving,
      onPressed: _isSaving ? null : _save,
    );
  }
}
```

---

## 📄 Cards

### Card simple

```dart
import 'package:creapolis_app/presentation/shared/widgets/custom_card.dart';

CustomCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Título del Card',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      SizedBox(height: AppSpacing.sm),
      Text(
        'Descripción del contenido que va en este card.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  ),
)
```

### Card clickeable (item de lista)

```dart
CustomCard(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen()),
    );
  },
  child: Row(
    children: [
      Icon(Icons.folder, size: 40, color: AppColors.primary),
      SizedBox(width: AppSpacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proyecto Alpha',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              '3 tareas pendientes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
      Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey400),
    ],
  ),
)
```

### Card de estadística

```dart
CustomCard(
  color: AppColors.primary.withOpacity(0.1),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.task_alt, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Tareas Completadas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
      SizedBox(height: AppSpacing.md),
      Text(
        '42',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: AppSpacing.xs),
      Text(
        '+12 esta semana',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.success,
        ),
      ),
    ],
  ),
)
```

---

## 📝 Formularios

### Formulario completo

```dart
import 'package:creapolis_app/presentation/widgets/form/validated_text_field.dart';
import 'package:creapolis_app/core/utils/validators.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    // Guardar datos...
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValidatedTextField(
            controller: _nameController,
            label: 'Nombre',
            hint: 'Tu nombre completo',
            prefixIcon: Icons.person,
            validator: Validators.required,
          ),
          SizedBox(height: AppSpacing.md),
          
          ValidatedTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'correo@ejemplo.com',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          SizedBox(height: AppSpacing.lg),
          
          PrimaryButton(
            text: 'Guardar',
            onPressed: _submit,
            isLoading: _isSaving,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 Estados

### Manejo completo de estados

```dart
import 'package:creapolis_app/presentation/shared/widgets/loading_widget.dart';
import 'package:creapolis_app/presentation/shared/widgets/error_widget.dart';
import 'package:creapolis_app/presentation/shared/widgets/empty_widget.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBloc, MyState>(
      builder: (context, state) {
        // Loading
        if (state is LoadingState) {
          return LoadingWidget(
            message: 'Cargando proyectos...',
          );
        }
        
        // Error
        if (state is ErrorState) {
          return ErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<MyBloc>().add(LoadDataEvent());
            },
          );
        }
        
        // Success con datos
        if (state is LoadedState) {
          if (state.items.isEmpty) {
            return EmptyWidget(
              message: 'No hay proyectos todavía',
              icon: Icons.folder_open,
            );
          }
          
          return _buildList(state.items);
        }
        
        return SizedBox.shrink();
      },
    );
  }
  
  Widget _buildList(List items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _buildItem(items[index]),
    );
  }
}
```

---

## 🎨 Layouts Responsive

### Grid adaptativo

```dart
import 'package:creapolis_app/core/constants/view_constants.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        
        if (width >= ViewConstants.desktopBreakpoint) {
          crossAxisCount = ViewConstants.desktopCrossAxisCount;  // 4
        } else if (width >= ViewConstants.tabletBreakpoint) {
          crossAxisCount = ViewConstants.tabletCrossAxisCount;   // 3
        } else {
          crossAxisCount = ViewConstants.mobileCrossAxisCount;   // 2
        }
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
```

### Layout adaptativo (Column/Row)

```dart
class AdaptiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ViewConstants.tabletBreakpoint) {
          // Tablet/Desktop: Layout horizontal
          return Row(
            children: [
              Expanded(flex: 2, child: MainContent()),
              SizedBox(width: AppSpacing.lg),
              Expanded(flex: 1, child: Sidebar()),
            ],
          );
        } else {
          // Mobile: Layout vertical
          return Column(
            children: [
              MainContent(),
              SizedBox(height: AppSpacing.md),
              Sidebar(),
            ],
          );
        }
      },
    );
  }
}
```

---

## 🎭 Animaciones

### Transición suave

```dart
import 'package:creapolis_app/core/constants/view_constants.dart';

AnimatedContainer(
  duration: ViewConstants.hoverTransition,  // 200ms
  curve: ViewConstants.hoverCurve,
  color: _isHovered ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
  child: YourWidget(),
)
```

### Fade in/out

```dart
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: ViewConstants.fadeTransition,  // 150ms
  child: YourWidget(),
)
```

---

## ✅ Checklist de Implementación

Al crear un nuevo componente/pantalla:

```dart
// ✅ Imports correctos
import 'package:creapolis_app/core/theme/app_theme.dart';
import 'package:creapolis_app/core/theme/app_dimensions.dart';
import 'package:creapolis_app/core/constants/view_constants.dart';

// ✅ Usar colores del sistema
color: AppColors.primary,  // ✅
color: Color(0xFF3B82F6),  // ❌

// ✅ Usar espaciado del sistema
padding: EdgeInsets.all(AppSpacing.md),  // ✅
padding: EdgeInsets.all(16.0),           // ❌

// ✅ Usar tipografía del sistema
style: TextStyle(fontSize: AppFontSizes.lg),  // ✅
style: TextStyle(fontSize: 18.0),             // ❌

// ✅ Usar componentes reutilizables
PrimaryButton(...),     // ✅
ElevatedButton(...),    // ❌ (a menos que necesites personalización)

// ✅ Manejar estados
LoadingWidget(),
ErrorWidget(onRetry: ...),
EmptyWidget(),

// ✅ Responsive
LayoutBuilder(...),
MediaQuery.of(context).size.width >= ViewConstants.tabletBreakpoint,
```

---

## 🔗 Referencias

- [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) - Sistema completo
- [COMPONENTS.md](./COMPONENTS.md) - Todos los componentes
- [DESIGN_SYSTEM_VISUAL_GUIDE.md](./DESIGN_SYSTEM_VISUAL_GUIDE.md) - Guía visual

---

**Tip**: Guarda este archivo como referencia rápida para copy-paste de código común.
