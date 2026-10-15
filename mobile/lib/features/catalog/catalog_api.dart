import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../auth/auth_provider.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.minStock,
    required this.currentQty,
    required this.stockStatus,
    this.categoryName,
  });

  final int id;
  final String name;
  final String unit;
  final double minStock;
  final double currentQty;
  final String stockStatus;
  final String? categoryName;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as int,
        name: j['name'] as String,
        unit: j['unit'] as String,
        minStock: (j['minStock'] as num).toDouble(),
        currentQty: (j['currentQty'] as num).toDouble(),
        stockStatus: j['stockStatus'] as String,
        categoryName: j['categoryName'] as String?,
      );
}

final productsProvider = FutureProvider.family<List<Product>, String?>((ref, q) async {
  final api = ref.watch(apiClientProvider);
  final data = await api.request('GET', '/products', query: q == null || q.isEmpty ? null : {'q': q});
  final list = data['products'] as List<dynamic>;
  return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.request('GET', '/dashboard');
});

final historyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final data = await api.request('GET', '/stock/history', query: {'limit': '100'});
  return (data['transactions'] as List).cast<Map<String, dynamic>>();
});

final staffProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final data = await api.request('GET', '/users');
  return (data['users'] as List).cast<Map<String, dynamic>>();
});

class StockActions {
  StockActions(this.api);
  final ApiClient api;

  Future<void> withdraw(int productId, double qty, {String? note}) =>
      api.request('POST', '/stock/withdraw', body: {
        'productId': productId,
        'quantity': qty,
        if (note != null) 'note': note,
      });

  Future<void> add(int productId, double qty, {String? note}) =>
      api.request('POST', '/stock/add', body: {
        'productId': productId,
        'quantity': qty,
        if (note != null) 'note': note,
      });

  Future<void> adjust(int productId, double newQty, {String? note}) =>
      api.request('POST', '/stock/adjust', body: {
        'productId': productId,
        'newQty': newQty,
        if (note != null) 'note': note,
      });

  Future<void> createProduct({
    required String name,
    required String unit,
    required double minStock,
    double initialQty = 0,
  }) async {
    final created = await api.request('POST', '/products', body: {
      'name': name,
      'unit': unit,
      'minStock': minStock,
    });
    if (initialQty > 0) {
      final id = created['id'] as int? ?? (created['product'] as Map?)?['id'] as int?;
      if (id != null) await add(id, initialQty);
    }
  }

  Future<void> updateProduct(
    int id, {
    required String name,
    required String unit,
    required double minStock,
  }) =>
      api.request('PATCH', '/products/$id', body: {
        'name': name,
        'unit': unit,
        'minStock': minStock,
      });

  Future<void> createUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) =>
      api.request('POST', '/users', body: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      });

  Future<void> setUserActive(int id, bool isActive) =>
      api.request('PATCH', '/users/$id/active', body: {'isActive': isActive});
}

final stockActionsProvider = Provider((ref) => StockActions(ref.watch(apiClientProvider)));
