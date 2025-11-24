import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_channels.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../../../core/services/socket_service.dart';
import '../../data/models/chat_message_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChannelsUseCase getChannels;
  final GetMessagesUseCase getMessages;
  final SendMessageUseCase sendMessage;
  final SocketService socketService;

  ChatBloc(
    this.getChannels,
    this.getMessages,
    this.sendMessage,
    this.socketService,
  ) : super(const ChatState()) {
    on<LoadChannels>(_onLoadChannels);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);

    _initSocketListeners();
  }

  void _initSocketListeners() {
    socketService.on('new_message', (data) {
      try {
        final message = MessageModel.fromJson(data);
        add(ReceiveMessage(message));
      } catch (e) {
        // Handle parsing error
      }
    });
  }

  Future<void> _onLoadChannels(
    LoadChannels event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final channels = await getChannels();
      emit(state.copyWith(status: ChatStatus.loaded, channels: channels));
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ChatStatus.loading,
        currentChannelId: event.channelId,
      ),
    );
    try {
      final messages = await getMessages(event.channelId);
      emit(state.copyWith(status: ChatStatus.loaded, messages: messages));
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = await sendMessage(event.channelId, event.content);
      final updatedMessages = List<Message>.from(state.messages)
        ..insert(0, message);
      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<ChatState> emit) {
    final message = event.message;
    if (message.channelId == state.currentChannelId) {
      final updatedMessages = List<Message>.from(state.messages)
        ..insert(0, message);
      emit(state.copyWith(messages: updatedMessages));
    }
    // Also update channel last message/unread count if I had that logic here
  }

  @override
  Future<void> close() {
    socketService.off('new_message');
    return super.close();
  }
}
