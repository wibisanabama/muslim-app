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
}
