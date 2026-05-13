import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/auth_tokens.dart';

String _extractError(DioException e, String fallback) {
  final data = e.response?.data;
  if (data is Map) return data['error'] ?? fallback;
  if (data is String) {
    try {
      final parsed = jsonDecode(data);
      if (parsed is Map) return parsed['error'] ?? fallback;
    } catch (_) {}
  }
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout) {
    return 'Cannot connect to server';
  }
  return fallback;
}

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        _extractError(e, 'Login failed'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String orgName,
    String currencyCode = 'MVR',
    String currencySymbol = 'Mvr',
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'org_name': orgName,
          'currency_code': currencyCode,
          'currency_symbol': currencySymbol,
        },
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        _extractError(e, 'Registration failed'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<SelectOrgResponse> selectOrg(String orgId) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.selectOrg,
        data: {'org_id': orgId},
      );
      return SelectOrgResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        _extractError(e, 'Failed to select organization'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<MeResponse> getMe() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.me);
      return MeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        _extractError(e, 'Failed to get user info'),
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> logout(String? refreshToken) async {
    try {
      await _client.dio.post(
        ApiEndpoints.logout,
        data: refreshToken != null ? {'refresh_token': refreshToken} : {},
      );
    } catch (_) {
      // Logout errors are not critical.
    }
  }
}
