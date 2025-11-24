import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadChannels extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String channelId;

  const LoadMessages(this.channelId);

  @override
  List<Object> get props => [channelId];
}

class SendMessage extends ChatEvent {
  final String channelId;
  final String content;

  const SendMessage(this.channelId, this.content);

  @override
  List<Object> get props => [channelId, content];
}

class ReceiveMessage extends ChatEvent {
  final Message message;

  const ReceiveMessage(this.message);

  @override
  List<Object> get props => [message];
}
