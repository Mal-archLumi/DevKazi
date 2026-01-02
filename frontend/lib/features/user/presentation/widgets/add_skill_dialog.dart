import 'package:flutter/material.dart';

class AddSkillDialog extends StatefulWidget {
  final Function(String skill) onAdd;

  const AddSkillDialog({super.key, required this.onAdd});

  @override
  State<AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<AddSkillDialog> {
  final _skillController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Add New Skill',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _skillController,
                decoration: InputDecoration(
                  labelText: 'Skill Name',
                  hintText: 'e.g., Flutter, Figma',
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
                    ),
                  ),
                ),
                validator: (value) =>
                    value!.trim().length < 2 ? 'Too short' : null,
                textCapitalization: TextCapitalization.words,
              ),
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
                FilledButton.icon(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Skill'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addSkill() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(_skillController.text.trim());
      Navigator.pop(context);
    }
  }
}
