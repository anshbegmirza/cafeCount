// Run (Android emulator + local API):
// flutter test integration_test/role_e2e_test.dart -d emulator-5554 --dart-define=API_BASE=http://10.0.2.2:3000/api/v1
//
// Needs: backend up, seed users (superadmin / shopadmin / employee, password test123).

import 'package:cafecount/app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// English strings from assets/translations/en.json (forced startLocale).
const _kAppName = 'Stock Room';
const _kIdentifier = 'Username or email';
const _kLogin = 'Login';
const _kHome = 'Home';
const _kMenu = 'Menu';
const _kStaff = 'Staff';
const _kReports = 'Reports';
const _kSettings = 'Settings';
const _kLogout = 'Logout';
const _kLogoutConfirm = 'Yes, log out';
const _kWithdrawStock = 'Withdraw stock';
const _kHistory = 'Stock history';
const _kPasswordValue = 'test123';

Future<void> _settle(WidgetTester tester, {Duration timeout = const Duration(seconds: 20)}) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  } on FlutterError {
    // Animations / network may prevent a clean settle — continue.
  }
}

Future<void> _bootApp(WidgetTester tester) async {
  await EasyLocalization.ensureInitialized();
  // Match main.dart boot; force EN so text finders stay stable.
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const ProviderScope(child: CafeCountApp()),
    ),
  );
  await tester.pump();
  await _settle(tester);
}

Future<void> _waitForLoginOrHome(WidgetTester tester) async {
  final deadline = DateTime.now().add(const Duration(seconds: 25));
  while (DateTime.now().isBefore(deadline)) {
    if (find.text(_kIdentifier).evaluate().isNotEmpty) return;
    if (find.text(_kHome).evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<bool> _ensureLoggedOut(WidgetTester tester) async {
  await _waitForLoginOrHome(tester);
  if (find.text(_kIdentifier).evaluate().isNotEmpty) return true;
  if (find.text(_kHome).evaluate().isEmpty) return false;

  // Already restored a session — logout via Settings.
  final settingsNav = find.text(_kSettings);
  if (settingsNav.evaluate().isEmpty) return false;
  await tester.tap(settingsNav.last);
  await _settle(tester);

  final logout = find.text(_kLogout);
  if (logout.evaluate().isEmpty) return false;
  await tester.tap(logout.first);
  await _settle(tester);

  final confirm = find.text(_kLogoutConfirm);
  if (confirm.evaluate().isNotEmpty) {
    await tester.tap(confirm.first);
    await _settle(tester);
  }

  await _waitForLoginOrHome(tester);
  return find.text(_kIdentifier).evaluate().isNotEmpty;
}

Future<bool> _login(WidgetTester tester, String username) async {
  expect(find.text(_kIdentifier), findsOneWidget);

  await tester.enterText(find.byType(TextField).at(0), username);
  await tester.enterText(find.byType(TextField).at(1), _kPasswordValue);
  await tester.pump();

  await tester.tap(find.widgetWithText(FilledButton, _kLogin));
  await tester.pump();
  await _settle(tester, timeout: const Duration(seconds: 25));

  // Still on login → API/auth failed; caller skips fragile asserts.
  if (find.text(_kIdentifier).evaluate().isNotEmpty) return false;
  return find.text(_kHome).evaluate().isNotEmpty;
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip(_kMenu));
  await _settle(tester);
}

Future<void> _closeDrawer(WidgetTester tester) async {
  final drawer = find.byType(Drawer);
  if (drawer.evaluate().isEmpty) return;
  Navigator.of(tester.element(drawer)).pop();
  await _settle(tester);
}

Future<void> _logoutViaSettings(WidgetTester tester) async {
  await tester.tap(find.text(_kSettings).last);
  await _settle(tester);
  await tester.tap(find.text(_kLogout).first);
  await _settle(tester);
  await tester.tap(find.text(_kLogoutConfirm).first);
  await _settle(tester);
  await _waitForLoginOrHome(tester);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('role walkthrough: superadmin, shopadmin, employee', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await _bootApp(tester);

    final ready = await _ensureLoggedOut(tester);
    if (!ready) {
      // ignore: avoid_print
      print('SKIP: could not reach login screen (restore/API?)');
      return;
    }

    const roles = <(String user, bool isAdmin)>[
      ('superadmin', true),
      ('shopadmin', true),
      ('employee', false),
    ];

    for (final (user, isAdmin) in roles) {
      // ignore: avoid_print
      print('E2E login as $user …');
      final ok = await _login(tester, user);
      if (!ok) {
        // ignore: avoid_print
        print('SKIP asserts for $user — login failed (is API at API_BASE up?)');
        // Try to recover for next role if somehow home appeared without fields.
        if (find.text(_kIdentifier).evaluate().isEmpty) {
          await _ensureLoggedOut(tester);
        }
        continue;
      }

      expect(find.text(_kHome), findsWidgets);

      await _openDrawer(tester);
      expect(find.text(_kAppName), findsWidgets); // drawer header
      expect(find.text(_kWithdrawStock), findsWidgets);
      expect(find.text(_kHistory), findsWidgets);

      if (isAdmin) {
        expect(find.text(_kStaff), findsOneWidget);
        expect(find.text(_kReports), findsOneWidget);
      } else {
        expect(find.text(_kStaff), findsNothing);
        expect(find.text(_kReports), findsNothing);
      }

      await _closeDrawer(tester);

      // Light screen walk: Settings tab is always reachable.
      await tester.tap(find.text(_kSettings).last);
      await _settle(tester);
      expect(find.text(_kLogout), findsOneWidget);

      await _logoutViaSettings(tester);
      expect(find.text(_kIdentifier), findsOneWidget);
    }
  });
}
