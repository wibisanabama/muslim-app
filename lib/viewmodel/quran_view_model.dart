import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/surah.dart';
import '../model/surah_detail.dart';
import '../repository/quran_repository.dart';

class QuranViewModel extends ChangeNotifier {
  final QuranRepository _repo;
  QuranViewModel(this._repo) {
    unawaited(loadLastRead());
  }

  bool _isLoading = false;
  String? _error;
  List<Surah> _surahs = [];

  bool _isDetailLoading = false;
  String? _detailError;
  SurahDetail? _surahDetail;

  int? _lastReadSurah;
  String? _lastReadSurahName;
  int? _lastReadAyah;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Surah> get surahs => _surahs;

  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;
  SurahDetail? get surahDetail => _surahDetail;

  int? get lastReadSurah => _lastReadSurah;
  String? get lastReadSurahName => _lastReadSurahName;
  int? get lastReadAyah => _lastReadAyah;

  Future<void> loadLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastReadSurah = prefs.getInt('last_read_surah');
      _lastReadSurahName = prefs.getString('last_read_surah_name');
      _lastReadAyah = prefs.getInt('last_read_ayah');
      notifyListeners();
    } catch (_) {}
  }

  Future<void> saveLastRead(
    int surahNumber,
    String surahName,
    int ayahNumber,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_read_surah', surahNumber);
      await prefs.setString('last_read_surah_name', surahName);
      await prefs.setInt('last_read_ayah', ayahNumber);

      _lastReadSurah = surahNumber;
      _lastReadSurahName = surahName;
      _lastReadAyah = ayahNumber;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_read_surah');
      await prefs.remove('last_read_surah_name');
      await prefs.remove('last_read_ayah');

      _lastReadSurah = null;
      _lastReadSurahName = null;
      _lastReadAyah = null;
      notifyListeners();
    } catch (_) {}
  }

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
