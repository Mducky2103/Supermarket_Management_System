import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/inventory_repository.dart';

class InventoryApprovalScreen extends StatefulWidget {
  const InventoryApprovalScreen({super.key});

  @override
  State<InventoryApprovalScreen> createState() => _InventoryApprovalScreenState();
}

class _InventoryApprovalScreenState extends State<InventoryApprovalScreen> {
  final _inventoryRepo = InventoryRepository();
  int? _managerId;

  @override
  void initState() {
    super.initState();
    _loadManagerId();
  }

  _loadManagerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _managerId = prefs.getInt('user_id'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Duyệt nhập kho")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _inventoryRepo.getPendingInbounds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty) return const Center(child: Text("Không có phiếu nào chờ duyệt."));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final inbound = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Phiếu #${inbound['inbound_id']} - NV: ${inbound['staff_name']}"),
                  subtitle: Text("Ngày tạo: ${inbound['created_at'].toString().substring(0, 16)}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDetailDialog(inbound),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> inbound) async {
    final items = await _inventoryRepo.getInboundItems(inbound['inbound_id']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Chi tiết phiếu #${inbound['inbound_id']}"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (c, i) => ListTile(
              title: Text(items[i]['product_name']),
              trailing: Text("SL nhập: ${items[i]['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              await _inventoryRepo.approveInbound(inbound['inbound_id'], _managerId!);
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã duyệt và cập nhật kho thành công!")));
            },
            child: const Text("PHÊ DUYỆT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}