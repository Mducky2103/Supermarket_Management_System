import 'package:flutter/material.dart';
import '../../../data/repositories/inventory_repository.dart';
import '../../../data/repositories/product_repository.dart';

class InboundScreen extends StatefulWidget {
  final String userRole;
  final int currentUserId;

  const InboundScreen({
    super.key,
    required this.userRole,
      required this.currentUserId
  });

  @override
  State<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends State<InboundScreen> {
  final InventoryRepository _repo = InventoryRepository();
  final ProductRepository _productRepo = ProductRepository();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Quản lý Nhập kho"),
          bottom: const TabBar(tabs: [Tab(text: "Danh sách phiếu"), Tab(text: "Tạo phiếu mới")]),
        ),
        body: TabBarView(children: [_buildPendingList(), _buildCreateForm()]),
      ),
    );
  }

  // --- PHẦN 1: DANH SÁCH PHIẾU CHỜ DUYỆT ---
  Widget _buildPendingList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _repo.getInboundsByStatus('Pending'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data ?? [];
        if (list.isEmpty) return const Center(child: Text("Không có phiếu nào chờ duyệt"));

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final item = list[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                onTap: () => _showInboundDetail(item['inbound_id']),
                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                title: Text("Phiếu nhập #${item['inbound_id']}"),
                subtitle: Text("Người tạo: ${item['staff_name'] ?? 'N/A'}\nNgày: ${item['created_at']}"),
                isThreeLine: true,
                trailing: widget.userRole == 'manager'
                    ? _buildManagerActions(item['inbound_id'])
                    : const Chip(label: Text("Đang chờ", style: TextStyle(fontSize: 12))),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildManagerActions(int id) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _approve(id)),
      IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => _reject(id)),
    ],
  );

  void _showInboundDetail(int id) async {
    final items = await _repo.getInboundItems(id);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Text("Chi tiết phiếu nhập", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(items[i]['product_name']),
                subtitle: Text("HSD: ${items[i]['expiry_date'] ?? 'N/A'} | Lô: ${items[i]['batch_number'] ?? 'N/A'}"),
                trailing: Text("SL: ${items[i]['quantity']}"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _approve(int id) async {
    await _repo.approveInbound(id, widget.currentUserId);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã duyệt nhập kho!")));
    setState(() {});
  }

  void _reject(int id) async {
    final reasonController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Từ chối phiếu"),
      content: TextField(controller: reasonController, decoration: const InputDecoration(hintText: "Nhập lý do...")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
        ElevatedButton(onPressed: () async {
          await _repo.rejectInbound(id, reasonController.text);
          Navigator.pop(ctx);
          setState(() {});
        }, child: const Text("Xác nhận từ chối")),
      ],
    ));
  }

  // --- PHẦN 2: FORM TẠO PHIẾU ---
  List<Map<String, dynamic>> _selectedProducts = [];

  Widget _buildCreateForm() {
    return Column(
      children: [
        Expanded(
          child: _selectedProducts.isEmpty 
            ? const Center(child: Text("Chưa có sản phẩm nào trong phiếu"))
            : ListView.builder(
                itemCount: _selectedProducts.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(_selectedProducts[i]['name']),
                  subtitle: Text("HSD: ${_selectedProducts[i]['expiry_date']} | Lô: ${_selectedProducts[i]['batch_number']}"),
                  trailing: Text("${_selectedProducts[i]['quantity']} sp"),
                ),
              ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openProductPicker,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text("Thêm sản phẩm"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: _selectedProducts.isEmpty ? null : _saveInbound,
                  child: const Text("Gửi phiếu nhập"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openProductPicker() async {
    final products = await _productRepo.getAllProducts();
    int? selectedId;
    final qtyCtrl = TextEditingController(text: "1");
    final expCtrl = TextEditingController();
    final batchCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thêm hàng vào phiếu"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                items: products.map((p) => DropdownMenuItem(value: p['product_id'] as int, child: Text(p['name']))).toList(),
                onChanged: (v) => selectedId = v,
                decoration: const InputDecoration(labelText: "Sản phẩm"),
              ),
              TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Số lượng"), keyboardType: TextInputType.number),
              TextField(controller: expCtrl, decoration: const InputDecoration(labelText: "Hạn sử dụng (VD: 2025-12-31)")),
              TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: "Số lô (Batch Number)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(onPressed: () {
            if (selectedId != null) {
              final prod = products.firstWhere((p) => p['product_id'] == selectedId);
              setState(() {
                _selectedProducts.add({
                  'product_id': prod['product_id'],
                  'name': prod['name'],
                  'quantity': int.parse(qtyCtrl.text),
                  'expiry_date': expCtrl.text,
                  'batch_number': batchCtrl.text,
                });
              });
              Navigator.pop(ctx);
            }
          }, child: const Text("Thêm")),
        ],
      ),
    );
  }

  void _saveInbound() async {
    await _repo.createInbound({
      'user_id': widget.currentUserId,
      'status': 'Pending',
      'created_at': DateTime.now().toString().split('.')[0]
    }, _selectedProducts);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã gửi phiếu nhập kho chờ duyệt!")));
    setState(() => _selectedProducts.clear());
  }
}
