import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as models;

class AuthService {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Default constructor
  AuthService() 
    : _firebaseAuth = auth.FirebaseAuth.instance,
      _firestore = FirebaseFirestore.instance;
  
  // Constructor with dependency injection for testing
  AuthService.withDependencies({
    required auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  // Get current user
  models.User? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // This is a simplified version, you'd typically want to fetch the full user data from Firestore
      return models.User(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL,
        following: [],
        followers: [],
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        favoriteRecipes: [],
        shoppingLists: [],
      );
    }
    return null;
  }

  // Sign in with email and password
  Future<models.User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update last login
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        
        // Fetch user data from Firestore
        final doc = await _firestore.collection('users').doc(result.user!.uid).get();
        return models.User.fromFirestore(doc);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Sign up with email and password
  Future<models.User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update user profile
        await result.user!.updateDisplayName(displayName);
        
        // Create user document in Firestore
        final user = models.User(
          id: result.user!.uid,
          email: email,
          displayName: displayName,
          following: [],
          followers: [],
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          favoriteRecipes: [],
          shoppingLists: [],
        );
        
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(user.toMap());
            
        return user;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }
        
        // Update Firestore document
        await _firestore.collection('users').doc(user.uid).update({
          if (displayName != null) 'displayName': displayName,
          if (photoUrl != null) 'photoUrl': photoUrl,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Stream of auth state changes
  Stream<models.User?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }
      
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return models.User.fromFirestore(doc);
    });
  }
}
