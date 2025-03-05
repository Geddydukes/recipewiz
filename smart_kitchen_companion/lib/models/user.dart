import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> following;
  final List<String> followers;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<String> favoriteRecipes;
  final List<String> shoppingLists;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.following,
    required this.followers,
    required this.createdAt,
    required this.lastLogin,
    required this.favoriteRecipes,
    required this.shoppingLists,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      following: List<String>.from(data['following']),
      followers: List<String>.from(data['followers']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: (data['lastLogin'] as Timestamp).toDate(),
      favoriteRecipes: List<String>.from(data['favoriteRecipes']),
      shoppingLists: List<String>.from(data['shoppingLists']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'following': following,
      'followers': followers,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'favoriteRecipes': favoriteRecipes,
      'shoppingLists': shoppingLists,
    };
  }

  User copyWith({
    String? displayName,
    String? photoUrl,
    List<String>? following,
    List<String>? followers,
    List<String>? favoriteRecipes,
    List<String>? shoppingLists,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      createdAt: createdAt,
      lastLogin: lastLogin,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      shoppingLists: shoppingLists ?? this.shoppingLists,
    );
  }
}
