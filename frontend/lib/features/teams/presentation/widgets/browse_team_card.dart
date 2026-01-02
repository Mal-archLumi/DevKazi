// features/teams/presentation/widgets/browse_team_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';

class BrowseTeamCard extends StatelessWidget {
  final TeamEntity team;
  final VoidCallback onTap;
  final VoidCallback onJoin;
  final bool isJoining;
  final bool hasPendingRequest;

  const BrowseTeamCard({
    super.key,
    required this.team,
    required this.onTap,
    required this.onJoin,
    this.isJoining = false,
    this.hasPendingRequest = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFull = team.memberCount >= (team.maxMembers ?? 4);

    // Safely get skills - handle null
    final skills = team.skills ?? [];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (team.name.isNotEmpty)
                            ? team.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${team.memberCount}/${team.maxMembers ?? 4} members',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildJoinButton(context, isFull),
                ],
              ),
              // Safe null check for description
              if (team.description != null && team.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  team.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Safe null check for skills - use local variable
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: skills.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        skill,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, bool isFull) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (hasPendingRequest) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 16, color: Colors.orange.shade700),
            const SizedBox(width: 4),
            Text(
              'Pending',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Full',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    return FilledButton(
      onPressed: isJoining ? null : onJoin,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: isJoining
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Join'),
    );
  }
}
