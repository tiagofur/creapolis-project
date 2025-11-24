import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/gamification/gamification_bloc.dart';
import '../../../injection.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<GamificationBloc>()..add(const LoadLeaderboard()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tabla de Clasificación')),
        body: BlocBuilder<GamificationBloc, GamificationState>(
          builder: (context, state) {
            if (state.status == GamificationStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == GamificationStatus.failure) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }

            if (state.leaderboard.isEmpty) {
              return const Center(child: Text('No hay datos disponibles'));
            }

            return ListView.builder(
              itemCount: state.leaderboard.length,
              itemBuilder: (context, index) {
                final user = state.leaderboard[index];
                final isTop3 = index < 3;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isTop3
                        ? Colors.amber
                        : Colors.grey.shade300,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isTop3 ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Chip(
                    label: Text('${user.reputation} pts'),
                    backgroundColor: isTop3 ? Colors.amber.shade100 : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
