import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import '../cubits/user_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_actions.dart';
import '../widgets/skills_section.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/add_skill_dialog.dart';
import 'package:frontend/core/themes/theme_manager.dart';
import 'package:frontend/core/constants/route_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isInitialLoad = true;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    // Use a small delay to ensure cubit is properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    if (mounted) {
      context.read<UserCubit>().loadCurrentUser();
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;

    // Prevent excessive refreshing
    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < const Duration(seconds: 2)) {
      return;
    }

    _lastRefreshTime = now;
    await context.read<UserCubit>().loadCurrentUser(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLoaded || state is UserError) {
          _isInitialLoad = false;
        }

        if (state is UserError && state.lastUser == null && !_isInitialLoad) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(label: 'Retry', onPressed: _loadUserData),
            ),
          );
        } else if (state is UserLogoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout warning: ${state.message}'),
              backgroundColor: Colors.orange,
            ),
          );
          _navigateToLogin();
        } else if (state is UserLoggedOut) {
          _navigateToLogin();
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: _showSettings,
                  ),
                ],
              ),
              _buildContent(state),
            ],
          ),
        );
      },
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteConstants.login,
          (route) => false,
        );
      }
    });
  }

  Widget _buildContent(UserState state) {
    // Show loading state for initial load
    if (_isInitialLoad && state is! UserLoaded) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your profile...'),
            ],
          ),
        ),
      );
    }

    if (state is UserLoading && _isInitialLoad) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your profile...'),
            ],
          ),
        ),
      );
    }

    if (state is UserLoaded) {
      return _buildProfileContent(context, state.user);
    }

    if (state is UserError && state.lastUser != null) {
      return _buildProfileContent(
        context,
        state.lastUser!,
        error: state.message,
      );
    }

    // Error state without cached data
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load profile',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (state is UserError) ...[
                const SizedBox(height: 12),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserEntity user, {
    String? error,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate([
        if (error != null) _buildErrorBanner(context, error),
        ProfileHeader(user: user),
        const SizedBox(height: 24),
        ProfileStats(user: user),
        const SizedBox(height: 24),
        ProfileActions(
          onEditProfile: () => _editProfile(context, user),
          onToggleTheme: _toggleTheme,
        ),
        const SizedBox(height: 24),
        SkillsSection(
          skills: user.skills,
          onAddSkill: () => _addSkill(context),
          onRemoveSkill: (skill) => _removeSkill(context, skill),
        ),
        const SizedBox(height: 32),
        _buildLogoutButton(context),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () => context.read<UserCubit>().clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.logout_outlined),
          label: const Text(
            'Log Out',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(
              color: Theme.of(context).colorScheme.error.withOpacity(0.3),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _showLogoutDialog(context),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          LogoutDialog(onConfirm: () => context.read<UserCubit>().logout()),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings page coming soon!')));
  }

  void _editProfile(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        user: user,
        onSave: (name, bio, education) {
          if (mounted) {
            context.read<UserCubit>().updateProfile(
              name: name,
              bio: bio,
              education: education,
            );
          }
        },
      ),
    );
  }

  void _addSkill(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddSkillDialog(
        onAdd: (skill) {
          if (mounted) {
            context.read<UserCubit>().addSkills([skill]);
          }
        },
      ),
    );
  }

  void _removeSkill(BuildContext context, String skill) {
    if (mounted) {
      context.read<UserCubit>().removeSkill(skill);
    }
  }

  void _toggleTheme() {
    final themeManager = ThemeManager();
    themeManager.toggleTheme();
  }

  @override
  void dispose() {
    _isInitialLoad = true;
    super.dispose();
  }
}
