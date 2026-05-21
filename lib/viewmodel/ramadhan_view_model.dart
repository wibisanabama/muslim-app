import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ramadhan_record.dart';

class RamadhanViewModel extends ChangeNotifier {
  List<ShalatDayLog> _shalatLogs = [];
  List<CeramahLog> _ceramahLogs = [];
  List<InfaqLog> _infaqLogs = [];
  bool _isLoading = false;

  List<ShalatDayLog> get shalatLogs => _shalatLogs;
  List<CeramahLog> get ceramahLogs => _ceramahLogs;
  List<InfaqLog> get infaqLogs => _infaqLogs;
  bool get isLoading => _isLoading;

  /// Hitung total akumulasi infaq
  double get totalInfaq {
    return _infaqLogs.fold(0.0, (sum, log) => sum + log.amount);
  }

  RamadhanViewModel() {
    _initializeDefaultShalatLogs();
    loadLogs();
  }

  /// Inisialisasi template default 30 hari shalat fardhu dan sunnah
  void _initializeDefaultShalatLogs() {
    _shalatLogs = List.generate(30, (index) => ShalatDayLog.createDefault(index + 1));
  }

  /// Memuat data dari SharedPreferences
  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load Shalat Logs
      final shalatJson = prefs.getString('ramadhan_shalat_logs');
      if (shalatJson != null) {
        final List<dynamic> decoded = jsonDecode(shalatJson);
        final loadedLogs = decoded.map((e) => ShalatDayLog.fromJson(e)).toList();
        
        // Gabungkan dengan template 30 hari untuk memastikan semua hari terisi
        for (var log in loadedLogs) {
          if (log.day >= 1 && log.day <= 30) {
            _shalatLogs[log.day - 1] = log;
          }
        }
      }

      // 2. Load Ceramah Logs
      final ceramahJson = prefs.getString('ramadhan_ceramah_logs');
      if (ceramahJson != null) {
        final List<dynamic> decoded = jsonDecode(ceramahJson);
        _ceramahLogs = decoded.map((e) => CeramahLog.fromJson(e)).toList();
        // Urutkan berdasarkan tanggal terbaru
        _ceramahLogs.sort((a, b) => b.date.compareTo(a.date));
      }

      // 3. Load Infaq Logs
      final infaqJson = prefs.getString('ramadhan_infaq_logs');
      if (infaqJson != null) {
        final List<dynamic> decoded = jsonDecode(infaqJson);
        _infaqLogs = decoded.map((e) => InfaqLog.fromJson(e)).toList();
        // Urutkan berdasarkan tanggal terbaru
        _infaqLogs.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      debugPrint('Error loading Ramadhan logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menyimpan data secara internal ke SharedPreferences
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save Shalat
      final shalatJson = jsonEncode(_shalatLogs.map((e) => e.toJson()).toList());
      await prefs.setString('ramadhan_shalat_logs', shalatJson);

      // Save Ceramah
      final ceramahJson = jsonEncode(_ceramahLogs.map((e) => e.toJson()).toList());
      await prefs.setString('ramadhan_ceramah_logs', ceramahJson);

      // Save Infaq
      final infaqJson = jsonEncode(_infaqLogs.map((e) => e.toJson()).toList());
      await prefs.setString('ramadhan_infaq_logs', infaqJson);
    } catch (e) {
      debugPrint('Error saving Ramadhan logs: $e');
    }
  }

  /// Menandai/mengubah status centang ibadah shalat pada hari tertentu
  void togglePrayer(int day, String prayerName) {
    if (day < 1 || day > 30) return;
    
    final log = _shalatLogs[day - 1];
    final currentValue = log.prayers[prayerName] ?? false;
    log.prayers[prayerName] = !currentValue;

    notifyListeners();
    _saveLogs();
  }

  /// Menambahkan catatan ceramah baru
  void addCeramahLog({
    required String speaker,
    required String title,
    required String summary,
    DateTime? date,
  }) {
    final newLog = CeramahLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date ?? DateTime.now(),
      speaker: speaker.trim().isEmpty ? 'Hamba Allah' : speaker.trim(),
      title: title.trim().isEmpty ? 'Kultum Ramadhan' : title.trim(),
      summary: summary.trim(),
    );

    _ceramahLogs.insert(0, newLog);
    notifyListeners();
    _saveLogs();
  }

  /// Menghapus catatan ceramah
  void deleteCeramahLog(String id) {
    _ceramahLogs.removeWhere((element) => element.id == id);
    notifyListeners();
    _saveLogs();
  }

  /// Menambahkan catatan infaq baru
  void addInfaqLog({
    required double amount,
    required String notes,
    DateTime? date,
  }) {
    final newLog = InfaqLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date ?? DateTime.now(),
      amount: amount,
      notes: notes.trim().isEmpty ? 'Sedekah Ramadhan' : notes.trim(),
    );

    _infaqLogs.insert(0, newLog);
    notifyListeners();
    _saveLogs();
  }

  /// Menghapus catatan infaq
  void deleteInfaqLog(String id) {
    _infaqLogs.removeWhere((element) => element.id == id);
    notifyListeners();
    _saveLogs();
  }
}
