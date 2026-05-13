import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/org_member.dart';
import '../models/role.dart';

class UserRepository {
  final ApiClient _client;

  UserRepository(this._client);

  Future<List<OrgMember>> listMembers() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.users);
      return (response.data as List)
          .map((e) => OrgMember.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load users',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> invite({
    required String email,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.userInvite,
        data: {'email': email, 'full_name': fullName, 'role': role},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to invite user',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> changeRole(String userId, String role) async {
    try {
      await _client.dio.put(
        ApiEndpoints.userRole(userId),
        data: {'role': role},
      );
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to change role',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<String> resetPassword(String userId) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.userResetPassword(userId),
      );
      return response.data['new_password'] ?? '';
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to reset password',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> remove(String userId) async {
    try {
      await _client.dio.delete(ApiEndpoints.userRemove(userId));
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to remove user',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Role>> listRoles() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.roles);
      return (response.data as List).map((e) => Role.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load roles',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getRoleDetail(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.role(id));
      return response.data;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to load role',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
