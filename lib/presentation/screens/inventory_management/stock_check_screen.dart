import 'package:flutter/material.dart';
import '../../../data/repositories/inventory_repository.dart';

class StockCheckScreen extends StatefulWidget {
  final int userId;
  const StockCheckScreen({super.key, required this.userId});

  @override
  State<StockCheckScreen> createState() => _StockCheckScreenState();
}

class _StockCheckScreenState extends State<StockCheckScreen> {
  final InventoryRepository _repo = InventoryRepository();
  final List<Map<String, dynamic>> _checkList = [];

  // Mở danh sách chọn sản phẩm từ kho
  void _showProductPicker() async {
    final allProducts = await _repo.getAllProducts();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        itemCount: allProducts.length,
        itemBuilder: (context, i) {
          final p = allProducts[i];
          final isSelected = _checkList.any((e) => e['product_id'] == p['product_id']);

          return ListTile(
            leading: const Icon(Icons.inventory_2),
            title: Text(p['name']),
            subtitle: Text("Tồn kho: ${p['stock_qty']}"),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.add_circle_outline),
            onTap: isSelected ? null : () {
              setState(() {
                _checkList.add({
                  'product_id': p['product_id'],
                  'name': p['name'],
                  'system_qty': p['stock_qty'],
                  'actual_qty': p['stock_qty'],
                });
              });
              Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }

  void _saveStockCheck() async {
    if (_checkList.isEmpty) return;
    await _repo.createStockCheck(widget.userId, _checkList);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã lưu phiếu kiểm kê chờ duyệt!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiểm kê thực tế"),
        actions: [IconButton(icon: const Icon(Icons.add_box), onPressed: _showProductPicker)],
      ),
      body: _checkList.isEmpty
          ? const Center(child: Text("Nhấn (+) để chọn sản phẩm kiểm kê"))
          : ListView.builder(
        itemCount: _checkList.length,
        itemBuilder: (context, i) {
          final item = _checkList[i];
          int diff = (item['actual_qty'] ?? 0) - (item['system_qty'] as int);

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Hệ thống: ${item['system_qty']} | Chênh lệch: ${diff > 0 ? '+' : ''}$diff"),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: "Thực tế"),
                  onChanged: (val) => setState(() => _checkList[i]['actual_qty'] = int.tryParse(val) ?? 0),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          onPressed: _checkList.isEmpty ? null : _saveStockCheck,
          child: const Text("LƯU PHIẾU KIỂM KÊ"),
        ),
      ),
    );
  }
}