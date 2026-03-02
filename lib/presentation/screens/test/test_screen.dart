import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 100, color: Colors.red),
            Text("Welcome, ADMIN!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Bạn có quyền: Quản lý kho, Nhân sự, Báo cáo."),
          ],
        ),
      ),
    );
  }
}