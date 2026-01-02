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
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _assignmentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 600,
        ),
        child: Scaffold(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Selection
                  DropdownButtonFormField<String>(
                    initialValue: assignment.role,
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
                      DropdownMenuItem(
                        value: 'ui',
                        child: Text('UI/UX Designer'),
                      ),
                      DropdownMenuItem(
                        value: 'fullstack',
                        child: Text('Full Stack Developer'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _assignments[index] = assignment.copyWith(
                          role: value!,
                          assignedTo: assignment.assignedTo,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Assigned To (Team Member Name)
                  TextFormField(
                    controller: _assignmentControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Assigned To',
                      hintText: 'Enter team member name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      _assignments[index] = assignment.copyWith(
                        assignedTo: value,
                      );
                    },
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
                    onChanged: (value) {
                      _assignments[index] = assignment.copyWith(
                        tasks: value,
                        assignedTo: assignment.assignedTo,
                      );
                    },
                  ),

                  // Show assigned user info if any (from database)
                  if (assignment.userName != null &&
                      assignment.userName!.isNotEmpty)
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
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
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
                          initialValue: phase.phase,
                          decoration: const InputDecoration(
                            labelText: 'Phase Name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            _timeline[index] = phase.copyWith(phase: value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeTimelinePhase(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    initialValue: phase.description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      _timeline[index] = phase.copyWith(description: value);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date pickers in vertical layout for mobile
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Start Date
                      InkWell(
                        onTap: () => _selectStartDate(index),
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
                                    _formatDate(phase.startDate),
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
                        onTap: () => _selectEndDate(index),
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
                                    _formatDate(phase.endDate),
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
                    initialValue: phase.status,
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
                      DropdownMenuItem(
                        value: 'planned',
                        child: Text('Planned'),
                      ),
                      DropdownMenuItem(
                        value: 'in-progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _timeline[index] = phase.copyWith(status: value!);
                      });
                    },
                  ),
                ],
              ),
            ),
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

    if (selectedDate != null) {
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

    if (selectedDate != null) {
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
      // Get the Cubit from the parent context (outside the dialog)
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

      if (mounted) {
        Navigator.pop(context);
        // Show success message in the parent screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update project: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Don't close the dialog on error so user can fix issues
        setState(() => _isSaving = false);
      }
    }
  }
}
