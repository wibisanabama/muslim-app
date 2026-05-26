import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ramadhan_record.dart';
import '../utils/logger.dart';

class RamadhanValidationError implements Exception {
  final String message;
  RamadhanValidationError(this.message);
  @override
  String toString() => message;
}

class RamadhanViewModel extends ChangeNotifier {
  List<ShalatDayLog> _shalatLogs = [];
  List<CeramahLog> _ceramahLogs = [];
  List<InfaqLog> _infaqLogs = [];
  bool _isLoading = false;

  static const _secureStorage = FlutterSecureStorage();

  List<ShalatDayLog> get shalatLogs => _shalatLogs;
  List<CeramahLog> get ceramahLogs => _ceramahLogs;
  List<InfaqLog> get infaqLogs => _infaqLogs;
  bool get isLoading => _isLoading;

  double get totalInfaq {
    return _infaqLogs.fold(0.0, (sum, log) => sum + log.amount);
  }

  RamadhanViewModel() {
    _initializeDefaultShalatLogs();
    unawaited(loadLogs());
  }

  void _initializeDefaultShalatLogs() {
    _shalatLogs = List.generate(
      30,
      (index) => ShalatDayLog.createDefault(index + 1),
    );
  }

  bool _isValidDate(DateTime date) {
    final minYear = 1970;
    final maxYear = DateTime.now().year + 1;
    return date.year >= minYear && date.year <= maxYear;
  }

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final shalatJson = prefs.getString('ramadhan_shalat_logs');
      if (shalatJson != null) {
        final List<dynamic> decoded = jsonDecode(shalatJson);
        final loadedLogs = decoded
            .map((e) {
              try {
                return ShalatDayLog.fromJson(e as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<ShalatDayLog>()
            .toList();

        for (var log in loadedLogs) {
          if (log.day >= 1 && log.day <= 30) {
            _shalatLogs[log.day - 1] = log;
          }
        }
      }

      final ceramahJson = prefs.getString('ramadhan_ceramah_logs');
      if (ceramahJson != null) {
        final List<dynamic> decoded = jsonDecode(ceramahJson);
        _ceramahLogs = decoded
            .map((e) {
              try {
                return CeramahLog.fromJson(e as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<CeramahLog>()
            .toList();

        _ceramahLogs.sort((a, b) => b.date.compareTo(a.date));
      }

      final infaqJson = await _secureStorage.read(key: 'ramadhan_infaq_logs');
      if (infaqJson != null) {
        final List<dynamic> decoded = jsonDecode(infaqJson);
        _infaqLogs = decoded
            .map((e) {
              try {
                return InfaqLog.fromJson(e as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<InfaqLog>()
            .toList();

        _infaqLogs.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      AppLogger.warningLazy(() => 'Error loading Ramadhan logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final shalatJson = jsonEncode(
        _shalatLogs.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('ramadhan_shalat_logs', shalatJson);

      final ceramahJson = jsonEncode(
        _ceramahLogs.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('ramadhan_ceramah_logs', ceramahJson);

      final infaqJson = jsonEncode(_infaqLogs.map((e) => e.toJson()).toList());
      await _secureStorage.write(key: 'ramadhan_infaq_logs', value: infaqJson);
    } catch (e) {
      AppLogger.warningLazy(() => 'Error saving Ramadhan logs: $e');
    }
  }

  void togglePrayer(int day, String prayerName) {
    if (day < 1 || day > 30) return;

    final log = _shalatLogs[day - 1];
    final currentValue = log.prayers[prayerName] ?? false;
    log.prayers[prayerName] = !currentValue;

    notifyListeners();
    unawaited(_saveLogs());
  }

  void addCeramahLog({
    required String speaker,
    required String title,
    required String summary,
    DateTime? date,
  }) {
    if (_ceramahLogs.length >= 1000) {
      throw RamadhanValidationError(
        'Catatan ceramah telah mencapai batas maksimum 1000 entri.',
      );
    }

    final finalDate = date ?? DateTime.now();
    if (!_isValidDate(finalDate)) {
      throw RamadhanValidationError(
        'Tanggal harus berada di antara tahun 1970 dan satu tahun setelah hari ini.',
      );
    }

    final cleanSpeaker = speaker.trim();
    if (cleanSpeaker.length > 100) {
      throw RamadhanValidationError(
        'Nama pembicara tidak boleh melebihi 100 karakter.',
      );
    }

    final cleanTitle = title.trim();
    if (cleanTitle.length > 200) {
      throw RamadhanValidationError('Judul tidak boleh melebihi 200 karakter.');
    }

    final cleanSummary = summary.trim();
    if (cleanSummary.length > 5000) {
      throw RamadhanValidationError(
        'Ringkasan tidak boleh melebihi 5000 karakter.',
      );
    }

    final newLog = CeramahLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: finalDate,
      speaker: cleanSpeaker.isEmpty ? 'Hamba Allah' : cleanSpeaker,
      title: cleanTitle.isEmpty ? 'Kultum Ramadhan' : cleanTitle,
      summary: cleanSummary,
    );

    _ceramahLogs.insert(0, newLog);
    notifyListeners();
    unawaited(_saveLogs());
  }

  void updateCeramahLog({
    required String id,
    required String speaker,
    required String title,
    required String summary,
  }) {
    final cleanSpeaker = speaker.trim();
    if (cleanSpeaker.length > 100) {
      throw RamadhanValidationError(
        'Nama pembicara tidak boleh melebihi 100 karakter.',
      );
    }

    final cleanTitle = title.trim();
    if (cleanTitle.length > 200) {
      throw RamadhanValidationError('Judul tidak boleh melebihi 200 karakter.');
    }

    final cleanSummary = summary.trim();
    if (cleanSummary.length > 5000) {
      throw RamadhanValidationError(
        'Ringkasan tidak boleh melebihi 5000 karakter.',
      );
    }

    final index = _ceramahLogs.indexWhere((element) => element.id == id);
    if (index != -1) {
      final oldLog = _ceramahLogs[index];
      _ceramahLogs[index] = CeramahLog(
        id: oldLog.id,
        date: oldLog.date,
        speaker: cleanSpeaker.isEmpty ? 'Hamba Allah' : cleanSpeaker,
        title: cleanTitle.isEmpty ? 'Kultum Ramadhan' : cleanTitle,
        summary: cleanSummary,
      );
      notifyListeners();
      unawaited(_saveLogs());
    }
  }

  void deleteCeramahLog(String id) {
    _ceramahLogs.removeWhere((element) => element.id == id);
    notifyListeners();
    unawaited(_saveLogs());
  }

  void addInfaqLog({
    required double amount,
    required String notes,
    DateTime? date,
  }) {
    if (_infaqLogs.length >= 1000) {
      throw RamadhanValidationError(
        'Catatan infaq telah mencapai batas maksimum 1000 entri.',
      );
    }

    final finalDate = date ?? DateTime.now();
    if (!_isValidDate(finalDate)) {
      throw RamadhanValidationError(
        'Tanggal harus berada di antara tahun 1970 dan satu tahun setelah hari ini.',
      );
    }

    if (amount <= 0) {
      throw RamadhanValidationError('Nominal infaq harus lebih dari 0.');
    }
    if (amount >= 1e12) {
      throw RamadhanValidationError(
        'Nominal infaq tidak boleh mencapai atau melebihi 1 triliun rupiah.',
      );
    }

    final cleanNotes = notes.trim();
    if (cleanNotes.length > 500) {
      throw RamadhanValidationError(
        'Catatan infaq tidak boleh melebihi 500 karakter.',
      );
    }

    final newLog = InfaqLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: finalDate,
      amount: amount,
      notes: cleanNotes.isEmpty ? 'Sedekah Ramadhan' : cleanNotes,
    );

    _infaqLogs.insert(0, newLog);
    notifyListeners();
    unawaited(_saveLogs());
  }

  void deleteInfaqLog(String id) {
    _infaqLogs.removeWhere((element) => element.id == id);
    notifyListeners();
    unawaited(_saveLogs());
  }

  void updateInfaqLog({
    required String id,
    required double amount,
    required String notes,
  }) {
    if (amount <= 0) {
      throw RamadhanValidationError('Nominal infaq harus lebih dari 0.');
    }
    if (amount >= 1e12) {
      throw RamadhanValidationError(
        'Nominal infaq tidak boleh mencapai atau melebihi 1 triliun rupiah.',
      );
    }

    final cleanNotes = notes.trim();
    if (cleanNotes.length > 500) {
      throw RamadhanValidationError(
        'Catatan infaq tidak boleh melebihi 500 karakter.',
      );
    }

    final index = _infaqLogs.indexWhere((element) => element.id == id);
    if (index != -1) {
      final oldLog = _infaqLogs[index];
      _infaqLogs[index] = InfaqLog(
        id: oldLog.id,
        date: oldLog.date,
        amount: amount,
        notes: cleanNotes.isEmpty ? 'Sedekah Ramadhan' : cleanNotes,
      );
      notifyListeners();
      unawaited(_saveLogs());
    }
  }

  void restoreCeramahLog(CeramahLog log) {
    if (_ceramahLogs.length >= 1000) {
      throw RamadhanValidationError(
        'Catatan ceramah telah mencapai batas maksimum 1000 entri.',
      );
    }
    _ceramahLogs.add(log);
    _ceramahLogs.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    unawaited(_saveLogs());
  }

  void restoreInfaqLog(InfaqLog log) {
    if (_infaqLogs.length >= 1000) {
      throw RamadhanValidationError(
        'Catatan infaq telah mencapai batas maksimum 1000 entri.',
      );
    }
    _infaqLogs.add(log);
    _infaqLogs.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    unawaited(_saveLogs());
  }
}