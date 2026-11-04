class AppException implements Exception {
  const AppException(this.message, {this.data});

  final String message;
  final Object? data;

  @override
  String toString() => message;
}
