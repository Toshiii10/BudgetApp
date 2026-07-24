// lib/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'transaction.dart' as my_model;

class DatabaseHelper {
  // 1. Create a Singleton (Ensures only one connection exists)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vault_ledger.db');
    return _database!;
  }

  // 2. Locate the phone's hard drive and open the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // 3. Write the SQL to create your table
  Future _createDB(Database db, int version) async {
    // SQLite uses TEXT for Strings, REAL for doubles/decimals
    await db.execute('''
    CREATE TABLE transactions (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      vault TEXT NOT NULL,
      tag TEXT NOT NULL
    )
    ''');
  }

  // 4. CRUD Operations (Create, Read, Delete)
  Future<void> insertTransaction(my_model.Transaction transaction) async {
    final db = await instance.database;
    // Your existing toJson() method perfectly matches SQL column requirements!
    await db.insert('transactions', transaction.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<my_model.Transaction>> fetchAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => my_model.Transaction.fromJson(json)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
  
  // Wipe the whole table (Useful for debugging)
  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('transactions');
  }
}