import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/user_repository.dart';

import 'dart:convert';


class AuthService {
  final UserRepository _userRepo = UserRepository();

  Future<bool> login(String username, String password) async {
    final user = await _userRepo.getUserByUsername(username);

    if (user != null && user['password'] == password) {
      // 1. Tạo Payload cho JWT
      final payload = {
        'user_id': user['user_id'],
        'role': user['role'],
        'exp': DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch,
      };

      // 2. Tạo Token (Giả lập chuỗi JWT Base64)
      String token = base64Encode(utf8.encode(jsonEncode(payload)));

      // 3. Lưu Token vào DB Local và SharedPreferences (Session)
      await _userRepo.updateToken(user['user_id'], token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await prefs.setString('user_role', user['role']);

      return true;
    }
    return false;
  }

  static String? _generatedOTP;
  static String? _emailToReset;

  // 1. Gửi OTP
  Future<String?> sendOTP(String email) async {
    final user = await _userRepo.getUserByEmail(email);
    if (user == null) return "Email không tồn tại trong hệ thống!";

    // Tạo mã OTP 6 số
    _generatedOTP = (Random().nextInt(900000) + 100000).toString();
    _emailToReset = email;

    // Cấu hình Gmail (Bạn cần tạo App Password của Google)
    String username = 'minhndhe170279@fpt.edu.vn';
    String password = 'cnna rbgx lewt grtk';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Supermarket Admin')
      ..recipients.add(email)
      ..subject = 'Mã xác thực Reset Password - [SMS Project]'
      ..text = 'Mã OTP của bạn là: $_generatedOTP. Mã có hiệu lực trong 5 phút.';

    try {
      await send(message, smtpServer);
      return null; // Trả về null nếu thành công
    } catch (e) {
      return "Lỗi gửi mail: $e";
    }
  }

  // 2. Xác thực OTP
  bool verifyOTP(String inputOTP) {
    if (_generatedOTP == null) return false;
    return _generatedOTP == inputOTP;
  }

  // 3. Đặt lại mật khẩu mới
  Future<bool> resetPassword(String newPassword) async {
    if (_emailToReset == null) return false;
    int result = await _userRepo.updatePassword(_emailToReset!, newPassword);

    // Xóa dữ liệu tạm sau khi thành công
    _generatedOTP = null;
    _emailToReset = null;

    return result > 0;
  }
}