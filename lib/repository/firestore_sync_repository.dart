import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSyncRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Quran Last Read ---
  Future<void> saveLastRead(String userId, Map<String, dynamic> lastRead) async {
    await _firestore.collection('users').doc(userId).set({
      'lastReadQuran': lastRead,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> loadLastRead(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('lastReadQuran')) {
        return data['lastReadQuran'] as Map<String, dynamic>?;
      }
    }
    return null;
  }

  // --- Saved Doas ---
  Future<void> saveSavedDoas(String userId, List<String> savedDoaIds) async {
    await _firestore.collection('users').doc(userId).set({
      'savedDoas': savedDoaIds,
    }, SetOptions(merge: true));
  }

  Future<List<String>?> loadSavedDoas(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('savedDoas')) {
        final List<dynamic>? list = data['savedDoas'] as List<dynamic>?;
        return list?.map((e) => e.toString()).toList();
      }
    }
    return null;
  }

  // --- Saved Hadiths ---
  Future<void> saveSavedHadiths(String userId, Map<String, List<int>> savedHadiths) async {
    // Convert to a firestore-friendly format (nested map string to array of numbers)
    final Map<String, List<int>> firestoreFriendly = {};
    savedHadiths.forEach((key, value) {
      if (value.isNotEmpty) {
        firestoreFriendly[key] = value;
      }
    });

    await _firestore.collection('users').doc(userId).set({
      'savedHadiths': firestoreFriendly,
    }, SetOptions(merge: true));
  }

  Future<Map<String, List<int>>?> loadSavedHadiths(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('savedHadiths')) {
        final Map<String, dynamic>? map = data['savedHadiths'] as Map<String, dynamic>?;
        if (map == null) return null;

        final Map<String, List<int>> result = {};
        map.forEach((key, value) {
          final List<dynamic>? list = value as List<dynamic>?;
          if (list != null) {
            result[key] = list.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e != 0).toList();
          }
        });
        return result;
      }
    }
    return null;
  }

  // --- Ramadhan Shalat Logs ---
  Future<void> saveRamadhanShalatLogs(String userId, List<Map<String, dynamic>> logs) async {
    await _firestore.collection('users').doc(userId).collection('ramadhan').doc('shalat_logs').set({
      'logs': logs,
    });
  }

  Future<List<Map<String, dynamic>>?> loadRamadhanShalatLogs(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).collection('ramadhan').doc('shalat_logs').get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('logs')) {
        final List<dynamic>? list = data['logs'] as List<dynamic>?;
        return list?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }
    return null;
  }

  Future<void> saveRamadhanStartDate(String userId, DateTime date) async {
    await _firestore.collection('users').doc(userId).collection('ramadhan').doc('config').set({
      'startDate': date.toIso8601String(),
    });
  }

  Future<DateTime?> loadRamadhanStartDate(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).collection('ramadhan').doc('config').get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('startDate')) {
        return DateTime.tryParse(data['startDate'] as String);
      }
    }
    return null;
  }

  // --- Ramadhan Ceramah Logs ---
  Future<void> saveCeramahLog(String userId, Map<String, dynamic> logData) async {
    final String id = logData['id'] as String;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('ceramah_logs')
        .doc(id)
        .set(logData);
  }

  Future<void> deleteCeramahLog(String userId, String id) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('ceramah_logs')
        .doc(id)
        .delete();
  }

  Future<List<Map<String, dynamic>>?> loadCeramahLogs(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('ceramah_logs')
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // --- Ramadhan Infaq Logs ---
  Future<void> saveInfaqLog(String userId, Map<String, dynamic> logData) async {
    final String id = logData['id'] as String;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('infaq_logs')
        .doc(id)
        .set(logData);
  }

  Future<void> deleteInfaqLog(String userId, String id) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('infaq_logs')
        .doc(id)
        .delete();
  }

  Future<List<Map<String, dynamic>>?> loadInfaqLogs(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('infaq_logs')
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
