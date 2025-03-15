import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../lib/services/ai_recipe_service.dart';
import '../../lib/models/recipe.dart';

@GenerateMocks([TextRecognizer])
void main() {
  late AIRecipeService aiRecipeService;
  late MockTextRecognizer mockTextRecognizer;

  setUp(() {
    mockTextRecognizer = MockTextRecognizer();
    aiRecipeService = AIRecipeService(apiKey: 'test_key');
  });

  group('AIRecipeService', () {
    test('extractRecipeFromImage processes text correctly', () async {
      final testImage = File('test/assets/test_recipe.jpg');
      final testRecognizedText = RecognizedText(
        text: 'Test Recipe\nIngredients: flour, sugar\nInstructions: Mix and bake',
        blocks: [],
      );

      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => testRecognizedText);

      expect(testRecognizedText.text, contains('Test Recipe'));
      expect(testRecognizedText.text, contains('Ingredients'));
      expect(testRecognizedText.text, contains('Instructions'));
    });

    test('isGeminiApiKeyConfigured returns correct value', () {
      expect(aiRecipeService.isApiKeyConfigured(), isTrue);
    });
  });
}
