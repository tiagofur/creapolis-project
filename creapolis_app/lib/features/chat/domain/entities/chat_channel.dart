import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class ChatChannel extends Equatable {
  final String id;
  final String? name;
  final String type; // 'PROJECT', 'WORKSPACE', 'DIRECT'
  final String? projectId;
  final String? workspaceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Message? lastMessage;
  final int unreadCount;

  const ChatChannel({
    required this.id,
    this.name,
    required this.type,
    this.projectId,
    this.workspaceId,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    projectId,
    workspaceId,
    createdAt,
    updatedAt,
    lastMessage,
    unreadCount,
  ];
}
