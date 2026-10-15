import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showHrBottomSheet<bool>(
      context: context,
      isScrollControlled: false,
      builder: (ctx) => HrSheetScaffold(
        title: 'logout'.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('logoutConfirm'.tr(), style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: HrColors.out),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('logoutConfirmAction'.tr()),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr())),
          ],
        ),
      ),
    );
    if (ok == true) await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = context.locale.languageCode == 'ar';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text('settings'.tr(), style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text('language'.tr(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                subtitle: Text(isAr ? 'languageAr'.tr() : 'languageEn'.tr()),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(96, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    final next = isAr ? const Locale('en') : const Locale('ar');
                    context.setLocale(next);
                  },
                  child: Text(isAr ? 'languageEn'.tr() : 'languageAr'.tr()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text('theme'.tr(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                subtitle: Text('${'themeLight'.tr()} · ${'themeDarkSoon'.tr()}'),
                trailing: const Icon(Icons.wb_sunny_outlined, color: HrColors.forest),
              ),
              const Divider(height: 1),
              ListTile(
                title: Text('about'.tr(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                subtitle: Text('aboutBody'.tr()),
                onTap: () {
                  showHrBottomSheet(
                    context: context,
                    builder: (_) => HrSheetScaffold(
                      title: 'about'.tr(),
                      child: Column(
                        children: [
                          Image.asset('assets/images/logo.png', width: 96, height: 96),
                          const SizedBox(height: 12),
                          const HrWordmark(compact: false),
                          const SizedBox(height: 8),
                          Text('aboutBody'.tr(), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: Text('logout'.tr(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: HrColors.out)),
                leading: const Icon(Icons.logout, color: HrColors.out),
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
