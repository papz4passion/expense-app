import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/transaction.dart';
import '../test_helpers.dart';

void main() {
  setUp(() {
    // Initialize the database for testing
    initializeTestDatabase();
  });

  group('Main App Widget Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify the app builds successfully
      expect(find.byType(MyApp), findsOneWidget);
    });
  });

  group('Simple Navigation Tests', () {
    testWidgets('Home page navigation should work', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify we can see some basic UI elements
      expect(find.text('Expenses'), findsOneWidget);

      // Test that we can open the add transaction button (assuming it uses a FAB)
      final addButton = find.byType(FloatingActionButton);
      expect(addButton, findsOneWidget);
    });
  });

  group('Dashboard Tests', () {
    testWidgets('Dashboard shows appropriate widgets', (
      WidgetTester tester,
    ) async {
      // Build app and navigate to dashboard
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Expect to find balance section
      expect(find.textContaining('Balance'), findsOneWidget);

      // Expect to find transaction list (even if empty)
      expect(find.text('Recent Transactions'), findsOneWidget);
    });
  });

  // Add more UI tests as appropriate for your Phase 1 implementation
}
