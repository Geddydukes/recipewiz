import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';
import '../models/recipe.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore;

  // Default constructor
  ShoppingListService() 
    : _firestore = FirebaseFirestore.instance;
  
  // Constructor with dependency injection for testing
  ShoppingListService.withDependencies({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  // Create a new shopping list
  Future<ShoppingList> createShoppingList(ShoppingList list) async {
    try {
      final docRef = await _firestore.collection('shopping_lists').add(list.toMap());
      
      // Add reference to user's shopping lists
      await _firestore.collection('users').doc(list.userId).update({
        'shoppingLists': FieldValue.arrayUnion([docRef.id]),
      });

      // Fetch the created shopping list
      final doc = await docRef.get();
      return ShoppingList.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  // Create shopping list from recipes
  Future<ShoppingList> createFromRecipes({
    required String userId,
    required String title,
    required List<Recipe> recipes,
  }) async {
    try {
      final list = ShoppingList.fromRecipes(
        userId: userId,
        title: title,
        recipes: recipes,
      );
      
      return await createShoppingList(list);
    } catch (e) {
      rethrow;
    }
  }

  // Get a shopping list by ID
  Future<ShoppingList?> getShoppingList(String id) async {
    try {
      final doc = await _firestore.collection('shopping_lists').doc(id).get();
      if (doc.exists) {
        return ShoppingList.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get shopping lists by user ID
  Stream<List<ShoppingList>> getUserShoppingLists(String userId) {
    return _firestore
        .collection('shopping_lists')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ShoppingList.fromFirestore(doc)).toList());
  }

  // Update a shopping list
  Future<ShoppingList> updateShoppingList(String id, ShoppingList list) async {
    try {
      await _firestore.collection('shopping_lists').doc(id).update(list.toMap());
      
      // Fetch the updated shopping list
      final doc = await _firestore.collection('shopping_lists').doc(id).get();
      return ShoppingList.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a shopping list
  Future<void> deleteShoppingList(String id, String userId) async {
    try {
      await _firestore.collection('shopping_lists').doc(id).delete();
      
      // Remove reference from user's shopping lists
      await _firestore.collection('users').doc(userId).update({
        'shoppingLists': FieldValue.arrayRemove([id]),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Toggle item checked status
  Future<void> toggleItemChecked(
    String listId,
    String itemName,
    bool isChecked,
  ) async {
    try {
      final doc = await _firestore.collection('shopping_lists').doc(listId).get();
      final list = ShoppingList.fromFirestore(doc);
      
      final updatedItems = list.items.map((item) {
        if (item.name == itemName) {
          return ShoppingItem(
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            section: item.section,
            isChecked: isChecked,
          );
        }
        return item;
      }).toList();

      await _firestore.collection('shopping_lists').doc(listId).update({
        'items': updatedItems.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Mark shopping list as completed
  Future<void> markAsCompleted(String id) async {
    try {
      await _firestore.collection('shopping_lists').doc(id).update({
        'isCompleted': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Add items to shopping list
  Future<void> addItems(String id, List<ShoppingItem> newItems) async {
    try {
      final doc = await _firestore.collection('shopping_lists').doc(id).get();
      final list = ShoppingList.fromFirestore(doc);
      
      final Map<String, ShoppingItem> consolidatedItems = {};
      
      // Add existing items
      for (final item in list.items) {
        consolidatedItems['${item.name}_${item.unit}'] = item;
      }
      
      // Add or update with new items
      for (final item in newItems) {
        final key = '${item.name}_${item.unit}';
        if (consolidatedItems.containsKey(key)) {
          consolidatedItems[key]!.quantity += item.quantity;
        } else {
          consolidatedItems[key] = item;
        }
      }

      await _firestore.collection('shopping_lists').doc(id).update({
        'items': consolidatedItems.values.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
