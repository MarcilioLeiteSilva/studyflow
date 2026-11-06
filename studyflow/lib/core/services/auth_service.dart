import 'dart:async';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Mock User class or just return null
  dynamic get currentUser => null;

  Stream<dynamic> get authStateChanges => Stream.value(null);

  // Sign in with Google (No-op)
  Future<dynamic> signInWithGoogle() async {
    print('Auth removed');
    return null;
  }

  // Sign out (No-op)
  Future<void> signOut() async {
    print('Auth removed');
  }
}
