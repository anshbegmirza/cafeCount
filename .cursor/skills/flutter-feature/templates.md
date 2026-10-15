# Flutter feature templates (guidance)

## Repository interface (domain)

```dart
abstract class StockRepository {
  Future<void> withdraw({required String productId, required double qty});
}
```

## Provider (presentation)

```dart
final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepositoryImpl(ref.watch(apiClientProvider));
});
```

## Role gate

```dart
if (role == UserRole.employee) {
  // show withdraw only
}
```

Keep templates minimal; match existing `core/` API client once it exists.
