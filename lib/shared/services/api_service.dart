import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mechamali/core/constants/app_constants.dart';
import '../models/models.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) {
  const storage = FlutterSecureStorage();
  return ApiService(storage);
});

// ── Service ───────────────────────────────────────────────────────────────────

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiService(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl:        AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(_AuthInterceptor(_dio, _storage));
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phone, String name) async {
    await _dio.post('/auth/send-otp', data: {'phone': phone, 'name': name});
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    final res = await _dio.post('/auth/verify-otp',
        data: {'phone': phone, 'code': code});
    return res.data;
  }

  // ── Matches ───────────────────────────────────────────────────────────────

  Future<List<MatchModel>> getMatches({
    String? leagueRegion,
    DateTime? date,
  }) async {
    final res = await _dio.get('/matches', queryParameters: {
      if (leagueRegion != null) 'leagueRegion': leagueRegion,
      if (date != null) 'date': date.toIso8601String().split('T').first,
    });
    return (res.data as List).map((e) => MatchModel.fromJson(e)).toList();
  }

  Future<MatchModel> getMatch(String id) async {
    final res = await _dio.get('/matches/$id');
    return MatchModel.fromJson(res.data);
  }

  Future<InsightModel> getInsight(String matchId) async {
    final res = await _dio.get('/matches/$matchId/insights');
    return InsightModel.fromJson(res.data);
  }

  // ── Watchlist ─────────────────────────────────────────────────────────────

  Future<List<MatchModel>> getWatchlist() async {
    final res = await _dio.get('/watchlist');
    return (res.data as List).map((e) => MatchModel.fromJson(e)).toList();
  }

  Future<void> addToWatchlist(String matchId) async {
    await _dio.post('/watchlist/$matchId');
  }

  Future<void> removeFromWatchlist(String matchId) async {
    await _dio.delete('/watchlist/$matchId');
  }

  Future<void> updateFcmToken(String token) async {
    await _dio.put('/watchlist/fcm-token', data: {'fcmToken': token});
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> initiateSubscription({
    required String phone,
    required String plan,
  }) async {
    final res = await _dio.post('/payments/mpesa/subscribe',
        data: {'phone': phone, 'plan': plan});
    return res.data;
  }
}

// ── Auth interceptor — attaches JWT, refreshes on 401 ────────────────────────

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  _AuthInterceptor(this._dio, this._storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        // Retry original request with new token
        final token =
            await _storage.read(key: AppConstants.accessTokenKey);
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refresh =
          await _storage.read(key: AppConstants.refreshTokenKey);
      if (refresh == null) return false;

      final res = await Dio().post(
        '${AppConstants.baseUrl}/auth/refresh',
        data: {'refreshToken': refresh},
      );

      await _storage.write(
          key: AppConstants.accessTokenKey,
          value: res.data['accessToken']);
      await _storage.write(
          key: AppConstants.refreshTokenKey,
          value: res.data['refreshToken']);
      return true;
    } catch (_) {
      return false;
    }
  }
}
