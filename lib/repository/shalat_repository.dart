import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../model/shalat_schedule_response.dart';
import '../constants/api_endpoints.dart';
import 'http_client.dart';

class ShalatRepository {
  final http.Client _client;
  ShalatRepository({http.Client? client})
    : _client = client ?? createSafeHttpClient(maxBytes: 2 * 1024 * 1024);

  Future<ShalatScheduleResponse> getMonthlySchedule({
    required int cityId,
    required int year,
    required int month,
  }) async {
    final url = Uri.parse(
      '${ApiEndpoints.myQuranBase}/sholat/jadwal/$cityId/$year/$month',
    );

    try {
      final res = await safeGet(_client, url);

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: gagal ambil data');
      }

      final Map<String, dynamic> jsonMap = json.decode(res.body);
      final parsed = ShalatScheduleResponse.fromJson(jsonMap);

      if (!parsed.status) {
        throw Exception(parsed.message ?? 'API status = false');
      }

      return parsed;
    } catch (e) {
      if (e is HandshakeException ||
          e is TlsException ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('TlsException')) {
        throw const TlsException('Koneksi aman tidak dapat dibuat');
      }
      rethrow;
    }
  }

  String _normalizeKeyword(String keyword) {
    String cleaned = keyword.replaceAll(RegExp(r'[^a-zA-Z0-9\s\.]'), ' ');
    String normalized = cleaned.trim().toLowerCase();
    normalized = normalized.replaceAll(
      RegExp(r'\b(kabupaten|kab)\b\.?', caseSensitive: false),
      'kab. ',
    );
    normalized = normalized.replaceAll(
      RegExp(r'\b(kota|kot)\b\.?', caseSensitive: false),
      'kota ',
    );
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    normalized = normalized.trim();

    final kabSuffixRegExp = RegExp(
      r'\s+(kabupaten|kab)\b\.?$',
      caseSensitive: false,
    );
    if (kabSuffixRegExp.hasMatch(normalized)) {
      final core = normalized.replaceAll(kabSuffixRegExp, '').trim();
      normalized = 'kab. $core';
    }

    final kotaSuffixRegExp = RegExp(
      r'\s+(kota|kot)\b\.?$',
      caseSensitive: false,
    );
    if (kotaSuffixRegExp.hasMatch(normalized)) {
      final core = normalized.replaceAll(kotaSuffixRegExp, '').trim();
      normalized = 'kota $core';
    }

    return normalized.trim();
  }

  Future<int?> searchCity(String keyword) async {
    final normalized = _normalizeKeyword(keyword);
    final url = Uri.parse(
      '${ApiEndpoints.myQuranBase}/sholat/kota/cari/${Uri.encodeComponent(normalized)}',
    );
    try {
      final res = await safeGet(_client, url);
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
    } catch (e) {
      if (e is HandshakeException ||
          e is TlsException ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('TlsException')) {
        throw const TlsException('Koneksi aman tidak dapat dibuat');
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchCities(String keyword) async {
    final normalized = _normalizeKeyword(keyword);
    final url = Uri.parse(
      '${ApiEndpoints.myQuranBase}/sholat/kota/cari/${Uri.encodeComponent(normalized)}',
    );
    try {
      final res = await safeGet(_client, url);
      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        if (jsonMap['status'] == true && jsonMap['data'] != null) {
          final list = jsonMap['data'] as List;
          return list.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      if (e is HandshakeException ||
          e is TlsException ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('TlsException')) {
        throw const TlsException('Koneksi aman tidak dapat dibuat');
      }
    }
    return [];
  }
}
