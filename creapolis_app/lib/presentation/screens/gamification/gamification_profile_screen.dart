import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/gamification_service.dart';
import '../../../domain/entities/gamification_profile.dart';
import '../../../injection.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/loading/skeleton_list.dart';

class GamificationProfileScreen extends StatefulWidget {
  const GamificationProfileScreen({super.key});

  @override
  State<GamificationProfileScreen> createState() => _GamificationProfileScreenState();
}

class _GamificationProfileScreenState extends State<GamificationProfileScreen> {
  final GamificationService _gamificationService = getIt<GamificationService>();
  GamificationProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });
    final user = context.read<WorkspaceContext>().currentUser;
    if (user != null) {
      _profile = await _gamificationService.getGamificationProfile(user.id);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gamification Profile'),
      ),
      body: _isLoading
          ? SkeletonList(itemCount: 3)
          : _profile == null
              ? const Center(child: Text('Could not load profile.'))
              : _buildProfile(),
    );
  }

  Widget _buildProfile() {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Points section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'My Points',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_profile!.points}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Badges section
          Text('My Badges', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _profile!.badges.isEmpty
              ? const Text('No badges earned yet.')
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _profile!.badges.length,
                  itemBuilder: (context, index) {
                    final badge = _profile!.badges[index];
                    return Tooltip(
                      message: '${badge.name}\n${badge.description}',
                      child: CircleAvatar(
                        radius: 30,
                        child: Text(badge.icon ?? '🏆'),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 24),

          // Achievements section
          Text('My Achievements', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._profile!.achievements.map((achievement) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          achievement.name,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (achievement.isUnlocked)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(achievement.description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: achievement.progress / achievement.goal,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 4),
                    Text('${achievement.progress} / ${achievement.goal}'),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
