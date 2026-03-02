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

  // Hàm giải mã JWT giả lập để lấy Role
  String _getRoleFromToken(String token) {
    try {
      // JWT giả lập của chúng ta là chuỗi Base64 của JSON Payload
      final String decoded = utf8.decode(base64Decode(token));
      final Map<String, dynamic> payload = jsonDecode(decoded);
      return payload['role'] ?? 'staff';
    } catch (e) {
      return 'staff'; // Mặc định nếu lỗi
    }
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    bool success = await _authService.login(_userController.text, _passController.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();

      // Lấy token để giải mã lấy Role (theo chuẩn JWT bạn đang làm)
      String? token = prefs.getString('jwt_token');

      if (token != null) {
        // Giải mã lấy role từ token
        final payload = jsonDecode(utf8.decode(base64Decode(token)));
        String role = payload['role'];

        print("DEBUG: Đăng nhập thành công với Role = $role");

        // Điều hướng
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/signup');
        }
      }
    } else {
      print("DEBUG: Đăng nhập thất bại");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Failed! Check username/password.')),
      );
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
              children: [
                const LoginHeader(), // Widget đã tách
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
                  onVisibilityPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (v) => v!.length < 3 ? "Too short" : null,
                ),
                const SizedBox(height: 24),

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
                    onPressed: _isLoading ? null : _onLogin,
                    child: _isLoading ? const CircularProgressIndicator() : const Text("LOGIN"),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text("Don't have an account? Sign Up"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}