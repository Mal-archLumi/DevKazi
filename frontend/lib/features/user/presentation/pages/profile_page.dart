import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import '../cubits/user_cubit.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    if (mounted) context.read<UserCubit>().loadCurrentUser();
  }

  Future<void> _onRefresh() async {
    await context.read<UserCubit>().loadCurrentUser(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserLoaded || state is UserError) _isInitialLoad = false;
        if (state is UserLoggedOut) _navigateToLogin();
      },
      builder: (context, state) {
        if (_isInitialLoad && state is UserLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }

        if (state is UserError && state.lastUser == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadUserData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = (state is UserLoaded)
            ? state.user
            : (state is UserError)
            ? state.lastUser!
            : null;

        if (user == null) return const SizedBox();

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context, user),
                  _buildContent(context, user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              // Top bar with settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleTheme,
                        icon: Icon(
                          theme.brightness == Brightness.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: colorScheme.onSurface,
                        ),
                        tooltip: 'Toggle theme',
                      ),
                      IconButton(
                        onPressed: () => _showSettingsMenu(context),
                        icon: Icon(
                          Icons.more_vert,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage:
                      user.picture != null && user.picture!.isNotEmpty
                      ? NetworkImage(user.picture!)
                      : null,
                  child: user.picture == null || user.picture!.isEmpty
                      ? Text(
                          _getInitials(user.name),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                user.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              // Bio
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  user.bio!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 20),

              // Edit profile button
              OutlinedButton.icon(
                onPressed: () => _editProfile(context, user),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserEntity user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          _buildStatsRow(context, user),

          const SizedBox(height: 28),

          // Skills section
          _buildSkillsSection(context, user),

          const SizedBox(height: 28),

          // Info section
          _buildInfoSection(context, user),

          const SizedBox(height: 28),

          // Account section
          _buildAccountSection(context),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserEntity user) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.folder_outlined,
            label: 'Projects',
            value: '${user.projectCount ?? 0}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.group_outlined,
            label: 'Teams',
            value: '${user.teamCount ?? 0}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.code_outlined,
            label: 'Skills',
            value: '${user.skills.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, UserEntity user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Skills',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addSkill(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (user.skills.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 32,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'No skills added yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills.map((skill) {
              return Chip(
                label: Text(skill),
                deleteIcon: Icon(
                  Icons.close,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                onDeleted: () => _removeSkill(context, skill),
                backgroundColor: colorScheme.surfaceContainerLow,
                side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, UserEntity user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildInfoTile(
                context,
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
              _buildInfoTile(
                context,
                icon: Icons.school_outlined,
                label: 'Education',
                value: user.education ?? 'Not specified',
              ),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
              _buildInfoTile(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Member since',
                value: _formatDate(user.createdAt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildActionTile(
                context,
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => _showChangePassword(context),
              ),
              Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
              _buildActionTile(
                context,
                icon: Icons.logout,
                label: 'Sign Out',
                onTap: () => _showLogoutDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color.withOpacity(0.7)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to notifications settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to privacy settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to help
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password coming soon')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          LogoutDialog(onConfirm: () => context.read<UserCubit>().logout()),
    );
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
}
