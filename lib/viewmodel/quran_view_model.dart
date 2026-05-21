import 'package:flutter/foundation.dart';
import '../model/surah.dart';
import '../model/surah_detail.dart';
import '../repository/quran_repository.dart';

class QuranViewModel extends ChangeNotifier {
  final QuranRepository _repo;
  QuranViewModel(this._repo);

  bool _isLoading = false;
  String? _error;
  List<Surah> _surahs = [];

  bool _isDetailLoading = false;
  String? _detailError;
  SurahDetail? _surahDetail;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Surah> get surahs => _surahs;

  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;
  SurahDetail? get surahDetail => _surahDetail;

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

  Future<void> fetchSurahDetail(int nomor) async {
    _isDetailLoading = true;
    _detailError = null;
    _surahDetail = null;
    notifyListeners();

    try {
      _surahDetail = await _repo.getSurahDetail(nomor);
    } catch (e) {
      _detailError = e.toString();
      _surahDetail = null;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}
