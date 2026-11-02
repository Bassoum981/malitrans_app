import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mali_trans_app/core/network/api_client.dart';

void main() {
  test('envoie le token bearer dans les requêtes authentifiées', () async {
    late Map<String, String> requestHeaders;
    final client = ApiClient(
      client: MockClient((request) async {
        requestHeaders = request.headers;

        return http.Response(
          jsonEncode({'success': true}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await client.get(
      Uri.parse('http://127.0.0.1/api/v1/driver/trajet-actif'),
      bearerToken: 'token-test',
    );

    expect(requestHeaders['authorization'], ['Bearer', 'token-test'].join(' '));
  });
}
