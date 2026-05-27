import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthViewModel({required this._repository}) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get displayName => _user?.displayName ?? 'Akun';
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;
  String get monogramLetter => displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await _repository.signInWithGoogle();
      _isLoading = false;
      if (credential == null) {
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _repository.signOut();

    _isLoading = false;
    notifyListeners();
  }
}