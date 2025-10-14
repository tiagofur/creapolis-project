// EJEMPLO DE INTEGRACIÓN: Colaboración en Tiempo Real en TaskDetailScreen
// Este archivo muestra cómo integrar la colaboración en tiempo real en una pantalla de detalles de tarea

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/collaboration/collaboration_bloc.dart';
import '../presentation/widgets/collaboration/active_viewers_widget.dart';
import '../presentation/widgets/collaboration/typing_indicator_widget.dart';

/// Ejemplo de pantalla de detalle de tarea con colaboración en tiempo real
class TaskDetailScreenWithCollaboration extends StatefulWidget {
  final int taskId;
  final int currentUserId;
  final String currentUserName;

  const TaskDetailScreenWithCollaboration({
    super.key,
    required this.taskId,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<TaskDetailScreenWithCollaboration> createState() =>
      _TaskDetailScreenWithCollaborationState();
}

class _TaskDetailScreenWithCollaborationState
    extends State<TaskDetailScreenWithCollaboration> {
  final _descriptionController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _joinCollaborationRoom();
    _setupDescriptionListener();
  }

  /// Unirse a la sala de colaboración al entrar a la pantalla
  void _joinCollaborationRoom() {
    final roomId = 'task_${widget.taskId}';
    context.read<CollaborationBloc>().add(JoinCollaborationRoom(
          roomId: roomId,
          userId: widget.currentUserId,
          userName: widget.currentUserName,
        ));
  }

  /// Configurar listener para detectar cuando el usuario está escribiendo
  void _setupDescriptionListener() {
    _descriptionController.addListener(() {
      final newIsTyping = _descriptionController.text.isNotEmpty;
      if (newIsTyping != _isTyping) {
        setState(() => _isTyping = newIsTyping);

        final roomId = 'task_${widget.taskId}';
        final bloc = context.read<CollaborationBloc>();

        if (newIsTyping) {
          bloc.add(StartTyping(
            roomId: roomId,
            userId: widget.currentUserId,
            userName: widget.currentUserName,
            field: 'description',
          ));
        } else {
          bloc.add(StopTyping(
            roomId: roomId,
            userId: widget.currentUserId,
            userName: widget.currentUserName,
            field: 'description',
          ));
        }
      }
    });
  }

  /// Enviar actualización de contenido cuando el usuario deja de escribir
  void _sendContentUpdate(String content) {
    final roomId = 'task_${widget.taskId}';
    context.read<CollaborationBloc>().add(UpdateContent(
          roomId: roomId,
          contentType: 'description',
          contentId: widget.taskId.toString(),
          content: content,
          userId: widget.currentUserId,
          userName: widget.currentUserName,
        ));
  }

  @override
  void dispose() {
    // Salir de la sala de colaboración al salir de la pantalla
    final roomId = 'task_${widget.taskId}';
    context.read<CollaborationBloc>().add(LeaveCollaborationRoom(roomId: roomId));
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tarea #${widget.taskId}'),
        actions: [
          // Mostrar usuarios activos en la AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<CollaborationBloc, CollaborationState>(
              builder: (context, state) {
                if (state is CollaborationConnected) {
                  return ActiveViewersWidget(
                    activeUsers: state.activeUsers,
                    currentUserId: widget.currentUserId,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      body: BlocListener<CollaborationBloc, CollaborationState>(
        listener: (context, state) {
          // Manejar actualizaciones de contenido de otros usuarios
          if (state is CollaborationContentUpdated) {
            if (state.contentType == 'description' &&
                state.userId != widget.currentUserId) {
              // Actualizar el campo de descripción con el contenido nuevo
              _descriptionController.text = state.content;
              
              // Mostrar snackbar informando quién hizo el cambio
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${state.userName} actualizó la descripción',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de descripción con indicador de escritura
              Text(
                'Descripción',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              
              // Mostrar indicador de escritura
              BlocBuilder<CollaborationBloc, CollaborationState>(
                builder: (context, state) {
                  if (state is CollaborationConnected) {
                    return TypingIndicatorWidget(
                      typingIndicators: state.typingIndicators,
                      currentField: 'description',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              
              // Campo de texto para descripción
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Escribe una descripción...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  // Enviar actualización después de 1 segundo de inactividad
                  Future.delayed(const Duration(seconds: 1), () {
                    if (_descriptionController.text == value) {
                      _sendContentUpdate(value);
                    }
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Estado de conexión
              BlocBuilder<CollaborationBloc, CollaborationState>(
                builder: (context, state) {
                  if (state is CollaborationConnecting) {
                    return const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Conectando...'),
                      ],
                    );
                  } else if (state is CollaborationDisconnected) {
                    return Row(
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Desconectado - Los cambios no se sincronizarán',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                    );
                  } else if (state is CollaborationConnected) {
                    return Row(
                      children: [
                        Icon(
                          Icons.cloud_done_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Conectado - Sincronización en tiempo real activa',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// INSTRUCCIONES DE USO:
/// 
/// 1. Inicializar CollaborationBloc en el árbol de widgets (main.dart o shell):
///    ```dart
///    BlocProvider<CollaborationBloc>(
///      create: (context) {
///        final wsService = WebSocketService(
///          baseUrl: 'http://localhost:3001',
///        );
///        final bloc = CollaborationBloc(webSocketService: wsService);
///        // Conectar automáticamente al iniciar
///        bloc.add(ConnectToWebSocket(token: authToken));
///        return bloc;
///      },
///      child: MaterialApp(...),
///    )
///    ```
///
/// 2. Navegar a la pantalla:
///    ```dart
///    Navigator.push(
///      context,
///      MaterialPageRoute(
///        builder: (context) => TaskDetailScreenWithCollaboration(
///          taskId: 123,
///          currentUserId: currentUser.id,
///          currentUserName: currentUser.name,
///        ),
///      ),
///    );
///    ```
///
/// 3. El sistema automáticamente:
///    - Se une a la sala 'task_123' al entrar
///    - Muestra usuarios activos en la AppBar
///    - Detecta y muestra quién está escribiendo
///    - Sincroniza cambios en tiempo real
///    - Sale de la sala al cerrar la pantalla
///
/// 4. Personalización:
///    - Cambiar roomId según el recurso (project_X, comment_Y, etc.)
///    - Agregar más campos editables con su propio tracking
///    - Personalizar el indicador de escritura
///    - Agregar cursores visuales si es necesario
