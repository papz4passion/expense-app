import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final bool isDefault;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'isDefault': isDefault ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map (database)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: Color(map['color']),
      isDefault: map['isDefault'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create a copy with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, color: $color, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Predefined categories for Phase 1
  static List<Category> getDefaultCategories() {
    final now = DateTime.now();
    return [
      Category(
        id: 'food',
        name: 'Food',
        icon: '🍔',
        color: Colors.orange,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'travel',
        name: 'Travel',
        icon: '✈️',
        color: Colors.blue,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        icon: '🛍️',
        color: Colors.pink,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'bills',
        name: 'Bills',
        icon: '📄',
        color: Colors.red,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'entertainment',
        name: 'Entertainment',
        icon: '🎬',
        color: Colors.purple,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'health',
        name: 'Health',
        icon: '🏥',
        color: Colors.green,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'education',
        name: 'Education',
        icon: '📚',
        color: Colors.indigo,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'other',
        name: 'Other',
        icon: '📦',
        color: Colors.grey,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'salary',
        name: 'Salary',
        icon: '💰',
        color: Colors.green,
        isDefault: true,
        createdAt: now,
      ),
      Category(
        id: 'investment',
        name: 'Investment',
        icon: '📈',
        color: Colors.teal,
        isDefault: true,
        createdAt: now,
      ),
    ];
  }
}
