import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/doa.dart';
import '../repository/doa_repository.dart';
import '../repository/firestore_sync_repository.dart';

class DoaViewModel extends ChangeNotifier {
  final DoaRepository _repo;
  FirestoreSyncRepository? _firestoreSyncRepository;
  String? _currentUserId;

  DoaViewModel(this._repo) {
    unawaited(loadSavedDoaIds());
  }

  bool _isLoading = false;
  String? _error;
  List<Doa> _doas = [];
  List<String> _savedDoaIds = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Doa> get doas => _doas;
  List<String> get savedDoaIds => _savedDoaIds;

  void updateUserId(String? userId, FirestoreSyncRepository? syncRepo) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _firestoreSyncRepository = syncRepo;
      if (userId != null) {
        unawaited(syncWithFirestore(userId));
      } else {
        unawaited(clearAllLocal());
      }
    }
  }

  Future<void> fetchDoas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doas = await _repo.getDoaList();
    } catch (e) {
      _error = e.toString();
      _doas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedDoaIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _savedDoaIds = prefs.getStringList('saved_doa_ids') ?? [];
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleSavedDoa(String doaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_savedDoaIds.contains(doaId)) {
        _savedDoaIds.remove(doaId);
      } else {
        _savedDoaIds.add(doaId);
      }
      await prefs.setStringList('saved_doa_ids', _savedDoaIds);
      notifyListeners();

      if (_currentUserId != null && _firestoreSyncRepository != null) {
        await _firestoreSyncRepository!.saveSavedDoas(_currentUserId!, _savedDoaIds);
      }
    } catch (_) {}
  }

  Future<void> syncWithFirestore(String userId) async {
    if (_firestoreSyncRepository == null) return;

    try {
      final cloudSaved = await _firestoreSyncRepository!.loadSavedDoas(userId);
      if (cloudSaved == null) {
        await _firestoreSyncRepository!.saveSavedDoas(userId, _savedDoaIds);
        return;
      }

      final merged = (List<String>.from(_savedDoaIds).toSet()..addAll(cloudSaved)).toList();
      _savedDoaIds = merged;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_doa_ids', _savedDoaIds);

      await _firestoreSyncRepository!.saveSavedDoas(userId, _savedDoaIds);
    } catch (_) {}
  }

  bool isDoaSaved(String doaId) {
    return _savedDoaIds.contains(doaId);
  }

  List<Doa> getSavedDoas() {
    return _doas.where((d) => _savedDoaIds.contains(d.id)).toList();
  }

  Future<void> clearAllLocal() async {
    _savedDoaIds = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_doa_ids');
    } catch (_) {}
  }
}