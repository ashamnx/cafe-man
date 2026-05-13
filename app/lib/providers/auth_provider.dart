import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/organization.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

// Auth repository provider.
final authRepositoryProvider = Provider((ref) {
  final client = ref.read(apiClientProvider);
  return AuthRepository(client);
});

// Auth state.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthUnauthenticated extends AuthState {
  final String? error;
  const AuthUnauthenticated({this.error});
}

class AuthAuthenticated extends AuthState {
  final User user;
  final List<Organization> orgs;
  final Organization? selectedOrg;

  const AuthAuthenticated({
    required this.user,
    required this.orgs,
    this.selectedOrg,
  });

  bool get needsOrgSelection => selectedOrg == null && orgs.length > 1;
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

// Auth notifier.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final SecureStorage _storage;

  AuthNotifier(this._authRepo, this._storage) : super(const AuthInitial());

  Future<void> checkAuth() async {
    final token = await _storage.getAccessToken();
    if (token == null) {
      state = const AuthUnauthenticated();
      return;
    }

    // Token exists — call /auth/me to restore the session.
    // The auth interceptor will auto-refresh if the access token is expired.
    try {
      final me = await _authRepo.getMe();
      state = AuthAuthenticated(
        user: me.user,
        orgs: me.orgs,
        selectedOrg: me.selectedOrg,
      );
    } catch (_) {
      await _storage.clearTokens();
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final response = await _authRepo.login(
        email: email,
        password: password,
      );

      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      if (response.orgs.length == 1) {
        state = AuthAuthenticated(
          user: response.user,
          orgs: response.orgs,
          selectedOrg: response.orgs.first,
        );
      } else {
        state = AuthAuthenticated(
          user: response.user,
          orgs: response.orgs,
        );
      }
    } catch (e) {
      state = AuthUnauthenticated(error: e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String orgName,
    String currencyCode = 'MVR',
    String currencySymbol = 'Mvr',
  }) async {
    state = const AuthLoading();
    try {
      final response = await _authRepo.register(
        email: email,
        password: password,
        fullName: fullName,
        orgName: orgName,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
      );

      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      state = AuthAuthenticated(
        user: response.user,
        orgs: [response.org],
        selectedOrg: response.org,
      );
    } catch (e) {
      state = AuthUnauthenticated(error: e.toString());
    }
  }

  Future<void> selectOrg(String orgId) async {
    final current = state;
    if (current is! AuthAuthenticated) return;

    state = const AuthLoading();
    try {
      final response = await _authRepo.selectOrg(orgId);
      await _storage.saveAccessToken(response.accessToken);

      state = AuthAuthenticated(
        user: current.user,
        orgs: current.orgs,
        selectedOrg: response.org,
      );
    } catch (e) {
      state = AuthAuthenticated(
        user: current.user,
        orgs: current.orgs,
      );
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    await _authRepo.logout(refreshToken);
    await _storage.clearTokens();
    state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthNotifier(authRepo, storage);
});
