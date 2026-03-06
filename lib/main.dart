import 'package:flutter/material.dart';
import 'package:sms_project/presentation/screens/actors_screen/admin_dashboard.dart';
import 'package:sms_project/presentation/screens/actors_screen/manager_screen.dart';
import 'package:sms_project/presentation/screens/actors_screen/user_management_screen.dart';
import 'package:sms_project/presentation/screens/actors_screen/warehouse_staff_screen.dart';
import 'package:sms_project/presentation/screens/authentication/login_screen.dart';
import 'package:sms_project/presentation/screens/authentication/password/forgot_password_screen.dart';
import 'package:sms_project/presentation/screens/authentication/signup_screen.dart';
import 'package:sms_project/presentation/screens/product_management/category_screen.dart';
import 'package:sms_project/presentation/screens/product_management/product_management_screen.dart';

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

        //Admin routes
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/user_management': (context) => const UserManagementScreen(),

        //Product routes
        '/product_management': (context) => const ProductManagementScreen(),
        '/category_management': (context) => const CategoryScreen(),

        //Employee routes
        '/warehouse_staff': (context) => const WarehouseStaffScreen(),
        '/manager_inventory': (context) => const ManagerInventoryScreen(),

        // '/cashier_dashboard': (context) => const CashierDashboard(),
      },

      // trường hợp không tìm thấy trang
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy trang: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}


