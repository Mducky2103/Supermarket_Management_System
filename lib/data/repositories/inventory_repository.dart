import '../datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class InventoryRepository {
  final dbHelper = DatabaseHelper.instance;

  // Tạo phiếu nhập mới
  Future<int> createInbound(Map<String, dynamic> inbound, List<Map<String, dynamic>> items) async {
    final db = await dbHelper.database;
    return await db.transaction((txn) async {
      int inboundId = await txn.insert('inventory_inbound', inbound);

      for (var item in items) {
        await txn.insert('inventory_inbound_items', {
          'inbound_id': inboundId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
        });
      }
      return inboundId;
    });
  }

  // Lấy danh sách phiếu đang chờ duyệt
  Future<List<Map<String, dynamic>>> getPendingInbounds() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT ib.*, u.name as staff_name 
      FROM inventory_inbound ib
      JOIN users u ON ib.user_id = u.user_id
      WHERE ib.status = 'Pending'
      ORDER BY ib.created_at DESC
    ''');
  }

  // Lấy chi tiết các món hàng trong một phiếu
  Future<List<Map<String, dynamic>>> getInboundItems(int inboundId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT i.*, p.name as product_name 
      FROM inventory_inbound_items i
      JOIN products p ON i.product_id = p.product_id
      WHERE i.inbound_id = ?
    ''', [inboundId]);
  }

  // Duyệt phiếu và cộng tồn kho
  Future<void> approveInbound(int inboundId, int managerId) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      // Cập nhật trạng thái phiếu nhập
      await txn.update(
        'inventory_inbound',
        {
          'status': 'Approved',
          'approved_by': managerId,
          'approved_at': DateTime.now().toIso8601String(),
        },
        where: 'inbound_id = ?',
        whereArgs: [inboundId],
      );

      // Lấy danh sách hàng hóa trong phiếu
      List<Map<String, dynamic>> items = await txn.query(
        'inventory_inbound_items',
        where: 'inbound_id = ?',
        whereArgs: [inboundId],
      );

      // Chạy vòng lặp cộng dồn vào bảng products
      for (var item in items) {
        await txn.execute('''
          UPDATE products 
          SET stock_qty = stock_qty + ? 
          WHERE product_id = ?
        ''', [item['quantity'], item['product_id']]);
      }
    });

    // Hàm lưu kết quả kiểm kê
    Future<void> saveStockCheck(int userId, List<Map<String, dynamic>> items) async {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        // Tạo bản ghi đợt kiểm kê
        int checkId = await txn.insert('inventory_checks', {
          'user_id': userId,
          'check_date': DateTime.now().toIso8601String(),
        });

        // Lưu chi tiết sản phẩm và tính chênh lệch
        for (var item in items) {
          int systemQty = item['system_qty']; // Số lượng đang có trên hệ thống
          int actualQty = item['actual_qty']; // Số lượng thực tế đếm được

          await txn.insert('inventory_check_items', {
            'check_id': checkId,
            'product_id': item['product_id'],
            'system_qty': systemQty,
            'actual_qty': actualQty,
            'discrepancy': actualQty - systemQty, // Tính chênh lệch
          });
        }
      });
    }
  }
}