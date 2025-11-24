import '../../domain/entities/chat_channel.dart';
import 'chat_message_model.dart';

class ChatChannelModel extends ChatChannel {
  const ChatChannelModel({
    required super.id,
    super.name,
    required super.type,
    super.projectId,
    super.workspaceId,
    required super.createdAt,
    required super.updatedAt,
    MessageModel? lastMessage,
    super.unreadCount = 0,
  }) : super(lastMessage: lastMessage);

  factory ChatChannelModel.fromJson(Map<String, dynamic> json) {
    return ChatChannelModel(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      projectId: json['projectId']?.toString(),
      workspaceId: json['workspaceId']?.toString(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'projectId': projectId,
      'workspaceId': workspaceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessage': (lastMessage as MessageModel?)?.toJson(),
      'unreadCount': unreadCount,
    };
  }
}
