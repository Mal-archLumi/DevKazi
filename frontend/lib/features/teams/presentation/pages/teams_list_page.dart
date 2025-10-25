// presentation/pages/teams_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/empty_state.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/features/teams/presentation/blocs/teams/teams_state.dart';
import '../blocs/teams/teams_cubit.dart';
import '../widgets/team_card.dart';
import '../widgets/teams_search_bar.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';

class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage> {
  int _currentIndex = 0;
  bool _showSearchBar = false;

  final List<Widget> _pages = [
    const TeamsListContent(),
    const Placeholder(), // NotificationsPage(),
    const Placeholder(), // ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar? _buildAppBar() {
    if (_currentIndex != 0) return null;

    return AppBar(
      title: _showSearchBar
          ? null
          : const Text(
              'My Teams',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
      actions: [
        if (!_showSearchBar)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _showSearchBar = true),
          ),
        if (!_showSearchBar)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _navigateToNotifications(),
          ),
      ],
      bottom: _showSearchBar
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TeamsSearchBar(
                  onSearchChanged: (query) {
                    context.read<TeamsCubit>().searchTeams(query);
                  },
                  onSearchClosed: () => setState(() => _showSearchBar = false),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(
        context,
      ).colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentIndex == 0 && !_showSearchBar) {
      return FloatingActionButton(
        onPressed: _navigateToCreateTeam,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  void _navigateToCreateTeam() {
    // TODO: Navigate to create team page
    // context.push('/teams/create');
  }

  void _navigateToNotifications() {
    // TODO: Navigate to notifications
  }
}

class TeamsListContent extends StatefulWidget {
  const TeamsListContent({super.key});

  @override
  State<TeamsListContent> createState() => _TeamsListContentState();
}

class _TeamsListContentState extends State<TeamsListContent> {
  @override
  void initState() {
    super.initState();
    // Load teams when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamsCubit>().loadUserTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<TeamsCubit>().loadUserTeams(),
          child: _buildContent(state),
        );
      },
    );
  }

  Widget _buildContent(TeamsState state) {
    if (state.status == TeamsStatus.loading) {
      return const TeamsLoadingShimmer();
    }

    if (state.status == TeamsStatus.error) {
      return ErrorState(
        message: state.errorMessage,
        onRetry: () => context.read<TeamsCubit>().loadUserTeams(),
      );
    }

    final teamsToShow = state.isSearching ? state.filteredTeams : state.teams;

    if (teamsToShow.isEmpty) {
      return EmptyState(
        title: state.isSearching ? 'No teams found' : 'No teams yet',
        message: state.isSearching
            ? 'Try searching with different keywords'
            : 'Create your first team to get started',
        icon: state.isSearching ? Icons.search_off : Icons.group_add,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teamsToShow.length,
      itemBuilder: (context, index) {
        final team = teamsToShow[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TeamCard(
            team: team,
            onTap: () => _navigateToTeamDetails(team.id),
          ),
        );
      },
    );
  }

  void _navigateToTeamDetails(String teamId) {
    // TODO: Navigate to team details
    // context.push('/teams/$teamId');
  }
}
