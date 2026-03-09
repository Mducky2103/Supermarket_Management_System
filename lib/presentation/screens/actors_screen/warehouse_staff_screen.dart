import 'package:flutter/material.dart';
import '../../../data/service/auth_service.dart';
import '../inventory_management/inbound_screen.dart';
import '../inventory_management/stock_check_screen.dart';
import '../inventory_management/low_stock_dashboard.dart';
import '../inventory_management/disposal_screen.dart';

class WarehouseStaffScreen extends StatefulWidget {
  const WarehouseStaffScreen({super.key});

  @override
  State<WarehouseStaffScreen> createState() => _WarehouseStaffScreenState();
}

class _WarehouseStaffScreenState extends State<WarehouseStaffScreen> {
  final _authService = AuthService();
  int? _userId;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final id = await _authService.getUserId();
    final name = await _authService.getUserName();
    if (mounted) {
      setState(() {
        _userId = id;
        _userName = name;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kho hàng & Tồn kho"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            const Text("NGHIỆP VỤ KHO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            const Text("GIÁM SÁT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildMonitoringCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Xin chào, ${_userName ?? 'Nhân viên'}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("Hôm nay bạn cần xử lý công việc gì?", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _menuCard(
            context, "Nhập kho", Icons.add_box_outlined, Colors.blue,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => InboundScreen(userRole: 'staff', currentUserId: _userId ?? 0)))
        ),
        _menuCard(
            context, "Kiểm kê", Icons.fact_check_outlined, Colors.orange,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => StockCheckScreen(userId: _userId ?? 0)))
        ),
        _menuCard(
            context, "Xuất hủy", Icons.delete_outline, Colors.red,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => DisposalScreen(userId: _userId ?? 0)))
        ),
      ],
    );
  }

  Widget _buildMonitoringCards(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(50)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LowStockDashboard())),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cảnh báo tồn kho", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Kiểm tra các mặt hàng sắp hết hạn hoặc hết số lượng", style: TextStyle(fontSize: 12, color: Colors.orange.shade900)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
