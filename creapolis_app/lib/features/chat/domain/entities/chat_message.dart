import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String channelId;
  final DateTime createdAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.channelId,
    required this.createdAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    senderId,
    senderName,
    senderAvatar,
    channelId,
    createdAt,
    isRead,
  ];
}
