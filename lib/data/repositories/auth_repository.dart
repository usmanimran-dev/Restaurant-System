import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant/config/constants.dart';
import 'package:restaurant/data/models/user_model.dart';
import 'dart:async';

/// Auth Repository now backed by Firebase Authentication and Firestore.
class AuthRepository {
  AuthRepository();

  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _cachedUser;

  UserModel? get currentUser => _cachedUser;
  bool get isAuthenticated => _auth.currentUser != null;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final user = cred.user;
      if (user == null) {
        throw Exception('Authentication failed - no user returned.');
      }

      final doc = await _firestore.collection(AppConstants.usersTable).doc(user.uid).get();
      
      if (!doc.exists) {
        throw Exception('User authenticated but profile not found in database (${user.uid}).');
      }

      final data = doc.data()!;
      data['id'] = user.uid; // Ensure ID matches auth UID
      
      try {
        _cachedUser = UserModel.fromJson(data);
        return _cachedUser!;
      } catch (parseError) {
        throw Exception('Failed to map Firestore doc: $parseError');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _cachedUser = null;
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    if (_cachedUser != null) return _cachedUser;

    try {
      final doc = await _firestore.collection(AppConstants.usersTable).doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = user.uid;
      _cachedUser = UserModel.fromJson(data);
      return _cachedUser;
    } catch (e) {
      return null; // Handle silently on load
    }
  }
}
