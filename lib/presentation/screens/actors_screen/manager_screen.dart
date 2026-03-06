import 'package:flutter/material.dart';
import '../inventory_management/inventory_approval_screen.dart';

class ManagerInventoryScreen extends StatelessWidget {
  const ManagerInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản trị Kho hàng")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard("Tổng giá trị kho", "1.250.000.000 VNĐ", Icons.account_balance_wallet, Colors.blue),
          const SizedBox(height: 20),
          const Text("Công việc cần làm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.amber.shade50,
            leading: const Icon(Icons.pending_actions, color: Colors.amber),
            title: const Text("Phê duyệt nhập kho"),
            subtitle: const Text("Có phiếu đang chờ bạn kiểm tra"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryApprovalScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.purple),
            title: const Text("Báo cáo tồn kho"),
            subtitle: const Text("Xem biến động nhập xuất hàng tháng"),
            onTap: () { /* Điều hướng tới Report Screen */ },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.low_priority, color: Colors.red),
            title: const Text("Điều chỉnh tồn kho"),
            subtitle: const Text("Xử lý chênh lệch sau kiểm kê"),
            onTap: () { /* Điều hướng tới Adjustment Screen */ },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}