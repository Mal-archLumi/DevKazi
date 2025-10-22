import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearchIcon;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showSearchIcon = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/images/logos/devkazi.png', height: 32, width: 32),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      actions: [
        if (showSearchIcon)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ...?actions,
      ],
    );
  }
}
