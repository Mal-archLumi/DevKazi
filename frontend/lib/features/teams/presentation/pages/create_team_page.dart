// presentation/pages/create_team_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/create_team/create_team_cubit.dart';
import '../blocs/create_team/create_team_state.dart';

class CreateTeamPage extends StatefulWidget {
  final VoidCallback? onTeamCreated;

  const CreateTeamPage({super.key, this.onTeamCreated});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (!_showSuccess) {
      context.read<CreateTeamCubit>().updateTeamName(_nameController.text);
    }
  }

  void _onDescriptionChanged(String description) {
    if (!_showSuccess) {
      context.read<CreateTeamCubit>().updateDescription(description);
    }
  }

  void _createTeam() {
    FocusScope.of(context).unfocus();
    context.read<CreateTeamCubit>().createTeam();
  }

  void _onSuccess() {
    setState(() {
      _showSuccess = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Team created successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Wait a bit then navigate back to teams tab
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // Call the callback to notify parent
        widget.onTeamCreated?.call();
      }
    });
  }

  void _resetForm() {
    setState(() {
      _showSuccess = false;
    });
    _nameController.clear();
    _descriptionController.clear();
    context.read<CreateTeamCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateTeamCubit, CreateTeamState>(
      listener: (context, state) {
        if (state.status == CreateTeamStatus.success && !_showSuccess) {
          _onSuccess();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Team'),
          leading: _showSuccess
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
          actions: _showSuccess
              ? null
              : [
                  BlocBuilder<CreateTeamCubit, CreateTeamState>(
                    builder: (context, state) {
                      return TextButton(
                        onPressed: state.isValid && !state.isLoading
                            ? _createTeam
                            : null,
                        child: state.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      );
                    },
                  ),
                ],
        ),
        body: _showSuccess ? _buildSuccessState() : _buildCreateForm(),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 24),
          Text(
            'Team Created!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your team "${_nameController.text}" has been created successfully.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.add),
                label: const Text('Create Another'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: widget.onTeamCreated,
                icon: const Icon(Icons.group),
                label: const Text('View Teams'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamNameField(),
          const SizedBox(height: 16),
          _buildDescriptionField(),
          const SizedBox(height: 24),
          _buildErrorSection(),
          const Spacer(),
          _buildCreateButton(),
        ],
      ),
    );
  }

  Widget _buildTeamNameField() {
    return BlocBuilder<CreateTeamCubit, CreateTeamState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Name *',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter team name (e.g., Frontend Developers)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: state.nameError,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              maxLength: 50,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 4),
            Text(
              '${_nameController.text.length}/50',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          onChanged: _onDescriptionChanged,
          decoration: InputDecoration(
            hintText: 'What is this team about? (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
        const SizedBox(height: 4),
        Text(
          '${_descriptionController.text.length}/500',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection() {
    return BlocBuilder<CreateTeamCubit, CreateTeamState>(
      builder: (context, state) {
        if (state.status == CreateTeamStatus.error) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.errorMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCreateButton() {
    return BlocBuilder<CreateTeamCubit, CreateTeamState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isValid && !state.isLoading ? _createTeam : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Create Team',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }
}
