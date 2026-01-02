import 'package:flutter/material.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';

class TimelineWidget extends StatelessWidget {
  final List<TimelinePhase> timeline;

  const TimelineWidget({super.key, required this.timeline});

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.route_outlined,
                  size: 20,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Project Roadmap',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (timeline.isEmpty)
          _buildEmptyState(context)
        else
          ...timeline.asMap().entries.map((entry) {
            return _buildTimelineItem(
              entry.value,
              entry.key == timeline.length - 1,
              context,
              entry.key,
            );
          }),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.map_outlined,
            size: 42,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No Roadmap Defined',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add phases to track your project\'s journey.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    TimelinePhase phase,
    bool isLast,
    BuildContext context,
    int index,
  ) {
    final isCompleted = phase.status == 'completed';
    final isInProgress = phase.status == 'in-progress';
    final statusColor = _getStatusColor(phase.status, context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline connector
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted || isInProgress
                          ? statusColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 2),
                      boxShadow: isInProgress
                          ? [
                              BoxShadow(
                                color: statusColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : isCompleted
                          ? [
                              BoxShadow(
                                color: statusColor.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : isInProgress
                        ? Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isCompleted
                                ? [statusColor, statusColor.withOpacity(0.5)]
                                : [
                                    Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.3),
                                    Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.1),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Phase content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isInProgress
                      ? statusColor.withOpacity(isDark ? 0.12 : 0.06)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isInProgress
                        ? statusColor.withOpacity(0.4)
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.15),
                    width: isInProgress ? 1.2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phase header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              phase.phase,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isInProgress || isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isInProgress
                                    ? statusColor
                                    : statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: isInProgress
                                    ? [
                                        BoxShadow(
                                          color: statusColor.withOpacity(0.4),
                                          blurRadius: 6,
                                          spreadRadius: 0,
                                        ),
                                      ]
                                    : null,
                                border: isCompleted
                                    ? Border.all(
                                        color: statusColor.withOpacity(0.3),
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isInProgress
                                        ? Icons.play_circle_filled
                                        : Icons.check_circle,
                                    size: 10,
                                    color: isInProgress
                                        ? Colors.white
                                        : statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isInProgress ? 'ACTIVE' : 'DONE',
                                    style: TextStyle(
                                      color: isInProgress
                                          ? Colors.white
                                          : statusColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Phase description
                      if (phase.description.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phase.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),

                      // Dates
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${_formatDate(phase.startDate)} — ${_formatDate(phase.endDate)}',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'completed':
        return Colors.green.shade500;
      case 'in-progress':
        return Colors.orange.shade500;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
