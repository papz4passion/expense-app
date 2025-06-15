import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MockDatabaseHelper {
  // In-memory database
  final Map<String, Map<String, dynamic>> _categories = {};
  final Map<String, Map<String, dynamic>> _transactions = {};

  // Constructor with initialization
  MockDatabaseHelper() {
    // Add default categories
    for (final category in Category.getDefaultCategories()) {
      _categories[category.id] = category.toMap();
    }
  }

  // Category operations
  Future<List<Category>> getCategories() async {
    return _categories.values.map((map) => Category.fromMap(map)).toList();
  }

  Future<Category?> getCategoryById(String id) async {
    if (_categories.containsKey(id)) {
      return Category.fromMap(_categories[id]!);
    }
    return null;
  }

  Future<String> insertCategory(Category category) async {
    _categories[category.id] = category.toMap();
    return category.id;
  }

  Future<int> updateCategory(Category category) async {
    if (_categories.containsKey(category.id)) {
      _categories[category.id] = category.toMap();
      return 1;
    }
    return 0;
  }

  Future<int> deleteCategory(String id) async {
    if (_categories.containsKey(id)) {
      _categories.remove(id);
      return 1;
    }
    return 0;
  }

  // Transaction operations
  Future<List<Transaction>> getTransactions({
    int? limit,
    int? offset,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var transactions = _transactions.values
        .map((map) => Transaction.fromMap(map))
        .toList();

    // Apply filters
    if (categoryId != null) {
      transactions = transactions
          .where((t) => t.categoryId == categoryId)
          .toList();
    }

    if (startDate != null) {
      transactions = transactions
          .where(
            (t) => t.date.isAfter(startDate.subtract(const Duration(days: 1))),
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

    // Apply pagination
    if (offset != null) {
      transactions = transactions.skip(offset).toList();
    }

    if (limit != null) {
      transactions = transactions.take(limit).toList();
    }

    return transactions;
  }

  Future<Transaction?> getTransactionById(String id) async {
    if (_transactions.containsKey(id)) {
      return Transaction.fromMap(_transactions[id]!);
    }
    return null;
  }

  Future<String> insertTransaction(Transaction transaction) async {
    _transactions[transaction.id] = transaction.toMap();
    return transaction.id;
  }

  Future<int> updateTransaction(Transaction transaction) async {
    if (_transactions.containsKey(transaction.id)) {
      _transactions[transaction.id] = transaction.toMap();
      return 1;
    }
    return 0;
  }

  Future<int> deleteTransaction(String id) async {
    if (_transactions.containsKey(id)) {
      _transactions.remove(id);
      return 1;
    }
    return 0;
  }

  // Analytics queries
  Future<double> getTotalBalance() async {
    double income = 0;
    double expense = 0;

    for (final map in _transactions.values) {
      final type = map['type'] as String;
      final amount = map['amount'] as double;

      if (type == TransactionType.income.name) {
        income += amount;
      } else if (type == TransactionType.expense.name) {
        expense += amount;
      }
    }

    return income - expense;
  }

  Future<Map<String, double>> getMonthlyTotals(DateTime month) async {
    double income = 0;
    double expense = 0;

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    for (final map in _transactions.values) {
      final type = map['type'] as String;
      final amount = map['amount'] as double;
      final date = DateTime.fromMillisecondsSinceEpoch(map['date'] as int);

      if (date.isAfter(startOfMonth) && date.isBefore(endOfMonth)) {
        if (type == TransactionType.income.name) {
          income += amount;
        } else if (type == TransactionType.expense.name) {
          expense += amount;
        }
      }
    }

    return {'income': income, 'expense': expense};
  }

  Future<double> getDailyTotal(DateTime date) async {
    double netTotal = 0;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    for (final map in _transactions.values) {
      final type = map['type'] as String;
      final amount = map['amount'] as double;
      final transactionDate = DateTime.fromMillisecondsSinceEpoch(
        map['date'] as int,
      );

      if (transactionDate.isAfter(startOfDay) &&
          transactionDate.isBefore(endOfDay)) {
        if (type == TransactionType.income.name) {
          netTotal += amount;
        } else if (type == TransactionType.expense.name) {
          netTotal -= amount;
        }
      }
    }

    return netTotal;
  }
}

void main() {
  group('Mock Database Helper Tests', () {
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
    });

    test('Initial state has default categories', () async {
      final categories = await mockDb.getCategories();
      expect(categories.length, 10);
      expect(categories.any((c) => c.id == 'food'), true);
      expect(categories.any((c) => c.id == 'travel'), true);
    });

    test('Insert and retrieve transaction', () async {
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: 100.0,
        description: 'Test Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      final id = await mockDb.insertTransaction(transaction);
      final retrieved = await mockDb.getTransactionById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.amount, 100.0);
      expect(retrieved.description, 'Test Transaction');
      expect(retrieved.type, TransactionType.expense);
    });

    test('Update transaction', () async {
      // Insert initial transaction
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: 50.0,
        description: 'Initial Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      final id = await mockDb.insertTransaction(transaction);

      // Update it
      final updated = transaction.copyWith(
        amount: 75.0,
        description: 'Updated Transaction',
        type: TransactionType.income,
        updatedAt: DateTime.now(),
      );

      await mockDb.updateTransaction(updated);

      // Retrieve and verify
      final retrieved = await mockDb.getTransactionById(id);
      expect(retrieved!.amount, 75.0);
      expect(retrieved.description, 'Updated Transaction');
      expect(retrieved.type, TransactionType.income);
      expect(retrieved.updatedAt, isNotNull);
    });

    test('Filter transactions by category', () async {
      // Insert transactions with different categories
      final transaction1 = Transaction(
        id: const Uuid().v4(),
        amount: 50.0,
        description: 'Food Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      final transaction2 = Transaction(
        id: const Uuid().v4(),
        amount: 100.0,
        description: 'Travel Transaction',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'travel',
        createdAt: DateTime.now(),
      );

      await mockDb.insertTransaction(transaction1);
      await mockDb.insertTransaction(transaction2);

      // Filter by food category
      final foodTransactions = await mockDb.getTransactions(categoryId: 'food');
      expect(foodTransactions.length, 1);
      expect(foodTransactions.first.description, 'Food Transaction');

      // Filter by travel category
      final travelTransactions = await mockDb.getTransactions(
        categoryId: 'travel',
      );
      expect(travelTransactions.length, 1);
      expect(travelTransactions.first.description, 'Travel Transaction');
    });

    test('Calculate total balance', () async {
      // Insert income and expense transactions
      await mockDb.insertTransaction(
        Transaction(
          id: const Uuid().v4(),
          amount: 1000.0,
          description: 'Salary',
          date: DateTime.now(),
          type: TransactionType.income,
          categoryId: 'salary',
          createdAt: DateTime.now(),
        ),
      );

      await mockDb.insertTransaction(
        Transaction(
          id: const Uuid().v4(),
          amount: 300.0,
          description: 'Rent',
          date: DateTime.now(),
          type: TransactionType.expense,
          categoryId: 'bills',
          createdAt: DateTime.now(),
        ),
      );

      await mockDb.insertTransaction(
        Transaction(
          id: const Uuid().v4(),
          amount: 50.0,
          description: 'Groceries',
          date: DateTime.now(),
          type: TransactionType.expense,
          categoryId: 'food',
          createdAt: DateTime.now(),
        ),
      );

      // Calculate balance
      final balance = await mockDb.getTotalBalance();

      // Expected: 1000 - (300 + 50) = 650
      expect(balance, 650.0);
    });
  });
}
