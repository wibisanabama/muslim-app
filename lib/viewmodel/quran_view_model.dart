import 'package:flutter/foundation.dart';
import '../model/surah.dart';
import '../repository/quran_repository.dart';

class QuranViewModel extends ChangeNotifier {
  final QuranRepository _repo;
  QuranViewModel(this._repo);

  bool _isLoading = false;
  String? _error;
  List<Surah> _surahs = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Surah> get surahs => _surahs;

  Future<void> fetchSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _repo.getSurahList();
    } catch (e) {
      _error = e.toString();
      _surahs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
