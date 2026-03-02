import 'package:flutter/material.dart';
import 'package:sms_project/presentation/screens/authentication/login_screen.dart';
import 'package:sms_project/presentation/screens/authentication/password/forgot_password_screen.dart';
import 'package:sms_project/presentation/screens/authentication/signup_screen.dart';
import 'package:sms_project/presentation/screens/test/test_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supermarket POS',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        // '/cashier_dashboard': (context) => const CashierDashboard(), // Bạn sẽ tạo sau
      },
    );
  }
}


