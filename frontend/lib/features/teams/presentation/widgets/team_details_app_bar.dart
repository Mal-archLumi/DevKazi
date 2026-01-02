// lib/features/teams/presentation/widgets/team_details_app_bar.dart
import 'package:flutter/material.dart';
import '../../domain/entities/team_entity.dart';
import 'team_details_menu.dart';

class TeamDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TeamEntity? team;
  final bool isLoading;

  const TeamDetailsAppBar({
    super.key,
    required this.team,
    required this.isLoading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(context),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      scrolledUnderElevation: 1,
      leading: const BackButton(),
      actions: [
        if (team != null && !isLoading)
          TeamDetailsMenu(teamId: team!.id, teamName: team!.name),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (isLoading && team == null) {
      return Text(
        'Loading...',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    return Text(
      team?.name ?? 'Team Details',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
