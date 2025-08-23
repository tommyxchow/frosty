import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Centralized Dio client configuration with interceptors and error handling
class DioClient {
  static Dio createClient({List<Interceptor>? additionalInterceptors}) {
    final dio = Dio();

    // Optimized configuration based on 2024-2025 best practices
    dio.options = BaseOptions(
      connectTimeout:
          const Duration(seconds: 8), // Balanced for various networks
      receiveTimeout:
          const Duration(seconds: 15), // Allow for larger API responses
      sendTimeout: const Duration(seconds: 10), // Reasonable for uploads
      headers: {
        'User-Agent': 'Frosty (Flutter Twitch Client)',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Connection': 'keep-alive', // Enable connection reuse
      },
      followRedirects: true,
      maxRedirects: 3, // Reduced for better performance
      persistentConnection: true, // Enable connection pooling
    );

    // Simple logging for debug builds
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('→ ${options.method} ${options.uri}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            final statusCode = response.statusCode ?? 0;
            final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
            debugPrint('$emoji ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
            handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('❌ ${error.type.name} ${error.requestOptions.method} ${error.requestOptions.uri}');
            if (error.response != null) {
              debugPrint('   Status: ${error.response!.statusCode}');
            }
            handler.next(error);
          },
        ),
      );
    }

    // Add any additional interceptors provided
    if (additionalInterceptors != null) {
      for (final interceptor in additionalInterceptors) {
        dio.interceptors.add(interceptor);
      }
    }

    return dio;
  }
}
