import 'package:injectable/injectable.dart';
import '../../domain/entities/chat_channel.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatChannel>> getChannels() async {
    return await remoteDataSource.getChannels();
  }

  @override
  Future<List<Message>> getMessages(
    String channelId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await remoteDataSource.getMessages(
      channelId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Message> sendMessage(String channelId, String content) async {
    return await remoteDataSource.sendMessage(channelId, content);
  }

  @override
  Future<ChatChannel> createChannel({
    required String type,
    String? name,
    String? projectId,
    String? workspaceId,
    List<String>? memberIds,
  }) async {
    return await remoteDataSource.createChannel(
      type: type,
      name: name,
      projectId: projectId,
      workspaceId: workspaceId,
      memberIds: memberIds,
    );
  }

  @override
  Future<void> markChannelAsRead(String channelId) async {
    await remoteDataSource.markChannelAsRead(channelId);
  }
}
