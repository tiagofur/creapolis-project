import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../routes/route_builder.dart';
import '../../widgets/common/adaptive_illustration.dart';
import '../../widgets/common/trackable_feature.dart';

/// Pantalla de onboarding con 4 páginas de introducción a la app.
///
/// Páginas:
/// 1. Welcome: Bienvenida a Creapolis
/// 2. Workspaces: Explicación de workspaces
/// 3. Projects: Gestión de proyectos
/// 4. Collaboration: Colaboración en equipo
///
/// Features:
/// - PageView para navegación entre páginas con swipe
/// - Indicadores de página (dots) interactivos
/// - Botón "Saltar" en todas las páginas
/// - Botón "Atrás" a partir de la segunda página
/// - Botón "Comenzar" en la última página
/// - Haptic feedback al cambiar de página
/// - Animación de hint de swipe en primera página
/// - SharedPreferences para flag de onboarding completado
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _previousPage = 0;
  static const int _totalPages = 4;
  static const List<String> _pageNames = [
    'Bienvenida',
    'Workspaces',
    'Proyectos',
    'Colaboración',
  ];

  // Animación para el hint de swipe
  late AnimationController _swipeHintController;
  late Animation<double> _swipeHintAnimation;
  bool _showSwipeHint = true;

  // Tracking de tiempo
  late DateTime _startTime;
  final Set<int> _pagesViewed = {};

  // Tracking de engagement por página
  DateTime? _pageEntryTime;
  static const List<int> _featuresPerPage = [
    0,
    2,
    2,
    3,
  ]; // Features en cada página

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initSwipeHintAnimation();
    _trackOnboardingStarted();
  }

  void _trackOnboardingStarted() {
    AnalyticsService.trackOnboardingStarted();
    _pageEntryTime = DateTime.now();
    _trackPageViewed(0);
  }

  void _trackPageViewed(int pageIndex) {
    if (!_pagesViewed.contains(pageIndex)) {
      _pagesViewed.add(pageIndex);
      AnalyticsService.trackOnboardingPageViewed(
        pageIndex: pageIndex,
        pageName: _pageNames[pageIndex],
        totalPages: _totalPages,
      );
    }
  }

  /// Trackea el engagement (tiempo de visualización) de la página anterior
  void _trackPageEngagement(int previousPage) {
    if (_pageEntryTime != null) {
      final viewDuration = DateTime.now().difference(_pageEntryTime!);
      AnalyticsService.trackOnboardingPageEngagement(
        pageIndex: previousPage,
        pageName: _pageNames[previousPage],
        viewDurationMs: viewDuration.inMilliseconds,
        featuresViewed: _featuresPerPage[previousPage],
      );
    }
    _pageEntryTime = DateTime.now();
  }

  void _initSwipeHintAnimation() {
    _swipeHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _swipeHintAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _swipeHintController, curve: Curves.easeInOut),
    );

    // Repetir la animación 3 veces y luego ocultarla
    _swipeHintController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showSwipeHint) {
        _swipeHintController.stop();
        setState(() => _showSwipeHint = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _swipeHintController.dispose();
    super.dispose();
  }

  /// Completar onboarding y navegar al dashboard
  Future<void> _completeOnboarding({bool skipped = false}) async {
    AppLogger.info('OnboardingScreen: Completando onboarding');

    // Track engagement de la última página
    _trackPageEngagement(_currentPage);

    // Track analytics
    final timeSpent = DateTime.now().difference(_startTime);
    if (skipped) {
      AnalyticsService.trackOnboardingSkipped(
        currentPage: _currentPage,
        totalPages: _totalPages,
        timeSpent: timeSpent,
      );
    } else {
      AnalyticsService.trackOnboardingCompleted(
        totalPagesViewed: _pagesViewed.length,
        timeSpent: timeSpent,
        skipped: false,
      );
    }

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

  /// Manejar cambio de página (por swipe o botón)
  void _onPageChanged(int index) {
    // Haptic feedback al cambiar página
    if (index != _previousPage) {
      HapticService.selectionClick();
      // Track engagement de la página que se abandona
      _trackPageEngagement(_previousPage);
    }

    setState(() {
      _previousPage = _currentPage;
      _currentPage = index;

      // Ocultar hint de swipe después del primer swipe
      if (_showSwipeHint && index > 0) {
        _swipeHintController.stop();
        _showSwipeHint = false;
      }
    });

    // Track página vista
    _trackPageViewed(index);
  }

  /// Siguiente página
  void _nextPage() {
    HapticService.selectionClick();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      HapticService.success();
      _completeOnboarding(skipped: false);
    }
  }

  /// Página anterior
  void _previousPageAction() {
    HapticService.selectionClick();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Ir a página específica (al tocar un dot)
  void _goToPage(int index) {
    HapticService.lightImpact();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Saltar onboarding
  void _skipOnboarding() {
    HapticService.lightImpact();
    _completeOnboarding(skipped: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        label: 'Pantalla de introducción a Creapolis',
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar + Skip button row
              _buildHeader(),

              // PageView con las 4 páginas
              Expanded(
                child: Semantics(
                  label:
                      'Página ${_currentPage + 1} de $_totalPages: ${_pageNames[_currentPage]}. Desliza horizontalmente para navegar',
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        children: const [
                          _WelcomePage(),
                          _WorkspacesPage(),
                          _ProjectsPage(),
                          _CollaborationPage(),
                        ],
                      ),

                      // Hint de swipe (solo en primera página)
                      if (_showSwipeHint && _currentPage == 0)
                        Positioned(
                          bottom: 80,
                          left: 0,
                          right: 0,
                          child: ExcludeSemantics(child: _buildSwipeHint()),
                        ),
                    ],
                  ),
                ),
              ),

              // Indicadores de página (dots interactivos)
              _buildPageIndicators(),
              const SizedBox(height: 24),

              // Botones de navegación
              _buildNavigationButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con Progress Bar y botón Saltar
  Widget _buildHeader() {
    final theme = Theme.of(context);
    final progress = (_currentPage + 1) / _totalPages;
    final progressPercent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Row con contador y botón saltar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Contador de página
              Semantics(
                label: 'Página ${_currentPage + 1} de $_totalPages',
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Botón Saltar
              Semantics(
                button: true,
                label: 'Saltar introducción e ir al inicio',
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: const Text('Saltar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar animada
          Semantics(
            label: 'Progreso: $progressPercent por ciento completado',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                tween: Tween<double>(begin: 0, end: progress),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hint visual de swipe
  Widget _buildSwipeHint() {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _swipeHintAnimation,
      builder: (context, child) {
        return AnimatedOpacity(
          opacity: _showSwipeHint ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Transform.translate(
            offset: Offset(-_swipeHintAnimation.value, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe_left_rounded,
                  size: 28,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Desliza para continuar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Indicadores de página (dots) - ahora interactivos
  Widget _buildPageIndicators() {
    return Semantics(
      label: 'Indicadores de página',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _totalPages,
          (index) => _buildDot(index, _pageNames[index]),
        ),
      ),
    );
  }

  /// Dot individual - ahora tocable con semántica
  Widget _buildDot(int index, String pageName) {
    final isActive = _currentPage == index;
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: isActive,
      label: 'Ir a página ${index + 1}: $pageName',
      hint: isActive ? 'Página actual' : 'Toca para ir a esta página',
      child: GestureDetector(
        onTap: () => _goToPage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Botones de navegación (Atrás + Siguiente/Comenzar)
  Widget _buildNavigationButtons() {
    final isLastPage = _currentPage == _totalPages - 1;
    final isFirstPage = _currentPage == 0;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Botón Atrás (solo visible a partir de la segunda página)
          AnimatedOpacity(
            opacity: isFirstPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isFirstPage ? 0 : 48,
              child: isFirstPage
                  ? const SizedBox.shrink()
                  : Semantics(
                      button: true,
                      label: 'Ir a la página anterior',
                      child: IconButton.outlined(
                        onPressed: _previousPageAction,
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: 'Página anterior',
                        style: IconButton.styleFrom(
                          side: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          if (!isFirstPage) const SizedBox(width: 16),

          // Botón Siguiente/Comenzar
          Expanded(
            child: Semantics(
              button: true,
              label: isLastPage
                  ? 'Comenzar a usar Creapolis'
                  : 'Ir a la siguiente página',
              child: FilledButton(
                onPressed: _nextPage,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isLastPage ? 'Comenzar' : 'Siguiente'),
                    if (!isLastPage) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
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

    return Semantics(
      label: 'Página de bienvenida',
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustración adaptativa al tema
            ExcludeSemantics(child: PredefinedIllustrations.welcome(size: 200)),
            const SizedBox(height: 48),

            // Título
            Semantics(
              header: true,
              child: Text(
                '¡Bienvenido a Creapolis!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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

    return Semantics(
      label: 'Página sobre workspaces',
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustración adaptativa al tema
            ExcludeSemantics(
              child: PredefinedIllustrations.workspace(size: 200),
            ),
            const SizedBox(height: 48),

            // Título
            Semantics(
              header: true,
              child: Text(
                'Organiza con Workspaces',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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

            // Features - ahora con tracking de interés
            TrackableFeature(
              featureName: 'Colaboración en tiempo real',
              featureCategory: 'workspaces',
              pageIndex: 1,
              child: _buildFeature(
                context,
                icon: Icons.people_rounded,
                title: 'Colaboración',
                description: 'Invita a tu equipo y colabora en tiempo real',
              ),
            ),
            const SizedBox(height: 16),
            TrackableFeature(
              featureName: 'Control de acceso',
              featureCategory: 'workspaces',
              pageIndex: 1,
              child: _buildFeature(
                context,
                icon: Icons.admin_panel_settings_rounded,
                title: 'Control de acceso',
                description: 'Define roles y permisos para cada miembro',
              ),
            ),
          ],
        ),
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

    return MergeSemantics(
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
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
      ),
    );
  }
}

/// Página 3: Projects
class _ProjectsPage extends StatelessWidget {
  const _ProjectsPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Página sobre proyectos',
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustración adaptativa al tema
            ExcludeSemantics(
              child: PredefinedIllustrations.projects(size: 200),
            ),
            const SizedBox(height: 48),

            // Título
            Semantics(
              header: true,
              child: Text(
                'Gestiona tus Proyectos',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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

            // Features - ahora con tracking de interés
            TrackableFeature(
              featureName: 'Tareas y subtareas',
              featureCategory: 'projects',
              pageIndex: 2,
              child: _buildFeature(
                context,
                icon: Icons.task_alt_rounded,
                title: 'Tareas y subtareas',
                description:
                    'Descompón proyectos complejos en tareas manejables',
              ),
            ),
            const SizedBox(height: 16),
            TrackableFeature(
              featureName: 'Fechas y Plazos',
              featureCategory: 'projects',
              pageIndex: 2,
              child: _buildFeature(
                context,
                icon: Icons.calendar_month_rounded,
                title: 'Fechas y Plazos',
                description:
                    'Establece fechas de inicio y fin para mantener el rumbo',
              ),
            ),
          ],
        ),
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

    return MergeSemantics(
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
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
      ),
    );
  }
}

/// Página 4: Collaboration
class _CollaborationPage extends StatelessWidget {
  const _CollaborationPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Página sobre colaboración',
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustración adaptativa al tema
            ExcludeSemantics(
              child: PredefinedIllustrations.collaboration(size: 200),
            ),
            const SizedBox(height: 48),

            // Título
            Semantics(
              header: true,
              child: Text(
                'Colabora en Tiempo Real',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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

            // Features - ahora con tracking de interés
            TrackableFeature(
              featureName: 'Notificaciones',
              featureCategory: 'collaboration',
              pageIndex: 3,
              child: _buildFeature(
                context,
                icon: Icons.notifications_active_rounded,
                title: 'Notificaciones',
                description:
                    'Mantente al día con actualizaciones en tiempo real',
              ),
            ),
            const SizedBox(height: 16),
            TrackableFeature(
              featureName: 'Comentarios',
              featureCategory: 'collaboration',
              pageIndex: 3,
              child: _buildFeature(
                context,
                icon: Icons.comment_rounded,
                title: 'Comentarios',
                description: 'Comenta y discute directamente en las tareas',
              ),
            ),
            const SizedBox(height: 16),
            TrackableFeature(
              featureName: 'Multiplataforma',
              featureCategory: 'collaboration',
              pageIndex: 3,
              child: _buildFeature(
                context,
                icon: Icons.mobile_friendly_rounded,
                title: 'Multiplataforma',
                description:
                    'Accede desde cualquier dispositivo, en cualquier lugar',
              ),
            ),
          ],
        ),
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

    return MergeSemantics(
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24),
            ),
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
      ),
    );
  }
}
