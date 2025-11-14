// features/teams/presentation/pages/team_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import '../blocs/team_details/team_details_cubit.dart';
import '../blocs/team_details/team_details_state.dart';
import '../widgets/team_details_app_bar.dart';
import '../widgets/team_tab_navigation.dart';
import '../widgets/team_chats_tab.dart';
import '../widgets/team_projects_tab.dart';
import '../widgets/team_members_tab.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/chat/presentation/cubits/chat_cubit.dart';
import 'package:frontend/core/injection_container.dart' as di;
import 'package:frontend/features/user/presentation/cubits/user_cubit.dart'; // ADD THIS
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class TeamDetailsPage extends StatefulWidget {
  final TeamEntity team;

  const TeamDetailsPage({super.key, required this.team});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  final PageController _pageController = PageController();
  int _currentTabIndex = 0;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    context.read<TeamDetailsCubit>().loadTeamWithMembers(widget.team.id);
    _loadAccessToken();
  }

  Future<void> _loadAccessToken() async {
    try {
      final authRepository = di.getIt<AuthRepository>();
      final token = await authRepository.getAccessToken();

      // Get current user from UserCubit
      final userCubit = di.getIt<UserCubit>();

      UserEntity? currentUser;

      // Check if user is already loaded in UserCubit
      if (userCubit.state is UserLoaded) {
        final userState = userCubit.state as UserLoaded;
        currentUser = userState.user;
        print(
          '🟢 TeamDetailsPage: Found current user in UserCubit: ${currentUser.name} (${currentUser.id})',
        );
      } else {
        // If user is not loaded, load it first
        print('🟡 TeamDetailsPage: User not loaded, loading current user...');
        await userCubit.loadCurrentUser();

        // Wait a moment for the state to update, then check again
        await Future.delayed(const Duration(milliseconds: 100));

        if (userCubit.state is UserLoaded) {
          final userState = userCubit.state as UserLoaded;
          currentUser = userState.user;
          print(
            '🟢 TeamDetailsPage: Loaded current user: ${currentUser.name} (${currentUser.id})',
          );
        } else {
          print(
            '🔴 TeamDetailsPage: Failed to load current user. State: ${userCubit.state}',
          );
        }
      }

      if (currentUser != null && token != null) {
        print(
          '🟢 TeamDetailsPage: Connecting to chat for team ${widget.team.id}',
        );
        final chatCubit = di.getIt<ChatCubit>();
        chatCubit.connectToChat(widget.team.id, token, currentUser);
      } else {
        print(
          '🔴 TeamDetailsPage: Cannot connect to chat - user: ${currentUser != null}, token: ${token != null}',
        );
      }

      setState(() {
        _accessToken = token;
      });
    } catch (e) {
      print('Error loading access token: $e');
    }
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
        // Show loading if token is not ready
        if (_accessToken == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: TeamDetailsAppBar(
            team: state.team,
            isLoading: state.status == TeamDetailsStatus.loading,
          ),
          body: Column(
            children: [
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
                    // FIXED: Use BlocProvider.value to share the same ChatCubit instance
                    BlocProvider.value(
                      value: di.getIt<ChatCubit>(),
                      child: TeamChatsTab(
                        teamId: widget.team.id,
                        accessToken: _accessToken!,
                      ),
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
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (team.description != null && team.description!.isNotEmpty) ...[
            Text(
              team.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              _buildMemberAvatars(team),
              const Spacer(),
              _buildTeamStatus(team.memberCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatars(TeamEntity team) {
    // Generate colors based on team name for consistency
    print(
      '🟡 _buildMemberAvatars: team.members.length = ${team.members.length}',
    );
    print('🟡 _buildMemberAvatars: team.memberCount = ${team.memberCount}');
    final colors = _generateColorsFromTeamName(team.name);

    return Expanded(
      child: Row(
        children: [
          // Check if members list has data
          if (team.members.isNotEmpty)
            for (int i = 0; i < team.members.length && i < 4; i++)
              Padding(
                padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: _buildMemberAvatar(
                  team.members[i].initials,
                  colors[i % colors.length],
                ),
              ),
          if (team.members.length > 4) ...[
            const SizedBox(width: 8),
            _buildExtraMembersCount(team.members.length - 4),
          ],
          // Fallback if no members data
          if (team.members.isEmpty)
            for (int i = 0; i < team.memberCount && i < 4; i++)
              Padding(
                padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: _buildMemberAvatar(
                  team.name[i % team.name.length].toUpperCase(),
                  colors[i % colors.length],
                ),
              ),
        ],
      ),
    );
  }

  List<Color> _generateColorsFromTeamName(String teamName) {
    // Generate consistent colors based on team name
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];

    // Use team name hash to determine color sequence
    final hash = teamName.hashCode;
    return [
      colors[hash % colors.length],
      colors[(hash + 1) % colors.length],
      colors[(hash + 2) % colors.length],
      colors[(hash + 3) % colors.length],
    ];
  }

  Widget _buildMemberAvatar(String initial, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamStatus(int memberCount) {
    final isFull = memberCount >= 4; // Changed to max 4 members
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFull
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFull
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
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
            isFull ? 'Full' : '$memberCount/4 members', // Updated to 4
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
