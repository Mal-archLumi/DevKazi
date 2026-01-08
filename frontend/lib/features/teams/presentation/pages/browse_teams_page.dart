import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/empty_state.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/core/widgets/loading_shimmer.dart';
import 'package:frontend/features/teams/presentation/blocs/browse_teams/browse_teams_cubit.dart';
import 'package:frontend/features/teams/presentation/widgets/browse_team_card.dart';

class BrowseTeamsPage extends StatefulWidget {
  final VoidCallback? onCreateTeamPressed;

  const BrowseTeamsPage({super.key, this.onCreateTeamPressed});

  @override
  State<BrowseTeamsPage> createState() => _BrowseTeamsPageState();
}

class _BrowseTeamsPageState extends State<BrowseTeamsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Load teams when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrowseTeamsCubit>().loadAllTeams();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<BrowseTeamsCubit>().searchTeams(query);
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Discover Teams',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: BlocBuilder<BrowseTeamsCubit, BrowseTeamsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<BrowseTeamsCubit>().loadAllTeams(),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header (always shown)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Create Team button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onCreateTeamPressed,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                            ),
                            child: const Text(
                              'Create Team',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        const Text(
                          'Explore Teams',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search bar
                        _buildSearchBar(),
                      ],
                    ),
                  ),
                ),
                // Dynamic content based on state
                _buildContent(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.green.shade400, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search all teams...',
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

  Widget _buildContent(BuildContext context, BrowseTeamsState state) {
    if (state.status == BrowseTeamsStatus.loading) {
      return const SliverToBoxAdapter(child: TeamsLoadingShimmer());
    }

    if (state.status == BrowseTeamsStatus.error) {
      return SliverFillRemaining(
        // CHANGED: Use SliverFillRemaining
        hasScrollBody: false,
        child: ErrorState(
          message: state.errorMessage ?? 'Something went wrong',
          onRetry: () => context.read<BrowseTeamsCubit>().loadAllTeams(),
        ),
      );
    }

    final teamsToShow = state.isSearching ? state.filteredTeams : state.teams;

    if (teamsToShow.isEmpty) {
      return SliverFillRemaining(
        // CHANGED: Use SliverFillRemaining
        hasScrollBody: false,
        child: EmptyState(
          title: state.isSearching ? 'No teams found' : 'No teams available',
          message: state.isSearching
              ? 'Try searching with different keywords'
              : 'Be the first to create a team and start collaborating!',
          icon: state.isSearching
              ? Icons.search_off_rounded
              : Icons.group_add_rounded,
          actionText: state.isSearching ? null : 'Create Team',
          onAction: state.isSearching ? null : widget.onCreateTeamPressed,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final team = teamsToShow[index];
        final hasPendingRequest = state.pendingRequestTeamIds.contains(team.id);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            index == 0 ? 8 : 4,
            16,
            index == teamsToShow.length - 1 ? 24 : 4,
          ),
          child: BrowseTeamCard(
            team: team,
            onTap: () => _navigateToTeamDetails(context, team.id),
            onJoin: () => _joinTeam(context, team.id),
            isJoining: state.joiningTeamId == team.id,
            hasPendingRequest: hasPendingRequest,
          ),
        );
      }, childCount: teamsToShow.length),
    );
  }

  void _navigateToTeamDetails(BuildContext context, String teamId) {
    debugPrint('Navigate to team details: $teamId');
  }

  void _joinTeam(BuildContext context, String teamId) {
    context.read<BrowseTeamsCubit>().joinTeam(teamId);

    // Listen for result and show appropriate snackbar
    final cubit = context.read<BrowseTeamsCubit>();

    // Use a listener or check state after action
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final state = cubit.state;
      if (state.pendingRequestTeamIds.contains(teamId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Join request sent successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });
  }
}
