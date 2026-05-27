import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import 'http_client.dart';

class AsmaulHusna {
  final int number;
  final String latin;
  final String arabic;
  final String translation;

  const AsmaulHusna({
    required this.number,
    required this.latin,
    required this.arabic,
    required this.translation,
  });

  factory AsmaulHusna.fromJson(Map<String, dynamic> json) {
    return AsmaulHusna(
      number: (json['urutan'] as num?)?.toInt() ?? 0,
      latin: (json['latin'] ?? '').toString(),
      arabic: (json['arab'] ?? '').toString(),
      translation: (json['arti'] ?? '').toString(),
    );
  }
}

class AsmaulHusnaRepository {
  final http.Client _client;
  AsmaulHusnaRepository({http.Client? client})
    : _client = client ?? createSafeHttpClient(maxBytes: 2 * 1024 * 1024);

  Future<List<AsmaulHusna>> getAsmaulHusnaList() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/asmaul_husna.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      final data = jsonMap['data'] as List?;
      if (data != null) {
        return data
            .map((e) => AsmaulHusna.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    final url = Uri.parse('${ApiEndpoints.asmaulHusnaBase}/api/all');
    final res = await safeGet(_client, url);

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat data Asmaul Husna: HTTP ${res.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(res.body);
    final data = jsonMap['data'] as List?;
    if (data == null) {
      throw Exception('Data Asmaul Husna tidak ditemukan');
    }

    return data
        .map((e) => AsmaulHusna.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
