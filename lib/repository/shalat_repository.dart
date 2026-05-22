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

  Future<int?> searchCity(String keyword) async {
    final url =
        Uri.parse('https://api.myquran.com/v2/sholat/kota/cari/$keyword');
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
    final url =
        Uri.parse('https://api.myquran.com/v2/sholat/kota/cari/$keyword');
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
