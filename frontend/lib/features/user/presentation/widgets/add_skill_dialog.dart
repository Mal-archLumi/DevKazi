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
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Skill'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _skillController,
              decoration: const InputDecoration(
                labelText: 'Skill',
                border: OutlineInputBorder(),
                hintText: 'e.g., Flutter, Node.js, UI/UX Design',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a skill';
                }
                if (value.trim().length < 2) {
                  return 'Skill must be at least 2 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _addSkill, child: const Text('Add')),
      ],
    );
  }

  void _addSkill() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd(_skillController.text.trim());
      Navigator.of(context).pop();
    }
  }
}
