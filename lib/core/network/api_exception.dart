/// Exception standar untuk error response API sesuai format:
/// { statusCode, success: false, message, errors, timestamp }
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => message;
}
