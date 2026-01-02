import 'package:flutter/material.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';

class EditProfileDialog extends StatefulWidget {
  final UserEntity user;
  final Function(String name, String bio, String education) onSave;

  const EditProfileDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _educationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _educationController = TextEditingController(
      text: widget.user.education ?? '',
    );
  }

  InputDecoration _modernInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: _modernInput('Full Name', Icons.person_outline),
                  validator: (v) => v!.trim().isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  decoration: _modernInput('Bio', Icons.info_outline),
                  maxLines: 3,
                  maxLength: 200,
                ),
                TextFormField(
                  controller: _educationController,
                  decoration: _modernInput('Education', Icons.school_outlined),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _saveProfile,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        _bioController.text.trim(),
        _educationController.text.trim(),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    super.dispose();
  }
}
