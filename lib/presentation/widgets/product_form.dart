import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/product_repository.dart';

class ProductForm extends StatefulWidget {
  final Map<String, dynamic>? product;
  final VoidCallback onSave;

  const ProductForm({super.key, this.product, required this.onSave});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _productRepo = ProductRepository();
  final _categoryRepo = CategoryRepository();

  final _barcodeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(); // Thêm controller cho vị trí

  int? _selectedCategoryId;
  String? _imagePath;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _barcodeCtrl.text = widget.product!['barcode'] ?? '';
      _nameCtrl.text = widget.product!['name'] ?? '';
      _priceCtrl.text = widget.product!['price']?.toString() ?? '';
      _costPriceCtrl.text = widget.product!['cost_price']?.toString() ?? '';
      _stockCtrl.text = widget.product!['stock_qty']?.toString() ?? '0';
      _locationCtrl.text = widget.product!['location'] ?? '';
      _selectedCategoryId = widget.product!['category_id'];
      _imagePath = widget.product!['image_path'];
    }
    _loadCategories();
  }

  _loadCategories() async {
    final list = await _categoryRepo.getAllCategories();
    setState(() => _categories = list);
  }

  String _generateRandomBarcode() {
    final random = Random();
    String barcode = '20';
    for (int i = 0; i < 10; i++) {
      barcode += random.nextInt(10).toString();
    }
    return barcode;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20, right: 20, top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.product == null ? "THÊM SẢN PHẨM MỚI" : "CẬP NHẬT SẢN PHẨM",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _imagePath != null && File(_imagePath!).existsSync()
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                  )
                      : const Icon(Icons.add_a_photo, size: 40, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _barcodeCtrl,
                decoration: InputDecoration(
                  labelText: "Mã vạch (Barcode)",
                  prefixIcon: const Icon(Icons.qr_code),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.autorenew, color: Colors.blue),
                    onPressed: () => setState(() => _barcodeCtrl.text = _generateRandomBarcode()),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Tên sản phẩm", prefixIcon: Icon(Icons.edit)),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: _categories.map((c) => DropdownMenuItem<int>(
                  value: c['category_id'],
                  child: Text(c['name']),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                decoration: const InputDecoration(labelText: "Danh mục", prefixIcon: Icon(Icons.category)),
                validator: (v) => v == null ? "Chọn danh mục" : null,
              ),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: "Vị trí trong kho (VD: Kệ A1, Tủ 2)", prefixIcon: Icon(Icons.location_on)),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceCtrl,
                      decoration: const InputDecoration(labelText: "Giá vốn (VND)"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Nhập giá vốn" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: "Giá bán (VND)"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Nhập giá bán" : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _stockCtrl,
                decoration: const InputDecoration(labelText: "Số lượng tồn kho"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Nhập số lượng" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final data = {
                          'barcode': _barcodeCtrl.text,
                          'name': _nameCtrl.text,
                          'category_id': _selectedCategoryId,
                          'price': double.parse(_priceCtrl.text),
                          'cost_price': double.parse(_costPriceCtrl.text),
                          'stock_qty': int.parse(_stockCtrl.text),
                          'location': _locationCtrl.text, // Thêm vào Map lưu trữ
                          'image_path': _imagePath,
                        };

                        if (widget.product == null) {
                          await _productRepo.insertProduct(data);
                        } else {
                          await _productRepo.updateProduct(widget.product!['product_id'], data);
                        }
                        widget.onSave();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Lỗi: Mã vạch đã tồn tại!"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text("LƯU THÔNG TIN", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
