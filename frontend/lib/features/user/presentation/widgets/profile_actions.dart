import 'package:flutter/material.dart';

class ProfileActions extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onToggleTheme;

  const ProfileActions({
    super.key,
    required this.onEditProfile,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onEditProfile,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Edit Profile'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: IconButton(
              onPressed: onToggleTheme,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              tooltip: 'Toggle Theme',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
