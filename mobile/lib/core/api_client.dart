import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiException implements Exception {
  ApiException(this.code, this.message);
  final String code;
  final String message;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? accessToken;
  String? refreshToken;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${AppConfig.apiBase}$path').replace(queryParameters: query);

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool auth = true,
    bool binary = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (auth && accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final uri = _uri(path, query);
    late http.Response res;
    switch (method) {
      case 'GET':
        res = await _client.get(uri, headers: headers);
      case 'POST':
        res = await _client.post(uri, headers: headers, body: jsonEncode(body ?? {}));
      case 'PATCH':
        res = await _client.patch(uri, headers: headers, body: jsonEncode(body ?? {}));
      default:
        throw ApiException('METHOD', 'Unsupported method');
    }

    if (res.statusCode == 401 && auth && refreshToken != null) {
      final ok = await _tryRefresh();
      if (ok) return request(method, path, body: body, query: query, auth: auth, binary: binary);
    }

    if (binary) {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'bytes': res.bodyBytes, 'contentType': res.headers['content-type']};
      }
      throw _parseError(res);
    }

    if (res.statusCode == 204) return {};
    final data = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw _parseError(res);
  }

  ApiException _parseError(http.Response res) {
    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final err = data['error'] as Map<String, dynamic>?;
      return ApiException(
        err?['code']?.toString() ?? 'ERROR',
        err?['message']?.toString() ?? 'Request failed',
      );
    } catch (_) {
      return ApiException('HTTP_${res.statusCode}', 'Request failed (${res.statusCode})');
    }
  }

  Future<bool> _tryRefresh() async {
    try {
      final res = await _client.post(
        _uri('/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        accessToken = data['accessToken'] as String?;
        refreshToken = data['refreshToken'] as String?;
        return accessToken != null;
      }
    } catch (_) {}
    return false;
  }

  Future<List<int>> getBytes(String path) async {
    final data = await request('GET', path, binary: true);
    return data['bytes'] as List<int>;
  }
}
