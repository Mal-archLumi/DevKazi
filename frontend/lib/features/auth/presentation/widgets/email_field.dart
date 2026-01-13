// lib/features/auth/presentation/widgets/email_field.dart
import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;

  const EmailField({
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
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        filled: true,
        errorText: errorText,
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}
