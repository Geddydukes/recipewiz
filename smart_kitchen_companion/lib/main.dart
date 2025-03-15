import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/recipe_service.dart';
import 'services/ai_recipe_service.dart';
import 'services/stripe_service.dart';
import 'services/feature_flag_service.dart';
import 'config/api_keys.dart';
import 'config/environment.dart';
import 'views/auth/auth_page.dart';
import 'views/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set environment
  const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  switch (environment) {
    case 'production':
      EnvironmentConfig.setEnvironment(Environment.production);
      break;
    case 'staging':
      EnvironmentConfig.setEnvironment(Environment.staging);
      break;
    default:
      EnvironmentConfig.setEnvironment(Environment.development);
  }
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: EnvironmentConfig.useEmulators
        ? const FirebaseOptions(
            apiKey: 'test_api_key',
            appId: 'test_app_id',
            messagingSenderId: 'test_sender_id',
            projectId: 'test_project_id',
          )
        : null,
  );
  
  // Initialize Stripe
  final stripeService = StripeService();
  if (isStripeConfigured()) {
    await stripeService.initialize();
  }
  
  // Initialize feature flags
  final featureFlagService = FeatureFlagService();
  
  runApp(MyApp(
    stripeService: stripeService,
    featureFlagService: featureFlagService,
  ));
}

class MyApp extends StatelessWidget {
  final StripeService stripeService;
  final FeatureFlagService featureFlagService;
  
  const MyApp({
    required this.stripeService,
    required this.featureFlagService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<RecipeService>(
          create: (_) => RecipeService(),
        ),
        Provider<AIRecipeService>(
          create: (_) => AIRecipeService(apiKey: GEMINI_API_KEY),
        ),
        Provider<StripeService>.value(value: stripeService),
        Provider<FeatureFlagService>.value(value: featureFlagService),
      ],
      child: MaterialApp(
        title: 'Smart Kitchen Companion',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: StreamBuilder(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            }
            return const AuthPage();
          },
        ),
      ),
    );
  }
}
