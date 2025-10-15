import 'package:flutter/material.dart';
import '../../../domain/entities/task_category.dart';

/// Widget para mostrar y enviar feedback sobre una categorización
class CategoryFeedbackDialog extends StatefulWidget {
  final CategorySuggestion suggestion;
  final Function(
    bool wasCorrect,
    TaskCategoryType? correctedCategory,
    String? comment,
  )
  onSubmit;

  const CategoryFeedbackDialog({
    super.key,
    required this.suggestion,
    required this.onSubmit,
  });

  @override
  State<CategoryFeedbackDialog> createState() => _CategoryFeedbackDialogState();
}

class _CategoryFeedbackDialogState extends State<CategoryFeedbackDialog> {
  bool _wasCorrect = true;
  TaskCategoryType? _correctedCategory;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Feedback sobre categorización'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar sugerencia actual
            Text(
              'Categoría sugerida:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  widget.suggestion.suggestedCategory.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.suggestion.suggestedCategory.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ¿Fue correcta?
            Text(
              '¿Fue correcta la sugerencia?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioTheme(
              data: RadioThemeData(
                fillColor: WidgetStateProperty.all(
                  Theme.of(context).primaryColor,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Sí, fue correcta'),
                          value: true,
                          selected: _wasCorrect == true,
                          onChanged: (value) {
                            setState(() {
                              _wasCorrect = value!;
                              _correctedCategory = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('No, fue incorrecta'),
                          value: false,
                          selected: _wasCorrect == false,
                          onChanged: (value) {
                            setState(() {
                              _wasCorrect = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selector de categoría correcta (si fue incorrecta)
            if (!_wasCorrect) ...[
              Text(
                'Selecciona la categoría correcta:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TaskCategoryType>(
                initialValue: _correctedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Selecciona una categoría',
                ),
                items: TaskCategoryType.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Text(
                              category.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(category.displayName),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _correctedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Comentario opcional
            Text(
              'Comentario (opcional):',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Escribe tus comentarios aquí...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validar que si fue incorrecta, haya una categoría seleccionada
            if (!_wasCorrect && _correctedCategory == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Debes seleccionar la categoría correcta'),
                ),
              );
              return;
            }

            widget.onSubmit(
              _wasCorrect,
              _correctedCategory,
              _commentController.text.isNotEmpty
                  ? _commentController.text
                  : null,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Enviar Feedback'),
        ),
      ],
    );
  }
}
