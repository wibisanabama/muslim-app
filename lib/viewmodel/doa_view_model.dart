import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/doa.dart';
import '../repository/doa_repository.dart';

class DoaViewModel extends ChangeNotifier {
  final DoaRepository _repo;
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
    } catch (_) {}
  }

  bool isDoaSaved(String doaId) {
    return _savedDoaIds.contains(doaId);
  }

  List<Doa> getSavedDoas() {
    return _doas.where((d) => _savedDoaIds.contains(d.id)).toList();
  }
}