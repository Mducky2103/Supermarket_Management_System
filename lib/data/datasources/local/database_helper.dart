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
      version: 5,
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
      CREATE TABLE users (
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
      CREATE TABLE categories (
        category_id $idType,
        name $textType,
        description TEXT
      )
    ''');

    // 3. Bảng Products
    await db.execute('''
      CREATE TABLE products (
        product_id $idType,
        barcode $textUniqueType,
        name $textType,
        category_id $integerType,
        price $doubleType,
        cost_price $doubleType,
        stock_qty $integerType,
        image_path TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES categories (category_id)
      )
    ''');

    // 4. Bảng Invoices
    await db.execute('''
      CREATE TABLE invoices (
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
      CREATE TABLE invoice_details (
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

    // 6. Bảng Customers (Quản lý khách hàng & Loyalty)
    await db.execute('''
    CREATE TABLE customers (
      customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone_number TEXT UNIQUE,
      full_name TEXT,
      loyalty_points INTEGER DEFAULT 0,
      created_at TEXT
    )
  ''');

    // 7. Bảng InventoryInbound (Nhập kho)
    await db.execute('''
    CREATE TABLE inventory_inbound (
      inbound_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,          -- Người tạo (Warehouse Staff)
      approved_by INTEGER,      -- Người duyệt (Manager)
      status TEXT,              -- Pending, Approved, Rejected
      notes TEXT,               
      created_at TEXT,          
      approved_at TEXT,         
      FOREIGN KEY (user_id) REFERENCES users (user_id),
      FOREIGN KEY (approved_by) REFERENCES users (user_id)
    )
  ''');

    // 8. Bảng InventoryInboundItems (Chi tiết phiếu nhập)
    await db.execute('''
    CREATE TABLE inventory_inbound_items (
      item_id INTEGER PRIMARY KEY AUTOINCREMENT,
      inbound_id INTEGER,       -- Liên kết với phiếu nhập bên trên
      product_id INTEGER,       -- Sản phẩm nào
      quantity INTEGER,         -- Số lượng nhập vào
      FOREIGN KEY (inbound_id) REFERENCES inventory_inbound (inbound_id),
      FOREIGN KEY (product_id) REFERENCES products (product_id)
    )
  ''');

    // 9. Bảng Promotions (Khuyến mãi)
    await db.execute('''
    CREATE TABLE promotions (
      promo_id INTEGER PRIMARY KEY AUTOINCREMENT,
      promo_code TEXT UNIQUE,
      discount_percent REAL,
      min_order_value REAL,
      is_active BOOLEAN
    )
  ''');

    // Chèn dữ liệu mẫu cho Admin
    await db.rawInsert(
        'INSERT INTO users(username, password, full_name, email, role, is_active) VALUES(?, ?, ?, ?, ?, ?)',
        ['admin', 'admin123', 'System Administrator', 'ducminh211103@gmail.com', 'admin', 1]
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN token TEXT');
    }
    if (oldVersion < 3) {
      // Thêm cột email vào bảng users nếu đang ở version cũ hơn 3
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
      print("Database upgraded: Added email column to users table");
    }
    if (oldVersion < 4 ) {
      try {
        await db.execute('ALTER TABLE products ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
        print("Đã thêm cột is_active thành công!");
      } catch (e) {
        print("Cột đã tồn tại hoặc có lỗi: $e");
      }
    }
    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE inventory_inbound ADD COLUMN approved_by INTEGER');
        await db.execute('ALTER TABLE inventory_inbound ADD COLUMN notes TEXT');
        await db.execute('ALTER TABLE inventory_inbound ADD COLUMN approved_at TEXT');

        print("Đã bổ sung các cột approved_by, notes, approved_at vào inventory_inbound");

        await db.execute('''
        CREATE TABLE inventory_inbound_items (
          item_id INTEGER PRIMARY KEY AUTOINCREMENT,
          inbound_id INTEGER,
          product_id INTEGER,
          quantity INTEGER NOT NULL,
          FOREIGN KEY (inbound_id) REFERENCES inventory_inbound (inbound_id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES products (product_id)
        )
      ''');

        print("Đã tạo bảng chi tiết inventory_inbound_items");
      } catch (e) {
        print("Lỗi khi nâng cấp bảng kho hàng: $e");
      }
    }
  }

  // Đóng kết nối
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}