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

    // Enhanced logging for debug builds
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Add request timestamp for performance tracking
            options.extra['request_start'] =
                DateTime.now().millisecondsSinceEpoch;

            // Enhanced request logging
            final buffer = StringBuffer();
            buffer.writeln('🚀 API REQUEST');
            buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            buffer.writeln('${options.method.toUpperCase()} ${options.uri}');

            if (options.headers.isNotEmpty) {
              buffer.writeln('📋 Headers:');
              options.headers.forEach((key, value) {
                // Don't log sensitive auth headers in full
                if (key.toLowerCase() == 'authorization' &&
                    value.toString().length > 20) {
                  buffer.writeln(
                    '  $key: ${value.toString().substring(0, 20)}...',
                  );
                } else {
                  buffer.writeln('  $key: $value');
                }
              });
            }

            if (options.queryParameters.isNotEmpty) {
              buffer.writeln('🔍 Query Parameters:');
              options.queryParameters.forEach((key, value) {
                buffer.writeln('  $key: $value');
              });
            }

            if (options.data != null) {
              buffer.writeln('📦 Request Data:');
              final dataStr = options.data.toString();
              if (dataStr.length > 500) {
                buffer.writeln('  ${dataStr.substring(0, 500)}...');
              } else {
                buffer.writeln('  $dataStr');
              }
            }

            debugPrint(buffer.toString());
            handler.next(options);
          },
          onResponse: (response, handler) {
            final requestStart =
                response.requestOptions.extra['request_start'] as int?;
            final duration = requestStart != null
                ? DateTime.now().millisecondsSinceEpoch - requestStart
                : null;

            // Enhanced response logging
            final buffer = StringBuffer();
            buffer.writeln('✅ API RESPONSE');
            buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            buffer.writeln(
              '${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}',
            );

            // Status with color coding
            final statusCode = response.statusCode ?? 0;
            String statusEmoji;
            if (statusCode >= 200 && statusCode < 300) {
              statusEmoji = '🟢';
            } else if (statusCode >= 300 && statusCode < 400) {
              statusEmoji = '🟡';
            } else {
              statusEmoji = '🔴';
            }

            buffer.write('$statusEmoji Status: $statusCode');
            if (duration != null) {
              String durationEmoji;
              if (duration < 100) {
                durationEmoji = '⚡'; // Very fast
              } else if (duration < 500) {
                durationEmoji = '🚀'; // Fast
              } else if (duration < 2000) {
                durationEmoji = '🐌'; // Slow
              } else {
                durationEmoji = '🔥'; // Very slow
              }
              buffer.write(' • $durationEmoji ${duration}ms');
            }
            buffer.writeln();

            if (response.headers.map.isNotEmpty) {
              buffer.writeln('📋 Response Headers:');
              response.headers.map.forEach((key, values) {
                buffer.writeln('  $key: ${values.join(', ')}');
              });
            }

            if (response.data != null) {
              buffer.writeln('📦 Response Data:');
              final dataStr = response.data.toString();
              if (dataStr.length > 1000) {
                buffer.writeln('  ${dataStr.substring(0, 1000)}...');
                buffer.writeln('  📏 (${dataStr.length} characters total)');
              } else {
                buffer.writeln('  $dataStr');
              }
            }

            debugPrint(buffer.toString());
            handler.next(response);
          },
          onError: (DioException error, ErrorInterceptorHandler handler) {
            final requestStart =
                error.requestOptions.extra['request_start'] as int?;
            final duration = requestStart != null
                ? DateTime.now().millisecondsSinceEpoch - requestStart
                : null;

            // Enhanced error logging
            final buffer = StringBuffer();
            buffer.writeln('❌ API ERROR');
            buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            buffer.writeln(
              '${error.requestOptions.method.toUpperCase()} ${error.requestOptions.uri}',
            );

            // Error type with emoji
            String errorEmoji;
            switch (error.type) {
              case DioExceptionType.connectionTimeout:
              case DioExceptionType.sendTimeout:
              case DioExceptionType.receiveTimeout:
                errorEmoji = '⏰';
                break;
              case DioExceptionType.connectionError:
                errorEmoji = '🌐';
                break;
              case DioExceptionType.badResponse:
                errorEmoji = '📄';
                break;
              case DioExceptionType.cancel:
                errorEmoji = '🚫';
                break;
              case DioExceptionType.badCertificate:
                errorEmoji = '🔒';
                break;
              case DioExceptionType.unknown:
                errorEmoji = '❓';
                break;
            }

            buffer.write('$errorEmoji Error Type: ${error.type.name}');
            if (duration != null) {
              buffer.write(' • ⏱️ ${duration}ms');
            }
            buffer.writeln();

            if (error.response?.statusCode != null) {
              buffer.writeln('📊 Status Code: ${error.response!.statusCode}');
            }

            if (error.message != null) {
              buffer.writeln('💬 Message: ${error.message}');
            }

            if (error.response?.data != null) {
              buffer.writeln('📦 Error Response:');
              final dataStr = error.response!.data.toString();
              if (dataStr.length > 500) {
                buffer.writeln('  ${dataStr.substring(0, 500)}...');
              } else {
                buffer.writeln('  $dataStr');
              }
            }

            debugPrint(buffer.toString());

            // Pass through error for handling in BaseApiClient
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
