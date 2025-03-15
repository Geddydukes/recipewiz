import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SubscriptionTier {
  free,
  premium,
}

class FeatureFlagService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Free features
  static const Map<String, dynamic> freeFeatures = {
    'manual_recipe_entry': true,
    'basic_shopping_list': true,
    'basic_community': true,
    'recipe_limit': 10,
    'ai_recipe_limit': 0,
  };

  // Premium features
  static const Map<String, dynamic> premiumFeatures = {
    'manual_recipe_entry': true,
    'basic_shopping_list': true,
    'basic_community': true,
    'advanced_shopping_list': true,
    'meal_planning': true,
    'recipe_sharing': true,
    'ai_recipe_extraction': true,
    'recipe_limit': -1, // unlimited
    'ai_recipe_limit': -1, // unlimited
  };

  // Get current user's subscription tier
  Future<SubscriptionTier> getCurrentTier() async {
    final user = _auth.currentUser;
    if (user == null) return SubscriptionTier.free;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('subscription')
        .doc('status')
        .get();

    if (!doc.exists) return SubscriptionTier.free;

    return doc.data()?['tier'] == 'premium'
        ? SubscriptionTier.premium
        : SubscriptionTier.free;
  }

  // Check if a specific feature is available
  Future<bool> isFeatureAvailable(String featureKey) async {
    final tier = await getCurrentTier();
    final features = tier == SubscriptionTier.premium ? premiumFeatures : freeFeatures;
    return features[featureKey] as bool? ?? false;
  }

  // Get recipe limit
  Future<int> getRecipeLimit() async {
    final tier = await getCurrentTier();
    final features = tier == SubscriptionTier.premium ? premiumFeatures : freeFeatures;
    return features['recipe_limit'] as int;
  }

  // Get AI recipe extraction limit
  Future<int> getAIRecipeLimit() async {
    final tier = await getCurrentTier();
    final features = tier == SubscriptionTier.premium ? premiumFeatures : freeFeatures;
    return features['ai_recipe_limit'] as int;
  }

  // Check if user has reached recipe limit
  Future<bool> hasReachedRecipeLimit() async {
    final user = _auth.currentUser;
    if (user == null) return true;

    final limit = await getRecipeLimit();
    if (limit == -1) return false; // unlimited

    final recipeCount = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recipes')
        .count()
        .get();

    return recipeCount.count >= limit;
  }

  // Check if user has reached AI recipe limit
  Future<bool> hasReachedAIRecipeLimit() async {
    final user = _auth.currentUser;
    if (user == null) return true;

    final limit = await getAIRecipeLimit();
    if (limit == -1) return false; // unlimited

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final aiRecipeCount = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ai_recipes')
        .where('created_at', isGreaterThanOrEqualTo: startOfMonth)
        .where('created_at', isLessThanOrEqualTo: endOfMonth)
        .count()
        .get();

    return aiRecipeCount.count >= limit;
  }
}
