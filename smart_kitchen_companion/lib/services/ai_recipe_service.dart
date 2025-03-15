import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/recipe.dart';

class AIRecipeService {
  final GenerativeModel _model;
  final TextRecognizer _textRecognizer;
  
  AIRecipeService({required String apiKey}) 
      : _model = GenerativeModel(
          model: 'gemini-pro-vision',
          apiKey: apiKey,
        ),
        _textRecognizer = TextRecognizer();

  Future<Recipe?> extractRecipeFromImage(File imageFile) async {
    try {
      // First, try to extract text from the image
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Prepare the prompt for Gemini
      final prompt = '''
      Extract recipe information from the following text and image. 
      Return a JSON object with these fields:
      {
        "title": "Recipe name",
        "description": "Brief description",
        "ingredients": ["List of ingredients with quantities"],
        "instructions": ["Numbered steps"],
        "prepTime": "Preparation time in minutes",
        "cookTime": "Cooking time in minutes",
        "servings": "Number of servings",
        "difficulty": "easy/medium/hard",
        "tags": ["cuisine type", "dietary restrictions", "meal type"]
      }
      
      Text from image:
      ${recognizedText.text}
      ''';

      // Get response from Gemini
      final content = [
        Content.text(prompt),
        Content.image(await imageFile.readAsBytes()),
      ];
      
      final response = await _model.generateContent(content);
      final responseText = response.text;
      
      if (responseText == null) {
        throw Exception('No response from AI model');
      }

      // Parse the JSON response and create a Recipe object
      // TODO: Implement JSON parsing and Recipe creation
      
      return null; // Replace with actual Recipe object
    } catch (e) {
      print('Error extracting recipe: $e');
      return null;
    }
  }

  Future<Recipe?> extractRecipeFromUrl(String url) async {
    try {
      final prompt = '''
      Extract recipe information from this URL: $url
      Return a JSON object with these fields:
      {
        "title": "Recipe name",
        "description": "Brief description",
        "ingredients": ["List of ingredients with quantities"],
        "instructions": ["Numbered steps"],
        "prepTime": "Preparation time in minutes",
        "cookTime": "Cooking time in minutes",
        "servings": "Number of servings",
        "difficulty": "easy/medium/hard",
        "tags": ["cuisine type", "dietary restrictions", "meal type"]
      }
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text;
      
      if (responseText == null) {
        throw Exception('No response from AI model');
      }

      // Parse the JSON response and create a Recipe object
      // TODO: Implement JSON parsing and Recipe creation
      
      return null; // Replace with actual Recipe object
    } catch (e) {
      print('Error extracting recipe from URL: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    _textRecognizer.close();
  }
}
