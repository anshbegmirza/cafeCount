import 'package:cafecount/core/password_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin password needs length, letter, digit, and special', () {
    expect(isValidAdminPassword('short1A'), isFalse);
    expect(isValidAdminPassword('abcdefgh'), isFalse);
    expect(isValidAdminPassword('12345678'), isFalse);
    expect(isValidAdminPassword('abcdefg1'), isFalse);
    expect(isValidAdminPassword('Passw0rd'), isFalse);
    expect(isValidAdminPassword('Passw0rd!'), isTrue);
    expect(isValidAdminPassword('super@123'), isTrue);
  });
}
