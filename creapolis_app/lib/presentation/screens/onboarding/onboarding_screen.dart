import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/utils/app_logger.dart';
import '../../../routes/route_builder.dart';

/// Pantalla de onboarding con 4 páginas de introducción a la app.
///
/// Páginas:
/// 1. Welcome: Bienvenida a Creapolis
/// 2. Workspaces: Explicación de workspaces
/// 3. Projects: Gestión de proyectos
/// 4. Collaboration: Colaboración en equipo
///
/// Features:
/// - PageView para navegación entre páginas
/// - Indicadores de página (dots)
/// - Botón "Saltar" en todas las páginas
/// - Botón "Comenzar" en la última página
/// - SharedPreferences para flag de onboarding completado
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Completar onboarding y navegar al dashboard
  Future<void> _completeOnboarding() async {
    AppLogger.info('OnboardingScreen: Completando onboarding');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.hasSeenOnboarding, true);

      if (mounted) {
        context.goToDashboard();
      }
    } catch (e) {
      AppLogger.error('OnboardingScreen: Error al guardar flag - $e');
      // Navegar de todos modos
      if (mounted) {
        context.goToDashboard();
      }
    }
  }

  /// Siguiente página
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  /// Saltar onboarding
  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón Saltar (top-right)
            _buildSkipButton(),

            // PageView con las 4 páginas
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: const [
                  _WelcomePage(),
                  _WorkspacesPage(),
                  _ProjectsPage(),
                  _CollaborationPage(),
                ],
              ),
            ),

            // Indicadores de página
            _buildPageIndicators(),
            const SizedBox(height: 24),

            // Botón de acción
            _buildActionButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Botón Saltar
  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: _skipOnboarding,
          child: const Text('Saltar'),
        ),
      ),
    );
  }

  /// Indicadores de página (dots)
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) => _buildDot(index)),
    );
  }

  /// Dot individual
  Widget _buildDot(int index) {
    final isActive = _currentPage == index;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// Botón de acción (Siguiente/Comenzar)
  Widget _buildActionButton() {
    final isLastPage = _currentPage == _totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _nextPage,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(isLastPage ? 'Comenzar' : 'Siguiente'),
        ),
      ),
    );
  }
}

// ========== PÁGINAS DEL ONBOARDING ==========

/// Página 1: Welcome
class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 100,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 48),

          // Título
          Text(
            '¡Bienvenido a Creapolis!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            'La herramienta perfecta para gestionar tus proyectos y colaborar con tu equipo de manera efectiva.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Página 2: Workspaces
class _WorkspacesPage extends StatelessWidget {
  const _WorkspacesPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business_rounded,
              size: 100,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 48),

          // Título
          Text(
            'Organiza con Workspaces',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            'Crea espacios de trabajo para diferentes equipos, departamentos o proyectos. Mantén todo organizado y accesible.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Features
          _buildFeature(
            context,
            icon: Icons.people_rounded,
            title: 'Colaboración',
            description: 'Invita a tu equipo y colabora en tiempo real',
          ),
          const SizedBox(height: 16),
          _buildFeature(
            context,
            icon: Icons.admin_panel_settings_rounded,
            title: 'Control de acceso',
            description: 'Define roles y permisos para cada miembro',
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Página 3: Projects
class _ProjectsPage extends StatelessWidget {
  const _ProjectsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_rounded,
              size: 100,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 48),

          // Título
          Text(
            'Gestiona tus Proyectos',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            'Crea proyectos, asigna tareas, establece fechas límite y visualiza el progreso de tu equipo en tiempo real.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Features
          _buildFeature(
            context,
            icon: Icons.task_alt_rounded,
            title: 'Tareas y subtareas',
            description: 'Descompón proyectos complejos en tareas manejables',
          ),
          const SizedBox(height: 16),
          _buildFeature(
            context,
            icon: Icons.insert_chart_rounded,
            title: 'Gráficos Gantt',
            description: 'Visualiza cronogramas y dependencias',
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Página 4: Collaboration
class _CollaborationPage extends StatelessWidget {
  const _CollaborationPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustración
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_rounded,
              size: 100,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 48),

          // Título
          Text(
            'Colabora en Tiempo Real',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            'Trabaja junto a tu equipo, comparte ideas, comenta tareas y mantén a todos sincronizados.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Features
          _buildFeature(
            context,
            icon: Icons.notifications_active_rounded,
            title: 'Notificaciones',
            description: 'Mantente al día con actualizaciones en tiempo real',
          ),
          const SizedBox(height: 16),
          _buildFeature(
            context,
            icon: Icons.comment_rounded,
            title: 'Comentarios',
            description: 'Comenta y discute directamente en las tareas',
          ),
          const SizedBox(height: 16),
          _buildFeature(
            context,
            icon: Icons.mobile_friendly_rounded,
            title: 'Multiplataforma',
            description:
                'Accede desde cualquier dispositivo, en cualquier lugar',
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
