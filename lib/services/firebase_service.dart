import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;

  // Collection references
  CollectionReference get usersCollection => firestore.collection('users');
  CollectionReference get loansCollection => firestore.collection('loans');
  CollectionReference get circlesCollection => firestore.collection('circles');
  CollectionReference get guarantorRequestsCollection => firestore.collection('guarantor_requests');
  CollectionReference get notificationsCollection => firestore.collection('notifications');

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Enable Firebase emulator for local development if in debug mode
    if (kDebugMode) {
      try {
        await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        print('Firebase emulators connected!');
      } catch (e) {
        print('Failed to connect to Firebase emulators: $e');
      }
    }
    
    // Enable offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Helper method to generate document ID
  String generateId() => firestore.collection('temp').doc().id;

  // Batch operations
  WriteBatch batch() => firestore.batch();

  // Transaction operations
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) {
    return firestore.runTransaction(updateFunction);
  }
}

