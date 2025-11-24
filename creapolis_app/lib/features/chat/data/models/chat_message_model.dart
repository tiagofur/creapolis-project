import '../../domain/entities/chat_message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.content,
    required super.senderId,
    super.senderName,
    super.senderAvatar,
    required super.channelId,
    required super.createdAt,
    super.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      content: json['content'],
      senderId: json['senderId'].toString(),
      senderName: json['sender']?['name'],
      senderAvatar: json['sender']?['avatar'],
      channelId: json['channelId'].toString(),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'channelId': channelId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
