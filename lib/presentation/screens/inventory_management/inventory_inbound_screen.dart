import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/product_repository.dart';

class InventoryInboundScreen extends StatefulWidget {
  const InventoryInboundScreen({super.key});

  @override
  State<InventoryInboundScreen> createState() => _InventoryInboundScreenState();
}

class _InventoryInboundScreenState extends State<InventoryInboundScreen> {
  final _inventoryRepo = InventoryRepository();
  final _productRepo = ProductRepository();

  List<Map<String, dynamic>> _selectedItems = [];
  List<Map<String, dynamic>> _allProducts = [];
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final products = await _productRepo.getAllProducts();
    setState(() {
      _currentUserId = prefs.getInt('user_id');
      _allProducts = products;
    });
  }

  void _submitInbound() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi: Chưa đăng nhập!")));
      return;
    }

    final inboundData = {
      'user_id': _currentUserId,
      'status': 'Pending',
      'notes': 'Nhập kho hàng thực tế',
      'created_at': DateTime.now().toIso8601String(),
    };

    await _inventoryRepo.createInbound(inboundData, _selectedItems);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo phiếu nhập kho")),
      body: Column(
        children: [
          ListTile(
            tileColor: Colors.blue.withOpacity(0.1),
            leading: const Icon(Icons.person),
            title: Text("Nhân viên thực hiện ID: ${_currentUserId ?? 'Loading...'}"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedItems.length,
              itemBuilder: (context, index) {
                final item = _selectedItems[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "SL: ${item['quantity']}", 
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedItems.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("Thêm món"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: _selectedItems.isEmpty ? null : _submitInbound,
                    child: const Text("LƯU PHIẾU"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    int? productId;
    final qtyCtrl = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Chọn hàng nhập kho"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              items: _allProducts.map((p) => DropdownMenuItem(value: p['product_id'] as int, child: Text(p['name']))).toList(),
              onChanged: (v) => productId = v,
              decoration: const InputDecoration(labelText: "Sản phẩm"),
            ),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Số lượng"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (productId != null) {
                final prod = _allProducts.firstWhere((p) => p['product_id'] == productId);
                setState(() {
                  _selectedItems.add({
                    'product_id': prod['product_id'],
                    'name': prod['name'],
                    'quantity': int.parse(qtyCtrl.text),
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }
}
