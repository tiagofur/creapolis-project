import 'package:flutter/material.dart';
import '../../../domain/entities/task_category.dart';

/// Widget para mostrar una sugerencia de categoría con su confianza
class CategorySuggestionCard extends StatelessWidget {
  final CategorySuggestion suggestion;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onFeedback;

  const CategorySuggestionCard({
    super.key,
    required this.suggestion,
    this.onAccept,
    this.onReject,
    this.onFeedback,
  });

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.8) return 'Alta confianza';
    if (confidence >= 0.5) return 'Confianza media';
    return 'Confianza baja';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con categoría e icono
            Row(
              children: [
                Text(
                  suggestion.suggestedCategory.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categoría sugerida',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion.suggestedCategory.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barra de confianza
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getConfidenceLabel(suggestion.confidence),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${(suggestion.confidence * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getConfidenceColor(suggestion.confidence),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: suggestion.confidence,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          _getConfidenceColor(suggestion.confidence),
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Razonamiento
            if (suggestion.reasoning.isNotEmpty) ...[
              Text(
                'Razonamiento:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                suggestion.reasoning,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 16),
            ],

            // Keywords
            if (suggestion.keywords.isNotEmpty) ...[
              Text(
                'Palabras clave detectadas:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestion.keywords
                    .map(
                      (keyword) => Chip(
                        label: Text(keyword),
                        backgroundColor: Colors.blue[50],
                        labelStyle: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onFeedback != null)
                  TextButton.icon(
                    onPressed: onFeedback,
                    icon: const Icon(Icons.feedback_outlined),
                    label: const Text('Feedback'),
                  ),
                if (onReject != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Rechazar'),
                  ),
                ],
                if (onAccept != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
