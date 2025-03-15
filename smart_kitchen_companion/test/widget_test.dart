// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../lib/main.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/recipe_service.dart';
import '../lib/services/ai_recipe_service.dart';
import '../lib/services/stripe_service.dart';
import '../lib/services/feature_flag_service.dart';

void main() {
  testWidgets('App loads and shows login page', (WidgetTester tester) async {
    final authService = AuthService();
    final recipeService = RecipeService();
    final aiRecipeService = AIRecipeService(apiKey: 'test_key');
    final stripeService = StripeService();
    final featureFlagService = FeatureFlagService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: authService),
          Provider<RecipeService>.value(value: recipeService),
          Provider<AIRecipeService>.value(value: aiRecipeService),
          Provider<StripeService>.value(value: stripeService),
          Provider<FeatureFlagService>.value(value: featureFlagService),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Login Page'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Login Page'), findsOneWidget);
  });
}
