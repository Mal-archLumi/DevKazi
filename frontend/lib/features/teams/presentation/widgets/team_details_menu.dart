// features/teams/presentation/widgets/team_details_menu.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/injection_container.dart' as di;
import 'package:frontend/features/teams/presentation/blocs/team_details/team_details_cubit.dart';

class TeamDetailsMenu extends StatelessWidget {
  final String teamId;
  final String teamName;

  const TeamDetailsMenu({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      onSelected: (value) {
        if (value == 'leave') {
          _showLeaveTeamConfirmation(context);
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'leave',
          child: Row(
            children: [
              Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Leave Team',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLeaveTeamConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Leave Team?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to leave "$teamName"? You will no longer have access to team chats, projects, and files.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog first
                _leaveTeam(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Leave Team'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
        );
      },
    );
  }

  void _leaveTeam(BuildContext context) {
    final cubit = di.getIt<TeamDetailsCubit>();

    cubit.leaveTeam(teamId).then((success) {
      // Use a post-frame callback to ensure the context is still valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (success) {
          // Navigate back to teams list - use popUntil to go all the way back
          Navigator.of(context).popUntil((route) => route.isFirst);

          // Show success message using a new context
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Left "$teamName" successfully'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        } else {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to leave "$teamName"'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      });
    });
  }
}
