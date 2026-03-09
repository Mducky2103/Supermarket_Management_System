import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/inventory_repository.dart';
import 'inbound_screen.dart';

class LowStockDashboard extends StatefulWidget {
  const LowStockDashboard({super.key});

  @override
  State<LowStockDashboard> createState() => _LowStockDashboardState();
}

class _LowStockDashboardState extends State<LowStockDashboard> {
  final InventoryRepository _repo = InventoryRepository();
  final int _safetyThreshold = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cảnh báo tồn kho thấp"),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _repo.getLowStockDashboard(_safetyThreshold),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final lowStockItems = snapshot.data!;
          return Column(
            children: [
              _buildSummaryHeader(lowStockItems.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: lowStockItems.length,
                  itemBuilder: (context, index) {
                    final item = lowStockItems[index];
                    return _buildLowStockCard(item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Có $count sản phẩm dưới ngưỡng an toàn ($_safetyThreshold)",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockCard(Map<String, dynamic> item) {
    // Tính toán mức độ nghiêm trọng (Dưới 3 cái là mức báo động đỏ)
    bool isCritical = (item['stock_qty'] ?? 0) <= 10;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCritical ? Colors.red.shade100 : Colors.orange.shade100,
          child: Text(
            "${item['stock_qty']}",
            style: TextStyle(
              color: isCritical ? Colors.red : Colors.orange.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(item['name'] ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Loại: ${item['category_name'] ?? 'Chưa phân loại'}"),
        trailing: ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final role = prefs.getString('user_role') ?? 'staff';
            final userId = prefs.getInt('user_id') ?? 0;

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InboundScreen(
                    userRole: role,
                    currentUserId: userId,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
          ),
          child: const Text("Nhập thêm"),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
          const SizedBox(height: 16),
          const Text(
            "Tồn kho đang ở mức an toàn!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
