import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseConnectionTest extends StatelessWidget {
  const FirebaseConnectionTest({Key? key}) : super(key: key);

  Future<void> _testFirebaseConnection(BuildContext context) async {
    try {
      // Test if Firebase is initialized
      if (Firebase.apps.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firebase is properly initialized! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Firebase not initialized');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _testFirebaseConnection(context),
        child: const Text('Test Firebase Connection'),
      ),
    );
  }
}
