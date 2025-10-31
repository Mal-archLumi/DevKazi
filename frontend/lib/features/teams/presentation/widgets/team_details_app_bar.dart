// lib/features/teams/presentation/widgets/team_details_app_bar.dart
import 'package:flutter/material.dart';
import '../../domain/entities/team_entity.dart';

class TeamDetailsAppBar extends AppBar {
  TeamDetailsAppBar({
    super.key,
    required TeamEntity? team,
    required bool isLoading,
  }) : super(
         title: isLoading
             ? const Text('Loading...')
             : Text(team?.name ?? 'Team Details'),
         elevation: 0,
       );
}
