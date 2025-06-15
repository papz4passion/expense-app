import 'dart:convert';
import 'dart:html' as html;
import '../models/transaction.dart' as app_transaction;
import '../models/category.dart' as app_category;

class WebStorage {
  static const String _transactionsKey = 'expense_tracker_transactions';
  static const String _categoriesKey = 'expense_tracker_categories';
  static const String _initialized = 'expense_tracker_initialized';

  static bool get isInitialized {
    return html.window.localStorage[_initialized] == 'true';
  }

  static Future<void> initialize() async {
    if (!isInitialized) {
      // Initialize with default categories
      final defaultCategories = app_category.Category.getDefaultCategories();
      await _saveCategories(defaultCategories);
      html.window.localStorage[_initialized] = 'true';
    }
  }

  // Category operations
  static Future<List<app_category.Category>> getCategories() async {
    final jsonString = html.window.localStorage[_categoriesKey];
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => app_category.Category.fromMap(json)).toList();
  }

  static Future<void> _saveCategories(
    List<app_category.Category> categories,
  ) async {
    final jsonList = categories.map((category) => category.toMap()).toList();
    html.window.localStorage[_categoriesKey] = json.encode(jsonList);
  }

  static Future<app_category.Category?> getCategoryById(String id) async {
    final categories = await getCategories();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Transaction operations
  static Future<List<app_transaction.Transaction>> getTransactions() async {
    final jsonString = html.window.localStorage[_transactionsKey];
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((json) => app_transaction.Transaction.fromMap(json))
        .toList();
  }

  static Future<void> _saveTransactions(
    List<app_transaction.Transaction> transactions,
  ) async {
    final jsonList = transactions
        .map((transaction) => transaction.toMap())
        .toList();
    html.window.localStorage[_transactionsKey] = json.encode(jsonList);
  }

  static Future<String> insertTransaction(
    app_transaction.Transaction transaction,
  ) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await _saveTransactions(transactions);
    return transaction.id;
  }

  static Future<int> updateTransaction(
    app_transaction.Transaction transaction,
  ) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await _saveTransactions(transactions);
      return 1;
    }
    return 0;
  }

  static Future<int> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    final initialLength = transactions.length;
    transactions.removeWhere((t) => t.id == id);
    if (transactions.length < initialLength) {
      await _saveTransactions(transactions);
      return 1;
    }
    return 0;
  }

  static Future<app_transaction.Transaction?> getTransactionById(
    String id,
  ) async {
    final transactions = await getTransactions();
    try {
      return transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}
