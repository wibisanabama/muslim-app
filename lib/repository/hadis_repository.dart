import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/hadis_model.dart';
import 'hadis_helper.dart' as helper;

class HadisRepository {
  final http.Client _client;
  HadisRepository({http.Client? client}) : _client = client ?? http.Client();

  // Fetch range of hadiths for a book (e.g. range=1-50)
  Future<List<Hadis>> getHadisRange(String bookId, int start, int end) async {
    try {
      final url = Uri.parse('https://api.hadith.gading.dev/books/$bookId?range=$start-$end');
      final res = await _client.get(url);

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        final List hadithList = jsonMap['data']['hadiths'] as List;
        return hadithList.map((e) => Hadis.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      // Return local fallback mapped list if error or offline
      return getLocalFallback();
    }
  }

  // Fetch a single hadith by number
  Future<Hadis> getSingleHadis(String bookId, int number) async {
    final url = Uri.parse('https://api.hadith.gading.dev/books/$bookId/$number');
    final res = await _client.get(url);

    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(res.body);
      final Map<String, dynamic> contents = jsonMap['data']['contents'] as Map<String, dynamic>;
      return Hadis.fromJson(contents);
    } else {
      throw Exception('Hadis tidak ditemukan (HTTP ${res.statusCode})');
    }
  }

  // Helper to map our 12 local curated hadiths to the Hadis model
  List<Hadis> getLocalFallback() {
    return helper.HadisHelper.list.map((local) {
      return Hadis(
        number: local.number,
        arabic: local.arabic,
        translation: "${local.title} (${local.narrator})\n\n${local.translation}\n\nPenjelasan & Kandungan:\n${local.explanation}",
      );
    }).toList();
  }
}
