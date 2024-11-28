import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._privateConstructor();
  static Database? _database;

  DBHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'food_ordering.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create food_items table
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');

    // Create order_plans table
    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        items TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final db = await instance.database;

    if (table == 'order_plans') {
      return await db.query(table, orderBy: 'date ASC'); // Sort by date for order_plans
    }

    // If food_items
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryByField(String table, String field, String value) async {
    final db = await instance.database;

    if (table == 'order_plans') {
      // Use LIKE for partial matching, add % on both sides of the value for pattern matching
      return await db.query(
        table,
        where: '$field LIKE ?',
        whereArgs: ['%$value%'],  // % allows partial match before and after the search term
        orderBy: 'date ASC',  // Sorting by date as before
      );
    }

    // If food_items (not used)
    return await db.query(table);
  }

  // Insert into table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert(table, data);
  }

  // Method to update an order plan
  Future<int> update(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      table,
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  // Delete from table
  Future<int> delete(String table, int id) async {
    final db = await instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
