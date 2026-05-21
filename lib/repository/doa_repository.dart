import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/doa.dart';
import 'doa_fallback.dart';

class DoaRepository {
  final http.Client _client;
  DoaRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Doa>> getDoaList() async {
    try {
      final url = Uri.parse('https://doa-doa-api-ahmadramadhan.fly.dev/api');
      final res = await _client.get(url);

      if (res.statusCode == 200) {
        final List jsonList = json.decode(res.body);
        return jsonList.map((e) => Doa.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (e) {
      // Graceful fallback to local static data when network/CORS issues occur
      return fallbackDoas.map((e) => Doa.fromJson(Map<String, dynamic>.from(e))).toList();
    }
  }
}
