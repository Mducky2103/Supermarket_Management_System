// lib/presentation/screens/inventory/stock_check_screen.dart
import 'package:flutter/material.dart';

class StockCheckScreen extends StatefulWidget {
  const StockCheckScreen({super.key});

  @override
  State<StockCheckScreen> createState() => _StockCheckScreenState();
}

class _StockCheckScreenState extends State<StockCheckScreen> {
  List<Map<String, dynamic>> _checkList = [
    {'product_id': 1, 'name': 'Coca Cola', 'system_qty': 50, 'actual_qty': 0},
    {'product_id': 2, 'name': 'Pepsi', 'system_qty': 30, 'actual_qty': 0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kiểm kê kho")),
      body: ListView.builder(
        itemCount: _checkList.length,
        itemBuilder: (context, index) {
          final item = _checkList[index];
          return Card(
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text("Hệ thống: ${item['system_qty']}"),
              trailing: SizedBox(
                width: 100,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Thực tế"),
                  onChanged: (val) {
                    _checkList[index]['actual_qty'] = int.tryParse(val) ?? 0;
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _finishCheck(),
        child: const Icon(Icons.check),
      ),
    );
  }

  void _finishCheck() {
    // Logic: Gọi repository để lưu vào DB và gửi thông báo cho Manager
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã lưu kết quả kiểm kê và gửi cho Quản lý!")),
    );
  }
}