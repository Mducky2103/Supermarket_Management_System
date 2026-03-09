import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/inventory_repository.dart';
import 'disposal_screen.dart';

class InventoryAdjustmentScreen extends StatefulWidget {
  const InventoryAdjustmentScreen({super.key});

  @override
  State<InventoryAdjustmentScreen> createState() => _InventoryAdjustmentScreenState();
}

class _InventoryAdjustmentScreenState extends State<InventoryAdjustmentScreen> {
  final InventoryRepository _repo = InventoryRepository();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Điều chỉnh & Xuất hủy"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Duyệt kiểm kê", icon: Icon(Icons.fact_check)),
              Tab(text: "Xuất hủy hàng", icon: Icon(Icons.delete_sweep)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildApprovalTab(),
            _buildDisposalTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: DUYỆT KIỂM KÊ (ADJUSTMENT) ---
  Widget _buildApprovalTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _repo.getPendingAdjustments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text("Không có phiếu kiểm kê nào chờ duyệt."));
        }

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.fact_check)),
              title: Text("Phiếu kiểm kê #${list[i]['check_id']}"),
              subtitle: Text("Người thực hiện: ${list[i]['staff_name']}\nNgày: ${list[i]['check_date'].split('T')[0]}"),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: () => _showDetail(list[i]['check_id']),
                child: const Text("Chi tiết"),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetail(int checkId) async {
    final items = await _repo.getCheckItems(checkId);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Chi tiết chênh lệch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(items[i]['product_name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text("Hệ thống: ${items[i]['system_qty']} | Thực tế: ${items[i]['actual_qty']}"),
                  trailing: Text(
                    "${items[i]['discrepancy'] > 0 ? '+' : ''}${items[i]['discrepancy']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: items[i]['discrepancy'] != 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () async {
                  await _repo.approveAdjustment(checkId);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã cập nhật số lượng tồn kho thực tế!")),
                    );
                    _refresh();
                  }
                },
                child: const Text("XÁC NHẬN ĐIỀU CHỈNH KHO", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: XUẤT HỦY (DISPOSAL) ---
  Widget _buildDisposalTab() {
    return FutureBuilder<int?>(
      future: _getCurrentUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return DisposalScreen(userId: snapshot.data!);
      },
    );
  }

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}
