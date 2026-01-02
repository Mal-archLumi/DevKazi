import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/projects/presentation/cubits/projects_cubit.dart';
import 'package:frontend/features/projects/presentation/widgets/add_link_dialog.dart';
import 'package:frontend/features/projects/presentation/widgets/create_project_dialog.dart';
import 'package:frontend/features/projects/presentation/widgets/edit_project_dialog.dart';
import 'package:frontend/features/projects/presentation/widgets/pinned_links_widget.dart';
import 'package:frontend/features/projects/presentation/widgets/project_assignment_card.dart';
import 'package:frontend/features/projects/presentation/widgets/timeline_widget.dart';
import 'package:frontend/features/projects/presentation/widgets/assign_member_dialog.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';
import 'package:frontend/features/teams/presentation/blocs/team_details/team_details_cubit.dart';
import 'package:frontend/features/teams/presentation/blocs/team_details/team_details_state.dart';

class TeamProjectsTab extends StatefulWidget {
  final String teamId;

  const TeamProjectsTab({super.key, required this.teamId});

  @override
  State<TeamProjectsTab> createState() => _TeamProjectsTabState();
}

class _TeamProjectsTabState extends State<TeamProjectsTab> {
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    context.read<ProjectsCubit>().loadProjects(widget.teamId);
  }

  Future<void> _onRefresh() async {
    await context.read<ProjectsCubit>().loadProjects(widget.teamId);
  }

  void _selectProject(String projectId) {
    setState(() {
      _selectedProjectId = _selectedProjectId == projectId ? null : projectId;
    });
  }

  void _clearSelectedProject() {
    setState(() {
      _selectedProjectId = null;
    });
  }

  Future<void> _showProjectOptions(
    BuildContext context,
    ProjectEntity project,
  ) async {
    final theme = Theme.of(context);
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                title: const Text('Edit Project'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Delete Project',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (result == 'edit') {
      _showEditProjectDialog(context, project);
    } else if (result == 'delete') {
      _showDeleteConfirmation(context, project);
    }
  }

  void _showDeleteConfirmation(BuildContext context, ProjectEntity project) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProjectsCubit>().deleteProject(project.id);
              Navigator.pop(context);
              _clearSelectedProject();
              _loadProjects(); // Refresh after delete
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Project "${project.name}" deleted'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, ProjectEntity project) {
    showDialog(
      context: context,
      builder: (context) => EditProjectDialog(project: project),
    ).then((_) {
      // Refresh after dialog closes
      _loadProjects();
    });
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateProjectDialog(teamId: widget.teamId),
    ).then((_) {
      // Refresh after dialog closes
      _loadProjects();
    });
  }

  void _showAddLinkDialog(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AddLinkDialog(projectId: projectId),
    ).then((_) {
      // Refresh after dialog closes
      _loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: _selectedProjectId == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedProjectId != null) {
          _clearSelectedProject();
        }
      },
      child: BlocConsumer<ProjectsCubit, ProjectsState>(
        listener: (context, state) {
          if (state.status == ProjectsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final projects = state.projects;

          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: _buildAppBar(context, projects),
            body: _buildContent(context, state, projects),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreateProjectDialog(context),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    List<ProjectEntity> projects,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_selectedProjectId != null) {
      final selectedProject = projects.firstWhere(
        (p) => p.id == _selectedProjectId,
        orElse: () => projects.first,
      );

      return AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _clearSelectedProject,
        ),
        title: Text(
          selectedProject.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProjectDialog(context, selectedProject),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: () => _showDeleteConfirmation(context, selectedProject),
          ),
        ],
      );
    }

    // Removed title, only refresh button
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadProjects,
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProjectsState state,
    List<ProjectEntity> projects,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.status == ProjectsStatus.loading && projects.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (state.status == ProjectsStatus.error && projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load projects', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadProjects,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (projects.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildEmptyState(context),
          ),
        ),
      );
    }

    if (_selectedProjectId != null) {
      final selectedProject = projects.firstWhere(
        (p) => p.id == _selectedProjectId,
        orElse: () => projects.first,
      );
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildProjectDetailView(context, selectedProject),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _buildProjectsGridView(context, projects),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No projects yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showCreateProjectDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsGridView(
    BuildContext context,
    List<ProjectEntity> projects,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return _buildProjectCard(context, projects[index]);
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectEntity project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = _calculateProgress(project);
    final progressColor = _getProgressColor(context, progress);

    // Get assigned member names
    final assignedMembers = project.assignments
        .where((a) => a.userId != null && a.userId!.isNotEmpty)
        .toList();
    final totalMembers = project.assignments.length;
    final completedPhases = project.timeline
        .where((p) => p.status == 'completed')
        .length;
    final totalPhases = project.timeline.length;

    return GestureDetector(
      onTap: () => _selectProject(project.id),
      onLongPress: () => _showProjectOptions(context, project),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerLow,
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 2, 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (project.description != null &&
                            project.description!.isNotEmpty)
                          Text(
                            project.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: PopupMenuButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: Icon(
                        Icons.more_vert,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditProjectDialog(context, project);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, project);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Progress section
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: colorScheme.outline.withOpacity(0.12),
                      color: progressColor,
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),

            // Members section - show assigned names
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: colorScheme.primary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Members',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (assignedMembers.isEmpty)
                    Text(
                      'No members assigned',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                    )
                  else
                    Text(
                      _formatMemberNames(assignedMembers, totalMembers),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom row: Phases and Status
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Phases
                  Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 12,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$completedPhases/$totalPhases',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'phases',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        context,
                        project.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: _getStatusColor(context, project.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatStatus(project.status),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(context, project.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMemberNames(
    List<ProjectAssignment> assignedMembers,
    int totalMembers,
  ) {
    if (assignedMembers.isEmpty) return 'No members assigned';

    final names = assignedMembers
        .map((a) => a.userName ?? 'Unknown')
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isEmpty) return '${assignedMembers.length} of $totalMembers';

    if (names.length == 1) {
      return '${names[0]} (1 of $totalMembers)';
    } else if (names.length == 2) {
      return '${names[0]}, ${names[1]} (2 of $totalMembers)';
    } else if (names.length == 3) {
      return '${names[0]}, ${names[1]}, ${names[2]}';
    } else {
      return '${names[0]}, ${names[1]} +${names.length - 2} more';
    }
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.8)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDetailView(BuildContext context, ProjectEntity project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description card
          if (project.description != null && project.description!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Description',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

          // Progress Section
          _buildProgressSection(context, project),
          const SizedBox(height: 20),

          // Team Assignments
          ProjectAssignmentCard(
            assignments: project.assignments,
            projectId: project.id,
            onAssignMember: (assignmentId, role) {
              _showAssignMemberDialog(context, project, assignmentId, role);
            },
          ),
          const SizedBox(height: 20),

          // Timeline
          TimelineWidget(timeline: project.timeline),
          const SizedBox(height: 20),

          // Pinned Links
          PinnedLinksWidget(
            pinnedLinks: project.pinnedLinks,
            onAddLink: () => _showAddLinkDialog(context, project.id),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAssignMemberDialog(
    BuildContext context,
    ProjectEntity project,
    String assignmentId,
    String role,
  ) {
    final theme = Theme.of(context);

    // Get team members from TeamDetailsCubit
    final teamState = context.read<TeamDetailsCubit>().state;

    // FIX: Use status enum check instead of 'is TeamDetailsLoaded'
    final List<TeamMember> teamMembers =
        teamState.status == TeamDetailsStatus.loaded && teamState.team != null
        ? teamState.team!.members
        : [];

    if (teamMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No team members available to assign'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AssignMemberDialog(
        project: project,
        role: role,
        teamMembers: teamMembers,
        onAssigned: (teamMember) {
          final assignments = List<ProjectAssignment>.from(project.assignments);
          final assignmentIndex = assignments.indexWhere(
            (a) => a.id == assignmentId,
          );

          if (assignmentIndex != -1) {
            assignments[assignmentIndex] = assignments[assignmentIndex]
                .copyWith(
                  userId: teamMember.userId,
                  userName: teamMember.name,
                  userEmail: teamMember.email,
                );

            context.read<ProjectsCubit>().updateProject(
              projectId: project.id,
              name: project.name,
              description: project.description,
              assignments: assignments,
              timeline: project.timeline,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${teamMember.name ?? 'Member'} assigned to $role',
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          }
        },
      ),
    ).then((_) {
      _loadProjects();
    });
  }

  Widget _buildProgressSection(BuildContext context, ProjectEntity project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = _calculateProgress(project);
    final progressColor = _getProgressColor(context, progress);

    final assignedMembers = project.assignments
        .where((a) => a.userId != null && a.userId!.isNotEmpty)
        .toList();
    final totalMembers = project.assignments.length;
    final completedCount = project.timeline
        .where((p) => p.status == 'completed')
        .length;
    final inProgressCount = project.timeline
        .where((p) => p.status == 'in-progress')
        .length;
    final pendingCount = project.timeline
        .where((p) => p.status == 'planned')
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${assignedMembers.length}/$totalMembers assigned',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: colorScheme.outline.withOpacity(0.15),
                      color: progressColor,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  children: [
                    _buildProgressStat(
                      context,
                      'Completed',
                      '$completedCount',
                      colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    _buildProgressStat(
                      context,
                      'In Progress',
                      '$inProgressCount',
                      Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    _buildProgressStat(
                      context,
                      'Pending',
                      '$pendingCount',
                      colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  double _calculateProgress(ProjectEntity project) {
    if (project.timeline.isEmpty) return 0.0;
    final completedCount = project.timeline
        .where((phase) => phase.status == 'completed')
        .length;
    return completedCount / project.timeline.length;
  }

  Color _getProgressColor(BuildContext context, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    if (progress < 0.33) return colorScheme.error;
    if (progress < 0.66) return Colors.orange;
    return colorScheme.primary;
  }

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'active':
        return colorScheme.primary;
      case 'in-progress':
        return Colors.orange;
      case 'completed':
        return colorScheme.tertiary;
      case 'archived':
        return colorScheme.outline;
      default:
        return colorScheme.secondary;
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
