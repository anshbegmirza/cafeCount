import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api_client.dart';
import 'auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

class AuthState {
  const AuthState({this.user, this.loading = false, this.error});
  final User? user;
  final bool loading;
  final String? error;

  AuthState copyWith({User? user, bool? loading, String? error, bool clearUser = false}) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        loading: loading ?? this.loading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo, this._api, this._storage) : super(const AuthState()) {
    _restore();
  }

  final AuthRepository _repo;
  final ApiClient _api;
  final FlutterSecureStorage _storage;

  Future<void> _restore() async {
    final access = await _storage.read(key: 'access');
    final refresh = await _storage.read(key: 'refresh');
    final userJson = await _storage.read(key: 'user');
    if (access == null || refresh == null || userJson == null) return;
    _api.accessToken = access;
    _api.refreshToken = refresh;
    try {
      final parts = userJson.split('|');
      state = AuthState(
        user: User(
          id: int.parse(parts[0]),
          username: parts[1],
          email: parts[2],
          role: parts[3],
          shopId: parts[4] == 'null' ? null : int.parse(parts[4]),
        ),
      );
    } catch (_) {}
  }

  Future<void> _persist(User user) async {
    await _storage.write(key: 'access', value: _api.accessToken);
    await _storage.write(key: 'refresh', value: _api.refreshToken);
    await _storage.write(
      key: 'user',
      value: '${user.id}|${user.username}|${user.email}|${user.role}|${user.shopId}',
    );
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _repo.login(identifier, password);
      await _persist(user);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(error: e.toString(), loading: false);
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    await _storage.deleteAll();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});
