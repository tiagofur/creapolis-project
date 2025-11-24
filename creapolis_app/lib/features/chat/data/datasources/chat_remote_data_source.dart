import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/chat_channel_model.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatChannelModel>> getChannels();
  Future<List<MessageModel>> getMessages(
    String channelId, {
    int limit = 50,
    int offset = 0,
  });
  Future<MessageModel> sendMessage(String channelId, String content);
  Future<ChatChannelModel> createChannel({
    required String type,
    String? name,
    String? projectId,
    String? workspaceId,
    List<String>? memberIds,
  });
  Future<void> markChannelAsRead(String channelId);
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ChatChannelModel>> getChannels() async {
    final response = await apiClient.get('/chat/channels');
    return (response.data['data'] as List)
        .map((json) => ChatChannelModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<MessageModel>> getMessages(
    String channelId, {
    int limit = 50,
    int offset = 0,
  }) async {
    // Using getChannel endpoint which returns { channel, messages }
    // We might want to add a dedicated messages endpoint for pagination later
    final response = await apiClient.get(
      '/chat/channels/$channelId',
      queryParameters: {
        'limit': limit,
        'before': null,
      }, // 'before' for pagination
    );
    return (response.data['data']['messages'] as List)
        .map((json) => MessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<MessageModel> sendMessage(String channelId, String content) async {
    final response = await apiClient.post(
      '/chat/channels/$channelId/messages',
      data: {'content': content},
    );
    return MessageModel.fromJson(response.data['data']);
  }

  @override
  Future<ChatChannelModel> createChannel({
    required String type,
    String? name,
    String? projectId,
    String? workspaceId,
    List<String>? memberIds,
  }) async {
    final response = await apiClient.post(
      '/chat/channels',
      data: {
        'type': type,
        'name': name,
        'projectId': projectId,
        'workspaceId': workspaceId,
        'memberIds': memberIds,
      },
    );
    return ChatChannelModel.fromJson(response.data['data']);
  }

  @override
  Future<void> markChannelAsRead(String channelId) async {
    await apiClient.post('/chat/channels/$channelId/read');
  }
}
