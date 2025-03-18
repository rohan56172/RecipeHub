class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});
}

class QuotaExceededException implements Exception {
  final String message;
  QuotaExceededException({required this.message});
}

class RateLimitExceededException implements Exception {
  final String message;
  RateLimitExceededException({required this.message});
}
