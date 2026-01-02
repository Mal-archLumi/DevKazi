import 'package:flutter/material.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class PinnedLinksWidget extends StatelessWidget {
  final List<PinnedLink> pinnedLinks;
  final VoidCallback onAddLink;

  const PinnedLinksWidget({
    super.key,
    required this.pinnedLinks,
    required this.onAddLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.link_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Resources',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onAddLink,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (pinnedLinks.isEmpty)
          _buildEmptyState(context)
        else
          _buildLinksList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.link_off_rounded,
            size: 32,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No resources pinned',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add links to docs, designs, or repos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pinnedLinks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildLinkCard(pinnedLinks[index], context);
      },
    );
  }

  Widget _buildLinkCard(PinnedLink link, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => _launchUrl(context, link.url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForUrl(link.url),
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getDomainFromUrl(link.url),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForUrl(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('figma.com')) return Icons.brush_outlined;
    if (lowerUrl.contains('github.com')) return Icons.code_rounded;
    if (lowerUrl.contains('gitlab.com')) return Icons.code_rounded;
    if (lowerUrl.contains('bitbucket')) return Icons.code_rounded;
    if (lowerUrl.contains('docs.google')) return Icons.description_outlined;
    if (lowerUrl.contains('notion.so')) return Icons.menu_book_rounded;
    if (lowerUrl.contains('confluence')) return Icons.menu_book_rounded;
    if (lowerUrl.contains('jira')) return Icons.view_kanban_rounded;
    if (lowerUrl.contains('trello')) return Icons.view_kanban_rounded;
    if (lowerUrl.contains('asana')) return Icons.task_alt_rounded;
    if (lowerUrl.contains('slack')) return Icons.chat_rounded;
    if (lowerUrl.contains('discord')) return Icons.chat_rounded;
    if (lowerUrl.contains('drive.google')) return Icons.folder_outlined;
    if (lowerUrl.contains('dropbox')) return Icons.folder_outlined;
    if (lowerUrl.contains('youtube')) return Icons.play_circle_outline;
    if (lowerUrl.contains('vimeo')) return Icons.play_circle_outline;
    if (lowerUrl.contains('stackoverflow')) return Icons.help_outline;
    return Icons.link_rounded;
  }

  String _getDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return url;
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return url.length > 30 ? '${url.substring(0, 30)}...' : url;
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    // Ensure URL has a scheme
    String urlToLaunch = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      urlToLaunch = 'https://$url';
    }

    final uri = Uri.parse(urlToLaunch);

    try {
      final canLaunch = await url_launcher.canLaunchUrl(uri);
      if (canLaunch) {
        await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open: $url'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to open link'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
