import '../datasources/local/database_helper.dart';

class InventoryRepository {
  final dbHelper = DatabaseHelper.instance;

  // --- PHẦN XUẤT HỦY (DISPOSAL) ---
  Future<void> createDisposal(List<Map<String, dynamic>> items, String reason) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      for (var item in items) {
        // 1. Lưu bản ghi xuất hủy
        await txn.insert('inventory_disposal', {
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'reason': reason,
          'created_at': DateTime.now().toIso8601String(),
        });
        // 2. Trừ kho trực tiếp (Vì Manager thực hiện nên trừ luôn)
        await txn.rawUpdate(
          'UPDATE products SET stock_qty = stock_qty - ? WHERE product_id = ?',
          [item['quantity'], item['product_id']]
        );
      }
    });
  }

  // --- PHẦN KIỂM KÊ (STOCK CHECK / ADJUSTMENT) ---
  Future<void> createStockCheck(int userId, List<Map<String, dynamic>> items) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      int checkId = await txn.insert('inventory_checks', {
        'user_id': userId,
        'check_date': DateTime.now().toIso8601String(),
        'status': 'Pending',
      });
      for (var item in items) {
        await txn.insert('inventory_check_items', {
          'check_id': checkId,
          'product_id': item['product_id'],
          'system_qty': item['system_qty'],
          'actual_qty': item['actual_qty'],
          'discrepancy': (item['actual_qty'] as int) - (item['system_qty'] as int),
        });
      }
    });
  }

  Future<void> approveAdjustment(int checkId) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      final items = await txn.query('inventory_check_items', where: 'check_id = ?', whereArgs: [checkId]);
      for (var item in items) {
        await txn.update('products', {'stock_qty': item['actual_qty']},
            where: 'product_id = ?', whereArgs: [item['product_id']]);
      }
      await txn.update('inventory_checks', {'status': 'Completed'},
          where: 'check_id = ?', whereArgs: [checkId]);
    });
  }

  Future<List<Map<String, dynamic>>> getPendingAdjustments() async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT ic.*, u.full_name as staff_name 
      FROM inventory_checks ic
      JOIN users u ON ic.user_id = u.user_id
      WHERE ic.status = 'Pending'
    ''');
  }

  Future<List<Map<String, dynamic>>> getCheckItems(int checkId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT ici.*, p.name as product_name 
      FROM inventory_check_items ici
      JOIN products p ON ici.product_id = p.product_id
      WHERE ici.check_id = ?
    ''', [checkId]);
  }

  // --- CÁC HÀM NHẬP KHO (INBOUND) ---
  Future<int> createInbound(Map<String, dynamic> inbound, List<Map<String, dynamic>> items) async {
    final db = await dbHelper.database;
    return await db.transaction((txn) async {
      int inboundId = await txn.insert('inventory_inbound', inbound);
      for (var item in items) {
        await txn.insert('inventory_inbound_items', {
          'inbound_id': inboundId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'expiry_date': item['expiry_date'],
          'batch_number': item['batch_number'],
        });
      }
      return inboundId;
    });
  }

  Future<void> approveInbound(int inboundId, int managerId) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.update('inventory_inbound', {'status': 'Approved', 'approved_by': managerId, 'approved_at': DateTime.now().toIso8601String()}, where: 'inbound_id = ?', whereArgs: [inboundId]);
      List<Map<String, dynamic>> items = await txn.query('inventory_inbound_items', where: 'inbound_id = ?', whereArgs: [inboundId]);
      for (var item in items) {
        await txn.rawUpdate('UPDATE products SET stock_qty = stock_qty + ? WHERE product_id = ?', [item['quantity'], item['product_id']]);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getInboundsByStatus(String status) async {
    final db = await dbHelper.database;
    return await db.rawQuery('SELECT ib.*, u.full_name as staff_name FROM inventory_inbound ib LEFT JOIN users u ON ib.user_id = u.user_id WHERE ib.status = ? ORDER BY ib.created_at DESC', [status]);
  }

  Future<List<Map<String, dynamic>>> getInboundItems(int inboundId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('SELECT item.*, p.name as product_name, p.barcode FROM inventory_inbound_items item JOIN products p ON item.product_id = p.product_id WHERE item.inbound_id = ?', [inboundId]);
  }

  Future<void> rejectInbound(int inboundId, String reason) async {
    final db = await dbHelper.database;
    await db.update('inventory_inbound', {'status': 'Rejected', 'notes': reason, 'approved_at': DateTime.now().toIso8601String()}, where: 'inbound_id = ?', whereArgs: [inboundId]);
  }

  // --- CÁC HÀM TIỆN ÍCH ---
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await dbHelper.database;
    return await db.query('products', where: 'is_active = 1');
  }

  Future<List<Map<String, dynamic>>> getLowStockDashboard(int threshold) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT p.*, c.name as category_name 
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.category_id
      WHERE p.stock_qty <= ? AND p.is_active = 1
      ORDER BY p.stock_qty ASC
    ''', [threshold]);
  }
}
