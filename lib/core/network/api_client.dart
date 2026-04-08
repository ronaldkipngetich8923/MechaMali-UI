import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(_AuthInterceptor(dio));

  return dio;
});

/// FIX: Replaces the TODO stub with a real refresh-and-retry interceptor.
///
/// Flow on 401:
///   1. Read the stored refresh token.
///   2. POST /auth/refresh — on success, persist new tokens and retry the
///      original request with the new access token.
///   3. On refresh failure (expired / missing), delete all stored tokens so
///      the router redirects to the auth flow.
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  static const _storage = FlutterSecureStorage();

  // Guard against recursive refresh loops (e.g. the /auth/refresh call itself 401s)
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final isRefreshEndpoint =
    err.requestOptions.path.contains('/auth/refresh');

    if (statusCode == 401 && !_isRefreshing && !isRefreshEndpoint) {
      _isRefreshing = true;
      try {
        final newAccessToken = await _refreshTokens();
        _isRefreshing = false;

        if (newAccessToken != null) {
          // Retry the original request with the fresh token
          final retryOptions = err.requestOptions
            ..headers['Authorization'] = 'Bearer $newAccessToken';

          final response = await _dio.fetch(retryOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {
        _isRefreshing = false;
        await _storage.deleteAll(); // Force sign-out
      }
    }

    handler.next(err);
  }

  /// Calls the refresh endpoint and persists the new token pair.
  /// Returns the new access token on success, or null on failure.
  Future<String?> _refreshTokens() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

    // Use a bare Dio instance to avoid triggering this interceptor again
    final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
    final res = await refreshDio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final data = res.data as Map<String, dynamic>;
    final newAccessToken = data['accessToken'] as String;
    final newRefreshToken = data['refreshToken'] as String;

    await _storage.write(key: 'access_token', value: newAccessToken);
    await _storage.write(key: 'refresh_token', value: newRefreshToken);

    return newAccessToken;
  }
}