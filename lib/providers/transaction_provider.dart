import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/category.dart' as app_category;
import '../database/database_helper.dart';
import 'package:uuid/uuid.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  List<Transaction> _transactions = [];
  List<app_category.Category> _categories = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  List<app_category.Category> get categories => _categories;
  bool get isLoading => _isLoading;

  // Initialize provider and load data
  Future<void> initialize() async {
    await _databaseHelper.ensureInitialized();
    await loadCategories();
    await loadTransactions();
  }

  // Load categories from database
  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      notifyListeners();

      _categories = await _databaseHelper.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load transactions from database
  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();

      _transactions = await _databaseHelper.getTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new transaction
  Future<bool> addTransaction({
    required double amount,
    required String description,
    required DateTime date,
    required TransactionType type,
    required String categoryId,
  }) async {
    try {
      final transaction = Transaction(
        id: _uuid.v4(),
        amount: amount,
        description: description,
        date: date,
        type: type,
        categoryId: categoryId,
        createdAt: DateTime.now(),
      );

      await _databaseHelper.insertTransaction(transaction);
      _transactions.insert(0, transaction);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  // Update existing transaction
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      final updatedTransaction = transaction.copyWith(
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateTransaction(updatedTransaction);

      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      await _databaseHelper.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  // Get transaction by ID
  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by ID
  app_category.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter transactions by category
  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  // Filter transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // Filter transactions by date range
  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get transactions for today
  List<Transaction> getTodayTransactions() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return getTransactionsByDateRange(startOfDay, endOfDay);
  }

  // Get transactions for current month
  List<Transaction> getCurrentMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getTransactionsByDateRange(startOfMonth, endOfMonth);
  }

  // Calculate total balance
  double getTotalBalance() {
    double balance = 0.0;
    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  // Calculate total income
  double getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    var filteredTransactions = _transactions;

    if (startDate != null && endDate != null) {
      filteredTransactions = getTransactionsByDateRange(startDate, endDate);
    }

    return filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Calculate total expenses
  double getTotalExpenses({DateTime? startDate, DateTime? endDate}) {
    var filteredTransactions = _transactions;

    if (startDate != null && endDate != null) {
      filteredTransactions = getTransactionsByDateRange(startDate, endDate);
    }

    return filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Get monthly totals
  Map<String, double> getMonthlyTotals(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final monthlyTransactions = getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    final income = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return {
      'income': income,
      'expense': expenses,
      'balance': income - expenses,
    };
  }
}
