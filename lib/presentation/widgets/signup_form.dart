// lib/presentation/widgets/signup_form.dart
import 'package:flutter/material.dart';
import 'common_text_field.dart';

class SignUpForm extends StatefulWidget {
  final Function(String user, String pass, String fullName, String email) onSignUp;
  final bool isLoading;

  const SignUpForm({super.key, required this.onSignUp, required this.isLoading});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CommonTextField(
            controller: _nameController,
            label: "Full Name",
            prefixIcon: Icons.badge,
            validator: (v) => v!.isEmpty ? "Enter your name" : null,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _emailController,
            label: "Email",
            prefixIcon: Icons.email,
            validator: (v) {
              if (v!.isEmpty) return "Vui lòng nhập email";
              if (!v.contains('@')) return "Email không hợp lệ";
              return null;
            },
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _userController,
            label: "Username",
            prefixIcon: Icons.person_add,
            validator: (v) => v!.isEmpty ? "Enter username" : null,
          ),
          const SizedBox(height: 16),
          CommonTextField(
            controller: _passController,
            label: "Password",
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            isVisible: _isPasswordVisible,
            onVisibilityPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            validator: (v) => v!.length < 6 ? "Password must be >= 6 chars" : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : () {
                if (_formKey.currentState!.validate()) {
                  widget.onSignUp(_userController.text, _passController.text, _nameController.text, _emailController.text);
                }
              },
              child: widget.isLoading ? const CircularProgressIndicator() : const Text("CREATE ACCOUNT"),
            ),
          ),
        ],
      ),
    );
  }
}