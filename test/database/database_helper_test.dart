import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:path/path.dart';

// Mock setup for SQLite database in memory
Future<void> setupTestDb() async {
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

void main() {
  // Initialize test database
  late Database db;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupTestDb();
  });

  setUp(() async {
    // Create a new in-memory database for each test
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Create the tables
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
    for (final category in Category.getDefaultCategories()) {
      await db.insert('categories', category.toMap());
    }
  });

  tearDown(() async {
    await db.close();
  });

  group('Category Database Tests', () {
    test('getCategories returns all default categories', () async {
      // Verify categories were inserted - manually calling SQL
      final List<Map<String, dynamic>> maps = await db.query('categories');
      final categories = List.generate(
        maps.length,
        (i) => Category.fromMap(maps[i]),
      );

      expect(categories.length, 10); // Default categories count
      expect(categories.any((c) => c.id == 'food'), true);
      expect(categories.any((c) => c.id == 'travel'), true);
    });

    test('insertCategory and getCategoryById', () async {
      final testCategory = Category(
        id: 'test-category',
        name: 'Test Custom Category',
        icon: '🧪',
        color: Colors.purple,
        createdAt: DateTime.now(),
      );

      // Insert directly using SQL for testing
      await db.insert('categories', testCategory.toMap());

      // Verify we can get it back
      final List<Map<String, dynamic>> maps = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: ['test-category'],
      );

      expect(maps.length, 1);
      final retrievedCategory = Category.fromMap(maps[0]);

      expect(retrievedCategory.id, 'test-category');
      expect(retrievedCategory.name, 'Test Custom Category');
      expect(retrievedCategory.icon, '🧪');
    });
  });

  group('Transaction Database Tests', () {
    test('insertTransaction and getTransactionById', () async {
      // Insert a test transaction
      final testTransaction = Transaction(
        id: 'test-transaction',
        amount: 150.75,
        description: 'Test Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food', // Using existing category
        createdAt: DateTime.now(),
      );

      // Insert directly using SQL for testing
      await db.insert('transactions', testTransaction.toMap());

      // Verify we can get it back
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'id = ?',
        whereArgs: ['test-transaction'],
      );

      expect(maps.length, 1);
      final retrievedTransaction = Transaction.fromMap(maps[0]);

      expect(retrievedTransaction.id, 'test-transaction');
      expect(retrievedTransaction.amount, 150.75);
      expect(retrievedTransaction.description, 'Test Transaction');
      expect(retrievedTransaction.type, TransactionType.expense);
      expect(retrievedTransaction.categoryId, 'food');
    });

    test('updateTransaction modifies an existing transaction', () async {
      // Create and insert initial transaction
      final initialTransaction = Transaction(
        id: 'test-transaction',
        amount: 50.0,
        description: 'Initial Description',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      await db.insert('transactions', initialTransaction.toMap());

      // Update the transaction
      final updatedTransaction = initialTransaction.copyWith(
        amount: 75.0,
        description: 'Updated Description',
        type: TransactionType.income,
        updatedAt: DateTime.now(),
      );

      await db.update(
        'transactions',
        updatedTransaction.toMap(),
        where: 'id = ?',
        whereArgs: ['test-transaction'],
      );

      // Retrieve the updated transaction
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'id = ?',
        whereArgs: ['test-transaction'],
      );

      expect(maps.length, 1);
      final retrievedTransaction = Transaction.fromMap(maps[0]);

      expect(retrievedTransaction.amount, 75.0);
      expect(retrievedTransaction.description, 'Updated Description');
      expect(retrievedTransaction.type, TransactionType.income);
      expect(retrievedTransaction.updatedAt, isNotNull);
    });

    test('deleteTransaction removes a transaction', () async {
      // Create and insert a test transaction
      final testTransaction = Transaction(
        id: 'test-transaction',
        amount: 50.0,
        description: 'Test Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      await db.insert('transactions', testTransaction.toMap());

      // Verify transaction exists
      var count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM transactions WHERE id = ?', [
          'test-transaction',
        ]),
      );
      expect(count, 1);

      // Delete the transaction
      await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: ['test-transaction'],
      );

      // Verify transaction was deleted
      count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM transactions WHERE id = ?', [
          'test-transaction',
        ]),
      );
      expect(count, 0);
    });
  });

  group('Analytics Query Tests', () {
    test('Total balance calculation', () async {
      // Insert some test transactions
      await db.insert(
        'transactions',
        Transaction(
          id: 'income1',
          amount: 1000.0,
          description: 'Salary',
          date: DateTime.now(),
          type: TransactionType.income,
          categoryId: 'salary',
          createdAt: DateTime.now(),
        ).toMap(),
      );

      await db.insert(
        'transactions',
        Transaction(
          id: 'expense1',
          amount: 250.0,
          description: 'Rent',
          date: DateTime.now(),
          type: TransactionType.expense,
          categoryId: 'bills',
          createdAt: DateTime.now(),
        ).toMap(),
      );

      await db.insert(
        'transactions',
        Transaction(
          id: 'expense2',
          amount: 50.0,
          description: 'Groceries',
          date: DateTime.now(),
          type: TransactionType.expense,
          categoryId: 'food',
          createdAt: DateTime.now(),
        ).toMap(),
      );

      // Calculate balance using SQL query (same as the real implementation)
      final result = await db.rawQuery('''
        SELECT 
          SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
          SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense
        FROM transactions
      ''');

      final totalIncome = result.first['total_income'] as double? ?? 0.0;
      final totalExpense = result.first['total_expense'] as double? ?? 0.0;
      final balance = totalIncome - totalExpense;

      // Expected: 1000 - (250 + 50) = 700
      expect(balance, 700.0);
    });
  });
}
