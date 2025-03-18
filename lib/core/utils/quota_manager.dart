import 'dart:async';
import 'package:dio/dio.dart';

// Enum to represent different Spoonacular API plans
enum ApiPlan {
  free(60, 1), // 60 requests per minute
  starter(120, 1), // 120 requests per minute
  cook(5, 1), // 5 requests per second
  culinarian(10, 1), // 10 requests per second
  chef(20, 1); // 20 requests per second

  final int requestsPerInterval;
  final int intervalSeconds;

  const ApiPlan(this.requestsPerInterval, this.intervalSeconds);
}

class QuotaManager {
  final ApiPlan plan;
  final Dio dio;
  int requestCount = 0;
  DateTime? lastResetTime;
  double quotaUsed = 0.0;
  double quotaLeft = 150.0; // Example default for free plan (adjust per plan)

  QuotaManager({required this.plan, required this.dio});

  // Check if a request can be made based on rate limit
  Future<bool> canMakeRequest() async {
    final now = DateTime.now();
    final interval = Duration(seconds: plan.intervalSeconds);

    if (lastResetTime == null || now.difference(lastResetTime!) > interval) {
      requestCount = 0;
      lastResetTime = now;
    }

    if (requestCount >= plan.requestsPerInterval) {
      final waitTime = interval - now.difference(lastResetTime!);
      await Future.delayed(waitTime);
      requestCount = 0;
      lastResetTime = DateTime.now();
    }

    return true;
  }

  // Update quota based on response headers
  void updateQuotaFromResponse(Response response) {
    final headers = response.headers;
    // final quotaRequest = double.tryParse(headers.value('X-API-Quota-Request') ?? '0') ?? 0.0;
    quotaUsed =
        double.tryParse(headers.value('X-API-Quota-Used') ?? '0') ?? 0.0;
    quotaLeft =
        double.tryParse(headers.value('X-API-Quota-Left') ?? '0') ?? 0.0;

    requestCount++;
  }

  // Check if quota is exceeded
  bool isQuotaExceeded() => quotaLeft <= 0;
}
