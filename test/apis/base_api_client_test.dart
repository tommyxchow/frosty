import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Concrete test subclass to test BaseApiClient through its public interface.
class TestApiClient extends BaseApiClient {
  TestApiClient(Dio dio) : super(dio, 'https://api.test.com');

  /// Test wrapper that exercises the error handling path through get().
  Future<dynamic> testGet(String endpoint) => get(endpoint);
}

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late TestApiClient client;

  setUp(() {
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    client = TestApiClient(dio);
  });

  group('isSuccessResponse', () {
    test('returns true for 200', () {
      final response = Response(
        requestOptions: RequestOptions(),
        statusCode: 200,
      );
      expect(client.isSuccessResponse(response), isTrue);
    });

    test('returns true for 201', () {
      final response = Response(
        requestOptions: RequestOptions(),
        statusCode: 201,
      );
      expect(client.isSuccessResponse(response), isTrue);
    });

    test('returns true for 204', () {
      final response = Response(
        requestOptions: RequestOptions(),
        statusCode: 204,
      );
      expect(client.isSuccessResponse(response), isTrue);
    });

    test('returns false for 300', () {
      final response = Response(
        requestOptions: RequestOptions(),
        statusCode: 300,
      );
      expect(client.isSuccessResponse(response), isFalse);
    });

    test('returns false for 400', () {
      final response = Response(
        requestOptions: RequestOptions(),
        statusCode: 400,
      );
      expect(client.isSuccessResponse(response), isFalse);
    });

    test('returns false for 500', () {
      final response = Response(
        requestOptions: RequestOptions(),
        statusCode: 500,
      );
      expect(client.isSuccessResponse(response), isFalse);
    });

    test('returns false for null statusCode', () {
      final response = Response(requestOptions: RequestOptions());
      expect(client.isSuccessResponse(response), isFalse);
    });
  });

  group('error handling through get()', () {
    test('400 throws ApiException', () async {
      dioAdapter.onGet(
        'https://api.test.com/test',
        (server) => server.reply(400, {'message': 'Bad field'}),
      );

      expect(
        () => client.testGet('/test'),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', 'Bad field'),
        ),
      );
    });

    test('401 throws UnauthorizedException', () async {
      dioAdapter.onGet(
        'https://api.test.com/auth',
        (server) => server.reply(401, {'message': 'Unauthorized'}),
      );

      expect(
        () => client.testGet('/auth'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('404 throws NotFoundException', () async {
      dioAdapter.onGet(
        'https://api.test.com/missing',
        (server) => server.reply(404, {'message': 'User not found'}),
      );

      expect(
        () => client.testGet('/missing'),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'User not found',
          ),
        ),
      );
    });

    test('404 with no server message uses default', () async {
      dioAdapter.onGet(
        'https://api.test.com/empty404',
        (server) => server.reply(404, 'not json'),
      );

      expect(
        () => client.testGet('/empty404'),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.message,
            'message',
            'Resource not found',
          ),
        ),
      );
    });

    test('409 throws ApiException about conflict', () async {
      dioAdapter.onGet(
        'https://api.test.com/conflict',
        (server) => server.reply(409, null),
      );

      expect(
        () => client.testGet('/conflict'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Conflict'),
          ),
        ),
      );
    });

    test('429 throws ApiException about rate limit', () async {
      dioAdapter.onGet(
        'https://api.test.com/ratelimit',
        (server) => server.reply(429, null),
      );

      expect(
        () => client.testGet('/ratelimit'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Rate limit'),
          ),
        ),
      );
    });

    test('500 throws ServerException', () async {
      dioAdapter.onGet(
        'https://api.test.com/server-error',
        (server) => server.reply(500, null),
      );

      expect(
        () => client.testGet('/server-error'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('502 throws ServerException', () async {
      dioAdapter.onGet(
        'https://api.test.com/bad-gateway',
        (server) => server.reply(502, null),
      );

      expect(
        () => client.testGet('/bad-gateway'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            502,
          ),
        ),
      );
    });

    test('503 throws ServerException', () async {
      dioAdapter.onGet(
        'https://api.test.com/maintenance',
        (server) => server.reply(503, null),
      );

      expect(
        () => client.testGet('/maintenance'),
        throwsA(isA<ServerException>()),
      );
    });

    test('504 throws ServerException', () async {
      dioAdapter.onGet(
        'https://api.test.com/timeout',
        (server) => server.reply(504, null),
      );

      expect(
        () => client.testGet('/timeout'),
        throwsA(isA<ServerException>()),
      );
    });

    test('422 uses server message from error field', () async {
      dioAdapter.onGet(
        'https://api.test.com/unprocessable',
        (server) => server.reply(422, {'error': 'Invalid email'}),
      );

      expect(
        () => client.testGet('/unprocessable'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Invalid email',
          ),
        ),
      );
    });

    test('400 uses error_description field', () async {
      dioAdapter.onGet(
        'https://api.test.com/oauth-error',
        (server) => server.reply(
          400,
          {'error_description': 'OAuth error description'},
        ),
      );

      expect(
        () => client.testGet('/oauth-error'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'OAuth error description',
          ),
        ),
      );
    });

    test('400 prefers message field over error field', () async {
      dioAdapter.onGet(
        'https://api.test.com/priority',
        (server) => server.reply(400, {
          'message': 'From message',
          'error': 'From error',
        }),
      );

      expect(
        () => client.testGet('/priority'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'From message',
          ),
        ),
      );
    });

    test('403 returns permission error', () async {
      dioAdapter.onGet(
        'https://api.test.com/forbidden',
        (server) => server.reply(403, null),
      );

      expect(
        () => client.testGet('/forbidden'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('permissions'),
          ),
        ),
      );
    });

    test('unknown status code throws ServerException', () async {
      dioAdapter.onGet(
        'https://api.test.com/teapot',
        (server) => server.reply(418, null),
      );

      expect(
        () => client.testGet('/teapot'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            418,
          ),
        ),
      );
    });
  });

  group('successful get()', () {
    test('returns data on success', () async {
      dioAdapter.onGet(
        'https://api.test.com/users',
        (server) => server.reply(200, {'data': 'test'}),
      );

      final result = await client.testGet('/users');
      expect(result, {'data': 'test'});
    });

    test('handles absolute URL', () async {
      dioAdapter.onGet(
        'https://other.com/endpoint',
        (server) => server.reply(200, {'result': 'ok'}),
      );

      final result = await client.testGet('https://other.com/endpoint');
      expect(result, {'result': 'ok'});
    });
  });

  group('ApiException', () {
    test('toString includes message', () {
      const exception = ApiException('Test error');
      expect(exception.toString(), 'ApiException: Test error');
    });

    test('stores status code and type', () {
      const exception = ApiException(
        'Error',
        404,
        DioExceptionType.badResponse,
      );
      expect(exception.statusCode, 404);
      expect(exception.type, DioExceptionType.badResponse);
    });
  });

  group('Exception subtypes', () {
    test('NetworkException has connectionError type', () {
      const exception = NetworkException('No network');
      expect(exception.type, DioExceptionType.connectionError);
      expect(exception.statusCode, isNull);
    });

    test('TimeoutException has connectionTimeout type', () {
      const exception = TimeoutException('Timed out');
      expect(exception.type, DioExceptionType.connectionTimeout);
    });

    test('ServerException has badResponse type and status code', () {
      const exception = ServerException('Server error', 500);
      expect(exception.type, DioExceptionType.badResponse);
      expect(exception.statusCode, 500);
    });

    test('NotFoundException has 404 status code', () {
      const exception = NotFoundException('Not found');
      expect(exception.statusCode, 404);
    });

    test('UnauthorizedException has 401 status code', () {
      const exception = UnauthorizedException('Unauthorized');
      expect(exception.statusCode, 401);
    });
  });
}
