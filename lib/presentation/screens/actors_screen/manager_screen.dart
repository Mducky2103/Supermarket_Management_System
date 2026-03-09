import 'package:flutter/material.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/service/auth_service.dart'; // Thêm import này
import '../inventory_management/inbound_screen.dart';
import '../inventory_management/inventory_adjustment_screen.dart';
import '../inventory_management/low_stock_dashboard.dart';

class ManagerInventoryScreen extends StatefulWidget {
  const ManagerInventoryScreen({super.key}); // Bỏ các tham số ở đây

  @override
  State<ManagerInventoryScreen> createState() => _ManagerInventoryScreenState();
}

class _ManagerInventoryScreenState extends State<ManagerInventoryScreen> {
  final InventoryRepository _repo = InventoryRepository();
  final _authService = AuthService(); // Khởi tạo AuthService

  int? _userId;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Hàm load thông tin người dùng từ SharedPreferences
  void _loadUserInfo() async {
    final id = await _authService.getUserId();
    final name = await _authService.getUserName();
    setState(() {
      _userId = id;
      _userName = name;
      _isLoading = false;
    });
  }

  // Hàm lấy thống kê thực tế từ DB
  Future<Map<String, dynamic>> _getDashboardStats() async {
    final products = await _repo.getAllProducts();
    final lowStock = await _repo.getLowStockDashboard(10);

    int totalQty = 0;
    for (var p in products) {
      totalQty += (p['stock_qty'] as int);
    }

    return {
      'total_stock': totalQty,
      'low_stock_count': lowStock.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Quản trị Kho hàng"),
        actions: [
          IconButton(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: _getDashboardStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? {'total_stock': 0, 'low_stock_count': 0};

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Xin chào, ${_userName ?? 'Manager'}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatsOverview(
                      stats['total_stock'].toString(),
                      stats['low_stock_count'].toString()
                  ),
                  const SizedBox(height: 24),
                  const Text("DANH MỤC PHÊ DUYỆT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildApprovalSection(context),
                  const SizedBox(height: 24),
                  const Text("BÁO CÁO NHANH", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildReportSection(context),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _buildStatsOverview(String total, String lowCount) {
    return Row(
      children: [
        _statCard("Tổng tồn kho", total, Icons.inventory_2, Colors.blue),
        const SizedBox(width: 12),
        _statCard("Sắp hết hàng", lowCount, Icons.warning, Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalSection(BuildContext context) {
    return Column(
      children: [
        _approvalTile(
            context,
            "Duyệt nhập kho",
            "Phiếu nhập đang chờ",
            Icons.download_rounded,
            Colors.green,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => InboundScreen(userRole: 'manager', currentUserId: _userId ?? 0)))
        ),
        const SizedBox(height: 10),
        _approvalTile(
            context,
            "Điều chỉnh & Xuất hủy",
            "Duyệt kiểm kê & Lệnh hủy hàng",
            Icons.fact_check,
            Colors.indigo,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryAdjustmentScreen()))
        ),
      ],
    );
  }

  Widget _approvalTile(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.white,
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildReportSection(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _reportCard("Hàng sắp hết", Icons.trending_down, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LowStockDashboard()))),
        _reportCard("Phân tích kho", Icons.analytics_outlined, Colors.purple, () {
          // Xử lý Phân tích kho tại đây
        }),
      ],
    );
  }

  Widget _reportCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}