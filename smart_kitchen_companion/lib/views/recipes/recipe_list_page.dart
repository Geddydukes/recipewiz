import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../config/api_keys.dart';
import 'recipe_detail_page.dart';
import 'ai_recipe_input_page.dart';

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: context.read<RecipeService>().getUserRecipes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return const Center(
              child: Text('No recipes yet. Add your first recipe!'),
            );
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                leading: recipe.mediaUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          recipe.mediaUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.restaurant),
                        ),
                      )
                    : const Icon(Icons.restaurant),
                title: Text(recipe.title),
                subtitle: Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(recipe: recipe),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isGeminiApiKeyConfigured()) ...[
            FloatingActionButton(
              heroTag: 'ai_recipe',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIRecipeInputPage(),
                ),
              ),
              child: const Icon(Icons.auto_awesome),
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            heroTag: 'manual_recipe',
            onPressed: () {
              // TODO: Navigate to manual recipe input page
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
