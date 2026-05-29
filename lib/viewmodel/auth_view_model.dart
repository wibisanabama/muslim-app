import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repository/auth_repository.dart';
import '../utils/error_formatter.dart';

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
  String? get userId => _user?.uid;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get displayName => _user?.displayName ?? 'Akun';
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;
  String get monogramLetter =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';

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
      _error = formatError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('last_read_surah');
      await prefs.remove('last_read_surah_name');
      await prefs.remove('last_read_ayah');

      await prefs.remove('saved_doa_ids');

      final books = [
        "bukhari",
        "muslim",
        "tirmidzi",
        "abu-daud",
        "nasai",
        "ibnu-majah",
        "malik",
        "ahmad",
        "darimi",
      ];
      for (final bookId in books) {
        await prefs.remove('saved_hadis_$bookId');
      }

      await prefs.remove('ramadhan_shalat_logs');
      await prefs.remove('ramadhan_ceramah_logs');

      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: 'ramadhan_infaq_logs');
    } catch (_) {}

    await _repository.signOut();

    _isLoading = false;
    notifyListeners();
  }
}
