import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/hadis_model.dart';
import '../constants/api_endpoints.dart';
import 'http_client.dart';

class HadisRepository {
  final http.Client _client;
  HadisRepository({http.Client? client})
    : _client = client ?? createSafeHttpClient(maxBytes: 10 * 1024 * 1024);

  Future<List<Hadis>> getHadisRange(String bookId, int start, int end) async {
    final url = Uri.parse(
      '${ApiEndpoints.hadithBase}/books/$bookId?range=$start-$end',
    );
    try {
      final res = await safeGet(_client, url);

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        final List hadithList = jsonMap['data']['hadiths'] as List;
        return hadithList
            .map((e) => Hadis.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Gagal memuat data hadis: HTTP ${res.statusCode}');
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

  Future<Hadis> getSingleHadis(String bookId, int number) async {
    final url = Uri.parse('${ApiEndpoints.hadithBase}/books/$bookId/$number');
    try {
      final res = await safeGet(_client, url);

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(res.body);
        final Map<String, dynamic> contents =
            jsonMap['data']['contents'] as Map<String, dynamic>;
        return Hadis.fromJson(contents);
      } else {
        throw Exception('Hadis tidak ditemukan (HTTP ${res.statusCode})');
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