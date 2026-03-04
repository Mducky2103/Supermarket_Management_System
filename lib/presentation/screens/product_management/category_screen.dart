import 'package:flutter/material.dart';
import 'package:sms_project/data/repositories/category_repository.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryRepository _categoryRepo = CategoryRepository();
  final _nameCtrl = TextEditingController();

  void _refresh() => setState(() {});

  void _deleteCategory(int id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn xóa danh mục này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              try {
                await _categoryRepo.deleteCategory(id);
                Navigator.pop(ctx);
                _refresh();
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lỗi: Không thể xóa danh mục đang có sản phẩm!"))
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editCategory(Map<String, dynamic> category) {
    final editCtrl = TextEditingController(text: category['name']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sửa tên danh mục"),
        content: TextField(
          controller: editCtrl,
          decoration: const InputDecoration(labelText: "Tên mới"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (editCtrl.text.isNotEmpty) {
                await _categoryRepo.updateCategory(category['category_id'], editCtrl.text);
                Navigator.pop(ctx);
                _refresh();
              }
            },
            child: const Text("Cập nhật"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Danh mục"), centerTitle: true),
      body: Column(
        children: [
          // Phần nhập danh mục mới
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      hintText: "Nhập tên danh mục mới...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 45),
                  onPressed: () async {
                    if (_nameCtrl.text.isNotEmpty) {
                      await _categoryRepo.insertCategory(_nameCtrl.text);
                      _nameCtrl.clear();
                      _refresh();
                    }
                  },
                )
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoryRepo.getAllCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Chưa có danh mục nào"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.category, size: 20)),
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCategory(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(item['category_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}