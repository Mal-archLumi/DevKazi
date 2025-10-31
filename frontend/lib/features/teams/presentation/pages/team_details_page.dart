// features/teams/presentation/pages/team_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/team_details/team_details_cubit.dart';
import '../blocs/team_details/team_details_state.dart';
import '../widgets/team_details_app_bar.dart';
import '../widgets/team_tab_navigation.dart';
import '../widgets/team_chats_tab.dart';
import '../widgets/team_projects_tab.dart';
import '../widgets/team_members_tab.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_cubit.dart';

class TeamDetailsPage extends StatefulWidget {
  final TeamEntity team;

  const TeamDetailsPage({super.key, required this.team});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  final PageController _pageController = PageController();
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TeamDetailsCubit>().setTeam(widget.team);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamDetailsCubit, TeamDetailsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: TeamDetailsAppBar(
            team: state.team,
            isLoading: state.status == TeamDetailsStatus.loading,
          ),
          body: Column(
            children: [
              // HEADER SECTION - Add this
              _buildTeamHeader(state.team),

              TeamTabNavigation(
                currentIndex: _currentTabIndex,
                onTabChanged: _onTabChanged,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onTabChanged,
                  children: [
                    BlocProvider(
                      create: (context) => ChatCubit(),
                      child: TeamChatsTab(teamId: widget.team.id),
                    ),
                    const TeamProjectsTab(),
                    const TeamMembersTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamHeader(TeamEntity? team) {
    if (team == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (team.description != null && team.description!.isNotEmpty) ...[
            Text(
              team.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Members and Status Row
          Row(
            children: [
              // Member Avatars
              _buildMemberAvatars(),

              const Spacer(),

              // Team Status
              _buildTeamStatus(team.memberCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatars() {
    // TODO: Replace with actual member data when available
    return Row(
      children: [
        _buildMemberAvatar('M1', Colors.blue),
        _buildMemberAvatar('M2', Colors.green),
        _buildMemberAvatar('M3', Colors.orange),
        if (widget.team.memberCount > 3) ...[
          // CHANGE: team → widget.team
          _buildExtraMembersCount(
            widget.team.memberCount - 3,
          ), // CHANGE: team → widget.team
        ],
      ],
    );
  }

  Widget _buildMemberAvatar(String initial, Color color) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildExtraMembersCount(int count) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamStatus(int memberCount) {
    final isFull = memberCount >= 10; // Adjust max members as needed
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFull
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFull
              ? Colors.red.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFull ? Icons.group_off : Icons.group,
            size: 16,
            color: isFull ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isFull ? 'Full' : '$memberCount/10 members',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFull ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
