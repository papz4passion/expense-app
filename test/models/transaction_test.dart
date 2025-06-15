import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    late Transaction testTransaction;
    final testDate = DateTime(2025, 6, 15, 12, 30);
    final testCreatedAt = DateTime(2025, 6, 15, 12, 30);

    setUp(() {
      // Create a test transaction instance for each test
      testTransaction = Transaction(
        id: 'trans-123',
        amount: 42.50,
        description: 'Test Transaction',
        date: testDate,
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: testCreatedAt,
      );
    });

    test('Transaction creation', () {
      expect(testTransaction.id, 'trans-123');
      expect(testTransaction.amount, 42.50);
      expect(testTransaction.description, 'Test Transaction');
      expect(testTransaction.date, testDate);
      expect(testTransaction.type, TransactionType.expense);
      expect(testTransaction.categoryId, 'food');
      expect(testTransaction.createdAt, testCreatedAt);
      expect(testTransaction.updatedAt, null);
    });

    test('toMap converts Transaction to correct Map format', () {
      final map = testTransaction.toMap();

      expect(map['id'], 'trans-123');
      expect(map['amount'], 42.50);
      expect(map['description'], 'Test Transaction');
      expect(map['date'], testDate.millisecondsSinceEpoch);
      expect(map['type'], 'expense');
      expect(map['categoryId'], 'food');
      expect(map['createdAt'], testCreatedAt.millisecondsSinceEpoch);
      expect(map['updatedAt'], null);
    });

    test('fromMap creates correct Transaction object', () {
      final updateDate = DateTime(2025, 6, 16, 9, 0);

      final map = {
        'id': 'map-trans',
        'amount': 100.75,
        'description': 'Map Transaction',
        'date': DateTime(2025, 6, 14).millisecondsSinceEpoch,
        'type': 'income',
        'categoryId': 'salary',
        'createdAt': DateTime(2025, 6, 14, 8, 0).millisecondsSinceEpoch,
        'updatedAt': updateDate.millisecondsSinceEpoch,
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.id, 'map-trans');
      expect(transaction.amount, 100.75);
      expect(transaction.description, 'Map Transaction');
      expect(transaction.date.millisecondsSinceEpoch, map['date']);
      expect(transaction.type, TransactionType.income);
      expect(transaction.categoryId, 'salary');
      expect(transaction.createdAt.millisecondsSinceEpoch, map['createdAt']);
      expect(transaction.updatedAt, updateDate);
    });

    test('fromMap with invalid transaction type defaults to expense', () {
      final map = {
        'id': 'invalid-type',
        'amount': 50.0,
        'description': 'Invalid Type',
        'date': DateTime.now().millisecondsSinceEpoch,
        'type': 'invalid_type',
        'categoryId': 'other',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      final transaction = Transaction.fromMap(map);
      expect(transaction.type, TransactionType.expense);
    });

    test('copyWith updates specified fields', () {
      final updatedTransaction = testTransaction.copyWith(
        amount: 99.99,
        description: 'Updated Description',
        updatedAt: DateTime(2025, 6, 16),
      );

      // Check updated fields
      expect(updatedTransaction.amount, 99.99);
      expect(updatedTransaction.description, 'Updated Description');
      expect(updatedTransaction.updatedAt, DateTime(2025, 6, 16));

      // Check preserved fields
      expect(updatedTransaction.id, testTransaction.id);
      expect(updatedTransaction.date, testTransaction.date);
      expect(updatedTransaction.type, testTransaction.type);
      expect(updatedTransaction.categoryId, testTransaction.categoryId);
      expect(updatedTransaction.createdAt, testTransaction.createdAt);
    });

    test('equality based on id', () {
      final transaction1 = Transaction(
        id: 'same-trans-id',
        amount: 50.0,
        description: 'Transaction 1',
        date: DateTime.now(),
        type: TransactionType.expense,
        categoryId: 'food',
        createdAt: DateTime.now(),
      );

      final transaction2 = Transaction(
        id: 'same-trans-id',
        amount: 100.0, // Different amount
        description: 'Transaction 2', // Different description
        date: DateTime.now().add(Duration(days: 1)), // Different date
        type: TransactionType.income, // Different type
        categoryId: 'travel', // Different category
        createdAt: DateTime.now(),
      );

      // Should be equal because they have the same ID
      expect(transaction1 == transaction2, true);
    });

    test('Transaction toString contains key fields', () {
      final transactionString = testTransaction.toString();

      // Verify the string representation contains key fields
      expect(transactionString.contains('trans-123'), true);
      expect(transactionString.contains('42.5'), true);
      expect(transactionString.contains('Test Transaction'), true);
      expect(transactionString.contains('expense'), true);
      expect(transactionString.contains('food'), true);
    });
  });
}
