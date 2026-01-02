import 'package:flutter/material.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/teams/domain/entities/team_entity.dart';

class AssignMemberDialog extends StatefulWidget {
  final ProjectEntity project;
  final String role;
  final List<TeamMember> teamMembers; // Pass team members from parent
  final Function(TeamMember) onAssigned;

  const AssignMemberDialog({
    super.key,
    required this.project,
    required this.role,
    required this.teamMembers,
    required this.onAssigned,
  });

  @override
  State<AssignMemberDialog> createState() => _AssignMemberDialogState();
}

class _AssignMemberDialogState extends State<AssignMemberDialog> {
  TeamMember? _selectedMember;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assign Team Member',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Assign a team member to "${widget.role}" role',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Team members list
            _buildTeamMembersList(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedMember != null ? _assignMember : null,
                  child: const Text('Assign'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMembersList() {
    if (widget.teamMembers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No team members available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          children: widget.teamMembers.map((member) {
            final isSelected = _selectedMember?.userId == member.userId;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    member.avatar != null && member.avatar!.isNotEmpty
                    ? NetworkImage(member.avatar!)
                    : null,
                child: member.avatar == null || member.avatar!.isEmpty
                    ? Text(
                        (member.name ?? member.email ?? '?')[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(member.name ?? 'Unknown'),
              subtitle: Text(member.email ?? ''),
              trailing: Radio<String>(
                value: member.userId,
                groupValue: _selectedMember?.userId,
                onChanged: (value) {
                  setState(() {
                    _selectedMember = member;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _selectedMember = member;
                });
              },
              selected: isSelected,
              selectedTileColor: Theme.of(
                context,
              ).primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _assignMember() {
    if (_selectedMember != null) {
      widget.onAssigned(_selectedMember!);
      Navigator.pop(context);
    }
  }
}
