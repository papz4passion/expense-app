import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/category.dart';

void main() {
  group('Category Model Tests', () {
    late Category testCategory;

    setUp(() {
      // Create a test category instance for each test
      testCategory = Category(
        id: 'test-id',
        name: 'Test Category',
        icon: '🔍',
        color: Colors.blue,
        isDefault: true,
        createdAt: DateTime(2025, 1, 15),
      );
    });

    test('Category creation', () {
      expect(testCategory.id, 'test-id');
      expect(testCategory.name, 'Test Category');
      expect(testCategory.icon, '🔍');
      expect(testCategory.color, Colors.blue);
      expect(testCategory.isDefault, true);
      expect(testCategory.createdAt, DateTime(2025, 1, 15));
    });

    test('toMap converts Category to correct Map format', () {
      final map = testCategory.toMap();

      expect(map['id'], 'test-id');
      expect(map['name'], 'Test Category');
      expect(map['icon'], '🔍');
      expect(map['color'], Colors.blue.value);
      expect(map['isDefault'], 1);
      expect(map['createdAt'], testCategory.createdAt.millisecondsSinceEpoch);
    });
    test('fromMap creates correct Category object', () {
      final map = {
        'id': 'map-id',
        'name': 'Map Category',
        'icon': '📱',
        'color': Colors.red.value,
        'isDefault': 0,
        'createdAt': DateTime(2025, 2, 20).millisecondsSinceEpoch,
      };

      final category = Category.fromMap(map);

      expect(category.id, 'map-id');
      expect(category.name, 'Map Category');
      expect(category.icon, '📱');
      expect(category.color.value, Colors.red.value);
      expect(category.isDefault, false);
      expect(category.createdAt, DateTime(2025, 2, 20));
    });

    test('copyWith updates specified fields', () {
      final updatedCategory = testCategory.copyWith(
        name: 'Updated Name',
        icon: '🚀',
      );

      // Check updated fields
      expect(updatedCategory.name, 'Updated Name');
      expect(updatedCategory.icon, '🚀');

      // Check preserved fields
      expect(updatedCategory.id, testCategory.id);
      expect(updatedCategory.color, testCategory.color);
      expect(updatedCategory.isDefault, testCategory.isDefault);
      expect(updatedCategory.createdAt, testCategory.createdAt);
    });

    test('equality based on id', () {
      final category1 = Category(
        id: 'same-id',
        name: 'Category 1',
        icon: '🌟',
        color: Colors.green,
        createdAt: DateTime.now(),
      );

      final category2 = Category(
        id: 'same-id',
        name: 'Category 2', // Different name
        icon: '🎵', // Different icon
        color: Colors.purple, // Different color
        createdAt: DateTime.now().add(Duration(days: 1)), // Different date
      );

      // Should be equal because they have the same ID
      expect(category1 == category2, true);
    });

    test('getDefaultCategories returns correct list', () {
      final categories = Category.getDefaultCategories();

      expect(categories.length, 10);

      // Check a few specific categories
      expect(categories.any((c) => c.id == 'food' && c.name == 'Food'), true);
      expect(
        categories.any((c) => c.id == 'travel' && c.name == 'Travel'),
        true,
      );
      expect(
        categories.any((c) => c.id == 'salary' && c.name == 'Salary'),
        true,
      );

      // All should be default categories
      expect(categories.every((c) => c.isDefault), true);
    });
  });
}
