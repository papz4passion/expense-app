// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';
import 'test_helpers.dart';

void main() {
  setUp(() {
    // Initialize the database for testing
    initializeTestDatabase();
  });

  testWidgets('App loads with bottom navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Allow animations to complete
    await tester.pumpAndSettle();

    // Verify that the app shows a bottom navigation bar
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify the navigation bar has the expected labels
    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Transactions'), findsAtLeastNWidgets(1));
  });
}
