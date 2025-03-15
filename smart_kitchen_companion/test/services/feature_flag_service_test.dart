import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import '../../lib/services/feature_flag_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  late FeatureFlagService featureFlagService;
  late MockFirebaseAuth mockAuth;
  late FirebaseFirestore fakeFirestore;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    mockUser = MockUser();
    featureFlagService = FeatureFlagService();

    when(mockUser.uid).thenReturn('test_user');
  });

  group('FeatureFlagService', () {
    test('returns free tier for unauthenticated user', () async {
      when(mockAuth.currentUser).thenReturn(null);
      final tier = await featureFlagService.getCurrentTier();
      expect(tier, equals(SubscriptionTier.free));
    });

    test('returns correct feature availability for free tier', () async {
      when(mockAuth.currentUser).thenReturn(null);
      
      expect(await featureFlagService.isFeatureAvailable('manual_recipe_entry'), isTrue);
      expect(await featureFlagService.isFeatureAvailable('basic_shopping_list'), isTrue);
      expect(await featureFlagService.isFeatureAvailable('ai_recipe_extraction'), isFalse);
    });

    test('returns correct recipe limits for free tier', () async {
      when(mockAuth.currentUser).thenReturn(null);
      
      expect(await featureFlagService.getRecipeLimit(), equals(10));
      expect(await featureFlagService.getAIRecipeLimit(), equals(0));
    });

    test('returns true when recipe limit is reached in free tier', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      
      // Add 10 recipes to fake Firestore
      final recipesRef = fakeFirestore
          .collection('users')
          .doc('test_user')
          .collection('recipes');
          
      for (var i = 0; i < 10; i++) {
        await recipesRef.add({
          'title': 'Recipe $i',
          'created_at': DateTime.now(),
        });
      }

      expect(await featureFlagService.hasReachedRecipeLimit(), isTrue);
    });
  });
}
