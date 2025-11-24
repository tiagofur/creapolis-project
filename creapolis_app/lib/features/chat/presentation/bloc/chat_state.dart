import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_channel.dart';
import '../../domain/entities/chat_message.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatChannel> channels;
  final List<Message> messages;
  final String? errorMessage;
  final String? currentChannelId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.channels = const [],
    this.messages = const [],
    this.errorMessage,
    this.currentChannelId,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatChannel>? channels,
    List<Message>? messages,
    String? errorMessage,
    String? currentChannelId,
  }) {
    return ChatState(
      status: status ?? this.status,
      channels: channels ?? this.channels,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      currentChannelId: currentChannelId ?? this.currentChannelId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    channels,
    messages,
    errorMessage,
    currentChannelId,
  ];
}
