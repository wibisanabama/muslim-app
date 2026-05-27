import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/firestore_sync_repository.dart';

class HadisViewModel extends ChangeNotifier {
  Map<String, List<int>> _savedHadiths = {};
  bool _isLoading = false;
  FirestoreSyncRepository? _firestoreSyncRepository;
  String? _currentUserId;

  HadisViewModel() {
    unawaited(loadSaved());
  }

  Map<String, List<int>> get savedHadiths => _savedHadiths;
  bool get isLoading => _isLoading;

  int get totalSavedCount {
    int total = 0;
    _savedHadiths.forEach((key, list) {
      total += list.length;
    });
    return total;
  }

  void updateUserId(String? userId, FirestoreSyncRepository? syncRepo) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _firestoreSyncRepository = syncRepo;
      if (userId != null) {
        // Sync when user logs in
        unawaited(syncWithFirestore(userId));
      } else {
        unawaited(clearAllLocal());
      }
    }
  }

  Future<void> loadSaved() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, List<int>> loaded = {};
      
      final books = ["bukhari", "muslim", "tirmidzi", "abu-daud", "nasai", "ibnu-majah", "malik", "ahmad", "darimi"];
      for (final bookId in books) {
        final savedList = prefs.getStringList('saved_hadis_$bookId') ?? [];
        final parsed = savedList
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e != 0)
            .toList();
        if (parsed.isNotEmpty) {
          loaded[bookId] = parsed;
        }
      }
      
      _savedHadiths = loaded;
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isSaved(String bookId, int number) {
    return _savedHadiths[bookId]?.contains(number) ?? false;
  }

  List<int> getSavedNumbers(String bookId) {
    return _savedHadiths[bookId] ?? [];
  }

  Future<void> toggleSaved(String bookId, int number) async {
    final list = List<int>.from(_savedHadiths[bookId] ?? []);
    if (list.contains(number)) {
      list.remove(number);
    } else {
      list.add(number);
    }

    if (list.isEmpty) {
      _savedHadiths.remove(bookId);
    } else {
      _savedHadiths[bookId] = list;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = list.map((e) => e.toString()).toList();
      await prefs.setStringList('saved_hadis_$bookId', stringList);

      if (_currentUserId != null && _firestoreSyncRepository != null) {
        await _firestoreSyncRepository!.saveSavedHadiths(_currentUserId!, _savedHadiths);
      }
    } catch (_) {}
  }

  Future<void> syncWithFirestore(String userId) async {
    if (_firestoreSyncRepository == null) return;

    try {
      final cloudSaved = await _firestoreSyncRepository!.loadSavedHadiths(userId);
      if (cloudSaved == null) {
        // Upload local data to cloud
        await _firestoreSyncRepository!.saveSavedHadiths(userId, _savedHadiths);
        return;
      }

      // Merge: Union of local and cloud
      final merged = Map<String, List<int>>.from(_savedHadiths);
      cloudSaved.forEach((bookId, cloudList) {
        final localList = merged[bookId] ?? [];
        final combined = (localList.toSet()..addAll(cloudList)).toList();
        if (combined.isNotEmpty) {
          merged[bookId] = combined;
        }
      });

      _savedHadiths = merged;
      notifyListeners();

      // Save back locally and to cloud
      final prefs = await SharedPreferences.getInstance();
      for (final entry in _savedHadiths.entries) {
        final stringList = entry.value.map((e) => e.toString()).toList();
        await prefs.setStringList('saved_hadis_${entry.key}', stringList);
      }

      await _firestoreSyncRepository!.saveSavedHadiths(userId, _savedHadiths);
    } catch (_) {}
  }

  Future<void> clearAllLocal() async {
    _savedHadiths = {};
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final books = ["bukhari", "muslim", "tirmidzi", "abu-daud", "nasai", "ibnu-majah", "malik", "ahmad", "darimi"];
      for (final bookId in books) {
        await prefs.remove('saved_hadis_$bookId');
      }
    } catch (_) {}
  }
}
