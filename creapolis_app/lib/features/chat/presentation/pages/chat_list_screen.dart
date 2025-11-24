import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBloc>()..add(LoadChannels()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state.status == ChatStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ChatStatus.error) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            if (state.channels.isEmpty) {
              return const Center(child: Text('No conversations yet'));
            }
            return ListView.builder(
              itemCount: state.channels.length,
              itemBuilder: (context, index) {
                final channel = state.channels[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(channel.name?[0] ?? '?')),
                  title: Text(channel.name ?? 'Unknown'),
                  subtitle: Text(channel.lastMessage?.content ?? 'No messages'),
                  trailing: channel.unreadCount > 0
                      ? CircleAvatar(
                          radius: 10,
                          child: Text(
                            channel.unreadCount.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          channelId: channel.id,
                          channelName: channel.name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
