import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/shell/home_shell.dart';

class CafeCountApp extends ConsumerStatefulWidget {
  const CafeCountApp({super.key});

  @override
  ConsumerState<CafeCountApp> createState() => _CafeCountAppState();
}

class _CafeCountAppState extends ConsumerState<CafeCountApp> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return MaterialApp(
      title: 'Hidden Room',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      themeMode: ThemeMode.light,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: !_splashDone
          ? const SplashScreen()
          : (auth.user == null ? const LoginScreen() : const HomeShell()),
    );
  }
}
