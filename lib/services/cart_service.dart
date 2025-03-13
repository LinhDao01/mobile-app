import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';

class CartDatabase {
  static final CartDatabase instance = CartDatabase._init();
  static Database? _database;

  CartDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cart(
        id TEXT PRIMARY KEY,
        title TEXT,
        imageUrl TEXT,
        quantity INTEGER,
        price REAL
      )
    ''');
  }

  Future<void> insertCartItem(CartItem item) async {
    final db = await instance.database;
    await db.insert('cart', item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await instance.database;
    final result = await db.query('cart');
    return result.map((json) => CartItem.fromJson(json)).toList();
  }

  Future<void> deleteItem(String table, String id) async {
    final db = await instance.database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart() async {
    final db = await instance.database;
    await db.delete('cart');
  }
}
