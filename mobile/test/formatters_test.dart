import 'package:cafecount/core/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatRelativeAbsolute returns relative and absolute parts', () {
    final iso = DateTime.utc(2026, 10, 14, 12, 26).toIso8601String();
    final out = formatRelativeAbsolute(iso);
    expect(out.contains('·'), isTrue);
    expect(out.toLowerCase().contains('oct'), isTrue);
    expect(out, isNot(contains('T12:26')));
  });

  test('formatQtyUnit singularizes bottles at 1', () {
    expect(formatQtyUnit(1, 'bottles'), '1 bottle');
    expect(formatQtyUnit(2, 'bottles'), '2 bottles');
  });

  test('txTypeKey maps known types', () {
    expect(txTypeKey('add'), 'txAdd');
    expect(txTypeKey('withdraw'), 'txWithdraw');
    expect(txTypeKey('adjust'), 'txAdjust');
  });
}
