import 'package:flutter/material.dart';

import '../../../core/error/error_message_mapper.dart';
import '../../../core/errors/failures.dart';

/// Widget que muestra errores de manera amigable con ilustración y sugerencias
class FriendlyErrorWidget extends StatelessWidget {
  final Failure? failure;
  final FriendlyErrorMessage? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onAction;
  final bool showReportButton;

  const FriendlyErrorWidget({
    super.key,
    this.failure,
    this.errorMessage,
    this.onRetry,
    this.onAction,
    this.showReportButton = true,
  }) : assert(
         failure != null || errorMessage != null,
         'Either failure or errorMessage must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = errorMessage ?? ErrorMessageMapper.map(failure!);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono grande con animación
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: message.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(message.icon, size: 64, color: message.color),
              ),
            ),

            const SizedBox(height: 24),

            // Título
            Text(
              message.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: message.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Mensaje
            Text(
              message.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Sugerencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: message.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: message.color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message.suggestion,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botones de acción
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                // Botón de reintentar
                if (message.canRetry && onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: message.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),

                // Botón de acción personalizada
                if (message.actionLabel != null && onAction != null)
                  OutlinedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(message.actionLabel!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: message.color,
                      side: BorderSide(color: message.color),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),

                // Botón de reportar problema
                if (showReportButton)
                  TextButton.icon(
                    onPressed: () => _showReportDialog(context),
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Reportar Problema'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente. '
          'Por favor, contacta con soporte si el problema persiste.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

/// Widget específico para error de conexión
class NoConnectionWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FriendlyErrorWidget(
      failure: const NetworkFailure(),
      onRetry: onRetry,
      showReportButton: false,
    );
  }
}

/// Widget específico para permiso denegado
class PermissionDeniedWidget extends StatelessWidget {
  final VoidCallback? onContactAdmin;

  const PermissionDeniedWidget({super.key, this.onContactAdmin});

  @override
  Widget build(BuildContext context) {
    return FriendlyErrorWidget(
      failure: const AuthorizationFailure(),
      onAction: onContactAdmin,
      showReportButton: false,
    );
  }
}

/// Widget específico para recurso no encontrado
class NotFoundWidget extends StatelessWidget {
  final VoidCallback? onGoBack;
  final String? resourceName;

  const NotFoundWidget({super.key, this.onGoBack, this.resourceName});

  @override
  Widget build(BuildContext context) {
    final message = FriendlyErrorMessage(
      title: 'No Encontrado',
      message: resourceName != null
          ? '$resourceName no existe o fue eliminado.'
          : 'El recurso solicitado no existe o fue eliminado.',
      icon: Icons.search_off,
      color: Colors.grey,
      suggestion: 'Verifica que la información sea correcta.',
      severity: ErrorSeverity.info,
      canRetry: false,
      actionLabel: 'Volver',
    );

    return FriendlyErrorWidget(
      errorMessage: message,
      onAction: onGoBack ?? () => Navigator.of(context).pop(),
      showReportButton: false,
    );
  }
}



