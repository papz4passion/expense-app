import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/models/category.dart' as app_category;
import 'package:expense_tracker/models/transaction.dart';

/// Initialize the SQLite database for testing
void initializeTestDatabase() {
  // Initialize FFI for SQLite
  sqfliteFfiInit();
  // Set the database factory to use FFI
  databaseFactory = databaseFactoryFfi;
}

/// Mock TransactionProvider for widget tests
class MockTransactionProvider extends TransactionProvider {
  final List<app_category.Category> _mockCategories =
      app_category.Category.getDefaultCategories();
  final List<Transaction> _mockTransactions = [];

  @override
  bool get isLoading => false;

  @override
  List<app_category.Category> get categories => _mockCategories;

  @override
  List<Transaction> get transactions => _mockTransactions;

  // Override initialize to prevent database access
  @override
  Future<void> initialize() async {
    // No database interaction in tests
    notifyListeners();
    return;
  }

  @override
  Future<void> loadCategories() async {
    // Return mock categories instead of database access
    notifyListeners();
    return;
  }

  @override
  Future<void> loadTransactions() async {
    // Return mock transactions instead of database access
    notifyListeners();
    return;
  }

  // Override to add transaction to the mock list
  @override
  Future<bool> addTransaction({
    required double amount,
    required String description,
    required DateTime date,
    required TransactionType type,
    required String categoryId,
  }) async {
    final transaction = Transaction(
      id: 'mock-${_mockTransactions.length}',
      amount: amount,
      description: description,
      date: date,
      type: type,
      categoryId: categoryId,
      createdAt: DateTime.now(),
    );

    _mockTransactions.add(transaction);
    notifyListeners();
    return true;
  }

  // Override other methods that access the database
  @override
  Future<bool> deleteTransaction(String id) async {
    _mockTransactions.removeWhere((t) => t.id == id);
    notifyListeners();
    return true;
  }

  @override
  Future<bool> updateTransaction(Transaction transaction) async {
    final index = _mockTransactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _mockTransactions[index] = transaction;
      notifyListeners();
    }
    return true;
  }

  @override
  app_category.Category? getCategoryById(String id) {
    try {
      return _mockCategories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Build a testable widget wrapped in required providers
Widget buildTestableWidget(Widget widget) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<TransactionProvider>(
        create: (_) => MockTransactionProvider(),
      ),
    ],
    child: MaterialApp(home: widget),
  );
}
