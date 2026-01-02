// lib/features/teams/presentation/widgets/team_tab_navigation.dart
import 'package:flutter/material.dart';

class TeamTabNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final bool showRequestsTab;
  final int pendingRequestsCount;

  const TeamTabNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    this.showRequestsTab = false,
    this.pendingRequestsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabItem(icon: Icons.chat_outlined, label: 'Chats'),
      _TabItem(icon: Icons.folder_outlined, label: 'Projects'),
      _TabItem(icon: Icons.people_outlined, label: 'Members'),
      if (showRequestsTab)
        _TabItem(
          icon: Icons.person_add_outlined,
          label: 'Requests',
          badge: pendingRequestsCount,
        ),
    ];

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = currentIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onTabChanged(index),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          tab.icon,
                          size: 22,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        // Badge for pending requests
                        if (tab.badge > 0)
                          Positioned(
                            right: -8,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                tab.badge > 9 ? '9+' : '${tab.badge}',
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
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final int badge;

  _TabItem({required this.icon, required this.label, this.badge = 0});
}
