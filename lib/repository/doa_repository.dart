import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../model/doa.dart';
import '../constants/api_endpoints.dart';
import 'http_client.dart';

class DoaRepository {
  final http.Client _client;
  DoaRepository({http.Client? client})
    : _client = client ?? createSafeHttpClient(maxBytes: 2 * 1024 * 1024);

  Future<List<Doa>> getDoaList() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/doa.json');
      final List jsonList = json.decode(jsonStr);
      return jsonList
          .map((e) => Doa.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}

    final url = Uri.parse('${ApiEndpoints.doaBase}/api');
    try {
      final res = await safeGet(_client, url);

      if (res.statusCode == 200) {
        final List jsonList = json.decode(res.body);
        return jsonList
            .map((e) => Doa.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Gagal memuat data doa: HTTP ${res.statusCode}');
      }
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