import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/service/auth_service.dart';
import '../../widgets/common_text_field.dart';
import '../../widgets/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Map<String, dynamic>? _getDecodedToken(String token) {
    try {
      final String decoded = utf8.decode(base64Decode(token));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error decoding token: $e");
      return null;
    }
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success = await _authService.login(_userController.text, _passController.text);

    setState(() => _isLoading = false);

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token != null) {
        final payload = _getDecodedToken(token);

        if (payload != null) {
          int userId = payload['user_id'] ?? 0;
          String role = payload['role'] ?? 'staff';
          String username = payload['username'] ?? '';

          await prefs.setInt('user_id', userId);
          await prefs.setString('user_role', role);
          await prefs.setString('user_name', username);

          debugPrint("DEBUG: Login Success | ID: $userId | Role: $role");

          // if (role == 'admin') {
          //   Navigator.pushReplacementNamed(context, '/admin_dashboard');
          // } else if (role == 'staff') {
          //   Navigator.pushReplacementNamed(context, '/warehouse_staff');
          // } else if (role == 'manager') {
          //   Navigator.pushReplacementNamed(context, '/manager_inventory');
          // } else if (role == 'cashier') {
          //   Navigator.pushReplacementNamed(context, '/cashier_dashboard'); // cashier
          // } else {
          //   Navigator.pushReplacementNamed(context, '/'); // customer
          // }
          final routes = {
            'admin': '/admin_dashboard',
            'warehouse_staff': '/warehouse_staff',
            'manager': '/manager_inventory',
            'cashier': '/cashier_dashboard',
          };

          final String destination = routes[role] ?? '/';
          Navigator.pushReplacementNamed(context, destination);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Failed! Invalid username or password.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoginHeader(),
                const SizedBox(height: 32),

                CommonTextField(
                  controller: _userController,
                  label: "Username",
                  prefixIcon: Icons.person,
                  validator: (v) => v!.isEmpty ? "Enter username" : null,
                ),
                const SizedBox(height: 16),

                CommonTextField(
                  controller: _passController,
                  label: "Password",
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onVisibilityPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (v) => v!.length < 3 ? "Too short" : null,
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _onLogin,
                    child: _isLoading
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text("Sign Up"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}