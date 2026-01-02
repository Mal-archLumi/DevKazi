// features/user/presentation/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import '../cubits/user_profile_cubit.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final bool isFromJoinRequest;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.isFromJoinRequest = false,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileCubit>().loadUserProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: widget.isFromJoinRequest
            ? [
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    // Navigate to chat with this user
                    _startChat(context);
                  },
                ),
              ]
            : null,
      ),
      body: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          if (state.status == UserProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UserProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? 'Failed to load profile',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<UserProfileCubit>()
                        .loadUserProfile(widget.userId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = state.user;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                // Bio
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  _buildSection('About', user.bio!),
                  const SizedBox(height: 20),
                ],
                // Education
                if (user.education != null && user.education!.isNotEmpty) ...[
                  _buildSection('Education', user.education!),
                  const SizedBox(height: 20),
                ],
                // Skills
                if (user.skills.isNotEmpty) ...[
                  _buildSkillsSection(user.skills),
                  const SizedBox(height: 20),
                ],
                // Contact Info
                _buildContactSection(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactSection(UserEntity user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.email,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Email'),
          subtitle: Text(user.email),
        ),
        // Add more contact info as needed
      ],
    );
  }

  void _startChat(BuildContext context) {
    // Implement chat navigation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Starting chat...')));
  }
}
