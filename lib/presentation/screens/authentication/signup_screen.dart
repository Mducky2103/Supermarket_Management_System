// lib/presentation/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/user_repository.dart';
import '../../widgets/login_header.dart';
import '../../widgets/signup_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;
  final _userRepo = UserRepository();

  void _handleSignUp(String user, String pass, String name, String email) async {
    setState(() => _isLoading = true);

    try {
      final existingUser = await _userRepo.getUserByUsername(user);
      final existingEmail = await _userRepo.getUserByEmail(email);

      if (existingUser != null) {
        throw ("Username has been used");
      }
      if (existingEmail != null) {
        throw ("Email has been used");
      }

      await _userRepo.createUser({
        'username': user,
        'password': pass,
        'full_name': name,
        'email': email,
        'role': 'staff',
        'is_active': 1,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please login.')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username already exists!')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const LoginHeader(),
            const SizedBox(height: 32),
            SignUpForm(onSignUp: _handleSignUp, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}