// teams_list_page.dart
import 'dart:math'; // Add this import for the min function
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/empty_state.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/teams/presentation/blocs/create_team/create_team_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/teams/teams_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/teams/teams_state.dart';
import 'package:frontend/features/teams/presentation/pages/create_team_page.dart';
import 'package:frontend/core/injection_container.dart';
import 'package:logger/logger.dart';
import '../widgets/team_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';

class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage> {
  int _currentIndex = 0;
  final GlobalKey<_TeamsListContentState> _teamsListKey = GlobalKey();

  List<Widget> get _pages => [
    TeamsListContent(key: _teamsListKey),
    BlocProvider(
      create: (context) => getIt<CreateTeamCubit>(),
      child: CreateTeamPage(
        onTeamCreated: _onTeamCreated, // Add this callback
      ),
    ),
    Container(alignment: Alignment.center, child: const Text('Profile Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          const swipeThreshold = 300.0;

          if (velocity.abs() < swipeThreshold) return;

          setState(() {
            if (velocity > 0 && _currentIndex > 0) {
              _currentIndex--;
            } else if (velocity < 0 && _currentIndex < _pages.length - 1) {
              _currentIndex++;
            }
          });
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar? _buildAppBar() {
    if (_currentIndex != 0) return null;

    return AppBar(
      title: Row(
        children: [
          Image.asset("assets/images/logos/devkazi.png", height: 36),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.green, Colors.blue, Colors.orange],
            ).createShader(bounds),
            child: const Text(
              'DevKazi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          key: const ValueKey(Size(24, 24)),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _navigateToNotifications,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 0
                  ? BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                _currentIndex == 0 ? Icons.group_rounded : Icons.group_outlined,
                size: 24,
              ),
            ),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 1
                  ? BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                _currentIndex == 1
                    ? Icons.add_circle_rounded
                    : Icons.add_circle_outline_rounded,
                size: 24,
              ),
            ),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 2
                  ? BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                _currentIndex == 2
                    ? Icons.person_rounded
                    : Icons.person_outlined,
                size: 24,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _navigateToNotifications() {
    setState(() => _currentIndex = 1);
  }

  // Add this method to handle team creation success
  void _onTeamCreated() {
    // Switch to teams tab
    setState(() {
      _currentIndex = 0;
    });

    // Refresh teams list
    _refreshTeamsList();
  }

  void _refreshTeamsList() {
    _teamsListKey.currentState?.refresh();
  }
}

class TeamsListContent extends StatefulWidget {
  const TeamsListContent({super.key});

  @override
  State<TeamsListContent> createState() => _TeamsListContentState();
}

class _TeamsListContentState extends State<TeamsListContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TeamsCubit>().loadUserTeams();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<TeamsCubit>().searchTeams(query);
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void refresh() {
    context.read<TeamsCubit>().loadUserTeams();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, state) {
        return RefreshIndicator.adaptive(
          onRefresh: () => context.read<TeamsCubit>().loadUserTeams(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSearchBar(),
                ),
              ),
              _buildContent(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade400, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.green.shade400, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search teams...',
          hintStyle: TextStyle(color: Colors.green.shade400, fontSize: 15),
          prefixIcon: _searchController.text.isEmpty
              ? Icon(Icons.search, color: Colors.green.shade400, size: 22)
              : null,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.green.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TeamsState state) {
    if (state.status == TeamsStatus.loading) {
      return const SliverFillRemaining(child: TeamsLoadingShimmer());
    }

    if (state.status == TeamsStatus.error) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorState(
              message: state.errorMessage,
              onRetry: () => context.read<TeamsCubit>().loadUserTeams(),
            ),
            const SizedBox(height: 16),
            // DEBUG BUTTON
            ElevatedButton(
              onPressed: () async {
                final authRepo = getIt<AuthRepository>();
                final token = await authRepo.getAccessToken();
                Logger().d('🔍 DEBUG: Current token: $token');
                if (token == null) {
                  Logger().d('🔍 DEBUG: NO TOKEN FOUND!');
                } else {
                  Logger().d('🔍 DEBUG: Token length: ${token.length}');
                  Logger().d(
                    '🔍 DEBUG: Token preview: ${token.substring(0, min(30, token.length))}...',
                  );
                }
              },
              child: const Text('Debug: Check Token'),
            ),
          ],
        ),
      );
    }

    final teamsToShow = state.isSearching ? state.filteredTeams : state.teams;

    if (teamsToShow.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          title: state.isSearching ? 'No teams found' : 'No teams yet',
          message: state.isSearching
              ? 'Try searching with different keywords'
              : 'Create your first team to get started',
          icon: state.isSearching
              ? Icons.search_off_rounded
              : Icons.group_add_rounded,
          actionText: state.isSearching ? null : 'Create Team',
          onAction: state.isSearching ? null : _navigateToCreateTeam,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final team = teamsToShow[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            index == teamsToShow.length - 1 ? 24 : 8,
          ),
          child: TeamCard(
            team: team,
            onTap: () => _navigateToTeamDetails(team.id),
          ),
        );
      }, childCount: teamsToShow.length),
    );
  }

  void _navigateToTeamDetails(String teamId) {
    // Navigate to team details page
  }

  void _navigateToCreateTeam() {
    Navigator.of(context).pushNamed('/create-team').then((shouldRefresh) {
      if (mounted && shouldRefresh == true) {
        context.read<TeamsCubit>().loadUserTeams();
      }
    });
  }
}
