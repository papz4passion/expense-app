import '../models/transaction.dart' as app_transaction;
import '../models/category.dart' as app_category;

// Stub implementation for non-web platforms
class WebStorage {
  static bool get isInitialized => false;
  static Future<void> initialize() async {}
  static Future<List<app_category.Category>> getCategories() async => [];
  static Future<app_category.Category?> getCategoryById(String id) async =>
      null;
  static Future<List<app_transaction.Transaction>> getTransactions() async =>
      [];
  static Future<String> insertTransaction(
    app_transaction.Transaction transaction,
  ) async => '';
  static Future<int> updateTransaction(
    app_transaction.Transaction transaction,
  ) async => 0;
  static Future<int> deleteTransaction(String id) async => 0;
  static Future<app_transaction.Transaction?> getTransactionById(
    String id,
  ) async => null;
}
