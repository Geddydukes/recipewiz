import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_kitchen_companion/services/auth_service.dart';
import 'package:smart_kitchen_companion/models/user.dart' as models;

// Generate mocks
@GenerateMocks([
  auth.FirebaseAuth, 
  auth.User, 
  auth.UserCredential,
  FirebaseFirestore,
  DocumentReference,
  CollectionReference,
  DocumentSnapshot,
  Query,
  QuerySnapshot
])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockDocSnapshot;
  late MockCollectionReference mockCollectionRef;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();
    mockCollectionRef = MockCollectionReference();

    // Setup common stubs
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUserCredential.user).thenReturn(mockUser);

    when(mockFirestore.collection('users')).thenReturn(mockCollectionRef);
    when(mockCollectionRef.doc('test-user-id')).thenReturn(mockDocRef);
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
    
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.id).thenReturn('test-user-id');
    when(mockDocSnapshot.data()).thenReturn({
      'id': 'test-user-id',
      'email': 'test@example.com',
      'displayName': 'Test User',
      'photoUrl': 'https://example.com/photo.jpg',
      'following': [],
      'followers': [],
      'createdAt': DateTime.now(),
      'lastLogin': DateTime.now(),
      'favoriteRecipes': [],
      'shoppingLists': [],
    });

    // Create AuthService with mocked dependencies
    authService = AuthService.withDependencies(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirestore,
    );
  });

  group('AuthService', () {
    test('currentUser should return user from firebase', () {
      // Act
      final user = authService.currentUser;

      // Assert
      expect(user, isNotNull);
      expect(user!.id, 'test-user-id');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('signInWithEmailAndPassword should return user on success', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final user = await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password',
      );

      // Assert
      expect(user, isNotNull);
      expect(user!.id, 'test-user-id');
      expect(user.email, 'test@example.com');
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      )).called(1);
      verify(mockDocRef.update({'lastLogin': any})).called(1);
    });

    test('signUpWithEmailAndPassword should return user on success', () async {
      // Arrange
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password',
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final user = await authService.signUpWithEmailAndPassword(
        'new@example.com',
        'password',
        'New User',
      );

      // Assert
      expect(user, isNotNull);
      expect(user!.id, 'test-user-id');
      expect(user.email, 'new@example.com');
      expect(user.displayName, 'New User');
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password',
      )).called(1);
      verify(mockUser.updateDisplayName('New User')).called(1);
      verify(mockDocRef.set(any)).called(1);
    });

    test('signOut should call Firebase signOut', () async {
      // Act
      await authService.signOut();

      // Assert
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('sendPasswordResetEmail should call Firebase sendPasswordResetEmail', () async {
      // Act
      await authService.sendPasswordResetEmail('test@example.com');

      // Assert
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: 'test@example.com')).called(1);
    });

    test('updateProfile should update user profile', () async {
      // Act
      await authService.updateProfile(
        displayName: 'Updated Name',
        photoUrl: 'https://example.com/updated.jpg',
      );

      // Assert
      verify(mockUser.updateDisplayName('Updated Name')).called(1);
      verify(mockUser.updatePhotoURL('https://example.com/updated.jpg')).called(1);
      verify(mockDocRef.update({
        'displayName': 'Updated Name',
        'photoUrl': 'https://example.com/updated.jpg',
      })).called(1);
    });

    test('onAuthStateChanged should emit user on auth changes', () async {
      // Arrange
      when(mockFirebaseAuth.authStateChanges()).thenAnswer(
        (_) => Stream.value(mockUser),
      );

      // Act
      final stream = authService.onAuthStateChanged;

      // Assert
      expect(
        stream,
        emits(isA<models.User>().having((u) => u.id, 'id', 'test-user-id')),
      );
    });
  });
} 