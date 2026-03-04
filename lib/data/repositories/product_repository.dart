
import '../datasources/local/database_helper.dart';

class ProductRepository {
  final dbHelper = DatabaseHelper.instance;

  // Lấy danh sách sản phẩm kèm tên danh mục
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT p.*, c.name as category_name
      FROM products p
      JOIN categories c ON p.category_id = c.category_id
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await dbHelper.database;
    // Join với bảng categories để lấy tên danh mục
    return await db.rawQuery('''
      SELECT p.*, c.name as category_name 
      FROM products p 
      JOIN categories c ON p.category_id = c.category_id
      ORDER BY p.product_id DESC
    ''');
  }

  Future<int> insertProduct(Map<String, dynamic> data) async {
    final db = await dbHelper.database;
    return await db.insert('products', data);
  }

  Future<int> updateProduct(int id, Map<String, dynamic> data) async {
    final db = await dbHelper.database;
    return await db.update('products', data, where: 'product_id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await dbHelper.database;
    return await db.delete('products', where: 'product_id = ?', whereArgs: [id]);
  }

  Future<int> toggleProductStatus(int id, bool isActive) async {
    final db = await dbHelper.database;
    return await db.update(
        'products',
        {'is_active': isActive ? 1 : 0},
        where: 'product_id = ?',
        whereArgs: [id]
    );
  }

  // Tìm sản phẩm theo Barcode
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final db = await dbHelper.database;

    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Cập nhật kho hàng
  Future<void> updateStock(int productId, int quantitySold) async {
    final db = await dbHelper.database;
    await db.execute(
      'UPDATE products SET stock_qty = stock_qty - ? WHERE product_id = ?',
      [quantitySold, productId],
    );
  }
}