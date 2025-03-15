import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/ai_recipe_service.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';

class AIRecipeInputPage extends StatefulWidget {
  const AIRecipeInputPage({super.key});

  @override
  State<AIRecipeInputPage> createState() => _AIRecipeInputPageState();
}

class _AIRecipeInputPageState extends State<AIRecipeInputPage> {
  final _urlController = TextEditingController();
  File? _selectedImage;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final aiService = context.read<AIRecipeService>();
      final recipe = await aiService.extractRecipeFromImage(_selectedImage!);

      if (recipe != null) {
        final recipeService = context.read<RecipeService>();
        await recipeService.addRecipe(recipe);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = 'Could not extract recipe from image';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing image: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a URL';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final aiService = context.read<AIRecipeService>();
      final recipe = await aiService.extractRecipeFromUrl(url);

      if (recipe != null) {
        final recipeService = context.read<RecipeService>();
        await recipeService.addRecipe(recipe);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = 'Could not extract recipe from URL';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing URL: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe with AI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Import from Image',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Photo'),
                ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isProcessing ? null : _processImage,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Extract Recipe from Image'),
              ),
            ],
            const SizedBox(height: 32),
            const Text(
              'Import from URL',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'Enter recipe URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processUrl,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Extract Recipe from URL'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
