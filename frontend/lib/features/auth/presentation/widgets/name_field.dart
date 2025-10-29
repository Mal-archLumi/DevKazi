// lib/features/auth/presentation/widgets/name_field.dart
import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const NameField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        filled: true,
        fillColor: Colors.white,

        // Completely remove borders
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: Colors.grey.shade600,
          size: 20,
        ),
      ),
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
