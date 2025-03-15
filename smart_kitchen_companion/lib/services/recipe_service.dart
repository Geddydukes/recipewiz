import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe.dart';
import 'gemini_video_service.dart';

class RecipeService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final GeminiVideoService? _geminiVideoService;

  // Default constructor
  RecipeService({String? geminiApiKey}) 
    : _firestore = FirebaseFirestore.instance,
      _storage = FirebaseStorage.instance,
      _geminiVideoService = geminiApiKey != null ? GeminiVideoService(apiKey: geminiApiKey) : null;
  
  // Constructor with dependency injection for testing
  RecipeService.withDependencies({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    GeminiVideoService? geminiVideoService,
  })  : _firestore = firestore,
        _storage = storage,
        _geminiVideoService = geminiVideoService;

  // Create a new recipe
  Future<Recipe> createRecipe(Recipe recipe, File? mediaFile) async {
    try {
      String? mediaUrl;
      
      // Upload media file if provided
      if (mediaFile != null) {
        final storageRef = _storage
            .ref()
            .child('recipes/${recipe.userId}/${DateTime.now().millisecondsSinceEpoch}');
        
        await storageRef.putFile(mediaFile);
        mediaUrl = await storageRef.getDownloadURL();
      }

      // Create recipe document
      final docRef = await _firestore.collection('recipes').add({
        ...recipe.toMap(),
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
      });

      // Fetch the created recipe
      final doc = await docRef.get();
      return Recipe.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  // Get a recipe by ID
  Future<Recipe?> getRecipe(String id) async {
    try {
      final doc = await _firestore.collection('recipes').doc(id).get();
      if (doc.exists) {
        return Recipe.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get recipes by user ID
  Stream<List<Recipe>> getUserRecipes(String userId) {
    return _firestore
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList());
  }

  // Update a recipe
  Future<Recipe> updateRecipe(String id, Recipe recipe, File? mediaFile) async {
    try {
      String? mediaUrl;
      
      // Upload new media file if provided
      if (mediaFile != null) {
        final storageRef = _storage
            .ref()
            .child('recipes/${recipe.userId}/$id');
        
        await storageRef.putFile(mediaFile);
        mediaUrl = await storageRef.getDownloadURL();
      }

      // Update recipe document
      await _firestore.collection('recipes').doc(id).update({
        ...recipe.toMap(),
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
      });

      // Fetch the updated recipe
      final doc = await _firestore.collection('recipes').doc(id).get();
      return Recipe.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String id) async {
    try {
      // Delete media file if exists
      final doc = await _firestore.collection('recipes').doc(id).get();
      final recipe = Recipe.fromFirestore(doc);
      
      if (recipe.mediaUrl.isNotEmpty) {
        await _storage.refFromURL(recipe.mediaUrl).delete();
      }

      // Delete recipe document
      await _firestore.collection('recipes').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Like/unlike a recipe
  Future<void> toggleLike(String recipeId, String userId) async {
    final docRef = _firestore.collection('recipes').doc(recipeId);
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final recipeDoc = await transaction.get(docRef);
      final userDoc = await transaction.get(userRef);

      if (!recipeDoc.exists || !userDoc.exists) {
        throw Exception('Recipe or user not found');
      }

      final likes = List<String>.from(recipeDoc.get('likes') ?? []);
      final favoriteRecipes = List<String>.from(userDoc.get('favoriteRecipes') ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
        favoriteRecipes.remove(recipeId);
      } else {
        likes.add(userId);
        favoriteRecipes.add(recipeId);
      }

      transaction.update(docRef, {'likes': likes});
      transaction.update(userRef, {'favoriteRecipes': favoriteRecipes});
    });
  }

  // Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      // This is a simple search implementation
      // For production, consider using Algolia or ElasticSearch
      final snapshot = await _firestore
          .collection('recipes')
          .where('tags', arrayContains: query.toLowerCase())
          .get();

      return snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get similar recipes
  Future<List<Recipe>> getSimilarRecipes(Recipe recipe) async {
    try {
      // This is a simple implementation
      // For production, consider using a recommendation engine
      final snapshot = await _firestore
          .collection('recipes')
          .where('tags', arrayContainsAny: recipe.tags)
          .limit(5)
          .get();

      return snapshot.docs
          .where((doc) => doc.id != recipe.id)
          .map((doc) => Recipe.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Generate TikTok-style recipe video using Gemini Flash
  Future<String?> generateTikTokStyleVideo(String recipeId) async {
    try {
      // Check if GeminiVideoService was initialized
      if (_geminiVideoService == null) {
        throw Exception('Gemini Video Service not initialized. API key required.');
      }
      
      // Get the recipe
      final recipe = await getRecipe(recipeId);
      if (recipe == null) {
        throw Exception('Recipe not found');
      }
      
      // Generate the video
      final videoUrl = await _geminiVideoService!.generateRecipeVideo(recipe);
      
      // Update the recipe with the video URL
      await _firestore.collection('recipes').doc(recipeId).update({
        'tikTokVideoUrl': videoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return videoUrl;
    } catch (e) {
      rethrow;
    }
  }
}
