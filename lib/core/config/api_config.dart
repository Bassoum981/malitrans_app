import 'dart:io';

abstract final class ApiConfig {
  static const apiPrefix = '/api/v1';

  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'https://slush-lark-manual.ngrok-free.dev';
    }

    return 'https://slush-lark-manual.ngrok-free.dev';
  }

  static String get apiUrl => '$baseUrl$apiPrefix';
}
