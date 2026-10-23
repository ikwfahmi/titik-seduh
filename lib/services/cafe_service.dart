import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cafe.dart';

class CafeApiException implements Exception {
  const CafeApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CafeService {
  CafeService({http.Client? client, this.timeout = const Duration(seconds: 25)})
    : _client = client ?? http.Client();
  static final endpoint = Uri.parse(
    'https://surabaya-cafe-api.vercel.app/api/cafes',
  );
  final http.Client _client;
  final Duration timeout;

  Future<List<Cafe>> fetchCafes() async {
    try {
      final response = await _client
          .get(endpoint, headers: {'Accept': 'application/json'})
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw CafeApiException(
          'Server belum dapat memuat data (HTTP ${response.statusCode}). Silakan coba lagi.',
        );
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! List) {
        throw const FormatException('Respons API harus berupa daftar kafe.');
      }
      return json
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Format data kafe tidak valid.');
            }
            return Cafe.fromJson(item);
          })
          .toList(growable: false);
    } on TimeoutException {
      throw const CafeApiException(
        'Koneksi terlalu lama. Periksa internet Anda lalu coba lagi.',
      );
    } on http.ClientException {
      throw const CafeApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw const CafeApiException(
        'Data dari server belum dapat dibaca. Silakan coba lagi nanti.',
      );
    }
  }

  void close() => _client.close();
}
