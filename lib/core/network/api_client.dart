import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, dynamic>? body,
    String? bearerToken,
  }) async {
    final response = await _client
        .post(
          uri,
          headers: _headers(bearerToken),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> get(Uri uri, {String? bearerToken}) async {
    final response = await _client
        .get(uri, headers: _headers(bearerToken))
        .timeout(const Duration(seconds: 15));

    return _decodeResponse(response);
  }

  Map<String, String> _headers(String? bearerToken) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const AppException('Réponse invalide du serveur.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const AppException('Réponse inattendue du serveur.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_errorMessage(decoded, response.statusCode));
    }

    return decoded;
  }

  String _errorMessage(Map<String, dynamic> response, int statusCode) {
    final message = response['message'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    if (statusCode == 401) {
      return 'Identifiants incorrects ou session expirée.';
    }

    return 'Le serveur a rencontré une erreur. Réessayez.';
  }
}
