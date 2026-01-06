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
import 'package:frontend/features/user/presentation/cubits/user_cubit.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/projects/presentation/cubits/projects_cubit.dart';
import 'package:frontend/features/teams/presentation/cubits/join_requests_cubit.dart';
import 'package:frontend/features/teams/presentation/pages/join_requests_page.dart';

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
  String? _currentUserId;
  UserEntity? _currentUser;
  late JoinRequestsCubit _joinRequestsCubit;
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _joinRequestsCubit = di.getIt<JoinRequestsCubit>();
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    try {
      debugPrint('🟡 TeamDetailsPage: Starting initialization...');

      // Step 1: Get auth token
      final authRepository = di.getIt<AuthRepository>();
      final token = await authRepository.getAccessToken();

      if (token == null) {
        debugPrint('🔴 TeamDetailsPage: No access token available');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint('🟢 TeamDetailsPage: Got access token');

      // Step 2: Get current user
      final userCubit = di.getIt<UserCubit>();
      UserEntity? currentUser;

      if (userCubit.state is UserLoaded) {
        currentUser = (userCubit.state as UserLoaded).user;
      } else {
        await userCubit.loadCurrentUser();
        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 200));

        if (userCubit.state is UserLoaded) {
          currentUser = (userCubit.state as UserLoaded).user;
        }
      }

      if (currentUser == null) {
        debugPrint('🔴 TeamDetailsPage: Could not get current user');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint('🟢 TeamDetailsPage: Got current user: ${currentUser.id}');

      // Step 3: Update state with auth info
      if (mounted) {
        setState(() {
          _accessToken = token;
          _currentUserId = currentUser!.id;
          _currentUser = currentUser;
          _isInitialized = true;
          _isLoading = false;
        });
      }

      // Step 4: Load team details
      if (mounted) {
        context.read<TeamDetailsCubit>().loadTeamWithMembers(widget.team.id);
      }

      // Step 5: Connect to chat
      final chatCubit = di.getIt<ChatCubit>();
      chatCubit.connectToChat(widget.team.id, token, currentUser);

      // Step 6: Load join requests if user is creator
      final isCreator = currentUser.id == widget.team.creatorId;
      debugPrint(
        '🟡 TeamDetailsPage: Is creator: $isCreator (userId: ${currentUser.id}, creatorId: ${widget.team.creatorId})',
      );

      if (isCreator) {
        debugPrint('🟡 TeamDetailsPage: Loading join requests for creator...');
        _joinRequestsCubit.loadJoinRequests(widget.team.id);
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 TeamDetailsPage: Error during initialization: $e');
      debugPrint('🔴 Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    // Validate index based on whether requests tab is visible
    final isCreator = _currentUserId == widget.team.creatorId;
    final maxIndex = isCreator ? 3 : 2;

    if (index > maxIndex) {
      return;
    }

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
    // Show loading while initializing
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.team.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if not initialized
    if (!_isInitialized || _accessToken == null || _currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.team.name)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text('Failed to load authentication'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _initializeAll();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<TeamDetailsCubit, TeamDetailsState>(
      builder: (context, state) {
        final TeamEntity displayTeam = state.team ?? widget.team;
        final bool isCreator = _currentUserId == displayTeam.creatorId;

        debugPrint(
          '🔵 TeamDetailsPage Build: isCreator=$isCreator, userId=$_currentUserId, creatorId=${displayTeam.creatorId}',
        );

        return BlocProvider.value(
          value: _joinRequestsCubit,
          child: BlocBuilder<JoinRequestsCubit, JoinRequestsState>(
            bloc: _joinRequestsCubit,
            builder: (context, joinRequestsState) {
              final pendingCount = isCreator
                  ? joinRequestsState.pendingCount
                  : 0;

              // Build the list of tab pages
              final List<Widget> tabPages = [
                BlocProvider.value(
                  value: di.getIt<ChatCubit>(),
                  child: TeamChatsTab(
                    teamId: widget.team.id,
                    accessToken: _accessToken!,
                    currentUser: _currentUser!,
                  ),
                ),
                BlocProvider(
                  create: (context) => di.getIt<ProjectsCubit>(),
                  child: TeamProjectsTab(teamId: widget.team.id),
                ),
                const TeamMembersTab(),
              ];

              // Add requests tab only if creator
              if (isCreator) {
                tabPages.add(
                  BlocProvider.value(
                    value: _joinRequestsCubit,
                    child: JoinRequestsPage(
                      teamId: widget.team.id,
                      isTeamCreator: true,
                    ),
                  ),
                );
              }

              return Scaffold(
                appBar: TeamDetailsAppBar(
                  team: displayTeam,
                  isLoading:
                      state.status == TeamDetailsStatus.loading &&
                      state.team == null,
                ),
                body: Column(
                  children: [
                    _buildTeamHeader(displayTeam),
                    TeamTabNavigation(
                      currentIndex: _currentTabIndex,
                      onTabChanged: _onTabChanged,
                      showRequestsTab: isCreator,
                      pendingRequestsCount: pendingCount,
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          // Validate index
                          final maxIndex = isCreator ? 3 : 2;
                          if (index <= maxIndex) {
                            setState(() {
                              _currentTabIndex = index;
                            });
                          }
                        },
                        children: tabPages,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTeamHeader(TeamEntity team) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (team.description != null && team.description!.isNotEmpty) ...[
            Text(
              team.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(child: _buildMemberAvatars(team)),
              const SizedBox(width: 12),
              _buildTeamStatus(team.memberCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatars(TeamEntity team) {
    final colors = _generateColorsFromTeamName(team.name);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (team.members.isNotEmpty)
          ...List.generate(
            team.members.length > 4 ? 4 : team.members.length,
            (i) => Padding(
              padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
              child: _buildMemberAvatar(
                team.members[i].initials,
                colors[i % colors.length],
              ),
            ),
          ),
        if (team.members.length > 4) ...[
          const SizedBox(width: 8),
          _buildExtraMembersCount(team.members.length - 4),
        ],
        if (team.members.isEmpty && team.memberCount > 0)
          ...List.generate(
            team.memberCount > 4 ? 4 : team.memberCount,
            (i) => Padding(
              padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
              child: _buildMemberAvatar(
                team.name[i % team.name.length].toUpperCase(),
                colors[i % colors.length],
              ),
            ),
          ),
      ],
    );
  }

  List<Color> _generateColorsFromTeamName(String teamName) {
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
    final isFull = memberCount >= 4;
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
            isFull ? 'Full' : '$memberCount/4',
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
