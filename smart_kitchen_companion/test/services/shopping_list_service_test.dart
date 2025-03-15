import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_kitchen_companion/services/shopping_list_service.dart';
import 'package:smart_kitchen_companion/models/shopping_list.dart';
import 'package:smart_kitchen_companion/models/recipe.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  DocumentReference,
  CollectionReference,
  DocumentSnapshot,
  Query,
  QuerySnapshot,
])
import 'shopping_list_service_test.mocks.dart';

void main() {
  late ShoppingListService shoppingListService;
  late MockFirebaseFirestore mockFirestore;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockDocSnapshot;
  late MockCollectionReference mockCollectionRef;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();
    mockCollectionRef = MockCollectionReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();

    // Setup common stubs
    when(mockFirestore.collection('shopping_lists')).thenReturn(mockCollectionRef);
    when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
    
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.id).thenReturn('test-shopping-list-id');
    when(mockDocSnapshot.data()).thenReturn({
      'id': 'test-shopping-list-id',
      'userId': 'test-user-id',
      'name': 'Test Shopping List',
      'items': [
        {
          'name': 'Test Item',
          'quantity': 1.0,
          'unit': 'piece',
          'category': 'produce',
          'isChecked': false,
          'price': 3.99,
        }
      ],
      'totalCost': 3.99,
      'isCompleted': false,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });

    // Create ShoppingListService with mocked dependencies
    shoppingListService = ShoppingListService.withDependencies(
      firestore: mockFirestore,
    );
  });

  group('ShoppingListService', () {
    test('getShoppingList should return shopping list on success', () async {
      // Act
      final shoppingList = await shoppingListService.getShoppingList('test-shopping-list-id');

      // Assert
      expect(shoppingList, isNotNull);
      expect(shoppingList!.id, 'test-shopping-list-id');
      expect(shoppingList.name, 'Test Shopping List');
      verify(mockFirestore.collection('shopping_lists')).called(1);
      verify(mockCollectionRef.doc('test-shopping-list-id')).called(1);
      verify(mockDocRef.get()).called(1);
    });

    test('createShoppingList should create and return shopping list', () async {
      // Arrange
      final newShoppingList = ShoppingList(
        id: '',
        userId: 'test-user-id',
        name: 'New Shopping List',
        items: [
          ShoppingItem(
            name: 'New Item',
            quantity: 2.0,
            unit: 'kg',
            category: 'dairy',
            isChecked: false,
            price: 5.99,
          ),
        ],
        totalCost: 5.99,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockCollectionRef.add(any)).thenAnswer((_) async => mockDocRef);

      // Act
      final result = await shoppingListService.createShoppingList(newShoppingList);

      // Assert
      expect(result, isNotNull);
      expect(result.id, 'test-shopping-list-id');
      verify(mockCollectionRef.add(any)).called(1);
    });

    test('updateShoppingList should update and return shopping list', () async {
      // Arrange
      final updatedShoppingList = ShoppingList(
        id: 'test-shopping-list-id',
        userId: 'test-user-id',
        name: 'Updated Shopping List',
        items: [
          ShoppingItem(
            name: 'Updated Item',
            quantity: 3.0,
            unit: 'box',
            category: 'pantry',
            isChecked: true,
            price: 7.99,
          ),
        ],
        totalCost: 7.99,
        isCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await shoppingListService.updateShoppingList(updatedShoppingList);

      // Assert
      expect(result, isNotNull);
      expect(result.id, 'test-shopping-list-id');
      verify(mockDocRef.update(any)).called(1);
    });

    test('deleteShoppingList should delete shopping list', () async {
      // Act
      await shoppingListService.deleteShoppingList('test-shopping-list-id');

      // Assert
      verify(mockDocRef.delete()).called(1);
    });

    test('getUserShoppingLists should return user shopping lists', () async {
      // Arrange
      final mockQueryDocSnapshot = MockDocumentSnapshot();
      when(mockQueryDocSnapshot.id).thenReturn('test-shopping-list-id');
      when(mockQueryDocSnapshot.data()).thenReturn({
        'id': 'test-shopping-list-id',
        'userId': 'test-user-id',
        'name': 'Test Shopping List',
        'items': [],
        'totalCost': 0.0,
        'isCompleted': false,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      when(mockCollectionRef.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
      when(mockQuery.orderBy('createdAt', descending: true)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocSnapshot]);

      // Act
      final result = await shoppingListService.getUserShoppingLists('test-user-id');

      // Assert
      expect(result, isNotNull);
      expect(result.length, 1);
      expect(result[0].id, 'test-shopping-list-id');
      verify(mockCollectionRef.where('userId', isEqualTo: 'test-user-id')).called(1);
    });

    test('generateFromRecipe should create shopping list from recipe', () async {
      // Arrange
      final recipe = Recipe(
        id: 'test-recipe-id',
        userId: 'test-user-id',
        title: 'Test Recipe',
        description: 'Test Description',
        ingredients: [
          Ingredient(name: 'Test Ingredient', quantity: 2.0, unit: 'cup'),
        ],
        instructions: ['Step 1', 'Step 2'],
        sourceType: MediaType.photo,
        mediaUrl: 'https://example.com/media.jpg',
        nutritionalInfo: NutritionalInfo(calories: 100, protein: 10, carbs: 20, fat: 5),
        estimatedCost: 10.0,
        tags: ['test', 'recipe'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockCollectionRef.add(any)).thenAnswer((_) async => mockDocRef);

      // Act
      final result = await shoppingListService.generateFromRecipe(recipe, 'New Shopping List');

      // Assert
      expect(result, isNotNull);
      expect(result.id, 'test-shopping-list-id');
      expect(result.items.length, 1);
      verify(mockCollectionRef.add(any)).called(1);
    });
  });
} 