import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config.dart';
import 'core/theme.dart';
import 'core/widgets/hr_widgets.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/home_shell.dart';

class CafeCountApp extends ConsumerWidget {
  const CafeCountApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return MaterialApp(
      title: AppConfig.appName,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      themeMode: ThemeMode.light,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: auth.restoring
          ? const Scaffold(backgroundColor: HrColors.paper)
          : auth.user == null
              ? const LoginScreen()
              : const HomeShell(),
    );
  }
}
