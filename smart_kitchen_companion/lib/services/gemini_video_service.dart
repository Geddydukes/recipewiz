import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe.dart';

class GeminiVideoService {
  final FirebaseStorage _storage;
  final String _apiKey; // API key for Gemini Flash
  final String _apiEndpoint = 'https://generativeai.googleapis.com/v1beta/models/gemini-flash:generateContent';
  final http.Client _httpClient;
  
  // Default constructor
  GeminiVideoService({required String apiKey}) 
    : _apiKey = apiKey,
      _storage = FirebaseStorage.instance,
      _httpClient = http.Client();
  
  // Constructor with dependency injection for testing
  GeminiVideoService.fromClient({
    required String apiKey,
    required http.Client httpClient,
    required FirebaseStorage storage,
  })  : _apiKey = apiKey,
        _storage = storage,
        _httpClient = httpClient;

  /// Generates a TikTok-style recipe video using Google Gemini Flash 2.0
  /// 
  /// Takes a recipe object and creates a viral-style short video showing
  /// the preparation process. Returns the URL of the generated video.
  Future<String> generateRecipeVideo(Recipe recipe) async {
    try {
      // 1. Prepare the prompt for Gemini Flash
      final prompt = _buildVideoPrompt(recipe);
      
      // 2. Make API request to Gemini Flash
      final videoData = await _callGeminiFlashAPI(prompt);
      
      // 3. Save video to temporary file
      final tempFile = await _saveTempVideo(videoData);
      
      // 4. Upload to Firebase Storage
      return await _uploadVideoToStorage(tempFile, recipe.id);
    } catch (e) {
      throw Exception('Failed to generate recipe video: $e');
    }
  }

  /// Builds a detailed prompt for Gemini Flash to generate a TikTok-style recipe video
  String _buildVideoPrompt(Recipe recipe) {
    final ingredients = recipe.ingredients.map((ing) => '${ing.quantity} ${ing.unit} ${ing.name}').join(', ');
    
    return '''
    Create a viral TikTok-style recipe video for: ${recipe.title}
    
    Description: ${recipe.description}
    
    Ingredients:
    $ingredients
    
    Instructions:
    ${recipe.instructions.join('\n')}
    
    Style guidance:
    - Fast-paced, engaging edits
    - Bright, colorful presentation
    - Overhead shots of food preparation
    - Close-ups of final dish
    - Use trending music and visual effects
    - Include text overlays for ingredients and key steps
    - Keep video between 30-60 seconds
    - End with a satisfying reveal of the finished dish
    ''';
  }

  /// Makes the API call to Gemini Flash and returns the video data
  Future<List<int>> _callGeminiFlashAPI(String prompt) async {
    final response = await _httpClient.post(
      Uri.parse('$_apiEndpoint?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text': prompt
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.9,
          'mediaType': 'video/mp4',
          'videoDurationSeconds': 45,
          'style': 'tiktok-recipe'
        }
      }),
    );

    if (response.statusCode == 200) {
      // Parse response to extract video data
      // This is a simplified version - actual response structure may vary
      final jsonResponse = jsonDecode(response.body);
      final base64Video = jsonResponse['candidates'][0]['content']['parts'][0]['videoData'];
      return base64Decode(base64Video);
    } else {
      throw Exception('Failed to generate video: ${response.statusCode} ${response.body}');
    }
  }

  /// Saves video data to a temporary file
  Future<File> _saveTempVideo(List<int> videoData) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.mp4');
    await tempFile.writeAsBytes(videoData);
    return tempFile;
  }

  /// Uploads the video to Firebase Storage and returns the download URL
  Future<String> _uploadVideoToStorage(File videoFile, String recipeId) async {
    final storageRef = _storage
        .ref()
        .child('recipe_videos/$recipeId/${DateTime.now().millisecondsSinceEpoch}.mp4');
    
    await storageRef.putFile(videoFile);
    final downloadUrl = await storageRef.getDownloadURL();
    
    // Delete the temporary file
    await videoFile.delete();
    
    return downloadUrl;
  }
} 