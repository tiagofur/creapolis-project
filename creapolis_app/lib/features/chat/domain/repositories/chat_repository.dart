import '../entities/chat_channel.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatChannel>> getChannels();
  Future<List<Message>> getMessages(
    String channelId, {
    int limit = 50,
    int offset = 0,
  });
  Future<Message> sendMessage(String channelId, String content);
  Future<ChatChannel> createChannel({
    required String type,
    String? name,
    String? projectId,
    String? workspaceId,
    List<String>? memberIds,
  });
  Future<void> markChannelAsRead(String channelId);
}
