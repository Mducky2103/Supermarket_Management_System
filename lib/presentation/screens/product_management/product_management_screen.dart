import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/repositories/product_repository.dart';
import '../../widgets/product_form.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductRepository _productRepo = ProductRepository();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Sản phẩm"),
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductForm(),
        label: const Text("Thêm sản phẩm"),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _productRepo.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có sản phẩm nào."));
          }

          final products = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = products[index];

              bool isActive = (item['is_active'] ?? 1) == 1;

              return Opacity(
                opacity: isActive ? 1.0 : 0.5,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item['image_path'] != null && File(item['image_path']).existsSync()
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(item['image_path']), fit: BoxFit.cover),
                    )
                        : const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                  title: Text(
                    item['name'] ?? "Không tên",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Barcode: ${item['barcode'] ?? 'N/A'}"),
                      Text(
                        "Kho: ${item['stock_qty']} | Giá: ${item['price']} VNĐ",
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      if (!isActive)
                        const Text(
                          "ĐÃ NGỪNG KINH DOANH",
                          style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue, size: 30),
                        onPressed: isActive ? () => _showProductForm(product: item) : null,
                      ),
                      Switch(
                        value: isActive,
                        activeThumbColor: Colors.green,
                        onChanged: (value) async {
                          await _productRepo.toggleProductStatus(item['product_id'], value);
                          _refresh();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value ? "Đã kích hoạt sản phẩm" : "Đã ngừng kinh doanh sản phẩm"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProductForm({Map<String, dynamic>? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductForm(
        product: product,
        onSave: () => _refresh(),
      ),
    );
  }
}