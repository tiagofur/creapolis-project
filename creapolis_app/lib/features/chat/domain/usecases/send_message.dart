import 'package:injectable/injectable.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

@lazySingleton
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Message> call(String channelId, String content) async {
    return await repository.sendMessage(channelId, content);
  }
}
