import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../../lib/services/ai_recipe_service.dart';
import '../../lib/services/recipe_service.dart';
import '../../lib/views/recipes/ai_recipe_input_page.dart';
import '../services/ai_recipe_service_test.mocks.dart';

class MockRecipeService extends Mock implements RecipeService {}

void main() {
  late MockGenerativeModel mockGenerativeModel;
  late MockRecipeService mockRecipeService;
  late AIRecipeService aiRecipeService;

  setUp(() {
    mockGenerativeModel = MockGenerativeModel();
    mockRecipeService = MockRecipeService();
    aiRecipeService = AIRecipeService(apiKey: 'test_key');
  });

  testWidgets('AIRecipeInputPage shows URL input field', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AIRecipeService>.value(value: aiRecipeService),
          Provider<RecipeService>.value(value: mockRecipeService),
        ],
        child: const MaterialApp(
          home: AIRecipeInputPage(),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Enter recipe URL'), findsOneWidget);
  });

  testWidgets('AIRecipeInputPage shows image buttons', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AIRecipeService>.value(value: aiRecipeService),
          Provider<RecipeService>.value(value: mockRecipeService),
        ],
        child: const MaterialApp(
          home: AIRecipeInputPage(),
        ),
      ),
    );

    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose Photo'), findsOneWidget);
  });

  testWidgets('Shows error message on invalid URL', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AIRecipeService>.value(value: aiRecipeService),
          Provider<RecipeService>.value(value: mockRecipeService),
        ],
        child: const MaterialApp(
          home: AIRecipeInputPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Extract Recipe from URL'));
    await tester.pump();

    expect(find.text('Please enter a URL'), findsOneWidget);
  });
}
