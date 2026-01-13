// lib/features/auth/presentation/widgets/name_field.dart
import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;

  const NameField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        errorText: errorText,
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}
