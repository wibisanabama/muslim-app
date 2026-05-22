import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/shalat_schedule_response.dart';

class ShalatRepository {
  final http.Client _client;
  ShalatRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<ShalatScheduleResponse> getMonthlySchedule({
    required int cityId,
    required int year,
    required int month,
  }) async {
    final url =
        Uri.parse('https://api.myquran.com/v2/sholat/jadwal/$cityId/$year/$month');

    final res = await _client.get(url);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: gagal ambil data');
    }

    final Map<String, dynamic> jsonMap = json.decode(res.body);
    final parsed = ShalatScheduleResponse.fromJson(jsonMap);

    if (!parsed.status) {
      throw Exception(parsed.message ?? 'API status = false');
    }

    return parsed;
  }

  String _normalizeKeyword(String keyword) {
    String normalized = keyword.trim().toLowerCase();
    
    // 1. Ganti "kabupaten" atau "kab" (dengan/tanpa titik) diikuti atau tidak oleh spasi menjadi "kab. "
    normalized = normalized.replaceAll(RegExp(r'\b(kabupaten|kab)\b\.?', caseSensitive: false), 'kab. ');
    
    // 2. Ganti "kota" atau "kot" (dengan/tanpa titik) menjadi "kota "
    normalized = normalized.replaceAll(RegExp(r'\b(kota|kot)\b\.?', caseSensitive: false), 'kota ');

    // 3. Bersihkan spasi ganda
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    normalized = normalized.trim();

    // 4. Rearrangement: Jika keyword diakhiri dengan " kab" / " kabupaten" / " kab."
    // Contoh: "bandung kab" -> "kab. bandung"
    final kabSuffixRegExp = RegExp(r'\s+(kabupaten|kab)\b\.?$', caseSensitive: false);
    if (kabSuffixRegExp.hasMatch(normalized)) {
      final core = normalized.replaceAll(kabSuffixRegExp, '').trim();
      normalized = 'kab. $core';
    }

    // Jika keyword diakhiri dengan " kota"
    // Contoh: "bandung kota" -> "kota bandung"
    final kotaSuffixRegExp = RegExp(r'\s+(kota|kot)\b\.?$', caseSensitive: false);
    if (kotaSuffixRegExp.hasMatch(normalized)) {
      final core = normalized.replaceAll(kotaSuffixRegExp, '').trim();
      normalized = 'kota $core';
    }

    return normalized.trim();
  }

  Future<int?> searchCity(String keyword) async {
    final normalized = _normalizeKeyword(keyword);
    final url =
        Uri.parse('https://api.myquran.com/v2/sholat/kota/cari/${Uri.encodeComponent(normalized)}');
    try {
      final res = await _client.get(url);
      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        if (jsonMap['status'] == true && jsonMap['data'] != null) {
          final list = jsonMap['data'] as List;
          if (list.isNotEmpty) {
            final firstMatch = list.first;
            final rawId = firstMatch['id'];
            if (rawId is int) {
              return rawId;
            } else if (rawId is String) {
              return int.tryParse(rawId);
            }
          }
        }
      }
    } catch (_) {
      // Mengembalikan null jika gagal dan menggunakan fallback bawaan
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchCities(String keyword) async {
    final normalized = _normalizeKeyword(keyword);
    final url =
        Uri.parse('https://api.myquran.com/v2/sholat/kota/cari/${Uri.encodeComponent(normalized)}');
    try {
      final res = await _client.get(url);
      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        if (jsonMap['status'] == true && jsonMap['data'] != null) {
          final list = jsonMap['data'] as List;
          return list.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (_) {
      // Mengembalikan list kosong jika gagal
    }
    return [];
  }
}
