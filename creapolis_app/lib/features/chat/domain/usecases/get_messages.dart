import 'package:injectable/injectable.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

@lazySingleton
class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<Message>> call(
    String channelId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await repository.getMessages(
      channelId,
      limit: limit,
      offset: offset,
    );
  }
}
