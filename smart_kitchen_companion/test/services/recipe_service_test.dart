import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smart_kitchen_companion/services/recipe_service.dart';
import 'package:smart_kitchen_companion/services/gemini_video_service.dart';
import 'package:smart_kitchen_companion/models/recipe.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  FirebaseStorage,
  DocumentReference,
  CollectionReference,
  DocumentSnapshot,
  Query,
  QuerySnapshot,
  StorageReference,
  StorageTask,
  StorageUploadTask,
  StorageTaskSnapshot,
  GeminiVideoService,
  File
])
import 'recipe_service_test.mocks.dart';

void main() {
  late RecipeService recipeService;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockGeminiVideoService mockGeminiVideoService;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockDocSnapshot;
  late MockCollectionReference mockCollectionRef;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockStorageReference mockStorageRef;
  late MockStorageUploadTask mockUploadTask;
  late MockStorageTaskSnapshot mockTaskSnapshot;
  late MockFile mockFile;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockGeminiVideoService = MockGeminiVideoService();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();
    mockCollectionRef = MockCollectionReference();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    mockStorageRef = MockStorageReference();
    mockUploadTask = MockStorageUploadTask();
    mockTaskSnapshot = MockStorageTaskSnapshot();
    mockFile = MockFile();

    // Setup common stubs
    when(mockFirestore.collection('recipes')).thenReturn(mockCollectionRef);
    when(mockCollectionRef.doc(any)).thenReturn(mockDocRef);
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
    
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.id).thenReturn('test-recipe-id');
    when(mockDocSnapshot.data()).thenReturn({
      'id': 'test-recipe-id',
      'userId': 'test-user-id',
      'title': 'Test Recipe',
      'description': 'Test Description',
      'ingredients': [
        {
          'name': 'Test Ingredient',
          'quantity': 1.0,
          'unit': 'cup',
        }
      ],
      'instructions': ['Step 1', 'Step 2'],
      'sourceType': 'photo',
      'mediaUrl': 'https://example.com/media.jpg',
      'tikTokVideoUrl': '',
      'nutritionalInfo': {
        'calories': 100,
        'protein': 10,
        'carbs': 20,
        'fat': 5
      },
      'estimatedCost': 10.0,
      'tags': ['test', 'recipe'],
      'likes': 0,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });

    // Storage mocks
    when(mockStorage.ref()).thenReturn(mockStorageRef);
    when(mockStorageRef.child(any)).thenReturn(mockStorageRef);
    when(mockStorageRef.putFile(any)).thenAnswer((_) async => mockUploadTask);
    when(mockStorageRef.getDownloadURL()).thenAnswer((_) async => 'https://example.com/media.jpg');

    // Create RecipeService with mocked dependencies
    recipeService = RecipeService.withDependencies(
      firestore: mockFirestore,
      storage: mockStorage,
      geminiVideoService: mockGeminiVideoService,
    );
  });

  group('RecipeService', () {
    test('getRecipe should return recipe on success', () async {
      // Act
      final recipe = await recipeService.getRecipe('test-recipe-id');

      // Assert
      expect(recipe, isNotNull);
      expect(recipe!.id, 'test-recipe-id');
      expect(recipe.title, 'Test Recipe');
      verify(mockFirestore.collection('recipes')).called(1);
      verify(mockCollectionRef.doc('test-recipe-id')).called(1);
      verify(mockDocRef.get()).called(1);
    });

    test('createRecipe should create and return recipe', () async {
      // Arrange
      final newRecipe = Recipe(
        id: '',
        userId: 'test-user-id',
        title: 'New Recipe',
        description: 'New Description',
        ingredients: [
          Ingredient(name: 'New Ingredient', quantity: 2.0, unit: 'tablespoon'),
        ],
        instructions: ['Step 1', 'Step 2'],
        sourceType: MediaType.photo,
        mediaUrl: '',
        nutritionalInfo: NutritionalInfo(calories: 200, protein: 15, carbs: 25, fat: 10),
        estimatedCost: 15.0,
        tags: ['new', 'test'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockCollectionRef.add(any)).thenAnswer((_) async => mockDocRef);

      // Act
      final result = await recipeService.createRecipe(newRecipe, mockFile);

      // Assert
      expect(result, isNotNull);
      expect(result.id, 'test-recipe-id');
      verify(mockStorageRef.putFile(mockFile)).called(1);
      verify(mockCollectionRef.add(any)).called(1);
    });

    test('updateRecipe should update and return recipe', () async {
      // Arrange
      final updatedRecipe = Recipe(
        id: 'test-recipe-id',
        userId: 'test-user-id',
        title: 'Updated Recipe',
        description: 'Updated Description',
        ingredients: [
          Ingredient(name: 'Updated Ingredient', quantity: 3.0, unit: 'teaspoon'),
        ],
        instructions: ['Updated Step 1', 'Updated Step 2'],
        sourceType: MediaType.photo,
        mediaUrl: 'https://example.com/media.jpg',
        nutritionalInfo: NutritionalInfo(calories: 300, protein: 20, carbs: 30, fat: 15),
        estimatedCost: 20.0,
        tags: ['updated', 'test'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final result = await recipeService.updateRecipe('test-recipe-id', updatedRecipe, null);

      // Assert
      expect(result, isNotNull);
      expect(result.id, 'test-recipe-id');
      verify(mockDocRef.update(any)).called(1);
    });

    test('deleteRecipe should delete recipe and media', () async {
      // Act
      await recipeService.deleteRecipe('test-recipe-id');

      // Assert
      verify(mockDocRef.delete()).called(1);
      // Verify media file deletion if needed
    });

    test('generateTikTokStyleVideo should call GeminiVideoService and update recipe', () async {
      // Arrange
      when(mockGeminiVideoService.generateRecipeVideo(any))
          .thenAnswer((_) async => 'https://example.com/tiktok_video.mp4');

      // Act
      final videoUrl = await recipeService.generateTikTokStyleVideo('test-recipe-id');

      // Assert
      expect(videoUrl, 'https://example.com/tiktok_video.mp4');
      verify(mockGeminiVideoService.generateRecipeVideo(any)).called(1);
      verify(mockDocRef.update({
        'tikTokVideoUrl': 'https://example.com/tiktok_video.mp4',
        'updatedAt': any,
      })).called(1);
    });

    test('generateTikTokStyleVideo should throw if recipe not found', () async {
      // Arrange
      when(mockDocSnapshot.exists).thenReturn(false);

      // Act & Assert
      expect(
        () => recipeService.generateTikTokStyleVideo('non-existent-id'),
        throwsException,
      );
    });
  });
} 