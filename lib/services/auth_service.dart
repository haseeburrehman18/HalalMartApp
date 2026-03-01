// lib/services/auth_service.dart
// Firebase Auth placeholder — swap stubs for real Firebase calls when ready

import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Simulate login — returns a [UserModel] based on email domain.
  /// Replace with `FirebaseAuth.instance.signInWithEmailAndPassword` in production.
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network

    // Determine role by email prefix for demo
    String role;
    if (email.startsWith('admin')) {
      role = AppConstants.roleAdmin;
    } else if (email.startsWith('seller')) {
      role = AppConstants.roleSeller;
    } else {
      role = AppConstants.roleUser;
    }

    _currentUser = UserModel(
      uid: 'uid_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  /// Simulate registration.
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(
      uid: 'uid_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;
}
