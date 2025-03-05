import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { photo, video, audio, text }

class Recipe {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final MediaType sourceType;
  final String mediaUrl;
  final NutritionalInfo nutritionalInfo;
  final double estimatedCost;
  final List<String> tags;
  final int likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.sourceType,
    required this.mediaUrl,
    required this.nutritionalInfo,
    required this.estimatedCost,
    required this.tags,
    this.likes = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      ingredients: (data['ingredients'] as List)
          .map((i) => Ingredient.fromMap(i))
          .toList(),
      instructions: List<String>.from(data['instructions']),
      sourceType: MediaType.values.firstWhere(
          (e) => e.toString() == 'MediaType.${data['sourceType']}'),
      mediaUrl: data['mediaUrl'],
      nutritionalInfo: NutritionalInfo.fromMap(data['nutritionalInfo']),
      estimatedCost: data['estimatedCost'].toDouble(),
      tags: List<String>.from(data['tags']),
      likes: data['likes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'sourceType': sourceType.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'nutritionalInfo': nutritionalInfo.toMap(),
      'estimatedCost': estimatedCost,
      'tags': tags,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class Ingredient {
  final String name;
  final double quantity;
  final String unit;
  final String section; // grocery store section

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.section,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'],
      quantity: map['quantity'].toDouble(),
      unit: map['unit'],
      section: map['section'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'section': section,
    };
  }
}

class NutritionalInfo {
  final int calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;

  NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.vitamins,
    required this.minerals,
  });

  factory NutritionalInfo.fromMap(Map<String, dynamic> map) {
    return NutritionalInfo(
      calories: map['calories'],
      protein: map['protein'].toDouble(),
      carbohydrates: map['carbohydrates'].toDouble(),
      fat: map['fat'].toDouble(),
      vitamins: Map<String, double>.from(map['vitamins']),
      minerals: Map<String, double>.from(map['minerals']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'vitamins': vitamins,
      'minerals': minerals,
    };
  }
}
