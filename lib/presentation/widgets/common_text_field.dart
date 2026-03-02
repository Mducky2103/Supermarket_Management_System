import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool isPassword;
  final bool? isVisible;
  final VoidCallback? onVisibilityPressed;
  final String? Function(String?)? validator;

  const CommonTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.isPassword = false,
    this.isVisible,
    this.onVisibilityPressed,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !(isVisible ?? false),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(isVisible == true ? Icons.visibility : Icons.visibility_off),
          onPressed: onVisibilityPressed,
        )
            : null,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}