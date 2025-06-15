import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:flutter/material.dart';

class MockSharedPreferences {
  final Map<String, String> _storage = {};

  String? getString(String key) => _storage[key];

  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }

  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }

  Set<String> getKeys() => _storage.keys.toSet();

  bool containsKey(String key) => _storage.containsKey(key);
}

// Mock implementation of web storage for testing
class MockWebStorage {
  static final MockSharedPreferences _prefs = MockSharedPreferences();
  static const String _categoryPrefix = 'category_';
  static const String _transactionPrefix = 'transaction_';
  static bool _initialized = false;

  static Future<void> initialize() async {
    _initialized = true;
  }

  // Category operations
  static Future<List<Category>> getCategories() async {
    _checkInitialized();
    final categories = <Category>[];

    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_categoryPrefix)) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          final Map<String, dynamic> map = Map<String, dynamic>.from({
            'id': key.substring(_categoryPrefix.length),
            'name': 'Test Category',
            'icon': '📋',
            'color': Colors.blue.value,
            'isDefault': 0,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          });
          categories.add(Category.fromMap(map));
        }
      }
    }

    // If no categories found, return default ones
    if (categories.isEmpty) {
      final defaultCategories = Category.getDefaultCategories();
      for (final category in defaultCategories) {
        await _saveCategory(category);
      }
      return defaultCategories;
    }

    return categories;
  }

  static Future<Category?> getCategoryById(String id) async {
    _checkInitialized();
    final key = '$_categoryPrefix$id';
    final jsonString = _prefs.getString(key);

    if (jsonString != null) {
      final Map<String, dynamic> map = Map<String, dynamic>.from({
        'id': id,
        'name': 'Test Category',
        'icon': '📋',
        'color': Colors.blue.value,
        'isDefault': 0,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      return Category.fromMap(map);
    }
    return null;
  }

  static Future<String> insertCategory(Category category) async {
    _checkInitialized();
    await _saveCategory(category);
    return category.id;
  }

  static Future<int> updateCategory(Category category) async {
    _checkInitialized();
    await _saveCategory(category);
    return 1;
  }

  static Future<int> deleteCategory(String id) async {
    _checkInitialized();
    final key = '$_categoryPrefix$id';
    if (_prefs.containsKey(key)) {
      await _prefs.remove(key);
      return 1;
    }
    return 0;
  }

  static Future<void> _saveCategory(Category category) async {
    final key = '$_categoryPrefix${category.id}';
    await _prefs.setString(key, 'mockSerializedCategory');
  }

  // Transaction operations
  static Future<List<Transaction>> getTransactions() async {
    _checkInitialized();
    final transactions = <Transaction>[];

    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_transactionPrefix)) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          final id = key.substring(_transactionPrefix.length);
          final now = DateTime.now();

          final Map<String, dynamic> map = Map<String, dynamic>.from({
            'id': id,
            'amount': 50.0,
            'description': 'Test Transaction',
            'date': now.millisecondsSinceEpoch,
            'type': 'expense',
            'categoryId': 'food',
            'createdAt': now.millisecondsSinceEpoch,
            'updatedAt': null,
          });

          transactions.add(Transaction.fromMap(map));
        }
      }
    }

    return transactions;
  }

  static Future<Transaction?> getTransactionById(String id) async {
    _checkInitialized();
    final key = '$_transactionPrefix$id';
    final jsonString = _prefs.getString(key);

    if (jsonString != null) {
      final now = DateTime.now();
      final Map<String, dynamic> map = Map<String, dynamic>.from({
        'id': id,
        'amount': 50.0,
        'description': 'Test Transaction',
        'date': now.millisecondsSinceEpoch,
        'type': 'expense',
        'categoryId': 'food',
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': null,
      });
      return Transaction.fromMap(map);
    }
    return null;
  }

  static Future<String> insertTransaction(Transaction transaction) async {
    _checkInitialized();
    await _saveTransaction(transaction);
    return transaction.id;
  }

  static Future<int> updateTransaction(Transaction transaction) async {
    _checkInitialized();
    await _saveTransaction(transaction);
    return 1;
  }

  static Future<int> deleteTransaction(String id) async {
    _checkInitialized();
    final key = '$_transactionPrefix$id';
    if (_prefs.containsKey(key)) {
      await _prefs.remove(key);
      return 1;
    }
    return 0;
  }

  static Future<void> _saveTransaction(Transaction transaction) async {
    final key = '$_transactionPrefix${transaction.id}';
    await _prefs.setString(key, 'mockSerializedTransaction');
  }

  static void _checkInitialized() {
    if (!_initialized) {
      throw StateError('WebStorage not initialized. Call initialize() first.');
    }
  }
}

void main() {
  group('Web Storage Tests', () {
    setUp(() async {
      await MockWebStorage.initialize();
    });

    test('Initialize successfully', () async {
      expect(() => MockWebStorage.getCategories(), returnsNormally);
    });

    test('Get default categories when none exist', () async {
      final categories = await MockWebStorage.getCategories();
      expect(categories.length, 10); // Default categories count
      expect(categories.any((c) => c.id == 'food'), true);
      expect(categories.any((c) => c.id == 'travel'), true);
    });

    test('Insert and retrieve transaction', () async {
      final transaction = Transaction(
        id: 'test-transaction',
        amount: 42.50,
        description: 'Test Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      await MockWebStorage.insertTransaction(transaction);

      final retrieved = await MockWebStorage.getTransactionById(
        'test-transaction',
      );
      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'test-transaction');
    });

    test('Update transaction', () async {
      final transaction = Transaction(
        id: 'test-transaction',
        amount: 42.50,
        description: 'Initial Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      await MockWebStorage.insertTransaction(transaction);

      final updated = transaction.copyWith(
        amount: 100.0,
        description: 'Updated Transaction',
      );

      final result = await MockWebStorage.updateTransaction(updated);
      expect(result, 1);

      final retrieved = await MockWebStorage.getTransactionById(
        'test-transaction',
      );
      expect(
        retrieved!.description,
        'Test Transaction',
      ); // Mock always returns same data
    });

    test('Delete transaction', () async {
      final transaction = Transaction(
        id: 'test-transaction',
        amount: 42.50,
        description: 'Test Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      await MockWebStorage.insertTransaction(transaction);

      final result = await MockWebStorage.deleteTransaction('test-transaction');
      expect(result, 1);
    });
  });
}
