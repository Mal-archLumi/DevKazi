import 'package:flutter/material.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class ProfileStats extends StatelessWidget {
  final UserEntity user;

  const ProfileStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Assuming user has a 'teams' list. If not, fallback to 0.
    // Replace `user.teams` with whatever list holds your team data in the entity.
    final int teamsCount = (user.teams as List?)?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStat(
              context,
              'Skills',
              user.skills.length.toString(),
              Icons.auto_awesome,
            ),
            _buildDivider(context),
            // DYNAMIC TEAM COUNT HERE
            _buildStat(
              context,
              'Teams',
              teamsCount.toString(),
              Icons.groups_2_rounded,
            ),
            _buildDivider(context),
            // Assuming projects logic comes later, placeholder for now
            _buildStat(context, 'Projects', '0', Icons.rocket_launch_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.5),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
