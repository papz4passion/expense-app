import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/category.dart' as app_category;
import 'web_storage.dart' if (dart.library.io) 'web_storage_stub.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite database not supported on web');
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> ensureInitialized() async {
    if (kIsWeb) {
      await WebStorage.initialize();
    } else {
      await database; // Initialize SQLite database
    }
  }

  Future<Database> _initDatabase() async {
    // Initialize database factory for web
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'expense_tracker.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date INTEGER NOT NULL,
        type TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Insert default categories
    final defaultCategories = app_category.Category.getDefaultCategories();
    for (final category in defaultCategories) {
      await db.insert('categories', category.toMap());
    }
  }

  // Category CRUD operations
  Future<List<app_category.Category>> getCategories() async {
    if (kIsWeb) {
      return await WebStorage.getCategories();
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(
      maps.length,
      (i) => app_category.Category.fromMap(maps[i]),
    );
  }

  Future<app_category.Category?> getCategoryById(String id) async {
    if (kIsWeb) {
      return await WebStorage.getCategoryById(id);
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return app_category.Category.fromMap(maps.first);
    }
    return null;
  }

  Future<String> insertCategory(app_category.Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap());
    return category.id;
  }

  Future<int> updateCategory(app_category.Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction CRUD operations
  Future<List<app_transaction.Transaction>> getTransactions({
    int? limit,
    int? offset,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kIsWeb) {
      // For web, get all transactions and apply filters in memory
      var transactions = await WebStorage.getTransactions();

      // Apply filters
      if (categoryId != null) {
        transactions = transactions
            .where((t) => t.categoryId == categoryId)
            .toList();
      }
      if (startDate != null) {
        transactions = transactions
            .where(
              (t) =>
                  t.date.isAfter(startDate.subtract(const Duration(days: 1))),
            )
            .toList();
      }
      if (endDate != null) {
        transactions = transactions
            .where((t) => t.date.isBefore(endDate.add(const Duration(days: 1))))
            .toList();
      }

      // Sort by date descending
      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Apply limit and offset
      if (offset != null) {
        transactions = transactions.skip(offset).toList();
      }
      if (limit != null) {
        transactions = transactions.take(limit).toList();
      }

      return transactions;
    }

    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (categoryId != null) {
      whereClause += 'categoryId = ?';
      whereArgs.add(categoryId);
    }

    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(
      maps.length,
      (i) => app_transaction.Transaction.fromMap(maps[i]),
    );
  }

  Future<app_transaction.Transaction?> getTransactionById(String id) async {
    if (kIsWeb) {
      return await WebStorage.getTransactionById(id);
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return app_transaction.Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<String> insertTransaction(
    app_transaction.Transaction transaction,
  ) async {
    if (kIsWeb) {
      return await WebStorage.insertTransaction(transaction);
    }
    final db = await database;
    await db.insert('transactions', transaction.toMap());
    return transaction.id;
  }

  Future<int> updateTransaction(app_transaction.Transaction transaction) async {
    if (kIsWeb) {
      return await WebStorage.updateTransaction(transaction);
    }
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    if (kIsWeb) {
      return await WebStorage.deleteTransaction(id);
    }
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Analytics queries for dashboard
  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense
      FROM transactions
    ''');

    if (result.isNotEmpty) {
      final totalIncome = result.first['total_income'] as double? ?? 0.0;
      final totalExpense = result.first['total_expense'] as double? ?? 0.0;
      return totalIncome - totalExpense;
    }
    return 0.0;
  }

  Future<Map<String, double>> getMonthlyTotals(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      '''
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense
      FROM transactions
      WHERE date >= ? AND date <= ?
    ''',
      [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch],
    );

    if (result.isNotEmpty) {
      final totalIncome = result.first['total_income'] as double? ?? 0.0;
      final totalExpense = result.first['total_expense'] as double? ?? 0.0;
      return {'income': totalIncome, 'expense': totalExpense};
    }
    return {'income': 0.0, 'expense': 0.0};
  }

  Future<double> getDailyTotal(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.rawQuery(
      '''
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as net_total
      FROM transactions
      WHERE date >= ? AND date <= ?
    ''',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );

    if (result.isNotEmpty) {
      return result.first['net_total'] as double? ?? 0.0;
    }
    return 0.0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
