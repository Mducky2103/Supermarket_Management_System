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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý Danh mục")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: "Tên danh mục mới"))),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 40),
                  onPressed: () async {
                    if (_nameCtrl.text.isNotEmpty) {
                      await _categoryRepo.insertCategory(_nameCtrl.text);
                      _nameCtrl.clear();
                      setState(() {});
                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoryRepo.getAllCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(snapshot.data![index]['name']),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}