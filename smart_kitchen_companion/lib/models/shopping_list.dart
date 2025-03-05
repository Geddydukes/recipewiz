import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe.dart';

class ShoppingList {
  final String id;
  final String userId;
  final String title;
  final List<ShoppingItem> items;
  final double totalCost;
  final DateTime createdAt;
  final bool isCompleted;
  final List<String> recipeIds;

  ShoppingList({
    required this.id,
    required this.userId,
    required this.title,
    required this.items,
    required this.totalCost,
    required this.createdAt,
    required this.isCompleted,
    required this.recipeIds,
  });

  factory ShoppingList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingList(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      items: (data['items'] as List)
          .map((i) => ShoppingItem.fromMap(i))
          .toList(),
      totalCost: data['totalCost'].toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'],
      recipeIds: List<String>.from(data['recipeIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'items': items.map((i) => i.toMap()).toList(),
      'totalCost': totalCost,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
      'recipeIds': recipeIds,
    };
  }

  // Helper method to create a shopping list from multiple recipes
  static ShoppingList fromRecipes({
    required String userId,
    required String title,
    required List<Recipe> recipes,
  }) {
    final Map<String, ShoppingItem> consolidatedItems = {};

    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        final key = '${ingredient.name}_${ingredient.unit}_${ingredient.section}';
        if (consolidatedItems.containsKey(key)) {
          consolidatedItems[key]!.quantity += ingredient.quantity;
        } else {
          consolidatedItems[key] = ShoppingItem(
            name: ingredient.name,
            quantity: ingredient.quantity,
            unit: ingredient.unit,
            section: ingredient.section,
            isChecked: false,
          );
        }
      }
    }

    return ShoppingList(
      id: '', // Will be set by Firestore
      userId: userId,
      title: title,
      items: consolidatedItems.values.toList()
        ..sort((a, b) => a.section.compareTo(b.section)),
      totalCost: 0, // Will need to be calculated
      createdAt: DateTime.now(),
      isCompleted: false,
      recipeIds: recipes.map((r) => r.id).toList(),
    );
  }
}

class ShoppingItem {
  final String name;
  double quantity;
  final String unit;
  final String section;
  bool isChecked;

  ShoppingItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.section,
    required this.isChecked,
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      name: map['name'],
      quantity: map['quantity'].toDouble(),
      unit: map['unit'],
      section: map['section'],
      isChecked: map['isChecked'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'section': section,
      'isChecked': isChecked,
    };
  }
}
