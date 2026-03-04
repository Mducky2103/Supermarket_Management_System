import '../datasources/local/database_helper.dart';

class CategoryRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await dbHelper.database;
    return await db.query('categories');
  }

  Future<int> insertCategory(String name) async {
    final db = await dbHelper.database;
    return await db.insert('categories', {'name': name});
  }

  Future<int> updateCategory(int id, String name) async {
    final db = await dbHelper.database;
    return await db.update('categories', {'name': name}, where: 'category_id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await dbHelper.database;
    return await db.delete('categories', where: 'category_id = ?', whereArgs: [id]);
  }
}