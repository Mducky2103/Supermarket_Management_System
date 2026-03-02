import 'package:flutter/material.dart';
import 'package:sms_project/presentation/screens/authentication/password/verify_otp_screen.dart';
import '../../../../data/service/auth_service.dart';
import '../../../widgets/common_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _submitEmail() async {
    setState(() => _isLoading = true);
    String? error = await _authService.sendOTP(_emailController.text.trim());
    setState(() => _isLoading = false);

    if (error == null) {
      // Sang màn hình nhập OTP nếu gửi thành công
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => VerifyOTPScreen(email: _emailController.text)
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Enter email to get OTP code"),
            const SizedBox(height: 20),
            CommonTextField(
              controller: _emailController,
              label: "Email",
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitEmail,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Send OTP code"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}