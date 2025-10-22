import 'package:flutter/material.dart';

class TeamCard extends StatelessWidget {
  final String teamName;
  final String teamInitial;
  final String? logoPath;
  final VoidCallback onTap;

  const TeamCard({
    super.key,
    required this.teamName,
    required this.teamInitial,
    this.logoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: logoPath != null
            ? CircleAvatar(backgroundImage: AssetImage(logoPath!), radius: 20)
            : CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  teamInitial,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        title: Text(
          teamName,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
