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
  final _scrollController = ScrollController();
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
    _scrollController.dispose();
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
    // Optional delay before callback to let the user see the success animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BlocListener<CreateTeamCubit, CreateTeamState>(
      listener: (context, state) {
        if (state.status == CreateTeamStatus.success && !_showSuccess) {
          _onSuccess();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // 1. Background Decor
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // 2. Main Content
              _showSuccess ? _buildSuccessView() : _buildFormView(),

              // 3. Custom App Bar Overlay
              if (!_showSuccess)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).viewPadding.top + 60,
        24,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Hero(
            tag: 'create_team_header',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.groups_3_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Assemble Your Squad',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a space for your team to collaborate, track projects, and share ideas.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Form Fields
          _buildModernTextField(
            controller: _nameController,
            label: 'Team Name',
            hint: 'e.g. The Code Benders',
            icon: Icons.badge_outlined,
            maxLength: 50,
          ),

          const SizedBox(height: 24),

          _buildModernTextField(
            controller: _descriptionController,
            label: 'Mission Statement',
            hint: 'What will this team working on?',
            icon: Icons.rocket_launch_outlined,
            maxLength: 500,
            maxLines: 4,
            onChanged: _onDescriptionChanged,
          ),

          const SizedBox(height: 32),

          // Error Display
          BlocBuilder<CreateTeamCubit, CreateTeamState>(
            builder: (context, state) {
              if (state.status == CreateTeamStatus.error) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.errorContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.errorMessage,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 32),

          // Action Button
          BlocBuilder<CreateTeamCubit, CreateTeamState>(
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: state.isValid && !state.isLoading
                      ? _createTeam
                      : null,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Create Team',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 40), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int? maxLength,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 12,
                  top: 12,
                  bottom: 12,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              // Align icon to top for multi-line inputs
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),

              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              counterText: "", // Hide default counter, or style it if preferred
            ),
          ),
        ),
        if (maxLength != null) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                return Text(
                  '${value.text.length}/$maxLength',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 48,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Squad Assembled!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Team "${_nameController.text}" is ready for action.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            // Success Actions
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Create Another Team'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onTeamCreated,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Go to My Teams'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
