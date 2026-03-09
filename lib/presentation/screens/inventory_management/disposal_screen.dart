import 'package:flutter/material.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/inventory_disposal_repository.dart';

class DisposalScreen extends StatefulWidget {
  final int userId;
  const DisposalScreen({super.key, required this.userId});

  @override
  State<DisposalScreen> createState() => _DisposalScreenState();
}

class _DisposalScreenState extends State<DisposalScreen> {
  final _inventoryRepo = InventoryRepository();
  final _productRepo = ProductRepository();
  final _disposalRepo = InventoryDisposalRepository();

  List<Map<String, dynamic>> _selectedItems = [];
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xuất hủy hàng hóa")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: "Lý do xuất hủy (Hết hạn, hư hỏng...)",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedItems.isEmpty
                ? const Center(child: Text("Chưa chọn hàng cần hủy"))
                : ListView.builder(
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = _selectedItems[index];
                      return ListTile(
                        leading: const Icon(Icons.delete_sweep, color: Colors.red),
                        title: Text(item['name']),
                        subtitle: Text("Số lượng hủy: ${item['quantity']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => setState(() => _selectedItems.removeAt(index)),
                        ),
                      );
                    },
                  ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _showProductPicker,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Thêm hàng"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: (_selectedItems.isEmpty || _isSubmitting) ? null : _submitDisposal,
              child: _isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("XÁC NHẬN HỦY"),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductPicker() async {
    final products = await _productRepo.getAllProducts();
    int? selectedId;
    final qtyCtrl = TextEditingController(text: "1");

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Chọn hàng xuất hủy"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              items: products.map((p) => DropdownMenuItem(value: p['product_id'] as int, child: Text(p['name']))).toList(),
              onChanged: (v) => selectedId = v,
              decoration: const InputDecoration(labelText: "Sản phẩm"),
            ),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Số lượng hủy"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (selectedId != null) {
                final prod = products.firstWhere((p) => p['product_id'] == selectedId);
                setState(() {
                  _selectedItems.add({
                    'product_id': prod['product_id'],
                    'name': prod['name'],
                    'quantity': int.tryParse(qtyCtrl.text) ?? 0,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  void _submitDisposal() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập lý do hủy!")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reason = _reasonController.text;
      for (var item in _selectedItems) {
        await _disposalRepo.disposeInventory(
          item['product_id'] as int,
          item['quantity'] as int,
          reason,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã thực hiện xuất hủy và cập nhật kho!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khi xuất hủy: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
