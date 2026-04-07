import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) => AuthState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  static const _storage = FlutterSecureStorage();

  AuthNotifier(this._dio) : super(const AuthState());

  Future<void> sendOtp(String phone, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res  = await _dio.post('/auth/send-otp', data: {'phone': phone, 'name': name});
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == false) {
        state = state.copyWith(isLoading: false, error: body['error'] as String? ?? 'Failed to send OTP');
        return;
      }
      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res  = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'code': code});
      final body = res.data as Map<String, dynamic>;

      // Response is wrapped: { isSuccess: true, data: { accessToken, refreshToken, user } }
      final payload = body['data'] as Map<String, dynamic>;

      final accessToken  = payload['accessToken']  as String;
      final refreshToken = payload['refreshToken'] as String;
      final user         = UserModel.fromJson(payload['user'] as Map<String, dynamic>);

      await _storage.write(key: 'access_token',  value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);

      state = state.copyWith(isLoading: false, user: user);
      return true;

    } on DioException catch (e) {
      debugPrint('verifyOtp error: ${e.response?.data}');
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  /// Rehydrates session from stored JWT on app start — no extra API call.
  Future<void> loadSavedSession() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return;

      // Pad base64 to valid length
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) payload += '=';

      final decoded = utf8.decode(base64.decode(payload));
      final claims  = jsonDecode(decoded) as Map<String, dynamic>;

      // Check token expiry
      final exp = claims['exp'] as int?;
      if (exp != null &&
          DateTime.fromMillisecondsSinceEpoch(exp * 1000).isBefore(DateTime.now())) {
        await _tryRefresh();
        return;
      }

      state = state.copyWith(
        user: UserModel(
          id:    claims['sub']   as String? ?? '',
          name:  claims['name']  as String? ?? '',
          phone: claims['phone'] as String? ?? '',
          isVip: claims['isVip'].toString() == 'true',
        ),
      );
    } catch (_) {
      await _storage.deleteAll();
    }
  }

  Future<void> _tryRefresh() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return;
    try {
      final res  = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      final data = res.data as Map<String, dynamic>;
      await _storage.write(key: 'access_token',  value: data['accessToken']  as String);
      await _storage.write(key: 'refresh_token', value: data['refreshToken'] as String);
      state = state.copyWith(user: UserModel.fromJson(data['user'] as Map<String, dynamic>));
    } catch (_) {
      await _storage.deleteAll();
    }
  }

  Future<void> signOut() async {
    await _storage.deleteAll();
    state = const AuthState();
  }

  String _parseError(DioException e) =>
      (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
          'Something went wrong. Please try again.';
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(ref.watch(dioProvider)),
);
