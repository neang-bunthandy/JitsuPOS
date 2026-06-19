import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataLocal {
  static final DataLocal instance = DataLocal._init();
  static Database? _database;

  DataLocal._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('project_pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filepath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost_price REAL NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        option TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_amount REAL NOT NULL,
        total_cost REAL NOT NULL,
        profit REAL NOT NULL,
        sale_date TEXT NOT NULL
      )
    ''');

    // Seed users
    await db.rawInsert(
      "INSERT INTO users (username, password, role) VALUES ('admin', 'admin123', 'admin')",
    );

    debugPrint('Database created and users seeded successfully.');
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await instance.database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<bool> loginUser(String username, String password, String role) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ? AND role = ?',
      whereArgs: [username, password, role],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, double>> getAdminReport() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(total_amount) as total_sales, 
        SUM(profit) as total_profit 
      FROM sales
    ''');

    double sales = 0.0;
    double profit = 0.0;

    if (result.isNotEmpty) {
      sales = (result.first['total_sales'] as num?)?.toDouble() ?? 0.0;
      profit = (result.first['total_profit'] as num?)?.toDouble() ?? 0.0;
    }

    return {'sales': sales, 'profit': profit};
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await instance.database;
    return await db.query('sales', orderBy: 'id DESC');
  }

  Future<void> completeSaleTransaction({
    required double totalAmount,
    required double totalCost,
    required double profit,
    required String saleDate,
    required Map<int, int> soldProducts,
  }) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert('sales', {
        'total_amount': totalAmount,
        'total_cost': totalCost,
        'profit': profit,
        'sale_date': saleDate,
      });

      for (final entry in soldProducts.entries) {
        final productId = entry.key;
        final qtySold = entry.value;
        await txn.rawUpdate(
          'UPDATE products SET quantity = quantity - ? WHERE id = ?',
          [qtySold, productId],
        );
      }
    });
  }

  Future<void> resetSalesDataOnly() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('sales');
      await txn.rawDelete("DELETE FROM sqlite_sequence WHERE name = 'sales'");
    });
  }

  Future<int> updateUserAccount({
    required int id,
    required String newUsername,
    required String newPassword,
  }) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'username': newUsername, 'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> createNewUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final db = await instance.database;
    final checkUser = await getUserByUsername(username);
    if (checkUser != null) {
      return false;
    }

    await db.insert('users', {
      'username': username,
      'password': password,
      'role': role,
    });
    return true;
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await instance.database;
    return await db.query('products', orderBy: 'id DESC');
  }

  Future<int> createNewProduct({
    required String name,
    required double costPrice,
    required double price,
    required int quantity,
    String? option,
  }) async {
    final db = await instance.database;
    return await db.insert('products', {
      'name': name,
      'cost_price': costPrice,
      'price': price,
      'quantity': quantity,
      'option': option,
    });
  }

  Future<int> updateProduct({
    required int id,
    required String name,
    required double costPrice,
    required double price,
    required int quantity,
    String? option,
  }) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {
        'name': name,
        'cost_price': costPrice,
        'price': price,
        'quantity': quantity,
        'option': option,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
