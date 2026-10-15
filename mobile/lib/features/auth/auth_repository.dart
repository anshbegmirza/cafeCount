import '../../core/api_client.dart';

class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.shopId,
  });

  final int id;
  final String username;
  final String email;
  final String role;
  final int? shopId;

  bool get isAdmin => role == 'super_admin' || role == 'shop_admin';

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as int,
        username: j['username'] as String,
        email: j['email'] as String,
        role: j['role'] as String,
        shopId: j['shopId'] as int?,
      );
}

class AuthRepository {
  AuthRepository(this.api);
  final ApiClient api;

  Future<User> login(String identifier, String password) async {
    final data = await api.request(
      'POST',
      '/auth/login',
      body: {'identifier': identifier, 'password': password},
      auth: false,
    );
    api.accessToken = data['accessToken'] as String;
    api.refreshToken = data['refreshToken'] as String;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await api.request('POST', '/auth/logout', body: {'refreshToken': api.refreshToken}, auth: false);
    } catch (_) {}
    api.accessToken = null;
    api.refreshToken = null;
  }
}
