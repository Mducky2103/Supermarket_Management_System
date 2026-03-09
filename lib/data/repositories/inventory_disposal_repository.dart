import 'package:sms_project/data/datasources/local/database_helper.dart';

class InventoryDisposalRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> disposeInventory(int productId, int quantity, String reason) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      // 1. Trừ kho sản phẩm
      await txn.execute(
          'UPDATE products SET stock_qty = stock_qty - ? WHERE product_id = ?',
          [quantity, productId]
      );

      // 2. Ghi nhật ký xuất hủy
      await txn.insert('inventory_disposal', {
        'product_id': productId,
        'quantity': quantity,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

// Lấy danh sách lịch sử hủy hàng
  Future<List<Map<String, dynamic>>> getDisposalHistory() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
    SELECT d.*, p.name as product_name 
    FROM inventory_disposal d
    JOIN products p ON d.product_id = p.product_id
    ORDER BY d.created_at DESC
  ''');
  }
}