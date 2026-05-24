import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/surah.dart';
import '../model/surah_detail.dart';
import '../constants/api_endpoints.dart';
import 'http_client.dart';

class QuranRepository {
  final http.Client _client;
  QuranRepository({http.Client? client})
    : _client = client ?? createSafeHttpClient(maxBytes: 5 * 1024 * 1024);

  Future<List<Surah>> getSurahList() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/quran.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      final data = jsonMap['surah_list'] as List?;
      if (data != null) {
        return data
            .map((e) => Surah.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final source = prefs.getString('content_source_quran') ?? 'offline';
    if (source == 'offline') {
      throw Exception(
        'Aplikasi dikonfigurasi untuk hanya menggunakan data Al-Quran offline. Aktifkan mode online di Pengaturan jika ingin mengunduh data terbaru.',
      );
    }

    final url = Uri.parse('${ApiEndpoints.eQuranBase}/surat');
    try {
      final res = await safeGet(_client, url);

      if (res.statusCode != 200) {
        throw Exception('Gagal memuat data: HTTP ${res.statusCode}');
      }

      final Map<String, dynamic> jsonMap = json.decode(res.body);
      final data = jsonMap['data'] as List?;
      if (data == null) {
        throw Exception('Daftar surat tidak ditemukan dalam respon API');
      }

      return data
          .map((e) => Surah.fromJson(e as Map<String, dynamic>))
          .toList();
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

  Future<SurahDetail> getSurahDetail(int nomor) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/quran.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      final detailsMap = jsonMap['details'] as Map<String, dynamic>?;
      if (detailsMap != null && detailsMap[nomor.toString()] != null) {
        return SurahDetail.fromJson(
          detailsMap[nomor.toString()] as Map<String, dynamic>,
        );
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final source = prefs.getString('content_source_quran') ?? 'offline';
    if (source == 'offline') {
      throw Exception(
        'Aplikasi dikonfigurasi untuk hanya menggunakan data Al-Quran offline. Aktifkan mode online di Pengaturan jika ingin mengunduh data terbaru.',
      );
    }

    try {
      final url = Uri.parse('${ApiEndpoints.eQuranBase}/surat/$nomor');
      final res = await safeGet(_client, url);

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        final data = jsonMap['data'];
        if (data != null) {
          return SurahDetail.fromJson(data as Map<String, dynamic>);
        }
      }

      return await _getSurahDetailV1(nomor);
    } catch (e) {
      if (e is HandshakeException ||
          e is TlsException ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('TlsException')) {
        throw const TlsException('Koneksi aman tidak dapat dibuat');
      }
      return await _getSurahDetailV1(nomor);
    }
  }

  Future<SurahDetail> _getSurahDetailV1(int nomor) async {
    final url = Uri.parse('${ApiEndpoints.eQuranV1Base}/surat/$nomor');
    try {
      final res = await safeGet(_client, url);

      if (res.statusCode != 200) {
        throw Exception(
          'Gagal memuat detail surat (v1 & v2): HTTP ${res.statusCode}',
        );
      }

      final Map<String, dynamic> jsonMap = json.decode(res.body);
      return SurahDetail.fromV1Json(jsonMap);
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
}
