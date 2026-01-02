import 'package:flutter/material.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';

class ProjectAssignmentCard extends StatelessWidget {
  final List<ProjectAssignment> assignments;

  const ProjectAssignmentCard({
    super.key,
    required this.assignments,
    required Null Function(dynamic assignmentId, dynamic role) onAssignMember,
    required String projectId,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.badge_outlined, size: 24, color: primaryColor),
              const SizedBox(width: 12),
              Text(
                'Team Assignments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            final cardHeight = cardWidth * 0.85;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: assignments.map((assignment) {
                return SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _buildAssignmentCard(assignment, context),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(
    ProjectAssignment assignment,
    BuildContext context,
  ) {
    final roleColors = {
      'frontend': Colors.blue,
      'backend': Colors.green,
      'ui': Colors.purple,
      'fullstack': Colors.orange,
    };
    final color = roleColors[assignment.role] ?? Colors.grey;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // FIX: Check assignedTo instead of userName
    final hasAssigned =
        assignment.assignedTo != null && assignment.assignedTo!.isNotEmpty;
    final assignedName = hasAssigned ? assignment.assignedTo! : 'Unassigned';
    // Also check if there's a database user assigned
    final hasDatabaseUser =
        assignment.userName != null && assignment.userName!.isNotEmpty;
    final databaseUserName = hasDatabaseUser
        ? ' (${assignment.userName!})'
        : '';

    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(isDark ? 0.3 : 0.1),
          width: 1,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _getRoleDisplayName(assignment.role).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Assigned Person Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: hasAssigned
                          ? color.withOpacity(0.2)
                          : Theme.of(context).disabledColor.withOpacity(0.2),
                      child: Icon(
                        hasAssigned ? Icons.person : Icons.person_outline,
                        size: 16,
                        color: hasAssigned
                            ? color
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignedName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: hasAssigned
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).disabledColor,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (hasDatabaseUser && hasAssigned)
                            Text(
                              databaseUserName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.green, fontSize: 10),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Show if there's only a database user but no assigned name
                if (hasDatabaseUser && !hasAssigned)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'DB: ${assignment.userName!}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            if (assignment.tasks.isNotEmpty)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          assignment.tasks,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                                fontSize: 11,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  'No tasks yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'frontend':
        return 'Frontend';
      case 'backend':
        return 'Backend';
      case 'ui':
        return 'Design';
      case 'fullstack':
        return 'Full Stack';
      default:
        return role;
    }
  }
}
