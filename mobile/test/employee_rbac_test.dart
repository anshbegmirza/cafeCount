import 'package:cafecount/features/auth/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('employee is not admin; shop_admin and super_admin are', () {
    User u(String role) => User(
          id: 1,
          username: 'u',
          email: 'u@test.local',
          role: role,
          shopId: 1,
        );

    expect(u('employee').isAdmin, isFalse);
    expect(u('shop_admin').isAdmin, isTrue);
    expect(u('super_admin').isAdmin, isTrue);
  });
}
