// presentation/widgets/teams_search_bar.dart
import 'package:flutter/material.dart';

class TeamsSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClosed;

  const TeamsSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onSearchClosed,
  });

  @override
  State<TeamsSearchBar> createState() => _TeamsSearchBarState();
}

class _TeamsSearchBarState extends State<TeamsSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _isSearching => _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onSearchChanged(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    widget.onSearchClosed();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search teams...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              onSubmitted: (value) {
                // Handle search submission if needed
              },
            ),
          ),
          if (_isSearching)
            IconButton(
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: _clearSearch,
            ),
        ],
      ),
    );
  }
}
