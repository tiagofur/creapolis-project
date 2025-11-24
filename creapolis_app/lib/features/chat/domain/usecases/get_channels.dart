import 'package:injectable/injectable.dart';
import '../entities/chat_channel.dart';
import '../repositories/chat_repository.dart';

@lazySingleton
class GetChannelsUseCase {
  final ChatRepository repository;

  GetChannelsUseCase(this.repository);

  Future<List<ChatChannel>> call() async {
    return await repository.getChannels();
  }
}
