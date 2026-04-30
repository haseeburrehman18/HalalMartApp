// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Stream of user changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> restoreCurrentUser() async {
    final firebaseUser = _auth.currentUser ??
        await _auth.authStateChanges().first.timeout(
              const Duration(seconds: 2),
              onTimeout: () => null,
            );
    if (firebaseUser == null) {
      _currentUser = null;
      return null;
    }

    return _getUserModel(firebaseUser.uid);
  }

  /// Login with Email and Password
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        return await _getUserModel(user.uid);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Register with Email and Password
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? shopName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: role,
          shopName: shopName,
          createdAt: DateTime.now(),
        );
        await _saveUser(newUser);
        _currentUser = newUser;
        return newUser;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Google Sign In
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user already exists in Firestore
        UserModel? existingUser = await _getUserModel(user.uid);
        if (existingUser == null) {
          // New user from Google
          UserModel newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'Google User',
            email: user.email ?? '',
            role: 'user', // Default role for Google sign-in
            photoUrl: user.photoURL,
            createdAt: DateTime.now(),
          );
          await _saveUser(newUser);
          _currentUser = newUser;
          return newUser;
        }
        _currentUser = existingUser;
        return existingUser;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
  }

  /// Helper: Get UserModel from Firestore
  Future<UserModel?> _getUserModel(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      return _currentUser;
    }
    return null;
  }

  /// Helper: Save UserModel to Firestore
  Future<void> _saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> updateProfile({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });

    final updated = await _getUserModel(uid);
    _currentUser = updated;
    return updated;
  }

  bool get isLoggedIn => _auth.currentUser != null;
}
