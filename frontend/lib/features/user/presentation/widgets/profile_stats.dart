import 'package:flutter/material.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class ProfileStats extends StatelessWidget {
  final UserEntity user;

  const ProfileStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            count: user.skills.length,
            label: 'Skills',
            context: context,
          ),
          _StatItem(
            count: 7, // TODO: Get actual teams count from user data
            label: 'Teams',
            context: context,
          ),
          _StatItem(
            count: 0, // TODO: Get actual projects count
            label: 'Projects',
            context: context,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final BuildContext context;

  const _StatItem({
    required this.count,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
