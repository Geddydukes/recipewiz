import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smart_kitchen_companion/services/gemini_video_service.dart';
import 'package:smart_kitchen_companion/models/recipe.dart';

// Generate mocks
@GenerateMocks([
  http.Client,
  FirebaseStorage,
  StorageReference,
  StorageUploadTask,
  StorageTaskSnapshot,
  File,
  Directory,
])
import 'gemini_video_service_test.mocks.dart';

void main() {
  late GeminiVideoService geminiVideoService;
  late MockClient mockHttpClient;
  late MockFirebaseStorage mockStorage;
  late MockStorageReference mockStorageRef;
  late MockFile mockFile;
  late MockDirectory mockTempDir;
  
  const testApiKey = 'test-api-key';

  setUp(() {
    mockHttpClient = MockClient();
    mockStorage = MockFirebaseStorage();
    mockStorageRef = MockStorageReference();
    mockFile = MockFile();
    mockTempDir = MockDirectory();

    // Setup common stubs
    when(mockStorage.ref()).thenReturn(mockStorageRef);
    when(mockStorageRef.child(any)).thenReturn(mockStorageRef);
    when(mockStorageRef.putFile(any)).thenAnswer((_) async => MockStorageUploadTask());
    when(mockStorageRef.getDownloadURL()).thenAnswer((_) async => 'https://example.com/video.mp4');
    
    when(Directory.systemTemp).thenReturn(mockTempDir);
    when(mockTempDir.path).thenReturn('/tmp');
    
    // Use the HttpClient.fromClient constructor to inject the mock client
    geminiVideoService = GeminiVideoService.fromClient(
      apiKey: testApiKey,
      httpClient: mockHttpClient,
      storage: mockStorage,
    );
  });

  group('GeminiVideoService', () {
    test('generateRecipeVideo should call Gemini API and return video URL', () async {
      // Arrange
      final testRecipe = Recipe(
        id: 'test-recipe-id',
        userId: 'test-user-id',
        title: 'Test Recipe',
        description: 'Test Description',
        ingredients: [
          Ingredient(name: 'Test Ingredient', quantity: 1.0, unit: 'cup'),
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

      // Mock HTTP Response
      final mockResponse = http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'videoData': base64Encode([1, 2, 3, 4, 5]), // Dummy base64 video data
                  }
                ]
              }
            }
          ]
        }),
        200,
      );

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockResponse);

      // Mock File operations
      when(File(any)).thenReturn(mockFile);
      when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);
      when(mockFile.delete()).thenAnswer((_) async => true);

      // Act
      final result = await geminiVideoService.generateRecipeVideo(testRecipe);

      // Assert
      expect(result, 'https://example.com/video.mp4');
      
      // Verify API call
      verify(mockHttpClient.post(
        Uri.parse('https://generativeai.googleapis.com/v1beta/models/gemini-flash:generateContent?key=$testApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: any,
      )).called(1);
      
      // Verify Storage operations
      verify(mockStorageRef.putFile(mockFile)).called(1);
      verify(mockStorageRef.getDownloadURL()).called(1);
      verify(mockFile.delete()).called(1);
    });

    test('generateRecipeVideo should throw exception if API call fails', () async {
      // Arrange
      final testRecipe = Recipe(
        id: 'test-recipe-id',
        userId: 'test-user-id',
        title: 'Test Recipe',
        description: 'Test Description',
        ingredients: [
          Ingredient(name: 'Test Ingredient', quantity: 1.0, unit: 'cup'),
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

      // Mock HTTP error response
      final mockErrorResponse = http.Response(
        jsonEncode({'error': 'API Error'}),
        400,
      );

      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => mockErrorResponse);

      // Act & Assert
      expect(
        () => geminiVideoService.generateRecipeVideo(testRecipe),
        throwsException,
      );
    });
  });
} 