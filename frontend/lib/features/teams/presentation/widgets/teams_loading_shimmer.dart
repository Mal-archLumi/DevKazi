import 'package:flutter/material.dart';

class TeamsLoadingShimmer extends StatelessWidget {
  const TeamsLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.grey),
              title: Container(width: 100, height: 16, color: Colors.grey),
              subtitle: Container(width: 150, height: 14, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
