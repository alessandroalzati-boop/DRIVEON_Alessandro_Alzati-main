import 'package:cloud_firestore/cloud_firestore.dart';

// Class dedicated to saving user data in the Firestore database.
class UserService {
  // Global Firestore database instance.
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Saves or updates the user profile within the 'users' collection.
  static Future<void> saveUserProfile({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    // Cleans and normalizes the name.
    final safeName = (displayName ?? '').trim();

    // Saves the user's data using the UID as the identifier.
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email.trim(),
      'displayName': safeName,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
