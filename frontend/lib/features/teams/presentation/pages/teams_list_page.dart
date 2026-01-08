// lib/features/teams/presentation/pages/teams_list_page.dart (UPDATED)

import 'dart:async';
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
import 'package:frontend/features/user/presentation/pages/profile_page.dart';
import 'package:logger/logger.dart';
import '../widgets/team_card.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import 'package:frontend/core/constants/route_constants.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/user/presentation/cubits/user_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/browse_teams/browse_teams_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubits/notifications_cubit.dart';
import 'package:frontend/features/notifications/presentation/cubits/notifications_state.dart';

class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage> {
  int _currentIndex = 0;
  final GlobalKey<_TeamsListBodyState> _teamsListKey = GlobalKey();
  final PageController _pageController = PageController();
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);

    // Load notifications on init
    Future.microtask(() {
      context.read<NotificationsCubit>().loadNotifications();
    });

    // Refresh unread count every 30 seconds
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context.read<NotificationsCubit>().refreshUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _notificationTimer?.cancel();
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
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => getIt<UserCubit>())],
      child: Scaffold(
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
            BlocProvider(
              create: (context) => getIt<BrowseTeamsCubit>(),
              child: BrowseTeamsPage(
                onCreateTeamPressed: _navigateToCreateTeam,
              ),
            ),
            const ProfilePage(),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? _buildFloatingActionButton()
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToCreateTeam,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, size: 28),
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
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final unreadCount = state.unreadCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: _navigateToNotifications,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
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
    Navigator.of(context).pushNamed(RouteConstants.notifications).then((_) {
      // Refresh unread count when returning from notifications page
      context.read<NotificationsCubit>().refreshUnreadCount();
    });
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

// Rest of the TeamsListBody stays the same...
class TeamsListBody extends StatefulWidget {
  const TeamsListBody({super.key});

  @override
  State<TeamsListBody> createState() => _TeamsListBodyState();
}

class _TeamsListBodyState extends State<TeamsListBody> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

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
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      print('🟡 TeamsListBody: Executing search with query: "$query"');

      if (query.isEmpty) {
        print('🟡 TeamsListBody: Query is empty, showing all teams');
      }

      context.read<TeamsCubit>().searchTeams(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebounce?.cancel();
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
            onTap: () => _navigateToTeamDetails(team),
          ),
        );
      }, childCount: teamsToShow.length),
    );
  }

  void _navigateToTeamDetails(TeamEntity team) {
    Navigator.of(
      context,
    ).pushNamed(RouteConstants.teamDetails, arguments: team);
  }
}
