import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/surah.dart';
import '../model/surah_detail.dart';

class QuranRepository {
  final http.Client _client;
  QuranRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Surah>> getSurahList() async {
    final url = Uri.parse('https://equran.id/api/v2/surat');
    final res = await _client.get(url);

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat data: HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(res.body);
    final data = jsonMap['data'] as List?;
    if (data == null) {
      throw Exception('Daftar surat tidak ditemukan dalam respon API');
    }

    return data.map((e) => Surah.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SurahDetail> getSurahDetail(int nomor) async {
    try {
      final url = Uri.parse('https://equran.id/api/v2/surat/$nomor');
      final res = await _client.get(url);

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        final data = jsonMap['data'];
        if (data != null) {
          return SurahDetail.fromJson(data as Map<String, dynamic>);
        }
      }
      
      // Fallback if not 200 or data is null
      return await _getSurahDetailV1(nomor);
    } catch (_) {
      // Fallback if any exception occurs (e.g. timeout, connection error)
      return await _getSurahDetailV1(nomor);
    }
  }

  Future<SurahDetail> _getSurahDetailV1(int nomor) async {
    final url = Uri.parse('https://equran.id/api/surat/$nomor');
    final res = await _client.get(url);

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat detail surat (v1 & v2): HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(res.body);
    return SurahDetail.fromV1Json(jsonMap);
  }
}
