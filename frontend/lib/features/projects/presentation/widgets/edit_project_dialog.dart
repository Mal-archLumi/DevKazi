import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/projects/domain/entities/project_entity.dart';
import 'package:frontend/features/projects/presentation/cubits/projects_cubit.dart';

class EditProjectDialog extends StatefulWidget {
  final ProjectEntity project;

  const EditProjectDialog({super.key, required this.project});

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _assignmentControllers;
  late List<ProjectAssignment> _assignments;
  late List<TimelinePhase> _timeline;
  bool _isSaving = false;
  bool _isDialogOpen = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController = TextEditingController(
      text: widget.project.description ?? '',
    );
    _assignments = List.from(widget.project.assignments);
    _assignmentControllers = _assignments
        .map((a) => TextEditingController(text: a.assignedTo ?? ''))
        .toList();
    _timeline = List.from(widget.project.timeline);
  }

  @override
  void dispose() {
    _isDialogOpen = false;
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _assignmentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          _isDialogOpen = false;
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: 600,
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('Edit Project'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Project Name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a project name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // Assignments Section
                          _buildAssignmentsSection(),
                          const SizedBox(height: 24),

                          // Timeline Section
                          _buildTimelineSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Assignments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Define roles, tasks, and assign team members',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),

        ..._assignments.asMap().entries.map((entry) {
          final index = entry.key;
          final assignment = entry.value;

          return _EditAssignmentCard(
            key: ValueKey('assignment_${assignment.id ?? index}'),
            assignment: assignment,
            controller: _assignmentControllers[index],
            onRoleChanged: (value) {
              if (!_isDialogOpen) return;
              setState(() {
                _assignments[index] = assignment.copyWith(
                  role: value!,
                  assignedTo: assignment.assignedTo,
                );
              });
            },
            onAssignedToChanged: (value) {
              if (!_isDialogOpen) return;
              _assignments[index] = assignment.copyWith(assignedTo: value);
            },
            onTasksChanged: (value) {
              if (!_isDialogOpen) return;
              _assignments[index] = assignment.copyWith(
                tasks: value,
                assignedTo: assignment.assignedTo,
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Project Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addTimelinePhase,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Phase'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ..._timeline.asMap().entries.map((entry) {
          final index = entry.key;
          final phase = entry.value;

          return _EditTimelinePhaseCard(
            key: ValueKey('timeline_${phase.id}'),
            phase: phase,
            onPhaseChanged: (value) {
              if (!_isDialogOpen) return;
              _timeline[index] = phase.copyWith(phase: value);
            },
            onDescriptionChanged: (value) {
              if (!_isDialogOpen) return;
              _timeline[index] = phase.copyWith(description: value);
            },
            onStartDateSelected: () => _selectStartDate(index),
            onEndDateSelected: () => _selectEndDate(index),
            onStatusChanged: (value) {
              if (!_isDialogOpen) return;
              setState(() {
                _timeline[index] = phase.copyWith(status: value!);
              });
            },
            onDelete: () => _removeTimelinePhase(index),
          );
        }),
      ],
    );
  }

  void _addTimelinePhase() {
    setState(() {
      final nextWeek = DateTime.now().add(const Duration(days: 7));
      _timeline.add(
        TimelinePhase(
          id: UniqueKey().toString(),
          phase: 'New Phase',
          description: '',
          startDate: DateTime.now(),
          endDate: nextWeek,
          status: 'planned',
        ),
      );
    });
  }

  void _removeTimelinePhase(int index) {
    setState(() {
      _timeline.removeAt(index);
    });
  }

  Future<void> _selectStartDate(int index) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _timeline[index].startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null && _isDialogOpen) {
      setState(() {
        _timeline[index] = _timeline[index].copyWith(startDate: selectedDate);
      });
    }
  }

  Future<void> _selectEndDate(int index) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _timeline[index].endDate,
      firstDate: _timeline[index].startDate,
      lastDate: DateTime(2030),
    );

    if (selectedDate != null && _isDialogOpen) {
      setState(() {
        _timeline[index] = _timeline[index].copyWith(endDate: selectedDate);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final projectsCubit = BlocProvider.of<ProjectsCubit>(
        context,
        listen: false,
      );

      await projectsCubit.updateProject(
        projectId: widget.project.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        assignments: _assignments,
        timeline: _timeline,
      );

      if (mounted && _isDialogOpen) {
        _isDialogOpen = false;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted && _isDialogOpen) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update project: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }
}

class _EditAssignmentCard extends StatelessWidget {
  final ProjectAssignment assignment;
  final TextEditingController controller;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String> onAssignedToChanged;
  final ValueChanged<String> onTasksChanged;

  const _EditAssignmentCard({
    required this.assignment,
    required this.controller,
    required this.onRoleChanged,
    required this.onAssignedToChanged,
    required this.onTasksChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role Selection
            DropdownButtonFormField<String>(
              value: assignment.role,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'frontend',
                  child: Text('Frontend Developer'),
                ),
                DropdownMenuItem(
                  value: 'backend',
                  child: Text('Backend Developer'),
                ),
                DropdownMenuItem(value: 'ui', child: Text('UI/UX Designer')),
                DropdownMenuItem(
                  value: 'fullstack',
                  child: Text('Full Stack Developer'),
                ),
              ],
              onChanged: onRoleChanged,
            ),
            const SizedBox(height: 12),

            // Assigned To (Team Member Name)
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Assigned To',
                hintText: 'Enter team member name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: onAssignedToChanged,
            ),
            const SizedBox(height: 12),

            // Tasks
            TextFormField(
              initialValue: assignment.tasks,
              decoration: const InputDecoration(
                labelText: 'Tasks',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: onTasksChanged,
            ),

            // Show assigned user info if any (from database)
            if (assignment.userName != null && assignment.userName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Database Assigned: ${assignment.userName ?? 'Team Member'}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (assignment.userEmail != null &&
                                assignment.userEmail!.isNotEmpty)
                              Text(
                                assignment.userEmail!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditTimelinePhaseCard extends StatefulWidget {
  final TimelinePhase phase;
  final ValueChanged<String> onPhaseChanged;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onStartDateSelected;
  final VoidCallback onEndDateSelected;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onDelete;

  const _EditTimelinePhaseCard({
    required this.phase,
    required this.onPhaseChanged,
    required this.onDescriptionChanged,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    required this.onStatusChanged,
    required this.onDelete,
    super.key,
  });

  @override
  State<_EditTimelinePhaseCard> createState() => __EditTimelinePhaseCardState();
}

class __EditTimelinePhaseCardState extends State<_EditTimelinePhaseCard> {
  late TextEditingController _phaseController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _phaseController = TextEditingController(text: widget.phase.phase);
    _descriptionController = TextEditingController(
      text: widget.phase.description,
    );
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phaseController,
                    decoration: const InputDecoration(
                      labelText: 'Phase Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: widget.onPhaseChanged,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 2,
              onChanged: widget.onDescriptionChanged,
            ),
            const SizedBox(height: 12),

            // Date pickers in vertical layout for mobile
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Start Date
                InkWell(
                  onTap: widget.onStartDateSelected,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(widget.phase.startDate),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // End Date
                InkWell(
                  onTap: widget.onEndDateSelected,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(widget.phase.endDate),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Status selection for timeline phases
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: widget.phase.status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'planned', child: Text('Planned')),
                DropdownMenuItem(
                  value: 'in-progress',
                  child: Text('In Progress'),
                ),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: widget.onStatusChanged,
            ),
          ],
        ),
      ),
    );
  }
}
