import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('supermarket.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (db) async {
        await db.rawQuery('PRAGMA journal_mode=WAL');
      },
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textUniqueType = 'TEXT NOT NULL UNIQUE';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';

    // 1. Bảng Users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        user_id $idType,
        username $textUniqueType,
        password $textType,
        full_name $textType,
        email TEXT, 
        role $textType,
        is_active $boolType,
        token TEXT 
      )
    ''');

    // 2. Bảng Categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        category_id $idType,
        name $textType,
        description TEXT
      )
    ''');

    // 3. Bảng Products
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        product_id $idType,
        barcode $textUniqueType,
        name $textType,
        category_id $integerType,
        price $doubleType,
        cost_price $doubleType,
        stock_qty INTEGER NOT NULL DEFAULT 0,
        location TEXT,
        image_path TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES categories (category_id)
      )
    ''');

    // 4. Bảng Invoices
    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoices (
        invoice_id $idType,
        user_id $integerType,
        total_amount $doubleType,
        discount $doubleType,
        created_at $textType,
        payment_mode $textType,
        FOREIGN KEY (user_id) REFERENCES users (user_id)
      )
    ''');

    // 5. Bảng InvoiceDetails
    await db.execute('''
      CREATE TABLE IF NOT EXISTS invoice_details (
        detail_id $idType,
        invoice_id $integerType,
        product_id $integerType,
        quantity $integerType,
        unit_price $doubleType,
        sub_total $doubleType,
        FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (product_id)
      )
    ''');

    // 6. Bảng Customers
    await db.execute('''
    CREATE TABLE IF NOT EXISTS customers (
      customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone_number TEXT UNIQUE,
      full_name TEXT,
      loyalty_points INTEGER DEFAULT 0,
      created_at TEXT
    )
  ''');

    // 7. Bảng InventoryInbound
    await db.execute('''
    CREATE TABLE IF NOT EXISTS inventory_inbound (
      inbound_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      approved_by INTEGER,
      status TEXT,
      notes TEXT,               
      created_at TEXT,          
      approved_at TEXT,         
      FOREIGN KEY (user_id) REFERENCES users (user_id),
      FOREIGN KEY (approved_by) REFERENCES users (user_id)
    )
  ''');

    // 8. Bảng InventoryInboundItems
    await db.execute('''
    CREATE TABLE IF NOT EXISTS inventory_inbound_items (
      item_id INTEGER PRIMARY KEY AUTOINCREMENT,
      inbound_id INTEGER,
      product_id INTEGER,
      quantity INTEGER,
      expiry_date TEXT,      
      batch_number TEXT, 
      FOREIGN KEY (inbound_id) REFERENCES inventory_inbound (inbound_id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES products (product_id)
    )
  ''');

    // 9. Bảng InventoryChecks
    await db.execute('''
    CREATE TABLE IF NOT EXISTS inventory_checks (
      check_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      check_date TEXT,
      status TEXT DEFAULT 'Pending',
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
  ''');

    // 10. Bảng InventoryCheckItems
    await db.execute('''
    CREATE TABLE IF NOT EXISTS inventory_check_items (
      check_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
      check_id INTEGER,
      product_id INTEGER,
      system_qty INTEGER,
      actual_qty INTEGER,
      discrepancy INTEGER,
      FOREIGN KEY (check_id) REFERENCES inventory_checks (check_id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES products (product_id)
    )
  ''');

    // 11. Bảng InventoryDisposal
    await db.execute('''
    CREATE TABLE IF NOT EXISTS inventory_disposal (
      disposal_id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER,
      quantity INTEGER,
      reason TEXT,
      created_at TEXT,
      FOREIGN KEY (product_id) REFERENCES products (product_id)
    )
  ''');

    // 12. Bảng Promotions
    await db.execute('''
    CREATE TABLE IF NOT EXISTS promotions (
      promo_id INTEGER PRIMARY KEY AUTOINCREMENT,
      promo_code TEXT UNIQUE,
      discount_percent REAL,
      min_order_value REAL,
      is_active BOOLEAN
    )
  ''');

    await db.insert(
      'users',
      {
        'username': 'admin',
        'password': '123456',
        'full_name': 'System Administrator',
        'email': 'admin@gmail.com',
        'role': 'admin',
        'is_active': 1
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {

  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
