import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_endpoints.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Ref _ref;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._storage, this._ref, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) {
          await _storage.clearTokens();
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        // Use a separate Dio instance to avoid interceptor loop.
        final refreshDio = Dio();
        final response = await refreshDio.post(
          ApiEndpoints.refresh,
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'] as String;
        await _storage.saveAccessToken(newAccessToken);
        _isRefreshing = false;

        // Retry the original request with the new token.
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(retryOptions);
        handler.resolve(retryResponse);
        return;
      } catch (e) {
        _isRefreshing = false;
        await _storage.clearTokens();
      }
    }

    handler.next(err);
  }
}
