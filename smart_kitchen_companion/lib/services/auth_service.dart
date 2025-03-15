import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as models;

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Follow user
  Future<void> followUser(String userId) async {
    if (_firebaseAuth.currentUser == null) return;

    final userRef = _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid);
    final otherUserRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final otherUserDoc = await transaction.get(otherUserRef);

      if (!userDoc.exists || !otherUserDoc.exists) return;

      List<String> following = List<String>.from(userDoc.data()?['following'] ?? []);
      List<String> followers = List<String>.from(otherUserDoc.data()?['followers'] ?? []);

      if (!following.contains(userId)) {
        following.add(userId);
        followers.add(_firebaseAuth.currentUser!.uid);

        transaction.update(userRef, {'following': following});
        transaction.update(otherUserRef, {'followers': followers});
      }
    });
  }

  // Unfollow user
  Future<void> unfollowUser(String userId) async {
    if (_firebaseAuth.currentUser == null) return;

    final userRef = _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid);
    final otherUserRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final otherUserDoc = await transaction.get(otherUserRef);

      if (!userDoc.exists || !otherUserDoc.exists) return;

      List<String> following = List<String>.from(userDoc.data()?['following'] ?? []);
      List<String> followers = List<String>.from(otherUserDoc.data()?['followers'] ?? []);

      following.remove(userId);
      followers.remove(_firebaseAuth.currentUser!.uid);

      transaction.update(userRef, {'following': following});
      transaction.update(otherUserRef, {'followers': followers});
    });
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_firebaseAuth.currentUser == null) return;
    await _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid).update(data);
  }
}
