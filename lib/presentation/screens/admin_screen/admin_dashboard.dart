import 'package:flutter/material.dart';
import 'user_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              title: "Quản lý User",
              icon: Icons.people_alt_rounded,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              ),
            ),
            _buildMenuCard(
              context,
              title: "Sản phẩm",
              icon: Icons.inventory_2_rounded,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/product_management');
              },
            ),
            _buildMenuCard(
              context,
              title: "Danh mục",
              icon: Icons.category_rounded,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/category_management');
              },
            ),
            _buildMenuCard(
              context,
              title: "Báo cáo doanh thu",
              icon: Icons.bar_chart_rounded,
              color: Colors.purple,
              onTap: () {},
            ),
            _buildMenuCard(
              context,
              title: "Khuyến mãi",
              icon: Icons.local_offer_rounded,
              color: Colors.red,
              onTap: () {},
            ),
            _buildMenuCard(
              context,
              title: "Cài đặt hệ thống",
              icon: Icons.settings_rounded,
              color: Colors.grey,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}