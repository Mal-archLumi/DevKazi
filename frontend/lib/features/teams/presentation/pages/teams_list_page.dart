import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/empty_state.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/teams/presentation/blocs/create_team/create_team_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/teams/teams_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/teams/teams_state.dart';
import 'package:frontend/features/teams/presentation/pages/browse_teams_page.dart';
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
  final GlobalKey<_TeamsListBodyState> _teamsListKey = GlobalKey();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    final newIndex = _pageController.page?.round() ?? 0;
    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Only show app bar for the first tab (My Teams)
      appBar: _currentIndex == 0 ? _buildMyTeamsAppBar() : null,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          TeamsListBody(key: _teamsListKey),
          BrowseTeamsPage(onCreateTeamPressed: _navigateToCreateTeam),
          Container(
            alignment: Alignment.center,
            child: const Text('Profile Page'),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildMyTeamsAppBar() {
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
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
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                _currentIndex == 0 ? Icons.group_rounded : Icons.group_outlined,
                size: 24,
              ),
            ),
            label: 'My Teams',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 1
                  ? BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                _currentIndex == 1
                    ? Icons.explore_rounded
                    : Icons.explore_outlined,
                size: 24,
              ),
            ),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 2
                  ? BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
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
    // Implement notifications navigation
  }

  void _navigateToCreateTeam() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<CreateTeamCubit>(),
          child: CreateTeamPage(onTeamCreated: _onTeamCreated),
        ),
      ),
    );
  }

  void _onTeamCreated() {
    _refreshTeamsList();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Team created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _refreshTeamsList() {
    _teamsListKey.currentState?.refresh();
  }
}

class TeamsListBody extends StatefulWidget {
  const TeamsListBody({super.key});

  @override
  State<TeamsListBody> createState() => _TeamsListBodyState();
}

class _TeamsListBodyState extends State<TeamsListBody> {
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
            physics: const AlwaysScrollableScrollPhysics(),
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
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.green.shade400, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search my teams...',
          hintStyle: TextStyle(
            color: Colors.green.shade400.withOpacity(0.7),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.green.shade400,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.green.shade400.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TeamsState state) {
    if (state.status == TeamsStatus.loading) {
      return const SliverToBoxAdapter(child: TeamsLoadingShimmer());
    }

    if (state.status == TeamsStatus.error) {
      return SliverToBoxAdapter(
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ErrorState(
                  message: state.errorMessage,
                  onRetry: () => context.read<TeamsCubit>().loadUserTeams(),
                ),
                const SizedBox(height: 16),
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
          ),
        ),
      );
    }

    final teamsToShow = state.isSearching ? state.filteredTeams : state.teams;

    if (teamsToShow.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: EmptyState(
              title: state.isSearching ? 'No teams found' : 'No teams yet',
              message: state.isSearching
                  ? 'Try searching with different keywords'
                  : 'Create your first team to get started',
              icon: state.isSearching
                  ? Icons.search_off_rounded
                  : Icons.group_add_rounded,
              actionText: state.isSearching ? null : 'Create Team',
              onAction: state.isSearching
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => getIt<CreateTeamCubit>(),
                            child: CreateTeamPage(
                              onTeamCreated: () {
                                refresh();
                              },
                            ),
                          ),
                        ),
                      );
                    },
            ),
          ),
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
}
