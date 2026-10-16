import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _roleLabel(String role) {
    switch (role) {
      case 'super_admin':
        return 'roleSuperAdmin'.tr();
      case 'shop_admin':
        return 'roleShopAdmin'.tr();
      default:
        return 'roleEmployee'.tr();
    }
  }

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
    final user = ref.watch(authProvider).user;

    return ListView(
      padding: HrLayout.pagePadding,
      children: [
        Text('settings'.tr(), style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 20),
        if (user != null) ...[
          _IdentityCard(user: user, roleLabel: _roleLabel(user.role)),
          const SizedBox(height: 16),
        ],
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
              // Theme row deferred until dark theme ships.
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

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user, required this.roleLabel});
  final User user;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final initial = user.username.isNotEmpty ? user.username[0].toUpperCase() : '?';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: HrColors.forest,
              child: Text(
                initial,
                style: const TextStyle(color: HrColors.cream, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: HrColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(user.email, style: const TextStyle(fontSize: 14, color: HrColors.muted)),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: HrColors.cream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HrColors.line),
                      ),
                      child: Text(
                        roleLabel,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HrColors.forest),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
