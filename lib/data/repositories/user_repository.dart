import '../datasources/local/database_helper.dart';

class UserRepository {
  final dbHelper = DatabaseHelper.instance;

  // lấy info của user theo form login
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await dbHelper.database;
    final res = await db.query('users', where: 'username = ?', whereArgs: [username]);
    return res.isNotEmpty ? res.first : null;
  }

  // Lấy info của user theo email (Dùng cho Forgot Password)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return res.isNotEmpty ? res.first : null;
  }

  // cập nhật token
  Future<void> updateToken(int userId, String token) async {
    final db = await dbHelper.database;
    await db.update('users', {'token': token}, where: 'user_id = ?', whereArgs: [userId]);
  }

  // tạo user mới
  Future<int> createUser(Map<String, dynamic> userData) async {
    final db = await dbHelper.database;
    return await db.insert('users', userData);
  }

  // update lại password
  Future<int> updatePassword(String email, String newPassword) async {
    final db = await dbHelper.database;
    return await db.update(
        'users',
        {'password': newPassword},
        where: 'email = ?',
        whereArgs: [email]
    );
  }
}