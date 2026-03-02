import 'package:flutter/material.dart';
import '../../../../data/service/auth_service.dart';
import '../../../widgets/common_text_field.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String email;

  const VerifyOTPScreen({super.key, required this.email});

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();
  final _authService = AuthService();

  bool _isPasswordVisible = false;

  void _onConfirm() async {
    if (_otpController.text.isEmpty || _newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đầy đủ OTP và mật khẩu mới"))
      );
      return;
    }

    if (_authService.verifyOTP(_otpController.text)) {
      bool success = await _authService.resetPassword(_newPassController.text);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đổi mật khẩu thành công!"))
        );
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mã OTP không chính xác!"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực OTP")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.mark_email_read, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                "Mã OTP đã được gửi đến:\n${widget.email}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              CommonTextField(
                controller: _otpController,
                label: "Nhập mã OTP 6 số",
                prefixIcon: Icons.lock_clock,
              ),
              const SizedBox(height: 16),

              CommonTextField(
                controller: _newPassController,
                label: "Mật khẩu mới",
                prefixIcon: Icons.vpn_key,
                isPassword: true,
                isVisible: _isPasswordVisible,
                onVisibilityPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    onPressed: _onConfirm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("XÁC NHẬN ĐỔI MẬT KHẨU")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}