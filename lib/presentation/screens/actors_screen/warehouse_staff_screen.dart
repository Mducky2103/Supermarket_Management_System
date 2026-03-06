import 'package:flutter/material.dart';
import '../inventory_management/inventory_inbound_screen.dart';

class WarehouseStaffScreen extends StatelessWidget {
  const WarehouseStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kho hàng (Nhân viên)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Xem lịch sử các phiếu đã tạo
            },
          )
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
              "Nhập Kho",
              Icons.add_business,
              Colors.blue,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryInboundScreen())),
            ),
            _buildMenuCard(
              context,
              "Kiểm Kê",
              Icons.inventory,
              Colors.orange,
                  () { /* Điều hướng tới màn hình Stock Check */ },
            ),
            _buildMenuCard(
              context,
              "Sản phẩm",
              Icons.list_alt,
              Colors.green,
                  () => Navigator.pushNamed(context, '/product_management'),
            ),
            _buildMenuCard(
              context,
              "Cảnh báo kho",
              Icons.warning_amber_rounded,
              Colors.red,
                  () { /* Xem hàng sắp hết */ },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}