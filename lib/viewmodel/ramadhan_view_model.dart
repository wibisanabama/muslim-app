import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ramadhan_record.dart';
import '../utils/logger.dart';
import '../repository/firestore_sync_repository.dart';

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
  FirestoreSyncRepository? _firestoreSyncRepository;
  String? _currentUserId;

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

      if (_currentUserId != null && _firestoreSyncRepository != null) {
        await _firestoreSyncRepository!.saveRamadhanShalatLogs(
          _currentUserId!,
          _shalatLogs.map((e) => e.toJson()).toList(),
        );
      }
    } catch (e) {
      AppLogger.warningLazy(() => 'Error saving Ramadhan logs: $e');
    }
  }

  Future<void> syncWithFirestore(String userId) async {
    if (_firestoreSyncRepository == null) return;

    try {
      // 1. Shalat Logs Sync
      final cloudShalat = await _firestoreSyncRepository!.loadRamadhanShalatLogs(userId);
      if (cloudShalat == null) {
        await _firestoreSyncRepository!.saveRamadhanShalatLogs(
          userId,
          _shalatLogs.map((e) => e.toJson()).toList(),
        );
      } else {
        final List<ShalatDayLog> mergedShalat = List.generate(
          30,
          (index) => ShalatDayLog.createDefault(index + 1),
        );
        
        final Map<int, ShalatDayLog> cloudLogsMap = {
          for (var item in cloudShalat.map((e) => ShalatDayLog.fromJson(e)))
            item.day: item
        };

        for (int i = 0; i < 30; i++) {
          final localLog = _shalatLogs[i];
          final cloudLog = cloudLogsMap[i + 1];
          if (cloudLog == null) {
            mergedShalat[i] = localLog;
          } else {
            final mergedPrayers = Map<String, bool>.from(localLog.prayers);
            cloudLog.prayers.forEach((key, value) {
              mergedPrayers[key] = (mergedPrayers[key] ?? false) || value;
            });
            mergedShalat[i] = ShalatDayLog(day: i + 1, prayers: mergedPrayers);
          }
        }
        _shalatLogs = mergedShalat;
        await _firestoreSyncRepository!.saveRamadhanShalatLogs(
          userId,
          _shalatLogs.map((e) => e.toJson()).toList(),
        );
      }

      // 2. Ceramah Logs Sync
      final cloudCeramah = await _firestoreSyncRepository!.loadCeramahLogs(userId) ?? [];
      final cloudCeramahIds = cloudCeramah.map((e) => e['id'] as String).toSet();
      
      final Map<String, CeramahLog> mergedCeramah = {};
      for (final log in _ceramahLogs) {
        mergedCeramah[log.id] = log;
      }
      for (final map in cloudCeramah) {
        try {
          final log = CeramahLog.fromJson(map);
          mergedCeramah[log.id] = log;
        } catch (_) {}
      }
      _ceramahLogs = mergedCeramah.values.toList()..sort((a, b) => b.date.compareTo(a.date));

      for (final log in _ceramahLogs) {
        if (!cloudCeramahIds.contains(log.id)) {
          await _firestoreSyncRepository!.saveCeramahLog(userId, log.toJson());
        }
      }

      // 3. Infaq Logs Sync
      final cloudInfaq = await _firestoreSyncRepository!.loadInfaqLogs(userId) ?? [];
      final cloudInfaqIds = cloudInfaq.map((e) => e['id'] as String).toSet();

      final Map<String, InfaqLog> mergedInfaq = {};
      for (final log in _infaqLogs) {
        mergedInfaq[log.id] = log;
      }
      for (final map in cloudInfaq) {
        try {
          final log = InfaqLog.fromJson(map);
          mergedInfaq[log.id] = log;
        } catch (_) {}
      }
      _infaqLogs = mergedInfaq.values.toList()..sort((a, b) => b.date.compareTo(a.date));

      for (final log in _infaqLogs) {
        if (!cloudInfaqIds.contains(log.id)) {
          await _firestoreSyncRepository!.saveInfaqLog(userId, log.toJson());
        }
      }

      notifyListeners();
      await _saveLogs();
    } catch (_) {}
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
    if (_currentUserId != null && _firestoreSyncRepository != null) {
      unawaited(_firestoreSyncRepository!.saveCeramahLog(_currentUserId!, newLog.toJson()));
    }
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
      final updated = CeramahLog(
        id: oldLog.id,
        date: oldLog.date,
        speaker: cleanSpeaker.isEmpty ? 'Hamba Allah' : cleanSpeaker,
        title: cleanTitle.isEmpty ? 'Kultum Ramadhan' : cleanTitle,
        summary: cleanSummary,
      );
      _ceramahLogs[index] = updated;
      notifyListeners();
      unawaited(_saveLogs());
      if (_currentUserId != null && _firestoreSyncRepository != null) {
        unawaited(_firestoreSyncRepository!.saveCeramahLog(_currentUserId!, updated.toJson()));
      }
    }
  }

  void deleteCeramahLog(String id) {
    _ceramahLogs.removeWhere((element) => element.id == id);
    notifyListeners();
    unawaited(_saveLogs());
    if (_currentUserId != null && _firestoreSyncRepository != null) {
      unawaited(_firestoreSyncRepository!.deleteCeramahLog(_currentUserId!, id));
    }
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
    if (_currentUserId != null && _firestoreSyncRepository != null) {
      unawaited(_firestoreSyncRepository!.saveInfaqLog(_currentUserId!, newLog.toJson()));
    }
  }

  void deleteInfaqLog(String id) {
    _infaqLogs.removeWhere((element) => element.id == id);
    notifyListeners();
    unawaited(_saveLogs());
    if (_currentUserId != null && _firestoreSyncRepository != null) {
      unawaited(_firestoreSyncRepository!.deleteInfaqLog(_currentUserId!, id));
    }
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
      final updated = InfaqLog(
        id: oldLog.id,
        date: oldLog.date,
        amount: amount,
        notes: cleanNotes.isEmpty ? 'Sedekah Ramadhan' : cleanNotes,
      );
      _infaqLogs[index] = updated;
      notifyListeners();
      unawaited(_saveLogs());
      if (_currentUserId != null && _firestoreSyncRepository != null) {
        unawaited(_firestoreSyncRepository!.saveInfaqLog(_currentUserId!, updated.toJson()));
      }
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
    if (_currentUserId != null && _firestoreSyncRepository != null) {
      unawaited(_firestoreSyncRepository!.saveCeramahLog(_currentUserId!, log.toJson()));
    }
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
    if (_currentUserId != null && _firestoreSyncRepository != null) {
      unawaited(_firestoreSyncRepository!.saveInfaqLog(_currentUserId!, log.toJson()));
    }
  }

  Future<void> clearAllLocal() async {
    _initializeDefaultShalatLogs();
    _ceramahLogs = [];
    _infaqLogs = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ramadhan_shalat_logs');
      await prefs.remove('ramadhan_ceramah_logs');
      await _secureStorage.delete(key: 'ramadhan_infaq_logs');
    } catch (_) {}
  }
}