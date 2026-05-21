import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/surah.dart';

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
}
