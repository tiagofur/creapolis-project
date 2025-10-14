import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../data/datasources/nlp_remote_datasource.dart';
import '../../../../domain/entities/task.dart';
import '../../../../domain/usecases/get_nlp_examples_usecase.dart';
import '../../../../domain/usecases/parse_task_instruction_usecase.dart';
import '../../blocs/task_bloc.dart';
import '../../blocs/task_event.dart';

/// Diálogo para crear tareas usando lenguaje natural
class NLPCreateTaskDialog extends StatefulWidget {
  final int projectId;

  const NLPCreateTaskDialog({
    super.key,
    required this.projectId,
  });

  @override
  State<NLPCreateTaskDialog> createState() => _NLPCreateTaskDialogState();
}

class _NLPCreateTaskDialogState extends State<NLPCreateTaskDialog> {
  final _instructionController = TextEditingController();
  final _parseInstructionUseCase = getIt<ParseTaskInstructionUseCase>();
  final _getExamplesUseCase = getIt<GetNLPExamplesUseCase>();

  bool _isProcessing = false;
  NLPParsedTask? _parsedTask;
  String? _errorMessage;
  List<String>? _examples;
  bool _showExamples = false;

  @override
  void initState() {
    super.initState();
    _loadExamples();
  }

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  Future<void> _loadExamples() async {
    final result = await _getExamplesUseCase();
    result.fold(
      (failure) {
        AppLogger.warning('No se pudieron cargar ejemplos: ${failure.message}');
      },
      (examples) {
        setState(() {
          _examples = [
            ...examples.spanish,
            ...examples.english,
          ];
        });
      },
    );
  }

  Future<void> _parseInstruction() async {
    if (_instructionController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, escribe una instrucción';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _parsedTask = null;
    });

    final result = await _parseInstructionUseCase(_instructionController.text);

    setState(() {
      _isProcessing = false;
    });

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
        });
      },
      (parsed) {
        setState(() {
          _parsedTask = parsed;
        });
      },
    );
  }

  void _createTask() {
    if (_parsedTask == null) return;

    context.read<TaskBloc>().add(
          CreateTask(
            projectId: widget.projectId,
            title: _parsedTask!.title,
            description: _parsedTask!.description,
            priority: _parsedTask!.priority,
            status: TaskStatus.planned,
            estimatedHours: 8.0, // Default
            startDate: DateTime.now(),
            endDate: _parsedTask!.dueDate,
          ),
        );

    Navigator.pop(context, true);
  }

  Widget _buildConfidenceIndicator(double confidence) {
    final percentage = (confidence * 100).toStringAsFixed(0);
    Color color;
    if (confidence >= 0.8) {
      color = Colors.green;
    } else if (confidence >= 0.6) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.analytics_outlined, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 550.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crear Tarea con IA',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Escribe en lenguaje natural',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Instruction input
                    TextField(
                      controller: _instructionController,
                      decoration: InputDecoration(
                        labelText: 'Tu instrucción',
                        hintText: 'Ej: Diseñar logo urgente para Juan, para el viernes',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.edit_note),
                        suffixIcon: _examples != null && _examples!.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  _showExamples ? Icons.expand_less : Icons.expand_more,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showExamples = !_showExamples;
                                  });
                                },
                                tooltip: 'Ver ejemplos',
                              )
                            : null,
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    // Examples
                    if (_showExamples && _examples != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ejemplos:',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(_examples!.take(3).map((example) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: InkWell(
                                    onTap: () {
                                      _instructionController.text = example;
                                      setState(() {
                                        _showExamples = false;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Icons.touch_app, size: 14),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            example,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Parse button
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _parseInstruction,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(_isProcessing ? 'Procesando...' : 'Analizar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Parsed result
                    if (_parsedTask != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Resultado del análisis',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                const Spacer(),
                                _buildConfidenceIndicator(
                                  _parsedTask!.analysis.overallConfidence,
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildResultField(
                              'Título',
                              _parsedTask!.title,
                              Icons.title,
                              _parsedTask!.analysis.overallConfidence,
                            ),
                            if (_parsedTask!.description.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildResultField(
                                'Descripción',
                                _parsedTask!.description,
                                Icons.description,
                                _parsedTask!.analysis.overallConfidence,
                              ),
                            ],
                            const SizedBox(height: 12),
                            _buildResultField(
                              'Prioridad',
                              _parsedTask!.priority.toString().split('.').last.toUpperCase(),
                              Icons.flag,
                              _parsedTask!.analysis.priority.confidence,
                            ),
                            const SizedBox(height: 12),
                            _buildResultField(
                              'Fecha límite',
                              _formatDate(_parsedTask!.dueDate),
                              Icons.calendar_today,
                              _parsedTask!.analysis.dueDate.confidence,
                            ),
                            if (_parsedTask!.assignee != null) ...[
                              const SizedBox(height: 12),
                              _buildResultField(
                                'Asignado',
                                _parsedTask!.assignee!,
                                Icons.person,
                                _parsedTask!.analysis.assignee.confidence,
                              ),
                            ],
                            if (_parsedTask!.category != null) ...[
                              const SizedBox(height: 12),
                              _buildResultField(
                                'Categoría',
                                _parsedTask!.category!,
                                Icons.category,
                                _parsedTask!.analysis.category?.confidence ?? 0.5,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Create button
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _createTask,
                              icon: const Icon(Icons.add_task),
                              label: const Text('Crear Tarea'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultField(
    String label,
    String value,
    IconData icon,
    double confidence,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildConfidenceIndicator(confidence),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Mañana';
    if (difference == -1) return 'Ayer';
    if (difference > 1 && difference < 7) {
      return 'En $difference días';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}
